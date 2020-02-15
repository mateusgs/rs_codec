project_open -force [lindex $argv 0] -revision [lindex $argv 1]
create_timing_netlist -model slow
read_sdc
update_timing_netlist

set outputFile [open fmax.txt w]
puts $outputFile [lindex [lindex [get_clock_fmax_info] 0] 1]
close $outputFile