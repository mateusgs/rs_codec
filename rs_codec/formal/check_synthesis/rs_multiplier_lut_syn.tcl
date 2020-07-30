clear -all
analyze -vhdl08 -L RS_CONSTANTS ../../rs_common/rs_constants.vhd
analyze -vhdl08 rs_multiplier_lut.vhd
elaborate -vhdl -top rs_multiplier_lut -parameter WORD_LENGTH 3 -parameter MULT_CONSTANT 4
