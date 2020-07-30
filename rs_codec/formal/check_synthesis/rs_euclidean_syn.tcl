clear -all
analyze -vhdl08 -L RS_CONSTANTS ../../rs_common/rs_constants.vhd
analyze -vhdl08 -L RS_COMPONENTS ../../rs_common/rs_components.vhd
analyze -vhdl08 -L GENERIC_COMPONENTS ../../generic_components/generic_components.vhd
analyze -vhdl08 rs_euclidean.vhd\
                ../../rs_common/rs_adder/rs_adder.vhd\
                ../../rs_common/rs_inverse/rs_inverse.vhd\
                ../../rs_common/rs_full_multiplier/rs_full_multiplier.vhd\
                ../../rs_common/rs_multiplier/rs_multiplier.vhd\
                ../../rs_common/rs_multiplier_lut/rs_multiplier_lut.vhd\
                ../../generic_components/d_flop/d_flop.vhd\
                ../../generic_components/d_flop_gen_rst/d_flop_gen_rst.vhd
elaborate -vhdl -top rs_euclidean -parameter WORD_LENGTH 4 -parameter T 2
