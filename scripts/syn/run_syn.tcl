proc quartus_set_parameters {param} {
    foreach kv $param {
        set_parameter -name [lindex $kv 0] [lindex $kv 1]
    }
}

proc generate_header {param} {
    set header []
    foreach kv $param {
        set header [linsert $header end [lindex $kv 0]]
    }

    set header [linsert $header end "logic_elements"]
    set header [linsert $header end "pins"]
    set header [linsert $header end "registers"]
    set header [linsert $header end "memory_bits"]
    set header [linsert $header end "fmax"]

    set header [join $header ";"]

    return $header
}

proc generate_row {param logic_elements pins registers memory_bits fmax} {
    set row []
    foreach kv $param {
        set row [linsert $row end [lindex $kv 1]]
    }
    set row [linsert $row end $logic_elements]
    set row [linsert $row end $pins]
    set row [linsert $row end $registers]
    set row [linsert $row end $memory_bits]
    set row [linsert $row end $fmax]

    set row [join $row ";"]

    return $row
}

proc generate_report_line {param project_name project_path script_path} {
    set has_file [file exists quartus_syn_report.csv]

    if { $has_file == 0} {
        set fp [open quartus_syn_report.csv w]
        puts -nonewline $fp [generate_header $param]
        close $fp
    } 

    load_package report
    load_report

    set id [get_report_panel_id {Flow Summary}]
    set logic_elements [lindex [get_report_panel_row -row_name {Total logic elements} -id 0] 1]
    set pins [lindex [get_report_panel_row -row_name {Total pins} -id 0] 1]
    set registers [lindex [get_report_panel_row -row_name {Total registers} -id 0] 1]
    set memory_bits [lindex [get_report_panel_row -row_name {Total memory bits} -id 0] 1]

    set project_path "[pwd]/$project_name.qpf"
    exec quartus_sta -t "$script_path/quartus_sta.tcl" $project_path $project_name
    set fp [open fmax.txt r]
    set fmax [read $fp]

    set fp [open quartus_syn_report.csv a+]

    set row [generate_row $param\
                          $logic_elements\
                          $pins\
                          $registers\
                          $memory_bits\
                          $fmax]
    if { $has_file == 0} {
        set row "\n$row"
    }
    puts -nonewline $fp $row

    close $fp
    unload_report
}

proc run_syn {project_name project_path script_path get_param_path} {
    source $get_param_path/get_parameters.tcl
    foreach param [get_parameters] {
        quartus_set_parameters $param
        
        load_package flow

        #Analysis & Synthesis
        execute_module -tool map

        #Place & Route
        execute_module -tool fit

        #Assembler
        execute_module -tool asm

        #Timing Analysis
        execute_module -tool sta

        #EDA Netlist Writer
        execute_module -tool eda

        generate_report_line $param $project_name $project_path $script_path
    }
}
