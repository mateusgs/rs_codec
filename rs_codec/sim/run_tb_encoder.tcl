#source run_tb.tcl
quit -sim
#cd C:/Users/mateu/OneDrive/Documents/msim/msim_encoder
cd C:/Users/mateu/OneDrive/Documents/GitHub/UFMG_digital_design/rs_codec/sim
vlib work
vmap work
vcom -2008 C:/Users/mateu/OneDrive/Documents/GitHub/UFMG_digital_design/generic_components/rtl/async_dff.vhd
vcom -2008 C:/Users/mateu/OneDrive/Documents/GitHub/UFMG_digital_design/generic_components/rtl/no_rst_dff.vhd
vcom -2008 C:/Users/mateu/OneDrive/Documents/GitHub/UFMG_digital_design/generic_components/rtl/generic_types.vhd
vcom -2008 C:/Users/mateu/OneDrive/Documents/GitHub/UFMG_digital_design/generic_components/rtl/generic_functions.vhd
vcom -2008 C:/Users/mateu/OneDrive/Documents/GitHub/UFMG_digital_design/generic_components/rtl/generic_components.vhd

vcom -2008 C:/Users/mateu/OneDrive/Documents/GitHub/UFMG_digital_design/rs_codec/rtl/rs_constants.vhd
vcom -2008 C:/Users/mateu/OneDrive/Documents/GitHub/UFMG_digital_design/rs_codec/rtl/rs_types.vhd
vcom -2008 C:/Users/mateu/OneDrive/Documents/GitHub/UFMG_digital_design/rs_codec/rtl/rs_functions.vhd

vcom -2008 C:/Users/mateu/OneDrive/Documents/GitHub/UFMG_digital_design/rs_codec/rtl/rs_components.vhd
vcom -2008 C:/Users/mateu/OneDrive/Documents/GitHub/UFMG_digital_design/rs_codec/rtl/rs_adder.vhd
vcom -2008 C:/Users/mateu/OneDrive/Documents/GitHub/UFMG_digital_design/rs_codec/rtl/rs_inverse.vhd
vcom -2008 C:/Users/mateu/OneDrive/Documents/GitHub/UFMG_digital_design/rs_codec/rtl/rs_multiplier.vhd
vcom -2008 C:/Users/mateu/OneDrive/Documents/GitHub/UFMG_digital_design/rs_codec/rtl/rs_multiplier_lut.vhd
vcom -2008 C:/Users/mateu/OneDrive/Documents/GitHub/UFMG_digital_design/rs_codec/rtl/rs_remainder_unit.vhd
vcom -2008 C:/Users/mateu/OneDrive/Documents/GitHub/UFMG_digital_design/rs_codec/rtl/rs_components.vhd
vcom -2008 C:/Users/mateu/OneDrive/Documents/GitHub/UFMG_digital_design/rs_codec/rtl/rs_encoder.vhd
vcom -2008 C:/Users/mateu/OneDrive/Documents/GitHub/UFMG_digital_design/rs_codec/sim/tb_rs_encoder.vhd
vsim tb_rs_encoder
log -r *
add wave -radix unsigned -r /*

#add wave -radix unsigned
run 700 ns
#vcom -2008 C:/Users/mateu/OneDrive/Documents/GitHub/UFMG_digital_design/rs_codec/rs_encoder/rs_encoder.vhd
