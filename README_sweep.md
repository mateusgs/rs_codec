RS Codec Synthesis Sweep (Synopsys DC)

Overview
- Runs multi-config synthesis for encoder/decoder/syndrome blocks using Design Compiler.
- Reads `sweep_configs_asap7.txt`, compiles per line, and writes power/area/timing reports.
- GF column is the symbol bit width (e.g., 4 => GF(2^4)=GF16).

Environment Setup (tcsh/csh)
- setenv SNPS "/w/apps3/Synopsys"
- source $SNPS/Design_Complier/vS-2021.06-SP4/SETUP  
- source $SNPS/Library_Compiler/vT-2022.03-SP4/SETUP

Environment Setup (bash/zsh)
- export SNPS="/w/apps3/Synopsys"
- source "$SNPS/Design_Complier/vS-2021.06-SP4/SETUP"
- source "$SNPS/Library_Compiler/vT-2022.03-SP4/SETUP"

Config Files
- ASAP7: `sweep_configs_asap7.txt`
- Nangate45: `sweep_configs_nangate45.txt`
- Format: `N K GF_WIDTH clock_ps [library_dir] [top]`
  - `N`: codeword length (e.g., 15, 31, 63)
  - `K`: info length (e.g., 11, 21, 51)
  - `GF_WIDTH`: symbol bit width (2..10). Example: 4 => GF(2^4)=GF16
  - `clock_ps`: target clock period in picoseconds (e.g., 2000.0)
  - `library_dir`: path containing compiled `.db` libraries
  - `top`: one of `rs_encoder_wrapper`, `rs_syndrome`, `rs_decoder_plus_syndrome` (alias of `rs_decoder`)

Example Lines
- 15 11 4 2000.0 /w/ee.00/puneet/aaronyen/asap7/asap7sc7p5t_28/LIB/CCS/TT rs_encoder_wrapper
- 15 11 4 2000.0 /w/ee.00/puneet/aaronyen/asap7/asap7sc7p5t_28/LIB/CCS/TT rs_syndrome
- 15 11 4 2000.0 /w/ee.00/puneet/aaronyen/asap7/asap7sc7p5t_28/LIB/CCS/TT rs_decoder_plus_syndrome

Run the Sweep
- ASAP7:
  - dc_shell -f scripts/run_sweep_asap7.tcl \
      -x "set CONFIG_FILE sweep_configs_asap7.txt" \
      -x "set OUT_ROOT data/asap7_sweep"
- Nangate45 (convenience wrapper):
  - dc_shell -f scripts/run_nangate45.tcl
- Parallel workers:
  - python3 scripts/run_sweep_parallel.py \
      --config sweep_configs_asap7.txt \
      --out-root data/asap7_sweep \
      --num-workers 4
  - The helper script reads the requested configuration file, removes comments
    and blank lines, and then distributes the remaining entries to each worker
    in a round-robin order. Worker 0 gets the 1st, (n+1)th, (2n+1)th, … entry,
    worker 1 gets the 2nd, (n+2)th, … entry, and so on, where ``n`` is
    ``--num-workers`` (clamped to the number of runnable configurations). Each
    worker runs ``dc_shell`` with its assigned subset and writes a temporary
    ``summary.workerX.csv``. When all workers finish, the script merges those
    summaries into ``summary.csv`` under ``--out-root``.

Outputs
- Per-run directory: `data/asap7_sweep/Nxx_Kyy_GF<W>_TT2Tnnn_CLKm.nns_<corner>_<top>/`
  - `generated/`: run-specific `generic_types.vhd` and wrapper (if used)
  - `.WORK/`: DC work library
  - `reports/`: `*_qor.rep`, `*_timing.rep`, `*_power.rep`, `*_area.rep`, `*_clock.rep`, `*_pathgroup.rep`
  - Netlist and constraints: `<top>.netlist.v`, `<top>.sdc`, `<top>.compile.ddc`
 - Summary CSV: `<OUT_ROOT>/summary.csv`
   - Columns: `label,top,N,K,GF_WIDTH,CLK_NS,area,wns,total_dyn_mw`

Blocks Supported
- `rs_encoder_wrapper`: encoder + syndrome unit wrapper; generics `N`, `K`, `RS_GF` set from config.
- `rs_syndrome`: requires `WORD_LENGTH` (= GF_WIDTH), `TWO_TIMES_T` (= N-K); the sweep script derives these.
- `rs_decoder_plus_syndrome`: alias of `rs_decoder` (decoder integrates syndrome internally).

Library Notes
- The script loads only compiled `.db` files in the supplied `library_dir` into `link_library` and `target_library` (it intentionally ignores `.lib`).
- ASAP7: point to a corner directory (e.g., `.../LIB/CCS/TT`).
- Nangate45: point to `.../NanGate45/db`.

Power Modeling Assumptions
- Random data on `i_symbol*` inputs: static_probability=0.5, toggle_rate=0.5/period (per ns).
- Standard clock; reset held inactive.
- Control/handshake inputs held steady: `i_valid*`/`i_consume*` high; `i_start_codeword*`, `i_end_codeword*`, FIFO-full flags low.
- Power is reported with `-analysis_effort medium`.

Troubleshooting
- `dc_shell: command not found`: source the DC setup — see Environment Setup (optional step).
- `Library dir not found` or `No .db found`: verify `library_dir` in config or set `DEFAULT_LIB_DIR` via `-x`.
- `Elaborate failed for top ...`: ensure `top` is one of the supported names; `rs_decoder_plus_syndrome` maps to `rs_decoder`.
- `Can't find port 'clk'/'rst'`: your top must expose `clk`/`rst`. All supported tops do.

One-off Quick Test
- Create a minimal config file (e.g., `sweep_one.txt`):
  - 15 11 4 2000.0 /w/ee.00/puneet/aaronyen/asap7/asap7sc7p5t_28/LIB/CCS/TT rs_encoder_wrapper
- Run:
  - dc_shell -f scripts/run_sweep_asap7.tcl \
      -x "set CONFIG_FILE sweep_one.txt" \
      -x "set OUT_ROOT data/asap7_sweep_test"
