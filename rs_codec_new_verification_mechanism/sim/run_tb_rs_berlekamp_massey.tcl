#source run_tb.tcl
quit -sim
cd C:/Users/mateu/OneDrive/Documents/msim/msim_bm
vlib work
vmap work
vcom -2008 C:/Users/mateu/OneDrive/Documents/GitHub/UFMG_digital_design/rs_codec/generic_components/generic_types.vhd
vcom -2008 C:/Users/mateu/OneDrive/Documents/GitHub/UFMG_digital_design/rs_codec/generic_components/generic_components.vhd
vcom -2008 C:/Users/mateu/OneDrive/Documents/GitHub/UFMG_digital_design/rs_codec/generic_components/generic_functions.vhd
vcom -2008 C:/Users/mateu/OneDrive/Documents/GitHub/UFMG_digital_design/rs_codec/generic_components/config_dff_array/config_dff_array.vhd
vcom -2008 C:/Users/mateu/OneDrive/Documents/GitHub/UFMG_digital_design/rs_codec/generic_components/d_sync_flop/d_sync_flop.vhd
vcom -2008 C:/Users/mateu/OneDrive/Documents/GitHub/UFMG_digital_design/rs_codec/generic_components/sync_dff_gen_rst/sync_dff_gen_rst.vhd
vcom -2008 C:/Users/mateu/OneDrive/Documents/GitHub/UFMG_digital_design/rs_codec/generic_components/sync_dff_array/sync_dff_array.vhd
vcom -2008 C:/Users/mateu/OneDrive/Documents/GitHub/UFMG_digital_design/rs_codec/rs_common/rs_types.vhd
vcom -2008 C:/Users/mateu/OneDrive/Documents/GitHub/UFMG_digital_design/rs_codec/rs_common/rs_functions.vhd
vcom -2008 C:/Users/mateu/OneDrive/Documents/GitHub/UFMG_digital_design/rs_codec/rs_common/rs_constants.vhd
vcom -2008 C:/Users/mateu/OneDrive/Documents/GitHub/UFMG_digital_design/rs_codec/rs_common/rs_components.vhd
vcom -2008 C:/Users/mateu/OneDrive/Documents/GitHub/UFMG_digital_design/rs_codec/rs_common/rs_full_multiplier/rs_full_multiplier.vhd
vcom -2008 C:/Users/mateu/OneDrive/Documents/GitHub/UFMG_digital_design/rs_codec/rs_common/rs_reduce_adder/rs_reduce_adder.vhd
vcom -2008 C:/Users/mateu/OneDrive/Documents/GitHub/UFMG_digital_design/rs_codec/rs_common/rs_inverse/rs_inverse.vhd
vcom -2008 C:/Users/mateu/OneDrive/Documents/GitHub/UFMG_digital_design/rs_codec/rs_common/rs_adder/rs_adder.vhd
vcom -2008 C:/Users/mateu/OneDrive/Documents/GitHub/UFMG_digital_design/rs_codec/rs_decoder/rtl/rs_berlekamp_massey/rs_berlekamp_massey.vhd
vcom -2008 C:/Users/mateu/OneDrive/Documents/GitHub/UFMG_digital_design/rs_codec/rs_decoder/rtl/rs_berlekamp_massey/tb_rs_berlekamp_massey.vhd

vsim tb_rs_berlekamp_massey
log -r *
add wave -radix unsigned -r /*

#add wave -radix unsigned
run 700 ns
#vcom -2008 C:/Users/mateu/OneDrive/Documents/GitHub/UFMG_digital_design/rs_codec/rs_encoder/rs_encoder.vhd
