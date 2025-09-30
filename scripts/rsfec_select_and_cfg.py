#!/usr/bin/env python3
"""
RS-FEC selector and synthesis-config generator (m=8, k power-of-two).

- Inputs: pre-FEC BER grid from 1e-4 down to 1e-15 in half-decade steps.
- Targets: post-FEC BER targets {1e-12, 1e-15, 1e-30}.
- For each (input, target), compute the minimal n (i.e., minimal t with n=k+2t)
  that meets the target using RS(n,k) over GF(2^8), scanning k in {16,32,64,128}.
- Choose across k by highest code rate (tie → smaller n).
- Outputs:
  1) CSV table mapping (input, target) → chosen (n,k,t,rate,post_ber_est)
  2) Synthesis config file in the requested format (unique (n,k) pairs):
     N K GF_WIDTH clock_ps [library_dir] [top]

Model assumptions:
- Bit errors are independent. Symbol error probability p_s = 1 - (1 - p_b)^m.
- RS(n,k) corrects up to t=(n-k)/2 symbol errors per block.
- Post-FEC BER approximation:
    BER_post ≈ 0.5 * Σ_{i=t+1..n} (i/n) * Binomial(n,i) * p_s^i * (1-p_s)^(n-i).
- GF(2^8) → n ≤ 255.

You can tweak parameters at the bottom (LIB path, clock_ps, k set, ranges).
"""

import math
import numpy as np
import pandas as pd
from pathlib import Path

# ---------- Parameters ----------
m = 8
targets = [1e-12, 1e-15, 1e-30]
exponents = np.arange(-4.0, -15.0, -0.5)  # -4, -4.5, ..., -15
ei_grid = 10.0 ** exponents
k_candidates = [16, 128, 512]
n_min, n_max = 0, 1024

# Synthesis-config formatting
LIB = "/w/ee.00/puneet/aaronyen/asap7/asap7sc7p5t_28/LIB/CCS/TT"
clock_ps = 5000.0  # 5.0 ns
# -------------------------------

def symbol_error_from_bit_error(p_b: float, m: int) -> float:
    return 1.0 - (1.0 - p_b) ** m

def rs_post_ber(p_b: float, n: int, k: int, m: int) -> float:
    """Approximate post-FEC BER for RS(n,k) over GF(2^m)."""
    if n < k + 2 or ((n - k) % 2) != 0:
        raise ValueError("Invalid RS(n,k): need n >= k+2 and (n-k) even.")
    t = (n - k) // 2
    p_s = symbol_error_from_bit_error(p_b, m)
    if p_s <= 0.0:
        return 0.0
    if p_s >= 1.0:
        return 0.5

    # Binomial tail with weighting 0.5*(i/n); compute in log domain for stability.
    log1m = math.log1p(-p_s)
    logfact = [0.0]
    for i in range(1, n + 1):
        logfact.append(logfact[-1] + math.log(i))
    def logC(nv, iv):
        return logfact[nv] - logfact[iv] - logfact[nv - iv]

    ber = 0.0
    for i in range(t + 1, n + 1):
        logpmf = logC(n, i) + i * math.log(p_s) + (n - i) * log1m
        pmf = math.exp(logpmf)
        ber += 0.5 * (i / n) * pmf
    return ber

def minimal_n_for_target(p_b: float, target: float, k: int):
    """Return minimal-n solution for this k that meets target (if any)."""
    n_start = max(k + 2, n_min)
    if (n_start - k) % 2 == 1:
        n_start += 1
    for n in range(n_start, n_max + 1, 2):
        post = rs_post_ber(p_b, n, k, m)
        if post <= target:
            return {
                "n": n, "k": k, "m": m, "t": (n - k) // 2,
                "rate": k / n, "post_ber_est": post
            }
    return None

def choose_best_over_k(p_b: float, target: float):
    """Pick highest rate across k; tie-break smaller n."""
    cands = []
    for k in k_candidates:
        sol = minimal_n_for_target(p_b, target, k)
        if sol:
            cands.append(sol)
    if not cands:
        return None
    cands.sort(key=lambda d: (-d["rate"], d["n"]))
    return cands[0]

def main():
    rows = []
    for target in targets:
        for p_b in ei_grid:
            best = choose_best_over_k(p_b, target)
            row = {"target_post_BER": target, "input_preFEC_BER": p_b}
            if best is None:
                row.update({"n": None, "k": None, "m": m, "t": None, "rate": None,
                            "post_ber_est": None, "note": "No RS(n,k) with m=8, n<=255 met the target"})
            else:
                row.update(best)
                row["note"] = ""
            rows.append(row)

    sel_df = pd.DataFrame(rows)
    csv_path = Path("rsfec_selection_m8_halfdec.csv")
    sel_df.to_csv(csv_path, index=False)

    # Build synthesis config of unique (n,k) found
    uniq = sel_df.dropna(subset=["n","k"]).drop_duplicates(subset=["n","k","m"]).sort_values(["k","n"])
    cfg_lines = []
    cfg_lines.append("# RS Codec Synthesis Configs (ASAP7, from selection over specified input/targets)")
    cfg_lines.append("# Format: N K GF_WIDTH clock_ps [library_dir] [top]")
    cfg_lines.append("# Library: ASAP7 TT compiled DBs")
    cfg_lines.append("")
    cfg_lines.append("# Targets: 1e-12, 1e-15, 1e-30; Inputs: 1e-4 down to 1e-15 in 0.5-decade steps")
    cfg_lines.append(f"# set LIB {LIB}")
    cfg_lines.append("")
    for _, r in uniq.iterrows():
        n, k, t = int(r["n"]), int(r["k"]), int(r["t"])
        cfg_lines.append(f"# RS({n},{k}), GF8 (t={t}), {clock_ps/1000:.1f} ns")
        for top in ["rs_encoder_wrapper", "rs_syndrome", "rs_decoder_plus_syndrome"]:
            cfg_lines.append(f"{n} {k} 8 {clock_ps} {LIB} {top}")
        cfg_lines.append("")
    cfg_path = Path("rs_codec_synth_configs_from_selection_halfdec.cfg")
    cfg_path.write_text("\n".join(cfg_lines), encoding="utf-8")

    print(f"Wrote: {csv_path}")
    print(f"Wrote: {cfg_path}")

if __name__ == "__main__":
    main()
