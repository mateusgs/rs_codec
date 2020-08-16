clear -all
analyze -vhdl rs_adder.vhd
elaborate -vhdl -top rs_adder -parameter WORD_LENGTH 4
reset -none
clock -none
prove -all
