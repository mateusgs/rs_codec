#!/usr/bin/env python3
"""Generate raw and FEC-corrected FoM tables and plots."""

from __future__ import annotations
from dataclasses import dataclass
from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import seaborn as sns


HERE = Path(__file__).resolve().parent
ROOT = HERE.parent


@dataclass(frozen=True)
class ScalingModel:
    node_nm: int
    coeffs: tuple[float, float, float]
    vdd: float

    def energy_factor(self) -> float:
        a2, a1, a0 = self.coeffs
        v = self.vdd
        return a2 * v**2 + a1 * v + a0


ENERGY_MODELS = {
    45: ScalingModel(45, (1.018, -0.3107, 0.1539), 1.10),
    32: ScalingModel(32, (0.8367, -0.4341, 0.1701), 0.97),
    20: ScalingModel(20, (0.3730, -0.1582, 0.04104), 0.90),
    16: ScalingModel(16, (0.2958, -0.1241, 0.03024), 0.86),
    14: ScalingModel(14, (0.2363, -0.09675, 0.02239), 0.86),
    10: ScalingModel(10, (0.2068, -0.09311, 0.02375), 0.83),
     7: ScalingModel(7, (0.1776, -0.09097, 0.02447), 0.80),
}

TSMC_SUB7_SCALING = {
    # Public TSMC guidance: N5 ~30% power reduction vs N7, N3 ~30% vs N5.
    # Values are relative multipliers to ASAP7's energy factor.
    5: 0.70,
    3: 0.49,  # 0.70 (N5/N7) * 0.70 (N3/N5)
}


BASE_DATASET_NODES = {
    "ASAP7": 7,
    "NanGate45": 45,
}


def choose_dataset(process_nm: float) -> str:
    # Select FEC dataset whose nominal process is closest to the target.
    return min(BASE_DATASET_NODES.keys(), key=lambda name: abs(process_nm - BASE_DATASET_NODES[name]))


def map_process_to_model(process_nm: float) -> int:
    # Map an arbitrary process to the closest defined scaling model.
    return min(ENERGY_MODELS.keys(), key=lambda node: abs(process_nm - node))


def tsmc_scaling_factor(process_nm: float) -> tuple[float, int]:
    key = min(TSMC_SUB7_SCALING.keys(), key=lambda node: abs(process_nm - node))
    return TSMC_SUB7_SCALING[key], key


def load_links(path: Path) -> pd.DataFrame:
    df = pd.read_csv(path)
    df = df.rename(columns={"Reach (mm)": "Reach_mm", "Gbps/mm": "Gbps_per_mm", "pJ/bit": "pJ_per_bit"})
    return df


def closest_row_by_ber(df: pd.DataFrame, target_ber: float) -> pd.Series:
    ber_col = "plot_ber" if "plot_ber" in df.columns else "input_preFEC_BER"
    idx = (df[ber_col].astype(float) - target_ber).abs().idxmin()
    return df.loc[idx]


def compute_metrics() -> pd.DataFrame:
    links = load_links(ROOT / "link_examples.csv")
    fec_data = {
        name: pd.read_csv(ROOT / "plots" / f"{name.lower()}_total_energy_rate_vs_ber.csv")
        for name in BASE_DATASET_NODES
    }

    rows = []
    for _, link in links.iterrows():
        process_nm = link["Process"]
        dataset = choose_dataset(process_nm)
        base_node = BASE_DATASET_NODES[dataset]
        fec_df = fec_data[dataset]
        fec_row = closest_row_by_ber(fec_df, link["BER"])

        code_rate = fec_row["rate"]
        fec_energy = fec_row["energy"]
        energy_factor_base = ENERGY_MODELS[base_node].energy_factor()

        if process_nm < 7:
            tsmc_scale, tsmc_ref = tsmc_scaling_factor(process_nm)
            energy_factor_target = energy_factor_base * tsmc_scale
            target_node = tsmc_ref
            scaling_source = f"TSMC_public_{tsmc_ref}nm"
        else:
            target_node = map_process_to_model(process_nm)
            energy_factor_target = ENERGY_MODELS[target_node].energy_factor()
            scaling_source = f"Polynomial_{target_node}nm"

        fec_energy_scaled = fec_energy * (energy_factor_target / energy_factor_base)

        gbps_per_mm = link["Gbps_per_mm"]
        link_energy = link["pJ_per_bit"]

        fom_raw = gbps_per_mm / link_energy
        numerator = gbps_per_mm * code_rate
        denom_unscaled = (link_energy / code_rate) + fec_energy
        denom_scaled = (link_energy / code_rate) + fec_energy_scaled

        rows.append(
            {
                "Name": link["Name"],
                "Process_nm": process_nm,
                "Reach_mm": link["Reach_mm"],
                "Gbps_per_mm": gbps_per_mm,
                "Link_pJ_per_bit": link_energy,
                "BER": link["BER"],
                "Chosen_FEC_dataset": dataset,
                "Base_node_nm": base_node,
                "Target_model_node_nm": target_node,
                "FEC_code_rate": code_rate,
                "FEC_energy_pJ_source": fec_energy,
                "FEC_energy_pJ_scaled": fec_energy_scaled,
                "FoM_raw": fom_raw,
                "FoM_fec_unscaled": numerator / denom_unscaled,
                "FoM_fec_scaled": numerator / denom_scaled,
                "Energy_factor_base": energy_factor_base,
                "Energy_factor_target": energy_factor_target,
                "Energy_scaling_source": scaling_source,
            }
        )

    return pd.DataFrame(rows)


def write_outputs(df: pd.DataFrame) -> None:
    out_csv = ROOT / "plots" / "reach_vs_fom_scaled.csv"
    df.to_csv(out_csv, index=False)

    sns.set_style("darkgrid")
    fig, ax = plt.subplots(figsize=(8, 5))
    colors = sns.color_palette("tab10", len(df))

    for color, (_, row) in zip(colors, df.iterrows()):
        reach = row["Reach_mm"]
        fom_raw = row["FoM_raw"]
        fom_scaled = row["FoM_fec_scaled"]

        ax.scatter(reach, fom_raw, marker="o", color=color, s=45)
        ax.scatter(reach, fom_scaled, marker="^", color=color, s=55)
        ax.plot([reach, reach], [fom_raw, fom_scaled], color=color, linewidth=0.9)
        ax.annotate(
            row["Name"],
            (reach, fom_raw),
            textcoords="offset points",
            xytext=(6, 4),
            fontsize=8,
            color=color,
        )

    ax.set_xscale("log")
    ax.set_xlim(xmax=1e3)
    ax.set_yscale("log")
    ax.set_xlabel("Reach (mm)")
    ax.set_ylabel("FoM")
    ax.set_title("Reach vs FoM (Raw vs FEC-Corrected)")
    ax.grid(True, which="both", linestyle="--", linewidth=0.6)

    from matplotlib.lines import Line2D

    legend_handles = [
        Line2D([0], [0], marker="o", color="w", markerfacecolor="black", markersize=6, linestyle="None", label="Raw FoM"),
        Line2D([0], [0], marker="^", color="w", markerfacecolor="black", markersize=6, linestyle="None", label="FEC-corrected FoM"),
    ]
    ax.legend(handles=legend_handles, loc="lower left")

    fig.tight_layout()
    fig.savefig(ROOT / "plots" / "reach_vs_fom_raw_vs_fec.png", dpi=200)


def main() -> None:
    df = compute_metrics()
    write_outputs(df)


if __name__ == "__main__":
    main()
