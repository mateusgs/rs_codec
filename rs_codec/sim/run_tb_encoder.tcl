#source run_tb.tcl
quit -sim
cd C:/Users/mateu/OneDrive/Documents/msim/msim_encoder
vlib work
vmap work
vcom -2008 C:/Users/mateu/OneDrive/Documents/GitHub/UFMG_digital_design/generic_components/async_dff/async_dff.vhd
vcom -2008 C:/Users/mateu/OneDrive/Documents/GitHub/UFMG_digital_design/generic_components/no_rst_dff/no_rst_dff.vhd
vcom -2008 C:/Users/mateu/OneDrive/Documents/GitHub/UFMG_digital_design/generic_components/generic_types.vhd
vcom -2008 C:/Users/mateu/OneDrive/Documents/GitHub/UFMG_digital_design/generic_components/generic_functions.vhd
vcom -2008 C:/Users/mateu/OneDrive/Documents/GitHub/UFMG_digital_design/generic_components/generic_components.vhd

vcom -2008 C:/Users/mateu/OneDrive/Documents/GitHub/UFMG_digital_design/rs_codec/rs_common/rs_constants.vhd
vcom -2008 C:/Users/mateu/OneDrive/Documents/GitHub/UFMG_digital_design/rs_codec/rs_common/rs_types.vhd
vcom -2008 C:/Users/mateu/OneDrive/Documents/GitHub/UFMG_digital_design/rs_codec/rs_common/rs_functions.vhd

vcom -2008 C:/Users/mateu/OneDrive/Documents/GitHub/UFMG_digital_design/rs_codec/rs_common/rs_components.vhd
vcom -2008 C:/Users/mateu/OneDrive/Documents/GitHub/UFMG_digital_design/rs_codec/rs_common/rs_adder/rs_adder.vhd
vcom -2008 C:/Users/mateu/OneDrive/Documents/GitHub/UFMG_digital_design/rs_codec/rs_common/rs_inverse/rs_inverse.vhd
vcom -2008 C:/Users/mateu/OneDrive/Documents/GitHub/UFMG_digital_design/rs_codec/rs_common/rs_multiplier/rs_multiplier.vhd
vcom -2008 C:/Users/mateu/OneDrive/Documents/GitHub/UFMG_digital_design/rs_codec/rs_common/rs_multiplier_lut/rs_multiplier_lut.vhd
vcom -2008 C:/Users/mateu/OneDrive/Documents/GitHub/UFMG_digital_design/rs_codec/rs_encoder/rtl/rs_remainder_unit/rs_remainder_unit.vhd
vcom -2008 C:/Users/mateu/OneDrive/Documents/GitHub/UFMG_digital_design/rs_codec/rs_common/rs_components.vhd
vcom -2008 C:/Users/mateu/OneDrive/Documents/GitHub/UFMG_digital_design/rs_codec/rs_encoder/rtl/rs_encoder.vhd
vcom -2008 C:/Users/mateu/OneDrive/Documents/GitHub/UFMG_digital_design/rs_codec/rs_encoder/sim/tb_rs_encoder.vhd
vsim tb_rs_encoder
log -r *
add wave -radix unsigned -r /*

#add wave -radix unsigned
run 700 ns
#vcom -2008 C:/Users/mateu/OneDrive/Documents/GitHub/UFMG_digital_design/rs_codec/rs_encoder/rs_encoder.vhd
