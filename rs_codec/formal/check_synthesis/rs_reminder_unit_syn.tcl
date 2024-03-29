clear -all
analyze -vhdl08 -L GENERIC_COMPONENTS ../../generic_components/generic_components.vhd
analyze -vhdl08 -L RS_COMPONENTS ../../rs_common/rs_components.vhd
analyze -vhdl08 -L RS_CONSTANTS ../../rs_common/rs_constants.vhd
analyze -vhdl08 rs_remainder_unit.vhd\
                ../../generic_components/d_flop/d_flop.vhd\
                ../../rs_common/rs_multiplier_lut/rs_multiplier_lut.vhd\
                ../../rs_common/rs_multiplier/rs_multiplier.vhd\
                ../../rs_common/rs_adder/rs_adder.vhd
elaborate -vhdl -top rs_remainder_unit -parameter WORD_LENGTH 4 -parameter MULT_CONSTANT 2
check_return {get_signal_info o -width} 4 
