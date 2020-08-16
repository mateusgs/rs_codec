clear -all

source compilation.itcl
source requirements.itcl

foreach param [get_parameters] {
    set N [lindex $param 0]
    set K [lindex $param 1] 
    set RS_GF [lindex $param 2]
    set NUM_PARITY [expr {$N - $K}]
    run_design_compilation $N $K $RS_GF "only_decoder"
    #assume -env {i_consume}
    clock clk
    reset -none
    set rs_decoder_requirements [get_requirements]
    set rs_decoder_requirements [create_properties $rs_decoder_requirements "reset" $NUM_PARITY]
    prove -task reset

    reset rst
    set rs_decoder_requirements [create_properties $rs_decoder_requirements "protocol" $NUM_PARITY]
    prove -task protocol

    #TODO: Add functional requirement here.
}
