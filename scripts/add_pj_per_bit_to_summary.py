#!/usr/bin/env python3
"""
Add a pJ/bit column to a synthesis summary CSV using the formula from
IET Computers & Digital Techniques (2021, Silva et al.).

Energy per information bit (pJ/bit) = total_dyn_mW * CLK_NS * cycles_per_symbol / (rate * m)

Where:
- rate = K / N
- m = GF_WIDTH (bits per symbol)
- cycles_per_symbol = 2 for 'rs_decoder_plus_syndrome' (half-decoder), else 1

The input CSV must contain columns:
  label,top,N,K,GF_WIDTH,CLK_NS,area,wns,total_dyn_mw

The script appends a new column 'pj_per_bit' and overwrites the file.
"""

import csv
from pathlib import Path
import sys


def compute_pj_per_bit(row: dict) -> float:
    try:
        n = float(row["N"]) if row.get("N") not in (None, "") else None
        k = float(row["K"]) if row.get("K") not in (None, "") else None
        m = float(row["GF_WIDTH"]) if row.get("GF_WIDTH") not in (None, "") else None
        clk_ns = float(row["CLK_NS"]) if row.get("CLK_NS") not in (None, "") else None
        p_mw = float(row["total_dyn_mw"]) if row.get("total_dyn_mw") not in (None, "") else None
        top = row.get("top", "")
    except Exception:
        return float("nan")

    if None in (n, k, m, clk_ns, p_mw) or m == 0 or k == 0 or n == 0:
        return float("nan")

    rate = k / n
    cycles_per_symbol = 2.0 if top == "rs_decoder_plus_syndrome" else 1.0
    pj = p_mw * clk_ns * cycles_per_symbol / (rate * m)
    return pj


def main(path: Path) -> int:
    # Read CSV
    with path.open(newline="") as f:
        reader = csv.DictReader(f)
        rows = list(reader)
        fieldnames = list(reader.fieldnames or [])

    # Append new column if not present
    new_col = "pj_per_bit"
    if new_col not in fieldnames:
        fieldnames.append(new_col)

    # Compute values
    for r in rows:
        r[new_col] = f"{compute_pj_per_bit(r):.6f}"

    # Write back
    with path.open("w", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(rows)

    return 0


if __name__ == "__main__":
    target = Path(sys.argv[1]) if len(sys.argv) > 1 else Path("data/asap7_sweep_clock_gate/summary.csv")
    sys.exit(main(target))

