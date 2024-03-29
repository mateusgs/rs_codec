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
