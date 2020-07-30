clear -all
analyze -vhdl08 rs_full_multiplier.vhd
elaborate -vhdl -top rs_full_multiplier -parameter WORD_LENGTH 2
