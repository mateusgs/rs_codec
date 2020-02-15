clear -all
analyze -vhdl08 shifter_left.vhd
#-parameter assign values for generic
elaborate -vhdl -top shifter_left -parameter N 4 -parameter S 1
check_return {get_signal_info o -width} 4
