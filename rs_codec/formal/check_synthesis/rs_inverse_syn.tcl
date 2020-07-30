clear -all
analyze -vhdl08 -L RS_CONSTANTS ../../rs_common/rs_constants.vhd
analyze -vhdl08 rs_inverse.vhd
elaborate -vhdl -top rs_inverse -parameter WORD_LENGTH 4
