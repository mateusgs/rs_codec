clear -all
analyze -vhdl08 -L RS_CONSTANTS ../../rs_common/rs_constants.vhd
analyze -vhdl08 rs_multiplier.vhd ../rs_multiplier_lut/rs_multiplier_lut.vhd
elaborate -vhdl -top rs_multiplier -parameter WORD_LENGTH 4 -parameter MULT_CONSTANT 4
check_return {get_signal_info o -width} 4
