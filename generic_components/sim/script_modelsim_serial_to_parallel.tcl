quit -sim
	
cd ..
cd ..
cd ..


if {[file isdirectory UFMG_digital_design]} {
		
	if {![file isdirectory modelsim_output_files]} {
		file mkdir modelsim_output_files
	}
	
	cd modelsim_output_files
	
	if {[file exists work]} {
		vdel -lib rtl_work -all
	}

	vlib rtl_work
	vmap work rtl_work

	
	vcom -2008 -work work ../UFMG_digital_design/generic_components/rtl/generic_types.vhd
	vcom -2008 -work work ../UFMG_digital_design/generic_components/rtl/generic_functions.vhd

	vcom -2008 -work work ../UFMG_digital_design/generic_components/rtl/serial_to_parallel.vhd

	vcom -2008 -work work ../UFMG_digital_design/generic_components/sim/serial_to_parallel_tb.vhd

	vsim -t 1ps -L altera -L lpm -L sgate -L altera_mf -L altera_lnsim -L cycloneii -L rtl_work -L work -voptargs="+acc"  serial_to_parallel_tb
	vsim -L altera -L lpm -L sgate -L altera_mf -L altera_lnsim -L cycloneii -L rtl_work -L work -voptargs=\"+acc\" -t 1ps serial_to_parallel_tb
	add wave *
	add wave -r r_data r_full
	view structure
	view signals
	run 1 us
}
