clear -all
analyze -vhdl08 -L GENERIC_TYPES ../../../generic_components/generic_types.vhd
analyze -vhdl08 -L GENERIC_FUNCTIONS ../../../generic_components/generic_functions.vhd
analyze -vhdl08 -L RS_CONSTANTS ../../rs_common/rs_constants.vhd
analyze -vhdl08 -L RS_TYPES ../../rs_common/rs_types.vhd
analyze -vhdl08 -L RS_FUNCTIONS ../../rs_common/rs_functions.vhd
analyze -vhdl08 -L RS_COMPONENTS  ../rs_components.vhd
analyze -vhdl08 ../rs_inverse/rs_inverse.vhd
elaborate -vhdl -top rs_inverse -parameter WORD_LENGTH 4
clock -none
reset -none
prove -all
