proc run_checks_with_disturber {N K RS_GF} {
    clear -all
    run_design_compilation $N $K $RS_GF "disturber"
    clock clk
    reset rst
    #TODO:Remove this constraint
    assume -env i_consume
    set TWO_TIMES_T [expr {$N - $K}]
    rs_decoder_stall_checks $TWO_TIMES_T
    rs_decoder_reset_checks $N $TWO_TIMES_T
    rs_decoder_codeword_check $N $K $TWO_TIMES_T "disturber"
}

proc run_checks_with_post_syndrome {N K RS_GF} {
    clear -all
    run_design_compilation $N $K $RS_GF "syndrome"
    clock clk
    reset rst
    set TWO_TIMES_T [expr {$N - $K}]
    rs_decoder_consume_checks
    rs_decoder_stall_checks $TWO_TIMES_T
    rs_decoder_reset_checks $N $TWO_TIMES_T
    rs_decoder_codeword_check $N $K $TWO_TIMES_T "syndrome"
}

clear -all
source requirements.itcl
source compilation.itcl
source procs.itcl

set params [get_parameters]

foreach param $params {
    set N [lindex $param 0]
    set K [lindex $param 1] 
    set RS_GF [lindex $param 2] 
    
    #run_checks_with_disturber $N $K $RS_GF
    run_checks_with_post_syndrome $N $K $RS_GF
}
