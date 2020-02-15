proc run_checks_with_disturber {N K RS_GF} {
    clear -all
    run_design_compilation $N $K $RS_GF "disturber"
    clock clk
    reset rst
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
    rs_decoder_stall_checks $TWO_TIMES_T
    rs_decoder_reset_checks $N $TWO_TIMES_T
    rs_decoder_codeword_check $N $K $TWO_TIMES_T "syndrome"
}

clear -all
source requirements.itcl
source procs.itcl

set params [get_parameters]

foreach param $params {
    set N [lindex $param 0]
    set K [lindex $param 1] 
    set RS_GF [lindex $param 2] 
    
    run_checks_with_post_syndrome $N $K $RS_GF
    #run_checks_with_disturber $N $K $RS_GF

    #if {$N == 7} {
    #  run_checks_with_disturber $N $K $RS_GF
    #}
    #run_checks_with_post_syndrome $N $K $RS_GF
}


#clock clk
#reset rst
##cover {o_valid and o_error_counter <= 2 |->  not o_fifo_xor_decoder_symbol}
#
##rs_decoder_stall_properties 4
##prove -task stall
#
##rs_decoder_codeword_check 15 4 2
#assert  {o_end_codeword |=> not(o_syndrome)}
#create_single_codeword_transmission_2 7
##prove -task formal
