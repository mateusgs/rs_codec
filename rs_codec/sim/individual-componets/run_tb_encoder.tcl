#source run_tb.tcl
quit -sim
set script_dir [file normalize [file dirname [info script]]]
set repo_root [file normalize [file join $script_dir ../../..]]
set generic_rtl [file join $repo_root generic_components rtl]
set rs_rtl [file join $repo_root rs_codec rtl]

cd $script_dir
vlib work
vmap work

foreach file [list \
    [file join $generic_rtl async_dff.vhd] \
    [file join $generic_rtl no_rst_dff.vhd] \
    [file join $generic_rtl generic_types.vhd] \
    [file join $generic_rtl generic_functions.vhd] \
    [file join $generic_rtl generic_components.vhd] \
    [file join $rs_rtl rs_constants.vhd] \
    [file join $rs_rtl rs_types.vhd] \
    [file join $rs_rtl rs_functions.vhd] \
    [file join $rs_rtl rs_components.vhd] \
    [file join $rs_rtl rs_adder.vhd] \
    [file join $rs_rtl rs_inverse.vhd] \
    [file join $rs_rtl rs_multiplier.vhd] \
    [file join $rs_rtl rs_multiplier_lut.vhd] \
    [file join $rs_rtl rs_remainder_unit.vhd] \
    [file join $rs_rtl rs_encoder.vhd] \
    [file join $script_dir tb_rs_encoder.vhd] \
] {
    vcom -2008 $file
}
vsim tb_rs_encoder
log -r *
add wave -radix unsigned -r /*

#add wave -radix unsigned
run 700 ns
