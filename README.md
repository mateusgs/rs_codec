# rs_codec

**If you're already using this repo, see this patch: https://github.com/mateusgs/rs_codec/commit/4ca278ca88efe6b2975cf8431e16ef8106898bb4**

This project comprises the RTL developement of a paramerizable RS Codec. It provides both RS encoder and decoder, and the following parameters that be adjusted in their instantiation.

N - Length of the codeword (message) -  Range -> 2 to 1023
K - Number of message symbols - Range -> 1 to N-2
m (RS_GF) - Galois Field(GF)  order - Range -> 2 to 10

If you do not understand the concepts of RS codec there is a plenty of references for learning it. I recommend the following:

- Clarke, C.K.P.: 'Reed-Solomon Error Correction', BBC R\&D White Paper, WHP, 31, 2002
- Geisel, W.A: 'Tutorial on Reed-Solomon Error Correction Coding'. Technical Memorandum 102162, NASA, 1990
- Wicker, S.B., Bhargava, V.K.: 'An Introduction to Reed-Solomon Codes', in Wicker, S.B. (Ed.): 'Reed-Solomon Codes and Their Applications' (Wiley-IEEE Press, 1994, 1st edn.), pp. 1-16

Top level ports:

I - Input
O - Ouput

clk - I - System clock pin \
rst - I - System reset pin \
i_start_cw - I - Delimiter of input codeword start \
i_end_cw - I - Delimiter of input codeword end \
i_valid - I - Validity of input symbols \ 
i_consume - I - Consumes output of the codec \
i_symbol - I - Input data symbol \
o_start_cw - O - Delimiter of output codeword starting \
o_end_cw - O - Delimiter of output codeword ending \
o_in_ready - O - Readiness to accept new input symbols \
o_valid - O - Validity of output symbols \
o_error - O - Error indicator \
o_symbol - O - Output data symbol


The top level .vhd files are: rs_decoder.vhd and rs_encoder.vhd

If you look the directory structure, inside the projects (rs_decoder and rs_encoder) there are four folders:

rtl - VHDL implementation of the IP \
sim - RTL simlulation scripts using Mentor ModelSim Student Edition \
formal - Scripts for formal verification using Cadence JasperGold Apps \
syn - Script for synthesis in FPGA using Quartus Prime Lite Edition 

There is a paper that explain all nuances of this project:
https://ietresearch.onlinelibrary.wiley.com/doi/10.1049/cdt2.12009

This project started at Universidade Federal de Minas Gerais (UFMG), and it is open for the community under the license "MIT".
Contact matgonsil@gmail.com (Mateus Silva) for any questions.

Synthesis Sweeps (Design Compiler)
- Multi-config synthesis sweep scripts and configs are included to evaluate area/timing/power across RS blocks.
- See `README_sweep_asap7.md` for details. It covers ASAP7 (via `config/sweep_configs_asap7.txt`) and Nangate45 (via `config/sweep_configs_nangate45.txt`),
  along with a Python helper that can split configuration files across multiple Design Compiler workers.
- Outputs per run include standard reports and a summary CSV with columns:
  - `label,top,N,K,GF_WIDTH,CLK_NS,area,wns,total_dyn_mw`.

**Plots: Energy/Rate vs Input BER**
- Script: `scripts/plot_rs_codec_vs_ber.py`
- Inputs:
  - RS-FEC selection: `rsfec_selection_m8_halfdec.csv` (from `scripts/rsfec_select_and_cfg.py`)
  - Synthesis summary: `data/asap7_sweep_512/summary.csv`
- Run:
  - `python scripts/plot_rs_codec_vs_ber.py --selection rsfec_selection_m8_halfdec.csv --summary data/asap7_sweep_512/summary.csv`
  - With decoder clock gating (syndrome-only for clean words):
    - `python scripts/plot_rs_codec_vs_ber.py --selection rsfec_selection_m8_halfdec.csv --summary data/asap7_sweep_512/summary.csv --gated --syndrome-cycles-per-symbol 1 --decoder-cycles-per-symbol 2`
- Outputs (under `plots/`):
  - Figures (PNG + PDF): `rscodec_pj_per_bit_vs_input_BER.*`, `rscodec_rate_vs_input_BER.*`
  - Raw data (CSV): `rscodec_pj_per_bit_vs_input_BER.csv`, `rscodec_rate_vs_input_BER.csv`
  - Total pJ/bit (default): encoder energy + expected decoder energy per bit.
    - Encoder: computed from `rs_encoder_wrapper` dynamic power and its cycles/symbol (default 1.0).
    - Decoder (gated): `E_rx = E_syndrome + P_correctable × (E_decoder − E_syndrome)` with
      `P_correctable = Σ_{i=1..t} Binom(n,i) p_s^i (1−p_s)^(n−i)`, `p_s = 1 − (1−p_b)^m`.
      Cycles/symbol: syndrome default 1.0, decoder default 2.0 (half-decoder).
    - Throughput used: `rate × m × f_clk / cycles_per_symbol` per block.
  - Legends are formatted as exact targets (`1e-12`, `1e-15`, `1e-30`).
