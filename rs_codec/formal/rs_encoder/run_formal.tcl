clear -all

source compilation.itcl
source requirements.tcl

foreach param [get_parameters] {
    set N [lindex $param 0]
    set K [lindex $param 1] 
    set RS_GF [lindex $param 2] 
    run_design_compilation $N $K $RS_GF
    clock clk
    task -create reset -set -source_task <embedded>\
    	-copy_stopats -copy_abstractions all\
    	-copy_assumes -copy <embedded>::rs_encoder_wrapper.mod2.REQ_RS_ENC_001_CHECK_01\
	-copy <embedded>::rs_encoder_wrapper.mod2.REQ_RS_ENC_001_CHECK_01:precondition1\
	-copy <embedded>::rs_encoder_wrapper.mod2.REQ_RS_ENC_001_CHECK_02\
	-copy <embedded>::rs_encoder_wrapper.mod2.REQ_RS_ENC_001_CHECK_02:precondition1\
	-copy <embedded>::rs_encoder_wrapper.mod2.REQ_RS_ENC_001_CHECK_03\
	-copy <embedded>::rs_encoder_wrapper.mod2.REQ_RS_ENC_001_CHECK_03:precondition1
    task -create functional -set -source_task <embedded>\
    	-copy_stopats -copy_abstractions all\
    	-copy_assumes -copy <embedded>::rs_encoder_wrapper.mod2.REQ_RS_ENC_017_CHECK_01\
	-copy <embedded>::rs_encoder_wrapper.mod2.REQ_RS_ENC_017_CHECK_01:precondition1\
    	-copy <embedded>::rs_encoder_wrapper.mod2.REQ_RS_ENC_017_CHECK_02\
	-copy <embedded>::rs_encoder_wrapper.mod2.REQ_RS_ENC_017_CHECK_02:precondition1

    #Checking reset requirements
    task -set reset
    reset -none
    prove -task reset
    check_return {get_property_list -include {status {cex unreachable}} -task {<constraints>}} {}

    #Setting reset expression and removing property already proven in the previous step
    reset rst
    task -set <embedded>
    assert -disable <embedded>::rs_encoder_wrapper.mod2.REQ_RS_ENC_001_CHECK_01
    cover -disable  <embedded>::rs_encoder_wrapper.mod2.REQ_RS_ENC_001_CHECK_01:precondition1
    assert -disable <embedded>::rs_encoder_wrapper.mod2.REQ_RS_ENC_001_CHECK_02
    cover -disable  <embedded>::rs_encoder_wrapper.mod2.REQ_RS_ENC_001_CHECK_02:precondition1
    assert -disable <embedded>::rs_encoder_wrapper.mod2.REQ_RS_ENC_001_CHECK_03
    cover -disable  <embedded>::rs_encoder_wrapper.mod2.REQ_RS_ENC_001_CHECK_03:precondition1
    assert -disable <embedded>::rs_encoder_wrapper.mod2.REQ_RS_ENC_017_CHECK_01
    cover -disable  <embedded>::rs_encoder_wrapper.mod2.REQ_RS_ENC_017_CHECK_01:precondition1
    assert -disable <embedded>::rs_encoder_wrapper.mod2.REQ_RS_ENC_017_CHECK_02
    cover -disable  <embedded>::rs_encoder_wrapper.mod2.REQ_RS_ENC_017_CHECK_02:precondition1

    clock clk
    reset rst
    prove -task <embedded>
    check_return {get_property_list -include {status {cex unreachable}} -task {<constraints>}} {}

    prove -task {<constraints>}
    check_return {get_property_list -include {status {cex unreachable}} -task {<constraints>}} {}

    #max bound should be Num max of valid signals + N-K + 3 = N + 3.
    task -set functional
    #assume i_consume
    set proof_bound [expr {$N + 3}]
    set_prove_target_bound $proof_bound
    set_max_trace_length $proof_bound
    prove -task functional
    check_return {get_property_list -include {status {cex unreachable}} -task {functional}} {}
}
