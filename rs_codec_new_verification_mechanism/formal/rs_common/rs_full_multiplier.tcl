clear -all
analyze -vhdl08 -L GENERIC_TYPES ../../../generic_components/generic_types.vhd
analyze -vhdl08 -L GENERIC_FUNCTIONS ../../../generic_components/generic_functions.vhd
analyze -vhdl08 -L RS_CONSTANTS ../../rs_common/rs_constants.vhd
analyze -vhdl08 -L RS_TYPES ../../rs_common/rs_types.vhd
analyze -vhdl08 -L RS_FUNCTIONS ../../rs_common/rs_functions.vhd
#analyze -vhdl08 -L GENERIC_COMPONENTS ../../../generic_components/generic_components.vhd
analyze -vhdl08 -L RS_COMPONENTS  ../rs_components.vhd
analyze -vhdl08 ../rs_multiplier/rs_multiplier.vhd
analyze -vhdl08 ../rs_multiplier_lut/rs_multiplier_lut.vhd
analyze -vhdl08 ../rs_inverse/rs_inverse.vhd
analyze -vhdl08 ../rs_full_multiplier/rs_full_multiplier_core.vhd
analyze -vhdl08 ../rs_full_multiplier/rs_full_multiplier.vhd
elaborate -vhdl -top rs_full_multiplier -parameter WORD_LENGTH 4
clock -none
reset -none
prove -all
