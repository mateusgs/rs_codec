clear -all
analyze -vhdl rs_adder.vhd
elaborate -vhdl -top rs_adder -parameter WORD_LENGTH 3
check_return {get_signal_info o -width} 4
