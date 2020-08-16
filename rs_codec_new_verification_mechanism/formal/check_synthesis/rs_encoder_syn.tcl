clear -all
analyze -vhdl08 -L GENERIC_TYPES ../generic_components/generic_types.vhd
analyze -vhdl08 -L GENERIC_COMPONENTS ../generic_components/generic_components.vhd
analyze -vhdl08 -L GENERIC_FUNCTIONS ../generic_components/generic_functions.vhd
analyze -vhdl08 -L RS_TYPES ../rs_common/rs_types.vhd
analyze -vhdl08 -L RS_FUNCTIONS ../rs_common/rs_functions.vhd
analyze -vhdl08 -L RS_COMPONENTS ../rs_common/rs_components.vhd
analyze -vhdl08 -L RS_CONSTANTS ../rs_common/rs_constants.vhd
analyze -vhdl08 rs_encoder.vhd\
                ../generic_components/d_flop/d_flop.vhd\
                ../rs_common/rs_adder/rs_adder.vhd\
                ../rs_common/rs_multiplier_lut/rs_multiplier_lut.vhd\
                ../rs_common/rs_multiplier/rs_multiplier.vhd\
                ../rs_encoder/rs_remainder_unit/rs_remainder_unit.vhd

elaborate -vhdl -top rs_encoder -parameter N 255 -parameter K 239
get_design_info
