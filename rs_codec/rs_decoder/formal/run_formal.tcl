clear -all

#jasper_scoreboard_3 -init
# check_cov -init -model { branch statement } -type { stimuli coi proof bound }

source compilation.itcl
source requirements.itcl

foreach param [get_parameters] {
    set N [lindex $param 0]
    set K [lindex $param 1] 
    set RS_GF [lindex $param 2]

    run_decoder_design_compilation $N $K $RS_GF

    clock clk
    reset -none
    set rs_decoder_requirements [get_requirements]
    set rs_decoder_requirements [create_properties $rs_decoder_requirements "reset"]
    prove -task reset

    reset rst
    set rs_decoder_requirements [create_properties $rs_decoder_requirements "protocol"]
    prove -task protocol

    #run_decoder_design_compilation $N $K $RS_GF
    #set rs_decoder_requirements [create_properties $rs_decoder_requirements "functional"]
    #prove -task functional


#     generate_csv_report $rs_encoder_requirements $N $K
}

session -new RST
session -run_cmds RST "source REQ_RS_ENC_RST.tcl"

# connect -bind -auto rs_encoder mod1 -auto -elaborate
#connect -bind -auto fv_encod mod2 -auto -elaborate 

# connect -bind -vhdl rs_encoder fv_encod\
# 			    -connect clk clk \
# 			    -connect rst rst \
# 			    -connect i_start_codeword 	i_start_codeword \
# 			    -connect i_end_codeword  	i_end_codeword \
# 			    -connect i_valid		i_valid \
# 			    -connect i_data		i_symbol \
# 			    -connect o_start_codeword	o_start_codeword \
# 			    -connect o_end_codeword	o_end_codeword \
# 			    -connect o_error		o_error \
# 			    -connect o_in_ready		o_in_ready \
# 			    -connect o_valid		o_valid \
# 			    -connect o_data		o_symbol \
# 			    -elaborate 


