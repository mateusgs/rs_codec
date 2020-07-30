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
# File: rs_decoder.tcl
# Generated on: Sun Feb 02 16:38:25 2020

# Load Quartus Prime Tcl Project package
package require ::quartus::project

set need_to_close_project 0
set make_assignments 1

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
	set_global_assignment -name PROJECT_CREATION_TIME_DATE "16:37:54  FEBRUARY 02, 2020"
	set_global_assignment -name LAST_QUARTUS_VERSION "18.1.0 Lite Edition"
	set_global_assignment -name VHDL_FILE ../rtl/rs_syndrome/rs_syndrome_subunit/rs_syndrome_subunit.vhd
	set_global_assignment -name VHDL_FILE ../rtl/rs_syndrome/rs_syndrome.vhd
	set_global_assignment -name VHDL_FILE ../rtl/rs_chien_forney/rs_chien/rs_chien.vhd
	set_global_assignment -name VHDL_FILE ../rtl/rs_chien_forney/rs_forney/rs_forney.vhd
	set_global_assignment -name VHDL_FILE ../rtl/rs_chien_forney/rs_chien_forney.vhd
	set_global_assignment -name VHDL_FILE ../rtl/rs_berlekamp_massey/rs_berlekamp_massey.vhd
	set_global_assignment -name VHDL_FILE ../../rs_common/rs_reduce_adder/rs_reduce_adder.vhd
	set_global_assignment -name VHDL_FILE ../../rs_common/rs_multiplier_lut/rs_multiplier_lut.vhd
	set_global_assignment -name VHDL_FILE ../../rs_common/rs_multiplier/rs_multiplier.vhd
	set_global_assignment -name VHDL_FILE ../../rs_common/rs_inverse/rs_inverse.vhd
	set_global_assignment -name VHDL_FILE ../../rs_common/rs_full_multiplier/rs_full_multiplier_core.vhd
	set_global_assignment -name VHDL_FILE ../../rs_common/rs_full_multiplier/rs_full_multiplier.vhd
	set_global_assignment -name VHDL_FILE ../../rs_common/rs_adder/rs_adder.vhd
	set_global_assignment -name VHDL_FILE ../../../generic_components/fifo_array/reg_fifo_array.vhd
	set_global_assignment -name VHDL_FILE ../../../generic_components/fifo/reg_fifo.vhd
	set_global_assignment -name VHDL_FILE ../../../generic_components/sync_dff_array/sync_dff_array.vhd
	set_global_assignment -name VHDL_FILE ../../../generic_components/config_dff_array/config_dff_array.vhd
	set_global_assignment -name VHDL_FILE ../../../generic_components/no_rst_dff/no_rst_dff.vhd
	set_global_assignment -name VHDL_FILE ../../../generic_components/d_sync_flop/d_sync_flop.vhd
	set_global_assignment -name VHDL_FILE ../../../generic_components/async_dff/async_dff.vhd
	set_global_assignment -name VHDL_FILE ../rtl/rs_decoder.vhd
	set_global_assignment -name VHDL_FILE ../../rs_common/rs_types.vhd
	set_global_assignment -name VHDL_FILE ../../rs_common/rs_functions.vhd
	set_global_assignment -name VHDL_FILE ../../rs_common/rs_constants.vhd
	set_global_assignment -name VHDL_FILE ../../rs_common/rs_components.vhd
	set_global_assignment -name VHDL_FILE ../../../generic_components/generic_types.vhd
	set_global_assignment -name VHDL_FILE ../../../generic_components/generic_functions.vhd
	set_global_assignment -name VHDL_FILE ../../../generic_components/generic_components.vhd
	set_global_assignment -name PROJECT_OUTPUT_DIRECTORY output_files
	set_global_assignment -name MIN_CORE_JUNCTION_TEMP 0
	set_global_assignment -name MAX_CORE_JUNCTION_TEMP 85
	set_global_assignment -name ERROR_CHECK_FREQUENCY_DIVISOR 1
	set_global_assignment -name NOMINAL_CORE_SUPPLY_VOLTAGE 1.2V

	# Commit assignments
	export_assignments

	#custom script start
	source ../../../scripts/syn/run_syn.tcl
	run_syn rs_decoder [pwd] ../../../scripts/syn
	#custom script end

	# Close project
	if {$need_to_close_project} {
		project_close
	}
}
#cd C:/Users/mateu/OneDrive/Documents/GitHub/UFMG_DIGITAL_DESIGN/rs_codec/rs_decoder/syn
