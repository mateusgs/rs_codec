#source run_tb.tcl
quit -sim
cd C:/Users/mateu/OneDrive/Documents/msim/msim_decoder
vlib work
vmap work
vcom -2008 C:/Users/mateu/OneDrive/Documents/GitHub/UFMG_digital_design/generic_components/generic_types.vhd
vcom -2008 C:/Users/mateu/OneDrive/Documents/GitHub/UFMG_digital_design/generic_components/generic_functions.vhd
vcom -2008 C:/Users/mateu/OneDrive/Documents/GitHub/UFMG_digital_design/generic_components/async_dff/async_dff.vhd
vcom -2008 C:/Users/mateu/OneDrive/Documents/GitHub/UFMG_digital_design/generic_components/async_dff_gen_rst/async_dff_gen_rst.vhd
vcom -2008 C:/Users/mateu/OneDrive/Documents/GitHub/UFMG_digital_design/generic_components/config_dff_array/config_dff_array.vhd
vcom -2008 C:/Users/mateu/OneDrive/Documents/GitHub/UFMG_digital_design/generic_components/d_sync_flop/d_sync_flop.vhd
vcom -2008 C:/Users/mateu/OneDrive/Documents/GitHub/UFMG_digital_design/generic_components/no_rst_dff/no_rst_dff.vhd
vcom -2008 C:/Users/mateu/OneDrive/Documents/GitHub/UFMG_digital_design/generic_components/sync_dff_gen_rst/sync_dff_gen_rst.vhd
vcom -2008 C:/Users/mateu/OneDrive/Documents/GitHub/UFMG_digital_design/generic_components/async_dff_array/async_dff_array.vhd
vcom -2008 C:/Users/mateu/OneDrive/Documents/GitHub/UFMG_digital_design/generic_components/sync_dff_array/sync_dff_array.vhd
vcom -2008 C:/Users/mateu/OneDrive/Documents/GitHub/UFMG_digital_design/generic_components/fifo_array/reg_fifo_array.vhd
vcom -2008 C:/Users/mateu/OneDrive/Documents/GitHub/UFMG_digital_design/generic_components/fifo/reg_fifo.vhd
vcom -2008 C:/Users/mateu/OneDrive/Documents/GitHub/UFMG_digital_design/generic_components/generic_components.vhd
vcom -2008 C:/Users/mateu/OneDrive/Documents/GitHub/UFMG_digital_design/rs_codec/rs_common/rs_constants.vhd
vcom -2008 C:/Users/mateu/OneDrive/Documents/GitHub/UFMG_digital_design/rs_codec/rs_common/rs_types.vhd
vcom -2008 C:/Users/mateu/OneDrive/Documents/GitHub/UFMG_digital_design/rs_codec/rs_common/rs_functions.vhd
vcom -2008 C:/Users/mateu/OneDrive/Documents/GitHub/UFMG_digital_design/rs_codec/rs_common/rs_components.vhd
vcom -2008 C:/Users/mateu/OneDrive/Documents/GitHub/UFMG_digital_design/rs_codec/rs_common/rs_components.vhd
vcom -2008 C:/Users/mateu/OneDrive/Documents/GitHub/UFMG_digital_design/rs_codec/rs_common/rs_adder/rs_adder.vhd
vcom -2008 C:/Users/mateu/OneDrive/Documents/GitHub/UFMG_digital_design/rs_codec/rs_common/rs_inverse/rs_inverse.vhd
vcom -2008 C:/Users/mateu/OneDrive/Documents/GitHub/UFMG_digital_design/rs_codec/rs_common/rs_multiplier/rs_multiplier.vhd
vcom -2008 C:/Users/mateu/OneDrive/Documents/GitHub/UFMG_digital_design/rs_codec/rs_common/rs_multiplier_lut/rs_multiplier_lut.vhd
vcom -2008 C:/Users/mateu/OneDrive/Documents/GitHub/UFMG_digital_design/rs_codec/rs_common/rs_reduce_adder/rs_reduce_adder.vhd
vcom -2008 C:/Users/mateu/OneDrive/Documents/GitHub/UFMG_digital_design/rs_codec/rs_encoder/rtl/rs_remainder_unit/rs_remainder_unit.vhd
vcom -2008 C:/Users/mateu/OneDrive/Documents/GitHub/UFMG_digital_design/rs_codec/rs_common/rs_full_multiplier/rs_full_multiplier.vhd
vcom -2008 C:/Users/mateu/OneDrive/Documents/GitHub/UFMG_digital_design/rs_codec/rs_common/rs_full_multiplier/rs_full_multiplier_core.vhd
vcom -2008 C:/Users/mateu/OneDrive/Documents/GitHub/UFMG_digital_design/rs_codec/rs_decoder/rtl/rs_syndrome/rs_syndrome_subunit/rs_syndrome_subunit.vhd
vcom -2008 C:/Users/mateu/OneDrive/Documents/GitHub/UFMG_digital_design/rs_codec/rs_decoder/rtl/rs_syndrome/rs_syndrome.vhd
vcom -2008 C:/Users/mateu/OneDrive/Documents/GitHub/UFMG_digital_design/rs_codec/rs_decoder/rtl/rs_berlekamp_massey/rs_berlekamp_massey.vhd
vcom -2008 C:/Users/mateu/OneDrive/Documents/GitHub/UFMG_digital_design/rs_codec/rs_decoder/rtl/rs_chien_forney/rs_chien_forney.vhd
vcom -2008 C:/Users/mateu/OneDrive/Documents/GitHub/UFMG_digital_design/rs_codec/rs_decoder/rtl/rs_chien_forney/rs_chien/rs_chien.vhd
vcom -2008 C:/Users/mateu/OneDrive/Documents/GitHub/UFMG_digital_design/rs_codec/rs_decoder/rtl/rs_chien_forney/rs_forney/rs_forney.vhd
vcom -2008 C:/Users/mateu/OneDrive/Documents/GitHub/UFMG_digital_design/rs_codec/rs_decoder/rtl/rs_decoder.vhd
vcom -2008 C:/Users/mateu/OneDrive/Documents/GitHub/UFMG_digital_design/rs_codec/rs_decoder/sim/tb_rs_decoder.vhd
vsim tb_rs_decoder
log -r *
add wave -radix unsigned -r /*

#add wave -radix unsigned
set NumericStdNoWarnings 1 
run 0 ps
set NumericStdNoWarnings 0 
run 1000 ns
#vcom -2008 C:/Users/mateu/OneDrive/Documents/GitHub/UFMG_digital_design/rs_codec/rs_encoder/rs_encoder.vhd
