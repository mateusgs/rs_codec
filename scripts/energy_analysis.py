#!/usr/bin/env python3
"""Analyze energy sweeps for ASAP7 and Nangate45 and produce plots."""

from __future__ import annotations

import math
from dataclasses import dataclass
from pathlib import Path
from typing import Dict, Tuple

import re

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd


@dataclass
class SweepResult:
    name: str
    slug: str
    data: pd.DataFrame
    min_energy_idx: int
    knee_idx: int


BLOCK_INFO = {
    "rs_encoder_wrapper": ("Encoder", 1.0),
    "rs_syndrome": ("Syndrome", 1.0),
    "rs_decoder_plus_syndrome": ("Decoder", 1.0),
}


def _power_units_to_mw(value: float, unit: str) -> float:
    unit = unit.lower()
    if unit == "w":
        return value * 1e3
    if unit == "mw":
        return value
    if unit == "uw":
        return value / 1e3
    if unit == "nw":
        return value / 1e6
    if unit == "pw":
        return value / 1e9
    if unit == "kw":
        return value * 1e6
    raise ValueError(f"Unknown power unit '{unit}'")


def _design_name(top: str, n: float, k: float) -> str:
    n_int = int(n)
    k_int = int(k)
    if top == "rs_decoder_plus_syndrome":
        return f"rs_decoder_N{n_int}_K{k_int}"
    if top == "rs_encoder_wrapper":
        return f"rs_encoder_wrapper_N{n_int}_K{k_int}"
    if top == "rs_syndrome":
        return f"rs_syndrome_N{n_int}_K{k_int}"
    return top


def _populate_power_columns(df: pd.DataFrame) -> pd.DataFrame:
    cache: Dict[Tuple[str, str], Tuple[float, float, float]] = {}
    leakages = []
    totals = []
    dynamics = []

    for _, row in df.iterrows():
        label = row["label"]
        top = row["top"]
        base = Path(row['__root'])
        key = (label, top, base)
        if key not in cache:
            design = _design_name(top, row["N"], row["K"])
            path = base / label / "reports" / f"{design}_power.rep"
            dyn = float(row.get("total_dyn_mw", 0.0))
            leak = 0.0
            total = dyn
            if path.exists():
                text = path.read_text()
                dyn_match = re.search(r"Total Dynamic Power\s*=\s*([0-9.eE+-]+)\s*([a-zA-Z]+)", text)
                leak_match = re.search(r"Cell Leakage Power\s*=\s*([0-9.eE+-]+)\s*([a-zA-Z]+)", text)
                total_match = re.search(r"Total Power\s*=\s*([0-9.eE+-]+)\s*([a-zA-Z]+)", text)
                if dyn_match:
                    dyn = _power_units_to_mw(float(dyn_match.group(1)), dyn_match.group(2))
                if leak_match:
                    leak = _power_units_to_mw(float(leak_match.group(1)), leak_match.group(2))
                if total_match:
                    total = _power_units_to_mw(float(total_match.group(1)), total_match.group(2))
                else:
                    total = dyn + leak
            cache[key] = (dyn, leak, total)
        dyn, leak, total = cache[key]
        dynamics.append(dyn)
        leakages.append(leak)
        totals.append(total)

    df = df.copy()
    df["dyn_mw"] = dynamics
    df["leak_mw"] = leakages
    df["total_power_mw"] = totals
    df = df.drop(columns=['__root'], errors='ignore')
    return df


def _aggregate_block(block_df: pd.DataFrame, cycles_per_symbol: float) -> pd.DataFrame:
    grouped = (
        block_df.groupby("CLK_NS", as_index=False)
        .agg(
            {
                "total_power_mw": "mean",
                "dyn_mw": "mean",
                "leak_mw": "mean",
                "N": "first",
                "K": "first",
                "GF_WIDTH": "first",
                "wns_ns": "mean",
            }
        )
        .rename(columns={"total_power_mw": "power_mw"})
    )

    grouped["freq_hz"] = 1.0 / (grouped["CLK_NS"] * 1e-9)
    grouped["freq_mhz"] = grouped["freq_hz"] / 1e6
    rate = grouped["K"] / grouped["N"]
    m = grouped["GF_WIDTH"].astype(float)
    grouped["energy_pj_per_bit"] = (
        grouped["power_mw"] * grouped["CLK_NS"] * cycles_per_symbol / (rate * m)
    )

    return grouped.sort_values("freq_mhz").reset_index(drop=True)


def _make_result(name: str, slug: str, data: pd.DataFrame) -> SweepResult:
    min_energy = data["energy_pj_per_bit"].min()
    within_band = data[data["energy_pj_per_bit"] <= min_energy * 1.005]
    within_band = within_band[within_band["wns_ns"] >= 0.0]
    if not within_band.empty:
        min_energy_idx = int(within_band["freq_mhz"].idxmax())
    else:
        min_energy_idx = int(data["energy_pj_per_bit"].idxmin())

    knee_idx = _find_knee_index(data["freq_mhz"].to_numpy(), data["power_mw"].to_numpy())

    return SweepResult(name=name, slug=slug, data=data, min_energy_idx=min_energy_idx, knee_idx=knee_idx)


def load_sweep(summary_paths: list[Path], name: str) -> list[SweepResult]:
    """Load summary CSV and compute derived metrics for encoder, syndrome, decoder, and total."""

    frames = []
    for path in summary_paths:
        if path.exists():
            frame = pd.read_csv(path)
            frame['__root'] = str(path.parent)
            frames.append(frame)
    if not frames:
        raise ValueError(f"No summary CSV found for {name}")
    df = pd.concat(frames, ignore_index=True)
    df = df[df["top"].isin(BLOCK_INFO.keys())].copy()
    if df.empty:
        raise ValueError(f"No recognised tops found in {summary_path}")

    # Normalise WNS to nanoseconds (reports mix ns and ps).
    df["wns_ns"] = df["wns"].apply(lambda x: x / 1000.0 if x > 50.0 else x)
    df = _populate_power_columns(df)

    block_frames: dict[str, pd.DataFrame] = {}
    results: list[SweepResult] = []

    for top, (label, cycles) in BLOCK_INFO.items():
        block_df = df[df["top"] == top].copy()
        if block_df.empty:
            continue
        aggregated = _aggregate_block(block_df, cycles)
        block_frames[top] = aggregated
        results.append(_make_result(f"{name} {label}", label.lower(), aggregated))

    # Build a total dataframe if we have at least two contributing blocks.
    if len(block_frames) >= 2:
        merged = None
        for top, (label, _cycles) in BLOCK_INFO.items():
            frame = block_frames.get(top)
            if frame is None:
                continue
            cols = {
                "power_mw": f"{label.lower()}_power_mw",
                "energy_pj_per_bit": f"{label.lower()}_energy_pj",
                "wns_ns": f"{label.lower()}_wns_ns",
            }
            subset = frame[["CLK_NS", "freq_mhz", "power_mw", "energy_pj_per_bit", "wns_ns"]].rename(columns=cols)
            merged = subset if merged is None else merged.merge(subset, on=["CLK_NS", "freq_mhz"], how="inner")

        if merged is not None and not merged.empty:
            power_cols = [c for c in merged.columns if c.endswith("_power_mw")]
            energy_cols = [c for c in merged.columns if c.endswith("_energy_pj")]
            wns_cols = [c for c in merged.columns if c.endswith("_wns_ns")]

            total_df = merged[["CLK_NS", "freq_mhz"]].copy()
            total_df["power_mw"] = merged[power_cols].sum(axis=1)
            total_df["energy_pj_per_bit"] = merged[energy_cols].sum(axis=1)
            if wns_cols:
                total_df["wns_ns"] = merged[wns_cols].min(axis=1)
            else:
                total_df["wns_ns"] = 0.0

            total_df = total_df.sort_values("freq_mhz").reset_index(drop=True)
            results.append(_make_result(f"{name} Total", "total", total_df))

    return results


def _find_knee_index(freq: np.ndarray, power: np.ndarray) -> int:
    """Find the knee of the power-frequency curve using a normalized distance metric."""
    if len(freq) < 3:
        return int(np.argmax(power))

    x = freq.astype(float)
    y = power.astype(float)
    x_min, x_max = float(x.min()), float(x.max())
    y_min, y_max = float(y.min()), float(y.max())

    if math.isclose(x_max, x_min):
        return int(np.argmax(y))
    if math.isclose(y_max, y_min):
        return 0

    x_norm = (x - x_min) / (x_max - x_min)
    y_norm = (y - y_min) / (y_max - y_min)
    diff = y_norm - x_norm
    idx = int(np.argmax(diff))
    return idx


def _plot_series(result: SweepResult, out_dir: Path) -> None:
    df = result.data
    out_dir.mkdir(parents=True, exist_ok=True)
    file_base = result.name.lower().replace(" ", "_")

    csv_path = out_dir / f"{file_base}_vs_freq.csv"
    df.to_csv(csv_path, index=False)

    # Energy per bit vs frequency
    fig, ax = plt.subplots(figsize=(6, 4))
    energy_max = df["energy_pj_per_bit"].max()
    ax.plot(df["freq_mhz"], df["energy_pj_per_bit"], marker="o")
    ax.set_xlabel("Frequency (MHz)")
    ax.set_ylabel("Energy/bit (pJ)")
    ax.set_title(f"{result.name} Energy per Bit vs Frequency")
    ax.grid(True, which="both", linestyle="--", linewidth=0.4)
    ax.set_ylim(bottom=0, top=max(energy_max * 1.1, 0.01))
    fig.tight_layout()
    energy_path = out_dir / f"{file_base}_energy_per_bit_vs_freq.png"
    fig.savefig(energy_path, dpi=200)
    plt.close(fig)

    # Power vs frequency
    fig, ax = plt.subplots(figsize=(6, 4))
    power_max = df["power_mw"].max()
    ax.plot(df["freq_mhz"], df["power_mw"], marker="o")
    ax.set_xlabel("Frequency (MHz)")
    ax.set_ylabel("Power (mW)")
    ax.set_title(f"{result.name} Power vs Frequency")
    ax.grid(True, which="both", linestyle="--", linewidth=0.4)
    ax.set_ylim(bottom=0, top=max(power_max * 1.1, 0.01))
    fig.tight_layout()
    power_path = out_dir / f"{file_base}_power_vs_freq.png"
    fig.savefig(power_path, dpi=200)
    plt.close(fig)


def main() -> int:
    base = Path(__file__).resolve().parent.parent
    out_dir = base / "plots"

    sweeps = [
        ([base / "newdata/asap7_energy_sweep/summary.csv"], "ASAP7"),
        ([base / "newdata/nangate45_energy_sweep/summary.csv"], "Nangate45"),
    ]

    results: list[SweepResult] = []
    for path, name in sweeps:
        sweep_results = load_sweep(path, name=name)
        for result in sweep_results:
            results.append(result)
            _plot_series(result, out_dir)

    for result in results:
        df = result.data
        min_row = df.iloc[result.min_energy_idx]
        knee_row = df.iloc[result.knee_idx]
        print(f"{result.name}: Min energy at {min_row['freq_mhz']:.2f} MHz (CLK {min_row['CLK_NS']:.2f} ns, WNS {min_row['wns_ns']:.3f} ns) "
              f"-> {min_row['energy_pj_per_bit']:.3f} pJ/bit, power {min_row['power_mw']:.3f} mW")
        print(f"{result.name}: Power knee near {knee_row['freq_mhz']:.2f} MHz (CLK {knee_row['CLK_NS']:.2f} ns, WNS {knee_row['wns_ns']:.3f} ns) "
              f"-> power {knee_row['power_mw']:.3f} mW, energy {knee_row['energy_pj_per_bit']:.3f} pJ/bit")
        print()

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
