#!/usr/bin/env python3
"""
Generate a sweep config (ASAP7/DC) for RS(544,514) with GF_WIDTH=10 across clock
frequencies in MHz, using 10 MHz increments by default.

Output format matches `config/sweep_configs_asap7_exhaustive.txt`:
  N K GF_WIDTH clock_ps [library_dir] [top]

For each frequency point, emit lines for:
  - rs_encoder_wrapper
  - rs_syndrome
  - rs_decoder_plus_syndrome

Examples
  python scripts/gen_sweep_rs544_m10.py \
    --out config/sweep_configs_asap7_rs544_m10_clk_sweep.txt \
    --fmin 10 --fmax 1000 --step 10 \
    --lib /w/ee.00/puneet/aaronyen/asap7/asap7sc7p5t_28/LIB/CCS/TT
"""

import argparse
from pathlib import Path
from typing import List


def mhz_to_ps(mhz: float) -> float:
    # period_ps = 1e12 / (freq_Hz) = 1e12 / (MHz*1e6) = 1e6 / MHz
    return 1e6 / mhz


def build_lines(f_min_mhz: float, f_max_mhz: float, step_mhz: float, lib: str) -> List[str]:
    N, K, GF = 544, 514, 10
    tops = ["rs_encoder_wrapper", "rs_syndrome", "rs_decoder_plus_syndrome"]

    hdr = []
    hdr.append("# RS Codec Synthesis Configs (ASAP7, RS(544,514) GF10 clock sweep)")
    hdr.append("# Format: N K GF_WIDTH clock_ps [library_dir] [top]")
    hdr.append("# Library: ASAP7 TT compiled DBs")
    hdr.append("")
    hdr.append(f"# Sweep: {f_min_mhz:g} MHz to {f_max_mhz:g} MHz in {step_mhz:g} MHz steps")
    hdr.append("")

    lines = []
    f = f_min_mhz
    # Ensure inclusive of f_max with float tolerance
    while f <= f_max_mhz + 1e-9:
        clk_ps = mhz_to_ps(f)
        t = (N - K) // 2
        lines.append(f"# RS({N},{K}), GF{GF} (t={t}), {f:g} MHz => {clk_ps:.1f} ps")
        for top in tops:
            lines.append(f"{N} {K} {GF} {clk_ps:.1f} {lib} {top}")
        lines.append("")
        f += step_mhz

    return hdr + lines


def main():
    ap = argparse.ArgumentParser(description="Generate clock sweep config for RS(544,514) GF10 (ASAP7)")
    ap.add_argument("--out", type=Path, default=Path("config/sweep_configs_asap7_rs544_m10_clk_sweep.txt"),
                    help="Output config file path")
    ap.add_argument("--fmin", type=float, default=10.0, help="Min frequency in MHz (inclusive)")
    ap.add_argument("--fmax", type=float, default=1000.0, help="Max frequency in MHz (inclusive)")
    ap.add_argument("--step", type=float, default=10.0, help="Step size in MHz")
    ap.add_argument("--lib", type=str,
                    default="/w/ee.00/puneet/aaronyen/asap7/asap7sc7p5t_28/LIB/CCS/TT",
                    help="Path to compiled ASAP7 .db directory")
    args = ap.parse_args()

    if args.fmin <= 0 or args.fmax <= 0 or args.step <= 0:
        raise SystemExit("fmin, fmax, step must be positive")
    if args.fmin > args.fmax:
        raise SystemExit("fmin must be <= fmax")

    lines = build_lines(args.fmin, args.fmax, args.step, args.lib)
    args.out.parent.mkdir(parents=True, exist_ok=True)
    args.out.write_text("\n".join(lines) + "\n", encoding="utf-8")
    print(f"Wrote {args.out} with {len(lines)} lines")


if __name__ == "__main__":
    main()
