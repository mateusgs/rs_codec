#!/usr/bin/env python3
"""Generate area-per-throughput vs BER plots for configurable sweep settings."""

from __future__ import annotations

import argparse
from itertools import cycle
from pathlib import Path
from typing import Iterable, Optional

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import seaborn as sns

import gen_k_sweep

HERE = Path(__file__).resolve().parent
ROOT = HERE.parent

SUMMARY_TECHS = ("ASAP7", "NanGate45")
SUMMARY_ROOT_CANDIDATES = (ROOT / "newdata",)

M = 8  # GF symbol width
CYCLES_PER_SYMBOL = 2.0  # decoder consumes two cycles per symbol


def find_summary_path(tech: str) -> Path:
    tech_dir = f"{tech.lower()}_opt_sweep"
    for base in SUMMARY_ROOT_CANDIDATES:
        candidate = base / tech_dir / "summary.csv"
        if candidate.exists():
            return candidate
    raise FileNotFoundError(f"summary.csv for {tech} not found in expected directories")


def load_or_generate_selection(args: argparse.Namespace, targets: list[float]) -> pd.DataFrame:
    if args.selection is not None:
        df = pd.read_csv(args.selection)
    else:
        df = gen_k_sweep.generate_sweep(
            k=args.k,
            exp_start=args.max_exp,
            exp_stop=args.min_exp,
            exp_step=-abs(args.step),
            targets=targets,
        )
        if args.save_selection is not None:
            args.save_selection.parent.mkdir(parents=True, exist_ok=True)
            df.to_csv(args.save_selection, index=False)

    df = df.dropna(subset=["n"]).copy()
    df["target_post_BER"] = df["target_post_BER"].astype(float)
    df["target_post_BER"] = df["target_post_BER"].apply(lambda val: match_target_ber(val, targets))
    df = df.dropna(subset=["target_post_BER"])
    df["n"] = df["n"].astype(int)

    if args.n_filter:
        df = df[df["n"].isin(args.n_filter)]

    if df.empty:
        raise ValueError("No sweep entries match the provided filters/targets")

    return df


def match_target_ber(value: float, targets: Iterable[float]) -> Optional[float]:
    for target in targets:
        if np.isclose(value, target, rtol=1e-2, atol=0.0):
            return float(target)
    return None


def build_dataset(selection: pd.DataFrame) -> pd.DataFrame:
    rows: list[dict[str, float]] = []
    for tech in SUMMARY_TECHS:
        summary_path = find_summary_path(tech)
        summary = pd.read_csv(summary_path)
        summary["cycles"] = summary["top"].map(
            lambda top: CYCLES_PER_SYMBOL if top == "rs_decoder_plus_syndrome" else 1.0
        )
        summary["energy"] = (
            summary["total_dyn_mw"]
            * summary["CLK_NS"]
            * summary["cycles"]
            / ((summary["K"] / summary["N"]) * summary["GF_WIDTH"])
        )

        area_map = summary.pivot_table(index="N", columns="top", values="area")
        clk_map = summary.pivot_table(index="N", columns="top", values="CLK_NS")

        for _, sel in selection.iterrows():
            if sel["n"] not in area_map.index:
                continue

            try:
                area_encoder = area_map.loc[sel["n"], "rs_encoder_wrapper"]
                area_syndrome = area_map.loc[sel["n"], "rs_syndrome"]
                area_decoder = area_map.loc[sel["n"], "rs_decoder_plus_syndrome"]
            except KeyError:
                continue

            clk_ns = clk_map.loc[sel["n"], "rs_decoder_plus_syndrome"]
            area_total_um2 = area_encoder + area_syndrome + area_decoder
            area_total_mm2 = area_total_um2 / 1e6
            throughput_gbps = sel["rate"] * M / (CYCLES_PER_SYMBOL * clk_ns * 1e-9) / 1e9
            if throughput_gbps == 0:
                continue
            area_per_gbps = area_total_mm2 / throughput_gbps

            rows.append(
                {
                    "tech": tech,
                    "target_post_BER": sel["target_post_BER"],
                    "input_preFEC_BER": sel["input_preFEC_BER"],
                    "n": sel["n"],
                    "rate": sel["rate"],
                    "clk_ns": clk_ns,
                    "area_total_um2": area_total_um2,
                    "area_total_mm2": area_total_mm2,
                    "throughput_gbps": throughput_gbps,
                    "area_per_gbps": area_per_gbps,
                }
            )

    return pd.DataFrame(rows)


def plot_area_vs_ber(df: pd.DataFrame, targets: list[float]) -> None:
    out_dir = ROOT / "plots"
    out_dir.mkdir(parents=True, exist_ok=True)
    df.to_csv(out_dir / "area_per_gbps_vs_ber.csv", index=False)

    sns.set_style("darkgrid")
    fig, ax_left = plt.subplots(figsize=(8, 5))

    bers_sorted = sorted(targets)
    colors = sns.color_palette("tab10", len(bers_sorted))
    marker_cycle_left: Iterable[str] = cycle(("o", "s", "d", "^"))
    marker_cycle_right: Iterable[str] = cycle(("^", "v", "<", ">"))

    nan_lines = []
    nan_labels = []
    nan_data = df[df["tech"] == "NanGate45"]
    for color, ber in zip(colors, bers_sorted):
        subset = nan_data[nan_data["target_post_BER"] == ber].sort_values("input_preFEC_BER")
        if subset.empty:
            continue
        marker = next(marker_cycle_left)
        (line,) = ax_left.plot(
            subset["input_preFEC_BER"],
            subset["area_per_gbps"],
            marker=marker,
            color=color,
            label=f"NanGate45 target {ber:.0e}",
        )
        nan_lines.append(line)
        nan_labels.append(f"NanGate45 target {ber:.0e}")

    ax_left.set_xscale("log")
    if not nan_data.empty:
        x_min = nan_data["input_preFEC_BER"].min()
        x_max = nan_data["input_preFEC_BER"].max()
        ax_left.set_xlim(x_min, x_max)
        nan_top = nan_data["area_per_gbps"].max() * 1.05
        if nan_top == 0:
            nan_top = 0.1
        ax_left.set_ylim(0, max(nan_top, 0.1))
    ax_left.set_xlabel("Input pre-FEC BER")
    ax_left.set_ylabel("NanGate45 area per throughput (mm²/Gbps)")

    ax_right = ax_left.twinx()
    asap_lines = []
    asap_labels = []
    asap_data = df[df["tech"] == "ASAP7"]
    for color, ber in zip(colors, bers_sorted):
        subset = asap_data[asap_data["target_post_BER"] == ber].sort_values("input_preFEC_BER")
        if subset.empty:
            continue
        marker = next(marker_cycle_right)
        (line,) = ax_right.plot(
            subset["input_preFEC_BER"],
            subset["area_per_gbps"],
            marker=marker,
            color=color,
            linestyle="--",
            label=f"ASAP7 target {ber:.0e}",
        )
        asap_lines.append(line)
        asap_labels.append(f"ASAP7 target {ber:.0e}")

    ax_right.set_xscale("log")
    ax_right.set_ylabel("ASAP7 area per throughput (mm²/Gbps)")
    if not asap_data.empty:
        asap_top = asap_data["area_per_gbps"].max() * 1.05
        if asap_top == 0:
            asap_top = 0.01
        ax_right.set_ylim(0, max(asap_top, 0.01))

    title_targets = ", ".join(f"{ber:.0e}" for ber in bers_sorted)
    fig.suptitle(f"FEC Area per Throughput vs Raw BER (Targets {title_targets})")

    handles = nan_lines + asap_lines
    labels = nan_labels + asap_labels
    ax_left.legend(handles, labels, loc="upper left", framealpha=1.0, facecolor="white")

    fig.tight_layout()
    fig.savefig(out_dir / "area_per_gbps_vs_ber.png", dpi=200)
    plt.close(fig)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Plot area-per-throughput vs BER")
    parser.add_argument("--selection", type=Path, help="precomputed sweep CSV; skip generation if provided")
    parser.add_argument("--save-selection", type=Path, help="optional path to save generated sweep data")
    parser.add_argument("--k", type=int, default=512, help="data symbols K when generating sweep")
    parser.add_argument("--min-exp", type=float, default=-30.0, help="minimum BER exponent (e.g., -30 for 1e-30)")
    parser.add_argument("--max-exp", type=float, default=-3.0, help="maximum BER exponent (e.g., -3 for 1e-3)")
    parser.add_argument("--step", type=float, default=0.5, help="log-scale step size in decades")
    parser.add_argument("--target", type=float, action="append", dest="targets", help="target post-FEC BER (repeatable)")
    parser.add_argument("--n", type=int, action="append", dest="n_filter", help="restrict to specific block length N (repeatable)")
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    targets = sorted(set(args.targets)) if args.targets else [1e-30, 1e-15]
    selection = load_or_generate_selection(args, targets)
    dataset = build_dataset(selection)
    plot_area_vs_ber(dataset, targets)


if __name__ == "__main__":
    main()
