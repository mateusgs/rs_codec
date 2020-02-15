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
# File: rs_encoder.tcl
# Generated on: Mon Nov 04 21:09:33 2019

# Load Quartus Prime Tcl Project package
package require ::quartus::project

set need_to_close_project 0
set make_assignments 1

# Check that the right project is open
if {[is_project_open]} {
	if {[string compare $quartus(project) "rs_encoder"]} {
		puts "Project rs_encoder is not open"
		set make_assignments 0
	}
} else {
	# Only open if not already open
	if {[project_exists rs_encoder]} {
		project_open -revision rs_encoder rs_encoder
	} else {
		project_new -revision rs_encoder rs_encoder
	}
	set need_to_close_project 1
}

# Make assignments
if {$make_assignments} {
	set_global_assignment -name FAMILY "Cyclone IV E"
	set_global_assignment -name DEVICE EP4CE6E22C6
	set_global_assignment -name ORIGINAL_QUARTUS_VERSION 18.1.0
	set_global_assignment -name PROJECT_CREATION_TIME_DATE "21:08:25  NOVEMBER 04, 2019"
	set_global_assignment -name LAST_QUARTUS_VERSION "18.1.0 Lite Edition"
    set_global_assignment -name VHDL_INPUT_VERSION VHDL_2008
	set_global_assignment -name VHDL_FILE ../../../generic_components/generic_types.vhd
	set_global_assignment -name VHDL_FILE ../../../generic_components/generic_components.vhd
	set_global_assignment -name VHDL_FILE ../../../generic_components/generic_functions.vhd
	set_global_assignment -name VHDL_FILE ../../rs_common/rs_types.vhd
	set_global_assignment -name VHDL_FILE ../../rs_common/rs_constants.vhd
	set_global_assignment -name VHDL_FILE ../../rs_common/rs_functions.vhd
	set_global_assignment -name VHDL_FILE ../../rs_common/rs_components.vhd
	set_global_assignment -name VHDL_FILE ../../rs_common/rs_constants.vhd
	set_global_assignment -name VHDL_FILE ../../rs_common/rs_inverse/rs_inverse.vhd
	set_global_assignment -name VHDL_FILE ../../rs_common/rs_full_multiplier/rs_full_multiplier.vhd
	set_global_assignment -name VHDL_FILE ../../rs_common/rs_full_multiplier/rs_full_multiplier_core.vhd
	set_global_assignment -name VHDL_FILE ../../rs_encoder/rtl/rs_encoder.vhd
	set_global_assignment -name VHDL_FILE ../../../generic_components/async_dff/async_dff.vhd
	set_global_assignment -name VHDL_FILE ../../rs_common/rs_adder/rs_adder.vhd
	set_global_assignment -name VHDL_FILE ../../rs_common/rs_multiplier_lut/rs_multiplier_lut.vhd
	set_global_assignment -name VHDL_FILE ../../rs_common/rs_multiplier/rs_multiplier.vhd
	set_global_assignment -name VHDL_FILE ../../rs_encoder/rtl/rs_remainder_unit/rs_remainder_unit.vhd
	set_global_assignment -name VHDL_FILE ../../rs_decoder/rtl/rs_syndrome/rs_syndrome.vhd
	set_global_assignment -name VHDL_FILE ../../rs_decoder/rtl/rs_syndrome/rs_syndrome_subunit/rs_syndrome_subunit.vhd
	set_global_assignment -name VHDL_FILE ../../rs_encoder/rtl/rs_encoder_wrapper.vhd
	
	set_global_assignment -name PROJECT_OUTPUT_DIRECTORY output_files

	# Including default assignments
	set_global_assignment -name TIMING_ANALYZER_MULTICORNER_ANALYSIS ON -family "Cyclone IV E"
	set_global_assignment -name TIMING_ANALYZER_REPORT_WORST_CASE_TIMING_PATHS ON -family "Cyclone IV E"
	set_global_assignment -name TIMING_ANALYZER_CCPP_TRADEOFF_TOLERANCE 0 -family "Cyclone IV E"
	set_global_assignment -name TDC_CCPP_TRADEOFF_TOLERANCE 0 -family "Cyclone IV E"
	set_global_assignment -name TIMING_ANALYZER_DO_CCPP_REMOVAL ON -family "Cyclone IV E"
	set_global_assignment -name DISABLE_LEGACY_TIMING_ANALYZER OFF -family "Cyclone IV E"
	set_global_assignment -name SYNTH_TIMING_DRIVEN_SYNTHESIS ON -family "Cyclone IV E"
	set_global_assignment -name SYNCHRONIZATION_REGISTER_CHAIN_LENGTH 2 -family "Cyclone IV E"
	set_global_assignment -name SYNTH_RESOURCE_AWARE_INFERENCE_FOR_BLOCK_RAM ON -family "Cyclone IV E"
	set_global_assignment -name OPTIMIZE_HOLD_TIMING "ALL PATHS" -family "Cyclone IV E"
	set_global_assignment -name OPTIMIZE_MULTI_CORNER_TIMING ON -family "Cyclone IV E"
	set_global_assignment -name AUTO_DELAY_CHAINS ON -family "Cyclone IV E"
	set_global_assignment -name CRC_ERROR_OPEN_DRAIN OFF -family "Cyclone IV E"
	set_global_assignment -name USE_CONFIGURATION_DEVICE OFF -family "Cyclone IV E"
	set_global_assignment -name ENABLE_OCT_DONE OFF -family "Cyclone IV E"
	set_global_assignment -name OPTIMIZATION_MODE "HIGH PERFORMANCE EFFORT"
	
	# Commit assignments
	export_assignments

	#custom script start
	source ../../../scripts/syn/run_syn.tcl
	run_syn rs_encoder [pwd] ../../../scripts/syn
	#custom script end

	# Close project
	if {$need_to_close_project} {
	#	project_close
	}
}
#cd C:/Users/mateu/OneDrive/Documents/GitHub/UFMG_DIGITAL_DESIGN/rs_codec/rs_encoder/syn
