# Copyright (C) 2018  Intel Corporation. All rights reserved.
# Your use of Intel Corporation's design tools, logic functions 
# and other software and tools, and its AMPP partner logic 
# functions, and any output files from any of the foregoing 
# (including device programming or simulation files), and any 
# associated documentation or information are expressly subject 
# to the terms and conditions of the Intel Program License 
# Subscription Agreement, the Intel Quartus Prime License Agreement,
# the Intel FPGA IP License Agreement, or other applicable license
# agreement, including, without limitation, that your use is for
# the sole purpose of programming logic devices manufactured by
# Intel and sold by Intel or its authorized distributors.  Please
# refer to the applicable agreement for further details.

# Quartus Prime: Generate Tcl File for Project
# File: rs_decoder_final.tcl
# Generated on: Fri Nov 08 00:16:29 2019

# Load Quartus Prime Tcl Project package
package require ::quartus::project

set need_to_close_project 0
set make_assignments 1

cd ..
cd ..
cd ..
cd ..
if {![file isdirectory rs_decoder]} {
	file mkdir rs_decoder
}

cd rs_decoder
# Check that the right project is open
if {[is_project_open]} {
	if {[string compare $quartus(project) "rs_decoder"]} {
		puts "Project rs_decoder is not open"
		set make_assignments 0
	}
} else {
	# Only open if not already open
	if {[project_exists rs_decoder]} {
		project_open -revision rs_decoder rs_decoder
	} else {
		project_new -revision rs_decoder rs_decoder
	}
	set need_to_close_project 1
}

# Make assignments
if {$make_assignments} {
	set_global_assignment -name FAMILY "Cyclone IV E"
	set_global_assignment -name DEVICE EP4CE6E22C6
	set_global_assignment -name ORIGINAL_QUARTUS_VERSION 18.1.0
	set_global_assignment -name PROJECT_CREATION_TIME_DATE "20:41:18  NOVEMBER 06, 2019"
	set_global_assignment -name LAST_QUARTUS_VERSION "18.1.0 Lite Edition"
	set_global_assignment -name VHDL_FILE ../UFMG_digital_design/generic_components/rtl/generic_types.vhd
	set_global_assignment -name VHDL_FILE ../UFMG_digital_design/generic_components/rtl/generic_components.vhd
	set_global_assignment -name VHDL_FILE ../UFMG_digital_design/generic_components/rtl/generic_functions.vhd
	set_global_assignment -name VHDL_FILE ../UFMG_digital_design/rs_codec/rtl/rs_types.vhd
	set_global_assignment -name VHDL_FILE ../UFMG_digital_design/rs_codec/rtl/rs_constants.vhd
	set_global_assignment -name VHDL_FILE ../UFMG_digital_design/rs_codec/rtl/rs_functions.vhd
	set_global_assignment -name VHDL_FILE ../UFMG_digital_design/rs_codec/rtl/rs_components.vhd
	set_global_assignment -name VHDL_FILE ../UFMG_digital_design/rs_codec/rtl/rs_decoder.vhd
	set_global_assignment -name VHDL_FILE ../UFMG_digital_design/generic_components/rtl/async_dff.vhd
	set_global_assignment -name VHDL_FILE ../UFMG_digital_design/generic_components/rtl/d_sync_flop.vhd
	set_global_assignment -name VHDL_FILE ../UFMG_digital_design/generic_components/rtl/no_rst_dff.vhd
	set_global_assignment -name VHDL_FILE ../UFMG_digital_design/generic_components/rtl/config_dff_array.vhd
	set_global_assignment -name VHDL_FILE ../UFMG_digital_design/generic_components/rtl/sync_dff_array.vhd
	set_global_assignment -name VHDL_FILE ../UFMG_digital_design/generic_components/rtl/reg_fifo_array.vhd
	set_global_assignment -name VHDL_FILE ../UFMG_digital_design/generic_components/rtl/reg_fifo.vhd
	set_global_assignment -name VHDL_FILE ../UFMG_digital_design/rs_codec/rtl/rs_adder.vhd
	set_global_assignment -name VHDL_FILE ../UFMG_digital_design/rs_codec/rtl/rs_multiplier_lut.vhd
	set_global_assignment -name VHDL_FILE ../UFMG_digital_design/rs_codec/rtl/rs_multiplier.vhd
	set_global_assignment -name VHDL_FILE ../UFMG_digital_design/rs_codec/rtl/rs_inverse.vhd
	set_global_assignment -name VHDL_FILE ../UFMG_digital_design/rs_codec/rtl/rs_full_multiplier.vhd
	set_global_assignment -name VHDL_FILE ../UFMG_digital_design/rs_codec/rtl/rs_full_multiplier_core.vhd
	set_global_assignment -name VHDL_FILE ../UFMG_digital_design/rs_codec/rtl/rs_reduce_adder.vhd
	set_global_assignment -name VHDL_FILE ../UFMG_digital_design/rs_codec/rtl/rs_syndrome_subunit.vhd
	set_global_assignment -name VHDL_FILE ../UFMG_digital_design/rs_codec/rtl/rs_syndrome.vhd
	set_global_assignment -name VHDL_FILE ../UFMG_digital_design/rs_codec/rtl/rs_berlekamp_massey.vhd
	set_global_assignment -name VHDL_FILE ../UFMG_digital_design/rs_codec/rtl/rs_chien.vhd
	set_global_assignment -name VHDL_FILE ../UFMG_digital_design/rs_codec/rtl/rs_forney.vhd
	set_global_assignment -name VHDL_FILE ../UFMG_digital_design/rs_codec/rtl/rs_chien_forney.vhd
	set_global_assignment -name PROJECT_OUTPUT_DIRECTORY output_files
	set_global_assignment -name VHDL_INPUT_VERSION VHDL_2008
	set_global_assignment -name VHDL_SHOW_LMF_MAPPING_MESSAGES OFF
	set_global_assignment -name PARTITION_NETLIST_TYPE SOURCE -section_id Top
	set_global_assignment -name PARTITION_FITTER_PRESERVATION_LEVEL PLACEMENT_AND_ROUTING -section_id Top
	set_global_assignment -name PARTITION_COLOR 16764057 -section_id Top
	set_instance_assignment -name PARTITION_HIERARCHY root_partition -to | -section_id Top

	#custom script start
	source ../UFMG_digital_design/scripts/syn/run_syn.tcl
	run_syn rs_decoder [pwd] ../UFMG_digital_design/scripts/syn ../UFMG_digital_design/rs_codec/syn/rs_decoder
	#custom script end

	# Close project
	if {$need_to_close_project} {
		project_close
	}
}
#cd C:/Users/mateu/OneDrive/Documents/GitHub/UFMG_DIGITAL_DESIGN/rs_codec/rs_decoder/syn