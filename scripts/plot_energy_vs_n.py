#!/usr/bin/env python3
"""Plot always-on total energy per bit as a function of block length N."""

from __future__ import annotations

import argparse
from pathlib import Path
from typing import Iterable

import matplotlib.pyplot as plt
import pandas as pd
import seaborn as sns


HERE = Path(__file__).resolve().parent
ROOT = HERE.parent

SUMMARY_TECHS = ("ASAP7", "NanGate45")
DEFAULT_SUMMARY_ROOTS = (ROOT / "newdata",)

# Decoder consumes two cycles per symbol; encoder/syndrome consume one.
CYCLES_PER_TOP = {
    "rs_encoder_wrapper": 1.0,
    "rs_syndrome": 1.0,
    "rs_decoder_plus_syndrome": 2.0,
}


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Plot total energy per bit vs N (encoder + syndrome + decoder)")
    parser.add_argument(
        "--summary-root",
        action="append",
        type=Path,
        help="Root directory containing <tech>_opt_sweep/summary.csv (default: newdata/, data/)",
    )
    parser.add_argument(
        "--n",
        type=int,
        action="append",
        dest="n_filter",
        help="Restrict plot to specific block lengths (repeatable)",
    )
    parser.add_argument(
        "--output-dir",
        type=Path,
        default=ROOT / "plots",
        help="Directory for CSV and figures (default: plots/)",
    )
    return parser.parse_args()


def find_summary_path(tech: str, roots: Iterable[Path]) -> Path:
    tech_dir = f"{tech.lower()}_opt_sweep"
    for root in roots:
        path = root / tech_dir / "summary.csv"
        if path.exists():
            return path
    raise FileNotFoundError(f"summary.csv for {tech} not found in {', '.join(str(r) for r in roots)}")


def compute_energy_table(summary_path: Path) -> pd.DataFrame:
    summary = pd.read_csv(summary_path)

    if summary.empty:
        return pd.DataFrame(columns=["N", "top", "energy_pj_per_bit"])

    summary = summary.assign(
        cycles=summary["top"].map(lambda top: CYCLES_PER_TOP.get(top, 1.0))
    )
    summary["energy_pj_per_bit"] = (
        summary["total_dyn_mw"]
        * summary["CLK_NS"]
        * summary["cycles"]
        / ((summary["K"] / summary["N"]) * summary["GF_WIDTH"])
    )

    energy = (
        summary.groupby(["top", "N"])["energy_pj_per_bit"].min().unstack("top")
    )
    required = {"rs_encoder_wrapper", "rs_syndrome", "rs_decoder_plus_syndrome"}
    missing = required - set(energy.columns)
    if missing:
        raise ValueError(f"Summary at {summary_path} missing energy for: {', '.join(sorted(missing))}")

    energy = energy[list(required)]
    total = energy.sum(axis=1)
    energy = energy.reset_index()
    energy["total_energy"] = total.values
    return energy[["N", "total_energy"]]


def build_dataset(summary_roots: Iterable[Path], n_filter: Iterable[int] | None) -> pd.DataFrame:
    rows = []
    for tech in SUMMARY_TECHS:
        summary_path = find_summary_path(tech, summary_roots)
        tech_energy = compute_energy_table(summary_path)
        tech_energy["tech"] = tech
        rows.append(tech_energy)

    df = pd.concat(rows, ignore_index=True)
    if n_filter:
        n_set = set(n_filter)
        df = df[df["N"].isin(n_set)]
    if df.empty:
        raise ValueError("No energy entries after applying filters")
    return df.sort_values(["tech", "N"]).reset_index(drop=True)


def plot_energy_vs_n(df: pd.DataFrame, output_dir: Path) -> None:
    output_dir.mkdir(parents=True, exist_ok=True)
    csv_path = output_dir / "total_energy_vs_n.csv"
    df.to_csv(csv_path, index=False)

    sns.set_style("darkgrid")
    for tech in SUMMARY_TECHS:
        data = df[df["tech"] == tech]
        if data.empty:
            continue
        plt.figure(figsize=(8, 5))
        sns.lineplot(data=data, x="N", y="total_energy", marker="o", color="C0")
        plt.xlabel("Block length N")
        plt.ylabel("Total energy per bit (pJ/bit)")
        plt.title(f"{tech} RS Energy/bit vs N (Encoder + Syndrome + Decoder)")
        plt.tight_layout()
        plt.savefig(output_dir / f"{tech.lower()}_energy_vs_n.png", dpi=200)
        plt.close()


def main() -> None:
    args = parse_args()
    summary_roots = args.summary_root if args.summary_root else DEFAULT_SUMMARY_ROOTS
    dataset = build_dataset(summary_roots, args.n_filter)
    plot_energy_vs_n(dataset, args.output_dir)


if __name__ == "__main__":
    main()
