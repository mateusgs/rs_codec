#!/usr/bin/env python3
"""
Plot RS-FEC tradeoffs: pJ/bit vs input BER, and code rate vs input BER.

Inputs
- rsfec_selection CSV (e.g., `rsfec_selection_m8_halfdec.csv`)
  - Must contain columns: `target_post_BER,input_preFEC_BER,n,k,m,t,rate,post_ber_est`.
- synthesis summary CSV (e.g., `data/asap7_sweep_512/summary.csv`)
  - Must contain columns: `label,top,N,K,GF_WIDTH,CLK_NS,area,wns,total_dyn_mw`.

Assumptions
- GF_WIDTH=m=8 (matches the selection file).
- Use decoder energy for pJ/bit: `top == 'rs_decoder_plus_syndrome'`.
- Throughput model (from the referenced paper):
  - Streaming decoder that processes one symbol every `DEC_CYCLES_PER_SYMBOL` clocks.
  - For the half-decoder configuration, `DEC_CYCLES_PER_SYMBOL = 2`.
  - Information-bit throughput (bits/s) = `rate * m * f_clk / DEC_CYCLES_PER_SYMBOL`.
- Energy per information bit pJ/bit = `1e9 * total_dyn_mW / throughput_bits_per_s`.

Outputs
- Figures (PNG + PDF):
  - `plots/rscodec_pj_per_bit_vs_input_BER.png` and `.pdf`
  - `plots/rscodec_rate_vs_input_BER.png` and `.pdf`
- Raw data (CSV):
  - `plots/rscodec_pj_per_bit_vs_input_BER.csv`
  - `plots/rscodec_rate_vs_input_BER.csv`

Usage
  python scripts/plot_rs_codec_vs_ber.py \
    --selection rsfec_selection_m8_halfdec.csv \
    --summary data/asap7_sweep_512/summary.csv \
    [--top rs_decoder_plus_syndrome] [--cycles-per-symbol 2] [--outdir plots]
"""

import argparse
from pathlib import Path
from typing import Optional

import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt


def parse_args() -> argparse.Namespace:
    p = argparse.ArgumentParser(description="Plot pJ/bit and code rate vs input BER for RS-FEC selections.")
    p.add_argument("--selection", type=Path, default=Path("rsfec_selection_m8_halfdec.csv"),
                   help="Path to selection CSV produced by rsfec_select_and_cfg.py")
    p.add_argument("--summary", type=Path, default=Path("data/asap7_sweep_512/summary.csv"),
                   help="Path to synthesis summary CSV with power and clock info")
    # Non-gated mode: choose a single top and its cycles-per-symbol
    p.add_argument("--top", type=str, default="rs_decoder_plus_syndrome",
                   choices=["rs_decoder_plus_syndrome", "rs_encoder_wrapper", "rs_syndrome"],
                   help="Top block for non-gated pJ/bit computation")
    p.add_argument("--cycles-per-symbol", type=float, default=2.0,
                   help="Cycles per processed symbol for --top (2.0 for half-decoder)")
    # Gated mode: combine syndrome + decoder based on corrected-codeword probability
    p.add_argument("--gated", action="store_true",
                   help="Enable decoder clock gating model: E = E_syndrome + P_correctable * (E_decoder - E_syndrome)")
    p.add_argument("--syndrome-top", type=str, default="rs_syndrome",
                   choices=["rs_decoder_plus_syndrome", "rs_encoder_wrapper", "rs_syndrome"],
                   help="Top name for syndrome-only energy when --gated")
    p.add_argument("--decoder-top", type=str, default="rs_decoder_plus_syndrome",
                   choices=["rs_decoder_plus_syndrome", "rs_encoder_wrapper", "rs_syndrome"],
                   help="Top name for decoder energy when --gated")
    p.add_argument("--syndrome-cycles-per-symbol", type=float, default=1.0,
                   help="Cycles per symbol for the syndrome block when --gated")
    p.add_argument("--decoder-cycles-per-symbol", type=float, default=2.0,
                   help="Cycles per symbol for the decoder block when --gated (2.0 for half-decoder)")
    # Encoder contribution
    p.add_argument("--encoder-top", type=str, default="rs_encoder_wrapper",
                   choices=["rs_decoder_plus_syndrome", "rs_encoder_wrapper", "rs_syndrome"],
                   help="Top name for encoder energy contribution")
    p.add_argument("--encoder-cycles-per-symbol", type=float, default=1.0,
                   help="Cycles per symbol for the encoder (typically 1.0)")
    p.add_argument("--no-encoder", dest="include_encoder", action="store_false",
                   help="Exclude encoder energy from total pJ/bit")
    p.set_defaults(include_encoder=True)
    p.add_argument("--outdir", type=Path, default=Path("plots"),
                   help="Directory to write output plots")
    p.add_argument("--style", type=str, default="darkgrid",
                   help="Seaborn style (e.g., whitegrid, darkgrid)")
    return p.parse_args()


def load_selection(selection_csv: Path) -> pd.DataFrame:
    df = pd.read_csv(selection_csv)
    required = {"target_post_BER", "input_preFEC_BER", "n", "k", "m", "t", "rate"}
    missing = required - set(df.columns)
    if missing:
        raise ValueError(f"Selection CSV missing columns: {sorted(missing)}")
    return df


def load_summary(summary_csv: Path) -> pd.DataFrame:
    df = pd.read_csv(summary_csv)
    required = {"top", "N", "K", "GF_WIDTH", "CLK_NS", "total_dyn_mw"}
    missing = required - set(df.columns)
    if missing:
        raise ValueError(f"Summary CSV missing columns: {sorted(missing)}")
    return df


def merge_selection_power_single(selection: pd.DataFrame, summary: pd.DataFrame, top: str,
                                 prefix: str) -> pd.DataFrame:
    """Merge selection with a single-top summary; columns are prefixed."""
    sel = selection.rename(columns={"n": "N", "k": "K"}).copy()
    summ = summary[summary["top"] == top].copy()
    if summ.empty:
        raise ValueError(f"No rows for top='{top}' in summary CSV")
    summ = summ[["N", "K", "GF_WIDTH", "CLK_NS", "total_dyn_mw"]].drop_duplicates(subset=["N", "K"]).copy()
    summ = summ.rename(columns={
        "GF_WIDTH": f"{prefix}GF_WIDTH",
        "CLK_NS": f"{prefix}CLK_NS",
        "total_dyn_mw": f"{prefix}total_dyn_mw",
    })
    merged = sel.merge(summ, on=["N", "K"], how="left")
    # Sanity: GF width vs m
    gf_col = f"{prefix}GF_WIDTH"
    mism = merged[(~merged[gf_col].isna()) & (merged[gf_col] != merged["m"])][["N", "K", gf_col, "m"]]
    if not mism.empty:
        print(f"Warning: GF width mismatch ({top}) in merged data; proceeding anyway:\n", mism.head())
    return merged


def compute_metrics_single_top(df: pd.DataFrame, cycles_per_symbol: float, prefix: str = "") -> pd.DataFrame:
    out = df.copy()
    clk_col = f"{prefix}CLK_NS" if prefix else "CLK_NS"
    pwr_col = f"{prefix}total_dyn_mw" if prefix else "total_dyn_mw"
    out[f"{prefix}fclk_hz"] = 1e9 / out[clk_col]
    out[f"{prefix}symbols_per_s"] = out[f"{prefix}fclk_hz"] / cycles_per_symbol
    out[f"{prefix}throughput_bps"] = out["rate"] * out["m"] * out[f"{prefix}symbols_per_s"]
    out[f"{prefix}pj_per_bit"] = 1e9 * out[pwr_col] / out[f"{prefix}throughput_bps"]
    return out


def corrected_codeword_probability(n: int, t: int, m_bits: int, p_b: float) -> float:
    """Probability that a codeword has 1..t symbol errors (correctable),
    given bit-error probability p_b and symbol size m_bits.
    """
    import math
    if t <= 0:
        return 0.0
    # Symbol error probability
    p_s = 1.0 - (1.0 - p_b) ** m_bits
    if p_s <= 0.0:
        return 0.0
    if p_s >= 1.0:
        return 1.0 if t >= 1 else 0.0
    # Sum_{i=1..t} Binom(n,i) p_s^i (1-p_s)^(n-i)
    log1m = math.log1p(-p_s)
    total = 0.0
    # Precompute log factorial via lgamma
    for i in range(1, min(t, n) + 1):
        logC = math.lgamma(n + 1) - math.lgamma(i + 1) - math.lgamma(n - i + 1)
        logpmf = logC + i * math.log(p_s) + (n - i) * log1m
        total += math.exp(logpmf)
    return min(max(total, 0.0), 1.0)


def plot_pj_per_bit_vs_ber(df: pd.DataFrame, outpath: Path, style: str) -> None:
    sns.set_style(style)
    plt.figure(figsize=(7.5, 5.0))
    # Order targets for consistent legend
    # Use formatted labels like '1e-12', '1e-15', '1e-30'
    order = [lbl for _, lbl in sorted({(e, l) for e, l in zip(df["target_exp"], df["target_label"])})]
    ax = sns.lineplot(
        data=df,
        x="input_preFEC_BER",
        y="pj_per_bit",
        hue="target_label",
        hue_order=order,
        marker="o",
        style="target_label",
        dashes=False,
        linewidth=2,
    )
    ax.set_xscale("log")
    ax.set_yscale("log")
    ax.set_xlabel("Input pre-FEC BER")
    ax.set_ylabel("Energy per info bit (pJ/bit)")
    ax.set_title("RS Decoder pJ/bit vs Input BER")
    ax.grid(True, which="both", linestyle=":", linewidth=0.5)
    ax.legend(title="Target post-FEC BER")
    plt.tight_layout()
    outpath.parent.mkdir(parents=True, exist_ok=True)
    plt.savefig(outpath, dpi=200)
    # Also save as PDF
    try:
        plt.savefig(outpath.with_suffix('.pdf'))
    except Exception as e:
        print(f"Warning: failed to save PDF for {outpath}: {e}")
    plt.close()


def plot_rate_vs_ber(df: pd.DataFrame, outpath: Path, style: str) -> None:
    sns.set_style(style)
    plt.figure(figsize=(7.5, 5.0))
    order = [lbl for _, lbl in sorted({(e, l) for e, l in zip(df["target_exp"], df["target_label"])})]
    ax = sns.lineplot(
        data=df,
        x="input_preFEC_BER",
        y="rate",
        hue="target_label",
        hue_order=order,
        marker="o",
        style="target_label",
        dashes=False,
        linewidth=2,
    )
    ax.set_xscale("log")
    ax.set_xlabel("Input pre-FEC BER")
    ax.set_ylabel("Code rate (k/n)")
    ax.set_title("RS Code Rate vs Input BER")
    ax.set_ylim(0.85, 1.01)
    ax.grid(True, which="both", linestyle=":", linewidth=0.5)
    ax.legend(title="Target post-FEC BER")
    plt.tight_layout()
    outpath.parent.mkdir(parents=True, exist_ok=True)
    plt.savefig(outpath, dpi=200)
    # Also save as PDF
    try:
        plt.savefig(outpath.with_suffix('.pdf'))
    except Exception as e:
        print(f"Warning: failed to save PDF for {outpath}: {e}")
    plt.close()


def main() -> None:
    args = parse_args()

    sel_df = load_selection(args.selection)
    sum_df = load_summary(args.summary)

    # Merge summary for required tops
    if args.gated:
        merged = merge_selection_power_single(sel_df, sum_df, args.syndrome_top, prefix="syn_")
        merged = merge_selection_power_single(merged, sum_df, args.decoder_top, prefix="dec_")
        if args.include_encoder:
            merged = merge_selection_power_single(merged, sum_df, args.encoder_top, prefix="enc_")
        # Drop rows missing power for either top
        before = len(merged)
        needed = ["syn_total_dyn_mw", "syn_CLK_NS", "dec_total_dyn_mw", "dec_CLK_NS"]
        if args.include_encoder:
            needed += ["enc_total_dyn_mw", "enc_CLK_NS"]
        merged = merged.dropna(subset=needed).copy()
        missing = before - len(merged)
        if missing:
            print(f"Warning: {missing} selection rows lack matching (N,K) for syndrome/decoder and were dropped.")

        # Compute pJ/bit for each block with their own cycles-per-symbol
        metrics = compute_metrics_single_top(merged, args.syndrome_cycles_per_symbol, prefix="syn_")
        metrics = compute_metrics_single_top(metrics, args.decoder_cycles_per_symbol, prefix="dec_")
        if args.include_encoder:
            metrics = compute_metrics_single_top(metrics, args.encoder_cycles_per_symbol, prefix="enc_")

        # Compute corrected-codeword probability and effective pJ/bit (gated)
        corr_probs = []
        for _, r in metrics.iterrows():
            n = int(r["N"]) if not pd.isna(r["N"]) else None
            t = int(r["t"]) if not pd.isna(r["t"]) else 0
            m_bits = int(r["m"]) if not pd.isna(r["m"]) else 8
            p_b = float(r["input_preFEC_BER"]) if not pd.isna(r["input_preFEC_BER"]) else 0.0
            pc = corrected_codeword_probability(n, t, m_bits, p_b) if (n is not None) else 0.0
            corr_probs.append(pc)
        metrics["p_correctable"] = corr_probs
        rx_pj = metrics["syn_pj_per_bit"] + metrics["p_correctable"] * (metrics["dec_pj_per_bit"] - metrics["syn_pj_per_bit"])
        metrics["rx_pj_per_bit"] = rx_pj
        if args.include_encoder:
            metrics["total_pj_per_bit"] = metrics["enc_pj_per_bit"] + rx_pj
        else:
            metrics["total_pj_per_bit"] = rx_pj
        # For reference, set nominal throughput columns from decoder path (slow path)
        metrics["fclk_hz"] = metrics["dec_fclk_hz"]
        metrics["throughput_bps"] = metrics["dec_throughput_bps"]
    else:
        merged = merge_selection_power_single(sel_df, sum_df, args.top, prefix="")
        if args.include_encoder:
            merged = merge_selection_power_single(merged, sum_df, args.encoder_top, prefix="enc_")
        before = len(merged)
        needed = ["total_dyn_mw", "CLK_NS"]
        if args.include_encoder:
            needed += ["enc_total_dyn_mw", "enc_CLK_NS"]
        merged = merged.dropna(subset=needed).copy()
        missing = before - len(merged)
        if missing:
            print(f"Warning: {missing} selection rows lack matching (N,K) in summary and were dropped.")

        metrics = compute_metrics_single_top(merged, args.cycles_per_symbol, prefix="")
        if args.include_encoder:
            metrics = compute_metrics_single_top(metrics, args.encoder_cycles_per_symbol, prefix="enc_")
            metrics["total_pj_per_bit"] = metrics["enc_pj_per_bit"] + metrics["pj_per_bit"]
        else:
            metrics["total_pj_per_bit"] = metrics["pj_per_bit"]

    # Prepare nicely formatted target labels for legend
    import numpy as np
    def _fmt_label(x: float) -> str:
        if x <= 0:
            return str(x)
        exp = int(round(np.log10(x)))
        return f"1e{exp}"
    metrics["target_exp"] = metrics["target_post_BER"].apply(lambda v: int(round(np.log10(v))) if v > 0 else 0)
    metrics["target_label"] = metrics["target_post_BER"].apply(_fmt_label)

    # Outputs directory and basenames
    outdir = args.outdir
    outdir.mkdir(parents=True, exist_ok=True)
    pj_base = outdir / "rscodec_pj_per_bit_vs_input_BER"
    rate_base = outdir / "rscodec_rate_vs_input_BER"

    # Plots
    # Plot uses total energy per bit
    plot_df = metrics.copy()
    plot_df["pj_per_bit"] = plot_df["total_pj_per_bit"]
    plot_pj_per_bit_vs_ber(plot_df, pj_base.with_suffix('.png'), args.style)
    plot_rate_vs_ber(metrics, rate_base.with_suffix('.png'), args.style)

    # Raw CSVs
    pj_cols = [
        "target_post_BER", "target_label", "input_preFEC_BER", "N", "K", "t", "rate", "m",
        "total_pj_per_bit"
    ]
    # Optional detailed columns
    if args.include_encoder:
        pj_cols += ["enc_CLK_NS", "enc_total_dyn_mw", "enc_pj_per_bit"]
    if args.gated:
        pj_cols += [
            "syn_CLK_NS", "syn_total_dyn_mw", "syn_pj_per_bit",
            "dec_CLK_NS", "dec_total_dyn_mw", "dec_pj_per_bit",
            "p_correctable", "rx_pj_per_bit",
        ]
    else:
        pj_cols += [
            "CLK_NS", "total_dyn_mw", "fclk_hz", "throughput_bps", "pj_per_bit"
        ]
    pj_df = metrics.loc[:, [c for c in pj_cols if c in metrics.columns]].sort_values(
        ["target_post_BER", "input_preFEC_BER"]
    )
    pj_df.to_csv(pj_base.with_suffix('.csv'), index=False)

    rate_cols = ["target_post_BER", "target_label", "input_preFEC_BER", "N", "K", "t", "rate"]
    rate_df = metrics.loc[:, [c for c in rate_cols if c in metrics.columns]].sort_values(
        ["target_post_BER", "input_preFEC_BER"]
    )
    rate_df.to_csv(rate_base.with_suffix('.csv'), index=False)

    print(f"Wrote plots and CSVs to: {outdir}")


if __name__ == "__main__":
    main()
