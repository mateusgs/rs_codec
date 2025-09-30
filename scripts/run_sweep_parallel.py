#!/usr/bin/env python3
"""Run Design Compiler sweep configurations in parallel.

This helper script partitions a sweep configuration file and spawns multiple
Design Compiler (`dc_shell`) processes, each running ``run_sweep.tcl`` with a
subset of the configurations. A per-worker summary CSV is produced and merged
into the canonical ``summary.csv`` once all workers complete.

Example usage::

    python3 scripts/run_sweep_parallel.py \
        --config sweep_configs_asap7.txt \
        --out-root data/asap7_sweep \
        --num-workers 4

Additional ``dc_shell`` ``-x"set ..."`` options can be supplied via
``--define`` or ``--dc-arg``.
"""

import argparse
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path
from typing import Iterable, List, Sequence


def parse_args(argv: Sequence[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--config",
        required=True,
        type=Path,
        help="Path to the sweep configuration file (same format as run_sweep.tcl)",
    )
    parser.add_argument(
        "--out-root",
        required=True,
        type=Path,
        help="Output root directory passed to run_sweep.tcl",
    )
    parser.add_argument(
        "--num-workers",
        type=int,
        default=1,
        help="Number of dc_shell worker processes to spawn",
    )
    parser.add_argument(
        "--run-script",
        type=Path,
        default=Path("scripts/run_sweep.tcl"),
        help="Tcl script executed by dc_shell (defaults to scripts/run_sweep.tcl)",
    )
    parser.add_argument(
        "--dc-bin",
        default="dc_shell",
        help="Design Compiler binary to execute (default: dc_shell)",
    )
    parser.add_argument(
        "--define",
        action="append",
        default=[],
        metavar="NAME=VALUE",
        help="Additional run_sweep.tcl variables to define via -x 'set NAME VALUE'",
    )
    parser.add_argument(
        "--dc-arg",
        action="append",
        default=[],
        help="Extra arguments forwarded verbatim to dc_shell",
    )
    parser.add_argument(
        "--keep-temporary",
        action="store_true",
        help="Do not delete worker temporary configuration directories",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Print worker commands without launching dc_shell",
    )
    return parser.parse_args(argv)


def iter_config_lines(path: Path) -> List[str]:
    """Return runnable lines from a sweep configuration file.

    Mirrors the parsing in run_sweep.tcl: removes comments and blank lines,
    requiring at least four whitespace-separated tokens per entry.
    """

    lines: List[str] = []
    with path.open() as fin:
        for raw in fin:
            stripped = raw.split("#", 1)[0].strip()
            if not stripped:
                continue
            if len(stripped.split()) < 4:
                continue
            lines.append(stripped)
    return lines


def chunk_round_robin(items: Sequence[str], n: int) -> List[List[str]]:
    buckets: List[List[str]] = [[] for _ in range(n)]
    for idx, item in enumerate(items):
        buckets[idx % n].append(item)
    return buckets


def build_dc_command(
    args: argparse.Namespace,
    config_path: Path,
    summary_path: Path,
) -> List[str]:
    """Build dc_shell command with -x assignments BEFORE -f script.

    Some dc_shell versions process -f eagerly; ensure variables are set first
    so run_sweep.tcl picks up CONFIG_FILE/OUT_ROOT/SUMMARY_FILE overrides.
    """
    cmd: List[str] = [args.dc_bin]

    # Define variables first
    cmd.extend(["-x", f"set CONFIG_FILE {config_path}"])
    cmd.extend(["-x", f"set OUT_ROOT {args.out_root}"])
    cmd.extend(["-x", f"set SUMMARY_FILE {summary_path}"])

    for definition in args.define:
        if "=" not in definition:
            raise ValueError(f"Invalid --define '{definition}'. Expected NAME=VALUE")
        name, value = definition.split("=", 1)
        name = name.strip()
        value = value.strip()
        if not name:
            raise ValueError(f"Invalid --define '{definition}'. NAME must be non-empty")
        cmd.extend(["-x", f"set {name} {value}"])

    # Then source the main sweep script
    cmd.extend(["-f", str(args.run_script)])

    # Additional dc options last
    if args.dc_arg:
        cmd.extend(args.dc_arg)

    return cmd


def merge_summaries(summary_files: Iterable[Path], dest: Path) -> None:
    header_written = False
    with dest.open("w") as fout:
        for summary in summary_files:
            if not summary.exists():
                continue
            with summary.open() as fin:
                for line_no, line in enumerate(fin):
                    if line_no == 0:
                        if header_written:
                            continue
                        header_written = True
                    fout.write(line)


def ensure_dir(path: Path) -> None:
    path.mkdir(parents=True, exist_ok=True)


def main(argv: Sequence[str]) -> int:
    args = parse_args(argv)

    if args.num_workers < 1:
        print("ERROR: --num-workers must be at least 1", file=sys.stderr)
        return 1

    if not args.config.is_file():
        print(f"ERROR: Config file not found: {args.config}", file=sys.stderr)
        return 1

    if not args.run_script.is_file():
        print(f"ERROR: run_sweep script not found: {args.run_script}", file=sys.stderr)
        return 1

    configs = iter_config_lines(args.config)
    if not configs:
        print(f"ERROR: No runnable configurations found in {args.config}", file=sys.stderr)
        return 1

    num_workers = min(args.num_workers, len(configs))
    ensure_dir(args.out_root)

    partitions = chunk_round_robin(configs, num_workers)

    worker_dirs: List[Path] = []
    worker_summaries: List[Path] = []
    worker_cmds: List[List[str]] = []

    for worker_idx, entries in enumerate(partitions):
        if not entries:
            continue
        tmp_dir = Path(tempfile.mkdtemp(prefix=f"sweep_worker_{worker_idx}_"))
        worker_dirs.append(tmp_dir)
        cfg_path = tmp_dir / "config.txt"
        cfg_path.write_text("\n".join(entries) + "\n")

        summary_path = args.out_root / f"summary.worker{worker_idx}.csv"
        worker_summaries.append(summary_path)

        cmd = build_dc_command(args, cfg_path.resolve(), summary_path.resolve())
        worker_cmds.append(cmd)

    # Python 3.6 compatibility: avoid subscripting subprocess.Popen in annotations
    procs = []  # type: List[subprocess.Popen]
    log_files = []
    try:
        for idx, cmd in enumerate(worker_cmds):
            log_path = args.out_root / f"worker_{idx}.log"
            log_file = None
            if not args.dry_run:
                log_file = log_path.open("w")
            printable_cmd = " ".join(cmd)
            print(f"[worker {idx}] Launching: {printable_cmd}")
            if args.dry_run:
                continue
            proc = subprocess.Popen(cmd, stdout=log_file, stderr=subprocess.STDOUT, text=True)
            procs.append(proc)
            log_files.append(log_file)
        if args.dry_run:
            return 0

        exit_code = 0
        for idx, proc in enumerate(procs):
            rc = proc.wait()
            if rc != 0:
                print(f"ERROR: Worker {idx} exited with code {rc}", file=sys.stderr)
                exit_code = rc if exit_code == 0 else exit_code

        if exit_code != 0:
            return exit_code

        merged_summary = args.out_root / "summary.csv"
        merge_summaries(worker_summaries, merged_summary)
        print(f"INFO: Merged summary written to {merged_summary}")

        for summary in worker_summaries:
            if summary.exists():
                summary.unlink()

        return 0
    finally:
        for handle in log_files:
            if handle is not None and not handle.closed:
                handle.close()
        if not args.keep_temporary:
            for tmp in worker_dirs:
                shutil.rmtree(tmp, ignore_errors=True)


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
