#!/usr/bin/env python3
"""Generate energy and rate vs BER plots without external sweep dependencies."""

from __future__ import annotations

import argparse
import math
from pathlib import Path
from typing import Iterable, Optional, Tuple

import matplotlib.pyplot as plt
import pandas as pd
import seaborn as sns

import gen_k_sweep


HERE = Path(__file__).resolve().parent
ROOT = HERE.parent

SUMMARY_TECHS = ("ASAP7", "NanGate45")
SUMMARY_ROOT_CANDIDATES = (ROOT / "newdata",)

GF_SYMBOL_WIDTH = 8
DECODER_CYCLES = 2.0  # decoder uses two cycles per symbol


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Plot total energy and rate vs BER")
    parser.add_argument("--selection", type=Path, help="precomputed sweep CSV; skip generation if provided")
    parser.add_argument("--save-selection", type=Path, help="optional path to save generated sweep data")
    parser.add_argument("--k", type=int, default=512, help="data symbols K when generating sweep")
    parser.add_argument("--min-exp", type=float, default=-30.0, help="minimum BER exponent (e.g., -30 for 1e-30)")
    parser.add_argument("--max-exp", type=float, default=-3.0, help="maximum BER exponent (e.g., -3 for 1e-3)")
    parser.add_argument("--step", type=float, default=0.5, help="log-scale step size in decades")
    parser.add_argument("--target", type=float, action="append", dest="targets", help="target post-FEC BER (repeatable)")
    parser.add_argument("--n", type=int, action="append", dest="n_filter", help="restrict to specific block length N (repeatable)")
    return parser.parse_args()


def load_or_generate_selection(
    args: argparse.Namespace, targets: Optional[Iterable[float]]
) -> Tuple[pd.DataFrame, list[float]]:
    if args.selection is not None:
        df = pd.read_csv(args.selection)
    else:
        df = gen_k_sweep.generate_sweep(
            k=args.k,
            exp_start=args.max_exp,
            exp_stop=args.min_exp,
            exp_step=-abs(args.step),
            targets=list(targets) if targets is not None else None,
        )
        if args.save_selection is not None:
            args.save_selection.parent.mkdir(parents=True, exist_ok=True)
            df.to_csv(args.save_selection, index=False)

    df = df.dropna(subset=["n", "t"]).copy()
    df["target_post_BER"] = df["target_post_BER"].astype(float)
    target_list = sorted(set(targets)) if targets is not None else sorted(df["target_post_BER"].unique())
    df["target_post_BER"] = df["target_post_BER"].apply(lambda val: match_target_ber(val, target_list))
    df = df.dropna(subset=["target_post_BER"])
    df["n"] = df["n"].astype(int)
    df["t"] = df["t"].astype(int)

    if args.n_filter:
        df = df[df["n"].isin(args.n_filter)]

    if df.empty:
        raise ValueError("No sweep entries match the provided filters/targets")

    return df, target_list


def match_target_ber(value: float, targets: Iterable[float]) -> Optional[float]:
    for target in targets:
        if math.isclose(value, target, rel_tol=1e-2, abs_tol=0.0):
            return float(target)
    return None


def find_summary_path(tech: str) -> Path:
    tech_dir = f"{tech.lower()}_opt_sweep"
    for base in SUMMARY_ROOT_CANDIDATES:
        candidate = base / tech_dir / "summary.csv"
        if candidate.exists():
            return candidate
    raise FileNotFoundError(f"summary.csv for {tech} not found in expected directories")


def p_correctable(n: int, t: int, p_b: float) -> float:
    if t <= 0:
        return 0.0
    p_s = 1.0 - (1.0 - p_b) ** GF_SYMBOL_WIDTH
    if p_s <= 0.0:
        return 0.0
    if p_s >= 1.0:
        return 1.0

    log1m = math.log1p(-p_s)
    total = 0.0
    for i in range(1, min(t, n) + 1):
        logc = math.lgamma(n + 1) - math.lgamma(i + 1) - math.lgamma(n - i + 1)
        logpmf = logc + i * math.log(p_s) + (n - i) * log1m
        total += math.exp(logpmf)
    return min(max(total, 0.0), 1.0)


def build_dataset(selection: pd.DataFrame) -> pd.DataFrame:
    rows: list[dict[str, float]] = []
    for tech in SUMMARY_TECHS:
        summary_path = find_summary_path(tech)
        summary = pd.read_csv(summary_path)
        summary["cycles"] = summary["top"].map(
            lambda top: DECODER_CYCLES if top == "rs_decoder_plus_syndrome" else 1.0
        )
        summary["energy_pj_per_bit"] = (
            summary["total_dyn_mw"]
            * summary["CLK_NS"]
            * summary["cycles"]
            / ((summary["K"] / summary["N"]) * summary["GF_WIDTH"])
        )
        energy_map = summary.pivot_table(index="N", columns="top", values="energy_pj_per_bit")

        for _, sel_row in selection.iterrows():
            n = int(sel_row["n"])
            if n not in energy_map.index:
                continue

            try:
                enc_energy = energy_map.loc[n, "rs_encoder_wrapper"]
                syn_energy = energy_map.loc[n, "rs_syndrome"]
                dec_energy = energy_map.loc[n, "rs_decoder_plus_syndrome"]
            except KeyError:
                continue

            t = int(sel_row["t"])
            p_in = float(sel_row["input_preFEC_BER"])
            rate = float(sel_row["rate"])
            target = float(sel_row["target_post_BER"])

            p_corr = p_correctable(n, t, p_in)
            total_energy = enc_energy + syn_energy + p_corr * (dec_energy - syn_energy)

            rows.append(
                {
                    "tech": tech,
                    "BER Target": target,
                    "input_preFEC_BER": p_in,
                    "n": n,
                    "t": t,
                    "rate": rate,
                    "energy": total_energy,
                    "p_correctable": p_corr,
                }
            )

    return pd.DataFrame(rows)


def plot_outputs(df: pd.DataFrame, targets: list[float], k: int) -> None:
    out_dir = ROOT / "plots"
    out_dir.mkdir(parents=True, exist_ok=True)
    df.to_csv(out_dir / "total_energy_rate_vs_ber.csv", index=False)

    sns.set_style("darkgrid")
    for tech in SUMMARY_TECHS:
        data = df[df["tech"] == tech]
        if data.empty:
            continue
        data.to_csv(out_dir / f"{tech.lower()}_total_energy_rate_vs_ber.csv", index=False)

        plt.figure(figsize=(8, 5))
        sns.lineplot(
            data=data,
            x="input_preFEC_BER",
            y="energy",
            hue="BER Target",
            style="BER Target",
            marker="o",
        )
        plt.xscale("log")
        plt.xlabel("Input Pre-FEC BER")
        plt.ylabel("Total energy per bit (pJ/bit)")
        targets_str = ", ".join(f"{t:.0e}" for t in targets)
        plt.title(f"{tech} RS(m=8,k={k}) Energy/bit vs Input BER (targets: {targets_str})")
        plt.tight_layout()
        plt.savefig(out_dir / f"{tech.lower()}_energy_vs_ber.png", dpi=200)
        plt.close()

        plt.figure(figsize=(8, 5))
        sns.lineplot(
            data=data,
            x="input_preFEC_BER",
            y="rate",
            hue="BER Target",
            style="BER Target",
            marker="o",
        )
        plt.xscale("log")
        plt.xlabel("Input Pre-FEC BER")
        plt.ylabel("Code rate (k/n)")
        plt.title(f"{tech} RS(m=8,k={k}) Rate vs Input BER (targets: {targets_str})")
        plt.tight_layout()
        plt.savefig(out_dir / f"{tech.lower()}_rate_vs_ber.png", dpi=200)
        plt.close()


def main() -> None:
    args = parse_args()
    targets_input = sorted(set(args.targets)) if args.targets else None
    selection, targets = load_or_generate_selection(args, targets_input)
    dataset = build_dataset(selection)
    if dataset.empty:
        raise ValueError("No dataset rows produced; check sweep/summary overlap")
    plot_outputs(dataset, targets, args.k)


if __name__ == "__main__":
    main()
