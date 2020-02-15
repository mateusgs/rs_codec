clear -all

#jasper_scoreboard_3 -init
# check_cov -init -model { branch statement } -type { stimuli coi proof bound }

source compilation.itcl
source requirements.tcl

foreach param [get_parameters] {
    set N [lindex $param 0]
    set K [lindex $param 1] 
    set RS_GF [lindex $param 2] 
    run_design_compilation $N $K $RS_GF

    set rs_encoder_requirements [get_requirements]
    set rs_encoder_requirements [create_properties $rs_encoder_requirements]
    set_prove_time_limit 2h

    clock clk
    reset -none
    prove -task reset
    check_return {get_property_list -include {status {cex unreachable}} -task {<constraints>}} {}

    clock clk
    reset rst
    prove -task protocol
    check_return {get_property_list -include {status {cex unreachable}} -task {protocol}} {}

    #max bound should be Num max of valid signals + N-K + 3 = N + 3.
    set proof_bound [expr {$N + 3}]
    set_prove_target_bound $proof_bound
    set_max_trace_length $proof_bound
    prove -task functional
    check_return {get_property_list -include {status {cex unreachable}} -task {functional}} {}
    set_prove_target_bound 0
    set_max_trace_length 0
    prove -task {<constraints>}
    check_return {get_property_list -include {status {cex unreachable}} -task {<constraints>}} {}
    prove -task {<embedded>}
    check_return {get_property_list -include {status {cex unreachable}} -task {<embedded>}} {}

    #generate_csv_report $rs_encoder_requirements $N $K
}
