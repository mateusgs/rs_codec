proc get_parameters {} {
    #return {{15 11 RS_GF_16} {15 7 RS_GF_16} {15 4 RS_GF_16} {15 2 RS_GF_16} {64 32 RS_GF_256} {160 128 RS_GF_256}}
    #return {{64 60 RS_GF_256}}
    #return {{64 32 RS_GF_128}}
    return {{15 11 RS_GF_16}}
}

proc get_requirements {} {
# This dict will be resposible for maintaining all information related to 
# the requirements of the RS Encoder
set rs_encoder_requirements [dict create]

#Generic information
# Possible states:
# WAIT_SYMBOL,
# START_CODEWORD,
# PROCESS_SYMBOLS,
# GENERATE_PARITY,
# END_CODEWORD,
# STALL,
# ERROR
# For more information regarding the state machine refer to the paper. 
# Process unit is also described in the paper.
# Remind that all output signals are delay by one cycle, it means that some action taken by some state
# will only take effect one cycle after. The only exception is "o_in_ready".
# Also, the VHDL code for RS encoder is relatively small, so it is a code that can be read. But use it as the
# resource.

# REQ_RS_ENC_001: Initial state of RS Encoder. 
dict set rs_encode_requirements REQ_RS_ENC_001 description\
"REQ_RS_ENC_001: The RS Encoder shall be reset by the input port 'rst', which is\
 an active high pin and asynchronous. If 'rst' is '1', it should take 1 cycle to\
 reset the whole block. Upon this scenario, 'DUT.RS_CONTROL.r_state', which is a register\
 that stores the current state of control unit, is assigned to 'WAIT_SYMBOL' and all\
 output ports of RS encoder should be set to zero. Such behavior holds even after 'rst'\
 being released when all other RS Encoder inputs remain '0'."

# REQ_RS_ENC_002: Valid 'WAIT_SYMBOL' transitions
dict set rs_encode_requirements REQ_RS_ENC_002 description\
"REQ_RS_ENC_002: If 'DUT.RS_CONTROL.r_state' is assigned to 'WAIT_SYMBOL' there are only 2 possible\
 transitions, which are to ERROR or START_CODEWORD. If i_valid and i_end_codeword and not i_start_codeword\
 are assigned to '1', it indicates an unexpected combination of inputs since WAIT_SYMBOL\
 actually waits for the first codeword symbol. For such scnario the next state assigned to\
 'DUT.RS_CONTROL.r_state' is 'ERROR'. If i_valid and i_start_codeword are '1', it means that the\
 first symbol of the codeword reached the encoder. Then, 'DUT.RS_CONTROL.r_state' is assigned\ 
 to 'START_CODEWORD'. 'DUT.RS_CONTROL.r_state' should be stuck at 'WAIT_SYMBOL' for any other\
 combination of inputs that does not cover the two scenarios mentioned above. If i_start_codeword\
 and i_end_codeword are '1' and valid (i_valid = '1'), it means that the message has only one symbol to\
 be encoded."

# REQ_RS_ENC_003: 'ERROR' state behavior
dict set rs_encode_requirements REQ_RS_ENC_003 description\
"REQ_RS_ENC_003: If 'DUT.RS_CONTROL.r_state' hits 'ERROR', it remains stuck at this state,\
 until RS Encoder be reset again. In the cycle subsequent this transition, 'o_error' is \
 assigned to '1' and all other outputs remain in '0'."

# REQ_RS_ENC_004: Unexpected behavior when processing valid inpus symbols
dict set rs_encode_requirements REQ_RS_ENC_004 description\
"REQ_RS_ENC_004: If i_valid = '1' and i_start_codeword = '1' during 'START_CODEWORD',\
 'PROCESS_SYMBOLS', 'STALL' and 'GENERATE_PARITY', 'DUT.RS_CONTROL.r_state' should be assigned\
 to 'ERROR' in the next cycle."

# REQ_RS_ENC_005: Missing 'i_end_codeword' signal after starting receiving valid input symbols.
dict set rs_encode_requirements REQ_RS_ENC_005 description\
"REQ_RS_ENC_005: After starting receving the valid input symbols (the transition from \
 'WAIT_SYMBOL' to 'START_CODEWORD'), it should take at most K valid input symbol cycles to \
 i_end_codeword indicates the last valid input symbol. If it does not happen, r_state must \
 be assigned to 'ERROR'. The only to states in which this scenario might happen are 'STALL' \
 and PROCESS_SYMBOLS. PS: The encoded codeword does not need to have K message symbols, and \
 this is actually the maximum capacity of a given encoder configuration. When the encoded codeword \
 has less than K message symbols, it is called as shortened codeword."

# REQ_RS_ENC_006: Valid 'START_CODEWORD' transitions
dict set rs_encode_requirements REQ_RS_ENC_006 description\
"REQ_RS_ENC_006: 'START_CODEWORD' has 4 possible transitions. REQ_RS_ENC_004 describes the \
 transition to 'ERROR'. The other two depends on i_valid value. If i_valid is '0', 'DUT.RS_CONTROL.r_state' \
 is assigned to 'STALL'. Otherwise, 'DUT.RS_CONTROL.r_state' is assigned to 'PROCESS_SYMBOLS' or 'GENERATE_PARTY'\
 if the message has only one symbol."

# REQ_RS_ENC_007: 'START_CODEWORD' state behavior
dict set rs_encode_requirements REQ_RS_ENC_007 description\
"REQ_RS_ENC_007: In the cycle subsequent to 'START_CODEWORD' transition, 'o_start_codeword', 'o_valid' and \
 'o_in_ready' shall be set to '1'. Other output control signal shall be '0'."

# REQ_RS_ENC_008: Valid 'STALL' transitions
dict set rs_encode_requirements REQ_RS_ENC_008 description\
"REQ_RS_ENC_008: 'STALL' state is resposible for freezing the processing unit during invalid input scenarios \
 informed by 'i_valid' status. If REQ_RS_ENC_004 and REQ_RS_ENC_005 are valid when 'DUT.RS_CONTROL.r_state' is 'STALL', \
 the next state shall be 'ERROR'. If i_valid is '0', 'DUT.RS_CONTROL.r_state' continues assuming 'STALL'. If i_valid is '1', \
 the next state shall be 'PROCESS_SYMBOLS'."

# REQ_RS_ENC_009: 'STALL' state behavior 
dict set rs_encode_requirements REQ_RS_ENC_009 description\
"REQ_RS_ENC_009: In the cycle subsequent to 'START_CODEWORD' transition, with the exception of 'past(o_in_ready)', all \
control outputs shall be '0'."

# REQ_RS_ENC_010: Valid 'PROCESS_SYMBOLS' transitions
dict set rs_encode_requirements REQ_RS_ENC_010 description\
"REQ_RS_ENC_010: 'PROCESS_SYMBOLS' is resposible for processing valid input message symbols. The next state can be \
'ERROR' if the scenarios described in REQ_RS_ENC_004 or REQ_RS_ENC_005 happen. Also, if 'i_valid' is 0 and 'i_end_codeword' \
 was not '1' in the previous state, the next state is 'STALL'. If i_end_codeword assumed '1' in the previous cycle, Then \
 the next state is 'GENERATE_PARITY'. The next state shall be 'PROCESS_SYMBOLS', if none of the described conditions \
 holds."

# REQ_RS_ENC_011: 'PROCESS_SYMBOLS' state behavior
dict set rs_encode_requirements REQ_RS_ENC_011 description\
"REQ_RS_ENC_011: In the cycle subsequent to 'PROCESS_SYMBOLS' transition, 'past(o_in_ready)' and 'o_valid' shall be '1'. \
 The other control output signals shall assume '0'."

# REQ_RS_ENC_012: Valid 'GENERATE_PARITY' transitions
dict set rs_encode_requirements REQ_RS_ENC_012 description\
"REQ_RS_ENC_012: 'GENERATE_PARITY' state is independent of 'i_symbol', since it outputs the parity symbols \
 generated in the previous cycles using the message symbols. This state will take N - K cycles, and the next \
 state is then 'END_CODEWORD'. If 'i_valid' is '1' and 'i_end_codeword' or 'i_start_codeword' is '1', this is \
 an unexpected input behavior. For such scenarios the next state is 'ERROR'."

# REQ_RS_ENC_013: 'GENERATE_PARITY' state behavior
dict set rs_encode_requirements REQ_RS_ENC_013 description\
"REQ_RS_ENC_013: When 'GENERATE_PARITY' assumed by 'DUT.RS_CONTROL.r_state', 'past(o_in_ready)' is set to zero. In the \
 subsequent cycle, only 'o_valid' assumes '1' and the other control outputs signals are assigned to '0'. "

# REQ_RS_ENC_014: Valid 'END_CODEWORD' transitions
dict set rs_encode_requirements REQ_RS_ENC_014 description\
"REQ_RS_ENC_014: 'END_CODEWORD' is responsible for the output of the last output symbol. If the new codeword \
 is already available (i_start_codeword = '1' and i_valid = '1'), the next state is 'START_CODEWORD'. There is \
 also an unexpected input behavior which is when i_end_codeword = '1' and i_valid = '1', and 'ERROR' shall be the \
 the next state for this case. If there is not any new codeword available, the next state is 'WAIT_SYMBOL' then."

# REQ_RS_ENC_015: 'END_CODEWORD' state behavior
dict set rs_encode_requirements REQ_RS_ENC_015 description\
"REQ_RS_ENC_015: In the cycle subsequent to 'END_CODEWORD' transition, 'o_valid' and 'o_end_codeword' are assigned \
 '1', and the other output control signal are assigned to zero."

# REQ_RS_ENC_016: generated codeword structure - the golden requirement. 
dict set rs_encode_requirements REQ_RS_ENC_018 description\
"REQ_RS_ENC_018: The encoded codeword should have at least N - K + 1 symbols because it must have at least 1 message \
 symbol and N - K parity symbols. Also, the polynomial formed by the encoded codeword should be always divisible by the \
 generated polynomial. The encoded codeword is composed by all valid output symbols ('o_symbol') between o_start_codeword and \
 o_end_codeword. The valid 'i_symbols' should be at 'o_symbol' with the delay of 1 cycle. The verification of the generated \
 parity symbols might use the \"syndrome calculator\", which is the first step of the decoding process. When there isn't any error \
 during the transmission, the output of the syndrome calculator should be zero after processing the entire input codeword. \
 Also, all scenarios should for producing the encoded codeword should be taken into account: it might have stall states in between \
 valid inputs and new input symbols might be available in END_CODEWORD state."
}




proc create_properties {requirements} {

    set k [lindex [get_design_info -list parameter] 1]

    task -create protocol -set
    set check_properties []
    set check_properties [linsert $check_properties end [assert {DUT.RS_CONTROL.r_state=WAIT_SYMBOL and i_valid and i_start_codeword and not(i_end_codeword)|=> DUT.RS_CONTROL.r_state=START_CODEWORD} -name REQ_RS_ENC_002.CHECK.01]]
    set check_properties [linsert $check_properties end [assert {DUT.RS_CONTROL.r_state=WAIT_SYMBOL and not(i_valid) |=> DUT.RS_CONTROL.r_state=WAIT_SYMBOL} -name REQ_RS_ENC_002.CHECK.02]]
    set check_properties [linsert $check_properties end [assert {DUT.RS_CONTROL.r_state=WAIT_SYMBOL and i_valid and i_end_codeword and not(i_start_codeword) |=> DUT.RS_CONTROL.r_state=ERROR} -name REQ_RS_ENC_002.CHECK.03]]
    set check_properties [linsert $check_properties end [assert {DUT.RS_CONTROL.r_state=WAIT_SYMBOL and i_valid and i_start_codeword and not(i_end_codeword)|=> mod2.sending_codeword_i} -name REQ_RS_ENC_002.CHECK.04]]
    set check_properties [linsert $check_properties end [assert {DUT.RS_CONTROL.r_state=WAIT_SYMBOL and i_valid and i_start_codeword and (i_end_codeword)|=> DUT.RS_CONTROL.r_state=START_CODEWORD} -name REQ_RS_ENC_002.CHECK.05]]
    dict set requirements REQ_RS_ENC_002 checks $check_properties

    set check_properties []
    set check_properties [linsert $check_properties end [assert  {DUT.RS_CONTROL.r_state=ERROR |=> DUT.RS_CONTROL.r_state=ERROR} -name REQ_RS_ENC_003.CHECK.01]]
    set check_properties [linsert $check_properties end [assert  {DUT.RS_CONTROL.r_state=ERROR |=> o_error} -name REQ_RS_ENC_003.CHECK.02]]
    set check_properties [linsert $check_properties end [assert  {DUT.RS_CONTROL.r_state=ERROR |=> not(o_start_codeword) and not(o_end_codeword) and $past(not(o_in_ready)) and not(o_valid)} -name REQ_RS_ENC_003.CHECK.03]] 
    dict set requirements REQ_RS_ENC_003 checks $check_properties


    set check_properties []
    set check_properties [linsert $check_properties end [assert  {DUT.RS_CONTROL.r_state=START_CODEWORD and mod2.i_valid and mod2.i_start_codeword |=> DUT.RS_CONTROL.r_state=ERROR} -name REQ_RS_ENC_004.CHECK.01]]
    set check_properties [linsert $check_properties end [assert  {DUT.RS_CONTROL.r_state=PROCESS_SYMBOLS and mod2.i_valid and mod2.i_start_codeword |=> DUT.RS_CONTROL.r_state=ERROR} -name REQ_RS_ENC_004.CHECK.02]]
    set check_properties [linsert $check_properties end [assert  {DUT.RS_CONTROL.r_state=GENERATE_PARITY and mod2.i_valid and mod2.i_start_codeword |=> DUT.RS_CONTROL.r_state=ERROR} -name REQ_RS_ENC_004.CHECK.03]]
    set check_properties [linsert $check_properties end [assert  {DUT.RS_CONTROL.r_state=STALL and mod2.i_valid and mod2.i_start_codeword |=> DUT.RS_CONTROL.r_state=ERROR} -name REQ_RS_ENC_004.CHECK.04]]
    dict set requirements REQ_RS_ENC_004 checks $check_properties

    set check_properties []
    dict set requirements REQ_RS_ENC_005 checks $check_properties
    set check_properties []
    set check_properties [linsert $check_properties end [assert {DUT.RS_CONTROL.r_state=PROCESS_SYMBOLS and  i_valid and i_start_codeword |=> DUT.RS_CONTROL.r_state=ERROR} -name REQ_RS_ENC_005.CHECK.01]]
    if {$k == 2} {
        set check_properties [linsert $check_properties end [assert {DUT.RS_CONTROL.r_state=PROCESS_SYMBOLS and (not i_valid or (not i_end_codeword and not i_start_codeword)) |=> DUT.RS_CONTROL.r_state=GENERATE_PARITY} -name REQ_RS_ENC_005.CHECK.02]]
        set check_properties [linsert $check_properties end [assert {DUT.RS_CONTROL.r_state=PROCESS_SYMBOLS and (i_valid and (i_end_codeword or i_start_codeword)) |=> DUT.RS_CONTROL.r_state=ERROR} -name REQ_RS_ENC_005.CHECK.03]]
        set check_properties [linsert $check_properties end [assert {DUT.RS_CONTROL.r_state=PROCESS_SYMBOLS |=> DUT.RS_CONTROL.r_state = ERROR or DUT.RS_CONTROL.r_state = GENERATE_PARITY} -name REQ_RS_ENC_005.CHECK.04]]
    } else {
        set check_properties [linsert $check_properties end [assert {not i_end_codeword and DUT.RS_CONTROL.r_state=START_CODEWORD ##1 i_valid and (not i_end_codeword and not i_start_codeword) and DUT.RS_CONTROL.r_state=PROCESS_SYMBOLS [*1:(K-3)] |=> DUT.RS_CONTROL.r_state=PROCESS_SYMBOLS}  -name REQ_RS_ENC_005.CHECK.02]]
        set check_properties [linsert $check_properties end [assert {not i_end_codeword and DUT.RS_CONTROL.r_state=START_CODEWORD ##1 i_valid and (not i_end_codeword and not i_start_codeword) and DUT.RS_CONTROL.r_state=PROCESS_SYMBOLS [*1:(K-3)] ##1 not i_valid |=> DUT.RS_CONTROL.r_state=STALL}  -name REQ_RS_ENC_005.CHECK.03]]
        set check_properties [linsert $check_properties end [assert {not i_end_codeword and DUT.RS_CONTROL.r_state=START_CODEWORD ##1 i_valid and not i_end_codeword and not i_start_codeword and DUT.RS_CONTROL.r_state=PROCESS_SYMBOLS [*K-2] |=> DUT.RS_CONTROL.r_state=ERROR}  -name REQ_RS_ENC_005.CHECK.04]]
        set check_properties [linsert $check_properties end [assert {not i_end_codeword and DUT.RS_CONTROL.r_state=START_CODEWORD ##1 i_valid and not i_end_codeword and not i_start_codeword and DUT.RS_CONTROL.r_state=PROCESS_SYMBOLS[*K-3] ##1 i_valid and  i_end_codeword and not i_start_codeword and DUT.RS_CONTROL.r_state=PROCESS_SYMBOLS ##1 DUT.RS_CONTROL.r_state=PROCESS_SYMBOLS and (not i_valid and not i_start_codeword and not i_end_codeword)|=> DUT.RS_CONTROL.r_state=GENERATE_PARITY}  -name REQ_RS_ENC_005.CHECK.05]]
        set check_properties [linsert $check_properties end [assert {i_end_codeword and DUT.RS_CONTROL.r_state=START_CODEWORD ##1 not i_valid and DUT.RS_CONTROL.r_state=PROCESS_SYMBOLS and (not i_start_codeword and not i_end_codeword)|=> DUT.RS_CONTROL.r_state=GENERATE_PARITY}  -name REQ_RS_ENC_005.CHECK.06]]
        set check_properties [linsert $check_properties end [assert {i_end_codeword and DUT.RS_CONTROL.r_state=START_CODEWORD ##1 i_valid and DUT.RS_CONTROL.r_state=PROCESS_SYMBOLS and (i_valid and (i_start_codeword or i_end_codeword))|=> DUT.RS_CONTROL.r_state=ERROR}  -name REQ_RS_ENC_005.CHECK.07]]
    }
    dict set requirements REQ_RS_ENC_005 checks $check_properties
    
    set check_properties [linsert $check_properties end [assert {not(i_end_codeword) ##1 DUT.RS_CONTROL.r_state=START_CODEWORD and i_valid and i_end_codeword and not(i_start_codeword) |=> DUT.RS_CONTROL.r_state=PROCESS_SYMBOLS} -name REQ_RS_ENC_006.CHECK.01]]
        set check_properties [linsert $check_properties end [assert {i_end_codeword ##1 DUT.RS_CONTROL.r_state=START_CODEWORD and not i_valid and not (i_end_codeword) and not(i_start_codeword) |=> DUT.RS_CONTROL.r_state=GENERATE_PARITY} -name REQ_RS_ENC_006.CHECK.02]]
    if {$k == 2} {
        set check_properties [linsert $check_properties end [assert {not(i_end_codeword) ##1 DUT.RS_CONTROL.r_state=START_CODEWORD and i_valid and not (i_end_codeword) and not(i_start_codeword) |=> DUT.RS_CONTROL.r_state=ERROR} -name REQ_RS_ENC_006.CHECK.03]]
    } else {
        set check_properties [linsert $check_properties end [assert {not(i_end_codeword) ##1 DUT.RS_CONTROL.r_state=START_CODEWORD and i_valid and not (i_end_codeword) and not(i_start_codeword) |=> DUT.RS_CONTROL.r_state=PROCESS_SYMBOLS} -name REQ_RS_ENC_006.CHECK.03]]
    }
    set check_properties [linsert $check_properties end [assert {DUT.RS_CONTROL.r_state=START_CODEWORD and not(i_valid) and $past(not(i_end_codeword)) |=> DUT.RS_CONTROL.r_state=STALL_FIRST} -name REQ_RS_ENC_006.CHECK.04]]
    dict set requirements REQ_RS_ENC_006 checks $check_properties

    set check_properties []
    set check_properties [linsert $check_properties end [assert {DUT.RS_CONTROL.r_state=START_CODEWORD |=> o_start_codeword and o_valid and $past(o_in_ready)} -name REQ_RS_ENC_007.CHECK.01]]
    set check_properties [linsert $check_properties end [assert {DUT.RS_CONTROL.r_state=END_CODEWORD |=> o_end_codeword} -name REQ_RS_ENC_007.CHECK.02]]
    dict set requirements REQ_RS_ENC_007 checks $check_properties

    set check_properties []
    set check_properties [linsert $check_properties end [assert {DUT.RS_CONTROL.r_state=STALL and not(i_valid)  |=> DUT.RS_CONTROL.r_state=STALL} -name REQ_RS_ENC_008.CHECK.01]]
    set check_properties [linsert $check_properties end [assert {DUT.RS_CONTROL.r_state=STALL and i_valid and not i_start_codeword and i_end_codeword |=> DUT.RS_CONTROL.r_state=PROCESS_SYMBOLS} -name REQ_RS_ENC_008.CHECK.02]]
    set check_properties [linsert $check_properties end [assert {DUT.RS_CONTROL.r_state=STALL and i_valid and not i_start_codeword and DUT.RS_CONTROL.r_counter=DUT.rs_CONTROL.DATA_LIMIT_INDEX-1 and not i_end_codeword |=> DUT.RS_CONTROL.r_state=ERROR} -name REQ_RS_ENC_008.CHECK.03]]
    if {$k != 2} {
        set check_properties [linsert $check_properties end [assert {DUT.RS_CONTROL.r_state=STALL and i_valid and not i_start_codeword and DUT.RS_CONTROL.r_counter/=DUT.rs_CONTROL.DATA_LIMIT_INDEX-1 and not i_end_codeword |=> DUT.RS_CONTROL.r_state=PROCESS_SYMBOLS} -name REQ_RS_ENC_008.CHECK.04]]
    }
    dict set requirements REQ_RS_ENC_008 checks $check_properties

    set check_properties []
    set check_properties [linsert $check_properties end [assert {DUT.RS_CONTROL.r_state=STALL |=> $past(o_in_ready)} -name REQ_RS_ENC_009.CHECK.01]]
    set check_properties [linsert $check_properties end [assert {DUT.RS_CONTROL.r_state=STALL |=> not(o_error) and not(o_valid) and not(o_start_codeword) and not(o_end_codeword) } -name REQ_RS_ENC_009.CHECK.02]]
    dict set requirements REQ_RS_ENC_009 checks $check_properties

    set check_properties []
    if {$k == 2} {
        set check_properties [linsert $check_properties end [assert {DUT.RS_CONTROL.r_state=PROCESS_SYMBOLS |-> $past(i_end_codeword)} -name REQ_RS_ENC_010.CHECK.01]]
    } else {
        set check_properties [linsert $check_properties end [assert  {DUT.RS_CONTROL.r_state=PROCESS_SYMBOLS and not(i_valid) and $past(not(mod2.i_end_codeword)) |=> DUT.RS_CONTROL.r_state=STALL} -name REQ_RS_ENC_010.CHECK.01]]
    }
    set check_properties [linsert $check_properties end [assert  {DUT.RS_CONTROL.r_state=PROCESS_SYMBOLS and not(i_valid) and $past(i_end_codeword) and not(i_start_codeword)|=> DUT.RS_CONTROL.r_state=GENERATE_PARITY} -name REQ_RS_ENC_010.CHECK.02]]
    dict set requirements REQ_RS_ENC_010 checks $check_properties

    set check_properties []
    set check_properties [linsert $check_properties end [assert  {DUT.RS_CONTROL.r_state=PROCESS_SYMBOLS |=> $past(o_in_ready) and o_valid } -name REQ_RS_ENC_011.CHECK.01]]
    set check_properties [linsert $check_properties end [assert  {DUT.RS_CONTROL.r_state=PROCESS_SYMBOLS |=> not(o_end_codeword) and not(o_start_codeword) } -name REQ_RS_ENC_011.CHECK.02]]
    dict set requirements REQ_RS_ENC_011 checks $check_properties

    set check_properties []
    set check_properties [linsert $check_properties end [assert  {(not(i_start_codeword) and not(i_end_codeword)) or not(i_valid) and DUT.RS_CONTROL.r_state=GENERATE_PARITY[*N-K-1] |=> DUT.RS_CONTROL.r_state=END_CODEWORD} -name REQ_RS_ENC_012.CHECK.01]]
    set check_properties [linsert $check_properties end [assert  {DUT.RS_CONTROL.r_state=GENERATE_PARITY and i_valid and i_start_codeword |=> DUT.RS_CONTROL.r_state=ERROR} -name REQ_RS_ENC_012.CHECK.02]]
    set check_properties [linsert $check_properties end [assert  {DUT.RS_CONTROL.r_state=GENERATE_PARITY and i_valid and i_end_codeword |=> DUT.RS_CONTROL.r_state=ERROR} -name REQ_RS_ENC_012.CHECK.03]]
    dict set requirements REQ_RS_ENC_012 checks $check_properties


    set check_properties []
    set check_properties [linsert $check_properties end [assert  {DUT.RS_CONTROL.r_state=GENERATE_PARITY |-> not(o_in_ready)} -name REQ_RS_ENC_013.CHECK.01]]
    set check_properties [linsert $check_properties end [assert  {DUT.RS_CONTROL.r_state=GENERATE_PARITY |=> o_valid and not(o_start_codeword) and not(o_end_codeword) and not(o_error)} -name REQ_RS_ENC_013.CHECK.02]]
    dict set requirements REQ_RS_ENC_013 checks $check_properties

    set check_properties []
    set check_properties [linsert $check_properties end [assert  {DUT.RS_CONTROL.r_state=END_CODEWORD and i_valid and i_start_codeword and not(i_end_codeword) |=> DUT.RS_CONTROL.r_state=START_CODEWORD} -name REQ_RS_ENC_014.CHECK.01]]
    set check_properties [linsert $check_properties end [assert  {DUT.RS_CONTROL.r_state=END_CODEWORD and i_valid and i_end_codeword |=> DUT.RS_CONTROL.r_state=ERROR} -name REQ_RS_ENC_014.CHECK.02]]
    set check_properties [linsert $check_properties end [assert  {DUT.RS_CONTROL.r_state=END_CODEWORD and not(i_valid) and not(i_start_codeword) and not(i_end_codeword) |=> DUT.RS_CONTROL.r_state=WAIT_SYMBOL} -name REQ_RS_ENC_014.CHECK.03]]
    dict set requirements REQ_RS_ENC_014 checks $check_properties
                                    

    set check_properties []
    set check_properties [linsert $check_properties end [assert  {DUT.RS_CONTROL.r_state=END_CODEWORD |=> o_valid and o_end_codeword} -name REQ_RS_ENC_015.CHECK.01]]
    set check_properties [linsert $check_properties end [assert  {DUT.RS_CONTROL.r_state=GENERATE_PARITY |=> $past(not(o_in_ready)) and not(o_error) and not(o_start_codeword) and not(o_end_codeword) and not(o_error)} -name REQ_RS_ENC_015.CHECK.02]]
    dict set requirements REQ_RS_ENC_015 checks $check_properties

#   Covers
    set cover_properties []
    set cover_properties [linsert $cover_properties end [cover {DUT.RS_CONTROL.r_state=WAIT_SYMBOL and i_valid and i_start_codeword and not(i_end_codeword)|=> DUT.RS_CONTROL.r_state=START_CODEWORD} -name REQ_RS_ENC_002.COVER.01]]
    set cover_properties [linsert $cover_properties end [cover {DUT.RS_CONTROL.r_state=WAIT_SYMBOL and not(i_valid) |=> DUT.RS_CONTROL.r_state=WAIT_SYMBOL} -name REQ_RS_ENC_002.COVER.02]]
    set cover_properties [linsert $cover_properties end [cover {DUT.RS_CONTROL.r_state=WAIT_SYMBOL and i_valid and i_end_codeword and not(i_start_codeword) |=> DUT.RS_CONTROL.r_state=ERROR} -name REQ_RS_ENC_002.COVER.03]]
    set cover_properties [linsert $cover_properties end [cover {DUT.RS_CONTROL.r_state=WAIT_SYMBOL and i_valid and i_start_codeword and not(i_end_codeword)|=> mod2.sending_codeword_i} -name REQ_RS_ENC_002.COVER.04]]
    dict set requirements REQ_RS_ENC_002 covers $cover_properties

    set cover_properties []
    set cover_properties [linsert $cover_properties end [cover  {DUT.RS_CONTROL.r_state=ERROR |=> DUT.RS_CONTROL.r_state=ERROR} -name REQ_RS_ENC_003.COVER.01]]
    set cover_properties [linsert $cover_properties end [cover  {DUT.RS_CONTROL.r_state=ERROR |=> o_error} -name REQ_RS_ENC_003.COVER.02]]
    set cover_properties [linsert $cover_properties end [cover  {DUT.RS_CONTROL.r_state=ERROR |=> not(o_start_codeword) and not(o_end_codeword) and not(o_in_ready) and not(o_valid) } -name REQ_RS_ENC_003.COVER.03]]
    dict set requirements REQ_RS_ENC_003 covers $cover_properties

    set cover_properties []
    dict set requirements REQ_RS_ENC_005 checks $cover_properties
    set cover_properties []
    set cover_properties [linsert $cover_properties end [cover {DUT.RS_CONTROL.r_state=PROCESS_SYMBOLS and  i_valid and i_start_codeword |=> DUT.RS_CONTROL.r_state=ERROR} -name REQ_RS_ENC_005.COVER.01]]
    if {$k == 2} {
        set cover_properties [linsert $cover_properties end [cover {DUT.RS_CONTROL.r_state=PROCESS_SYMBOLS and (not i_valid or (not i_end_codeword and not i_start_codeword)) |=> DUT.RS_CONTROL.r_state=GENERATE_PARITY} -name REQ_RS_ENC_005.COVER.02]]
        set cover_properties [linsert $cover_properties end [cover {DUT.RS_CONTROL.r_state=PROCESS_SYMBOLS and (i_valid and (i_end_codeword or i_start_codeword)) |=> DUT.RS_CONTROL.r_state=ERROR} -name REQ_RS_ENC_005.COVER.03]]
        set cover_properties [linsert $cover_properties end [cover {DUT.RS_CONTROL.r_state=PROCESS_SYMBOLS |=> DUT.RS_CONTROL.r_state = ERROR or DUT.RS_CONTROL.r_state = GENERATE_PARITY} -name REQ_RS_ENC_005.COVER.04]]
    } else {
        set cover_properties [linsert $cover_properties end [cover {not i_end_codeword and DUT.RS_CONTROL.r_state=START_CODEWORD ##1 i_valid and (not i_end_codeword and not i_start_codeword) and DUT.RS_CONTROL.r_state=PROCESS_SYMBOLS [*1:(K-3)] |=> DUT.RS_CONTROL.r_state=PROCESS_SYMBOLS}  -name REQ_RS_ENC_005.COVER.02]]
        set cover_properties [linsert $cover_properties end [cover {not i_end_codeword and DUT.RS_CONTROL.r_state=START_CODEWORD ##1 i_valid and (not i_end_codeword and not i_start_codeword) and DUT.RS_CONTROL.r_state=PROCESS_SYMBOLS [*1:(K-3)] ##1 not i_valid |=> DUT.RS_CONTROL.r_state=STALL}  -name REQ_RS_ENC_005.COVER.03]]
        set cover_properties [linsert $cover_properties end [cover {not i_end_codeword and DUT.RS_CONTROL.r_state=START_CODEWORD ##1 i_valid and not i_end_codeword and not i_start_codeword and DUT.RS_CONTROL.r_state=PROCESS_SYMBOLS [*K-2] |=> DUT.RS_CONTROL.r_state=ERROR}  -name REQ_RS_ENC_005.COVER.04]]
        set cover_properties [linsert $cover_properties end [cover {not i_end_codeword and DUT.RS_CONTROL.r_state=START_CODEWORD ##1 i_valid and not i_end_codeword and not i_start_codeword and DUT.RS_CONTROL.r_state=PROCESS_SYMBOLS[*K-3] ##1 i_valid and  i_end_codeword and not i_start_codeword and DUT.RS_CONTROL.r_state=PROCESS_SYMBOLS ##1 DUT.RS_CONTROL.r_state=PROCESS_SYMBOLS and (not i_valid and not i_start_codeword and not i_end_codeword)|=> DUT.RS_CONTROL.r_state=GENERATE_PARITY}  -name REQ_RS_ENC_005.COVER.05]]
        set cover_properties [linsert $cover_properties end [cover {i_end_codeword and DUT.RS_CONTROL.r_state=START_CODEWORD ##1 not i_valid and DUT.RS_CONTROL.r_state=PROCESS_SYMBOLS and (not i_start_codeword and not i_end_codeword)|=> DUT.RS_CONTROL.r_state=GENERATE_PARITY}  -name REQ_RS_ENC_005.COVER.06]]
        set cover_properties [linsert $cover_properties end [cover {i_end_codeword and DUT.RS_CONTROL.r_state=START_CODEWORD ##1 i_valid and DUT.RS_CONTROL.r_state=PROCESS_SYMBOLS and (i_valid and (i_start_codeword or i_end_codeword))|=> DUT.RS_CONTROL.r_state=ERROR}  -name REQ_RS_ENC_005.COVER.07]]
    }
    dict set requirements REQ_RS_ENC_005 covers $cover_properties

    set cover_properties []
    set cover_properties [linsert $cover_properties end [cover {not(i_end_codeword) ##1 DUT.RS_CONTROL.r_state=START_CODEWORD and i_valid and i_end_codeword and not(i_start_codeword) |=> DUT.RS_CONTROL.r_state=PROCESS_SYMBOLS} -name REQ_RS_ENC_006.COVER.01]]
        set cover_properties [linsert $cover_properties end [cover {i_end_codeword ##1 DUT.RS_CONTROL.r_state=START_CODEWORD and not i_valid and not (i_end_codeword) and not(i_start_codeword) |=> DUT.RS_CONTROL.r_state=GENERATE_PARITY} -name REQ_RS_ENC_006.COVER.02]]
    set k [lindex [get_design_info -list parameter] 1]
    if {$k == 2} {
        set cover_properties [linsert $cover_properties end [cover {not(i_end_codeword) ##1 DUT.RS_CONTROL.r_state=START_CODEWORD and i_valid and not (i_end_codeword) and not(i_start_codeword) |=> DUT.RS_CONTROL.r_state=ERROR} -name REQ_RS_ENC_006.COVER.03]]
    } else {
        set cover_properties [linsert $cover_properties end [cover {not(i_end_codeword) ##1 DUT.RS_CONTROL.r_state=START_CODEWORD and i_valid and not (i_end_codeword) and not(i_start_codeword) |=> DUT.RS_CONTROL.r_state=PROCESS_SYMBOLS} -name REQ_RS_ENC_006.COVER.03]]
    }
    set cover_properties [linsert $cover_properties end [cover {DUT.RS_CONTROL.r_state=START_CODEWORD and not(i_valid) and $past(not(i_end_codeword)) |=> DUT.RS_CONTROL.r_state=STALL_FIRST} -name REQ_RS_ENC_006.COVER.04]]
    dict set requirements REQ_RS_ENC_006 covers $cover_properties

    set cover_properties []
    set cover_properties [linsert $cover_properties end [assert {DUT.RS_CONTROL.r_state=START_CODEWORD |=> o_start_codeword and o_valid and $past(o_in_ready)} -name REQ_RS_ENC_007.COVER.01]]
    set cover_properties [linsert $cover_properties end [assert {DUT.RS_CONTROL.r_state=END_CODEWORD |=> o_end_codeword} -name REQ_RS_ENC_007.COVER.02]]
    dict set requirements REQ_RS_ENC_007 checks $cover_properties

    set cover_properties []
    set cover_properties [linsert $cover_properties end [assert {DUT.RS_CONTROL.r_state=STALL and not(i_valid)  |=> DUT.RS_CONTROL.r_state=STALL} -name REQ_RS_ENC_008.COVER.01]]
    set cover_properties [linsert $cover_properties end [assert {DUT.RS_CONTROL.r_state=STALL and i_valid and not i_start_codeword and i_end_codeword |=> DUT.RS_CONTROL.r_state=PROCESS_SYMBOLS} -name REQ_RS_ENC_008.COVER.02]]
    set cover_properties [linsert $cover_properties end [assert {DUT.RS_CONTROL.r_state=STALL and i_valid and not i_start_codeword and DUT.RS_CONTROL.r_counter=DUT.rs_CONTROL.DATA_LIMIT_INDEX-1 and not i_end_codeword |=> DUT.RS_CONTROL.r_state=ERROR} -name REQ_RS_ENC_008.COVER.03]]
    if {$k != 2} {
        set cover_properties [linsert $cover_properties end [assert {DUT.RS_CONTROL.r_state=STALL and i_valid and not i_start_codeword and DUT.RS_CONTROL.r_counter/=DUT.rs_CONTROL.DATA_LIMIT_INDEX-1 and not i_end_codeword |=> DUT.RS_CONTROL.r_state=PROCESS_SYMBOLS} -name REQ_RS_ENC_008.COVER.04]]
    }
    dict set requirements REQ_RS_ENC_008 covers $cover_properties

    set cover_properties []
    set cover_properties [linsert $cover_properties end [cover {DUT.RS_CONTROL.r_state=STALL |=> o_in_ready} -name REQ_RS_ENC_009.COVER.01]]
    set cover_properties [linsert $cover_properties end [cover {DUT.RS_CONTROL.r_state=STALL |=> not(o_error) and not(o_valid) and not(o_start_codeword) and not(o_end_codeword) } -name REQ_RS_ENC_009.COVER.02]]
    dict set requirements REQ_RS_ENC_009 covers $cover_properties

    set cover_properties []
    if {$k == 2} {
        set cover_properties [linsert $cover_properties end [cover {DUT.RS_CONTROL.r_state=PROCESS_SYMBOLS |-> $past(i_end_codeword)} -name REQ_RS_ENC_010.COVER.01]]
    } else {
        set cover_properties [linsert $cover_properties end [cover  {DUT.RS_CONTROL.r_state=PROCESS_SYMBOLS and not(i_valid) and $past(not(i_end_codeword)) |=> DUT.RS_CONTROL.r_state=STALL} -name REQ_RS_ENC_010.COVER.01]]
    }
    set cover_properties [linsert $cover_properties end [cover  {DUT.RS_CONTROL.r_state=PROCESS_SYMBOLS and not(i_valid) and $past(i_end_codeword) and not(i_start_codeword)|=> DUT.RS_CONTROL.r_state=GENERATE_PARITY} -name REQ_RS_ENC_010.COVER.02]]
    dict set requirements REQ_RS_ENC_010 covers $cover_properties

    set cover_properties []
    set cover_properties [linsert $cover_properties end [cover  {DUT.RS_CONTROL.r_state=PROCESS_SYMBOLS |=> $past(o_in_ready) and o_valid } -name REQ_RS_ENC_011.COVER.01]]
    set cover_properties [linsert $cover_properties end [cover  {DUT.RS_CONTROL.r_state=PROCESS_SYMBOLS |=> not(o_end_codeword) and not(o_start_codeword)} -name REQ_RS_ENC_011.COVER.02]]
    dict set requirements REQ_RS_ENC_011 covers $cover_properties

    set cover_properties []
    set cover_properties [linsert $cover_properties end [cover {not(i_start_codeword) and not (i_end_codeword) and DUT.RS_CONTROL.r_state=GENERATE_PARITY[*N-K-1] |=> DUT.RS_CONTROL.r_state=END_CODEWORD}  -name REQ_RS_ENC_012.COVER.01]]
    set cover_properties [linsert $cover_properties end [cover  {DUT.RS_CONTROL.r_state=GENERATE_PARITY and i_valid and i_start_codeword |=> DUT.RS_CONTROL.r_state=ERROR} -name REQ_RS_ENC_012.COVER.02]]
    set cover_properties [linsert $cover_properties end [cover  {DUT.RS_CONTROL.r_state=GENERATE_PARITY and i_valid and i_end_codeword |=> DUT.RS_CONTROL.r_state=ERROR} -name REQ_RS_ENC_012.COVER.03]]
    dict set requirements REQ_RS_ENC_012 covers $cover_properties

    set cover_properties []
    set cover_properties [linsert $cover_properties end [cover  {DUT.RS_CONTROL.r_state=GENERATE_PARITY |-> not o_in_ready} -name REQ_RS_ENC_013.COVER.01]]
    set cover_properties [linsert $cover_properties end [cover  {DUT.RS_CONTROL.r_state=GENERATE_PARITY |=> o_valid and not(o_start_codeword) and not(o_end_codeword) and not(o_error)} -name REQ_RS_ENC_013.COVER.02]]
    dict set requirements REQ_RS_ENC_013 covers $cover_properties

    set cover_properties []
    set cover_properties [linsert $cover_properties end [cover {DUT.RS_CONTROL.r_state=END_CODEWORD and mod2.i_valid and mod2.i_start_codeword |=> DUT.RS_CONTROL.r_state=START_CODEWORD} -name REQ_RS_ENC_014.COVER.01]]
    dict set requirements REQ_RS_ENC_014 covers $cover_properties

    set cover_properties []
    set cover_properties [linsert $cover_properties end [cover  {DUT.RS_CONTROL.r_state=END_CODEWORD |=> o_valid and o_end_codeword} -name REQ_RS_ENC_015.COVER.01]]
    set cover_properties [linsert $cover_properties end [cover  {DUT.RS_CONTROL.r_state=GENERATE_PARITY |=> $past(not(o_in_ready)) and not(o_error) and not(o_start_codeword) and not(o_end_codeword) and not(o_error)} -name REQ_RS_ENC_015.COVER.02]]
    dict set requirements REQ_RS_ENC_015 covers $cover_properties


    #TASK FOR GOLDEN REQUIREMENT
    task -create functional -set

    # Assumptions
    set generate_properties []
    set generate_properties [linsert $generate_properties end [assume -bound 1 i_start_codeword -name REQ_RS_ENC_016.GENERATE.01]]
    set generate_properties [linsert $generate_properties end [assume {i_start_codeword |=> not (i_start_codeword)} -name REQ_RS_ENC_016.GENERATE.02]]
    set generate_properties [linsert $generate_properties end [assume {not (i_start_codeword) |=> not (i_start_codeword)} -name REQ_RS_ENC_016.GENERATE.03]]

    set CMD "assume \{##$k not i_end_codeword |=> not i_end_codeword\} -name REQ_RS_ENC_016.GENERATE.04"
    set generate_properties [linsert $generate_properties end [eval $CMD]]
    set num_cycles_not_end_codeword [expr {$k - 1}]
    set CMD "assume \{i_start_codeword |-> not i_end_codeword \[*0:$num_cycles_not_end_codeword\] ##1 i_end_codeword\} -name REQ_RS_ENC_016.GENERATE.05"
    set generate_properties [linsert $generate_properties end [eval $CMD]]
    set generate_properties [linsert $generate_properties end [assume {i_end_codeword |=> not (i_valid)} -name REQ_RS_ENC_016.GENERATE.06]]
    set generate_properties [linsert $generate_properties end [assume {not (i_valid) |=> not (i_valid)} -name REQ_RS_ENC_016.GENERATE.07]]

    #set generate_properties [linsert $generate_properties end [assume {not i_end_codeword [] ##1 i_end_codeword |=> not (i_end_codeword)} -name REQ_RS_ENC_016.GENERATE.04]]
    #set generate_properties [linsert $generate_properties end [assume {i_end_codeword |=> not (i_end_codeword)} -name REQ_RS_ENC_016.GENERATE.04]]
    #set generate_properties [linsert $generate_properties end [assume {not (i_end_codeword) |=> not (i_end_codeword)} -name REQ_RS_ENC_016.GENERATE.05]]
    dict set requirements REQ_RS_ENC_016 generates $generate_properties

    # Asserts 
    set check_properties []
    set check_properties [linsert $check_properties end [assert  {o_end_codeword |=> not(o_syndrome)} -name REQ_RS_ENC_016.CHECK.01]]
    set check_properties [linsert $check_properties end [assert  {o_end_codeword |-> not DUT.rs_PROCESS_UNIT.r_cascade_outputs} -name REQ_RS_ENC_016.CHECK.02]]
    dict set requirements REQ_RS_ENC_016 checks $check_properties

    #Covers
    set cover_properties []
    set cover_properties [linsert $cover_properties end [cover  {o_end_codeword |=> not(o_syndrome)} -name REQ_RS_ENC_016.COVER.01]]
    set check_properties [linsert $check_properties end [cover  {o_end_codeword |-> not DUT.rs_PROCESS_UNIT.r_cascade_outputs} -name REQ_RS_ENC_016.COVER.02]]
    dict set requirements REQ_RS_ENC_016 covers $cover_properties

    #TASK FOR RESET CHECK
    task -create reset -set

    # Asserts 
    set check_properties []
    set check_properties [linsert $check_properties end [assert {rst |=> DUT.RS_CONTROL.r_state=WAIT_SYMBOL} -name REQ_RS_ENC_001.CHECK.01]]
    set check_properties [linsert $check_properties end [assert {rst |=> not(i_valid and o_error and o_in_ready and o_end_codeword and o_start_codeword)} -name REQ_RS_ENC_001.CHECK.02]]
    dict set requirements REQ_RS_ENC_001 checks $check_properties

    #Covers
    set cover_properties []
    set cover_properties [linsert $cover_properties end [cover {rst |=> DUT.RS_CONTROL.r_state=WAIT_SYMBOL} -name REQ_RS_ENC_001.COVER.01]]
    set cover_properties [linsert $cover_properties end [cover {rst |=> not(i_valid and o_error and o_in_ready and o_end_codeword and o_start_codeword)} -name REQ_RS_ENC_001.COVER.02]]
    dict set requirements REQ_RS_ENC_001 covers $check_properties
  
    return $requirements
}

proc generate_csv_report {requirements N K} {
    #TODO: Create a report to dump in a CSV file. The name of the file must have the encoder
    # parameters. It is a simple CSV file with requirements, properties and their status. 
    # An example of an iteration in a dict is showed below.
    foreach key [dict keys $requirements] {
        set description_value [dict get $requirements $key description]
        catch {set generates_value [dict get $requirements $key generates]}
        catch {set checks_value [dict get $requirements $key checks]}
        catch {set covers_value [dict get $requirements $key covers]}
        
        puts "--------------------------------------------------------------------"
        puts "$key:"
        puts "Description: $description_value"
        puts "Generates: $generates_value"
        puts "Checks: $checks_value"
        puts "Covers: $covers_value"
    }
}
