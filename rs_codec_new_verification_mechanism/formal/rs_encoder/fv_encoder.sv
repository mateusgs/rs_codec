module fv_encod #(WORD_LENGTH=8, N=15, K=11) (
		  clk,
		  rst,
		  i_start_codeword,
		  i_end_codeword,
		  i_valid,
		  i_consume,
		  i_symbol,
		  o_start_codeword,
		  o_end_codeword,
		  o_error,
		  o_in_ready,
		  o_valid,
		  o_symbol);

input			  clk;
input		  	rst;
input		  	i_start_codeword;
input		  	i_end_codeword;
input		  	i_valid;
input		  	i_consume;
input       [WORD_LENGTH-1:0]	i_symbol;
input		  	o_start_codeword;
input		  	o_end_codeword;
input		  	o_error;
input		  	o_in_ready;
input		  	o_valid;
input       [WORD_LENGTH-1:0]	o_symbol;

localparam WAIT_SYMBOL 		= 3'b000;
localparam START_CODEWORD 	= 3'b001;
localparam PROCESS_SYMBOLS 	= 3'b010;
localparam GENERATE_PARITY 	= 3'b011;
localparam END_CODEWORD		= 3'b100;
localparam ERROR 		= 3'b101;

property p (expr);
    @(posedge clk) disable iff (rst)
    expr;
endproperty

let w_rx_start = i_start_codeword && i_valid && o_in_ready;
let w_tx_end = o_end_codeword && i_consume;
let w_receive_sym = i_valid && o_in_ready;

reg r_sending_cw;
reg r_sending_parity;
shortint r_symbol_cnt;
shortint r_parity_cnt;

always @(posedge clk or posedge o_error or posedge rst) begin
  if (rst || o_error) begin
     r_symbol_cnt <= 0; 
     r_parity_cnt <= 0; 
     r_sending_cw <= 1'b0;
     r_sending_parity <= 1'b0;
  end else if (w_rx_start) begin
     r_symbol_cnt <= 1;
     r_sending_cw <= 1'b1;
     r_parity_cnt <= 0; 
     if (i_end_codeword) begin
         r_sending_parity <= 1'b1;
     end else begin
         r_sending_parity <= 1'b0;
     end	
  end else if (w_tx_end) begin
     r_symbol_cnt <= 0; 
     r_parity_cnt <= 0; 
     r_sending_cw <= 1'b0;
     r_sending_parity <= 1'b0;
  end else if (r_sending_cw && !r_sending_parity && w_receive_sym) begin
     r_symbol_cnt <= r_symbol_cnt + 1;
     r_sending_cw <= 1'b1;
     r_parity_cnt <= 0; 
     if (i_end_codeword) begin
         r_sending_parity <= 1'b1;
     end else begin
         r_sending_parity <= 1'b0;
     end	
  end else if (r_sending_parity && i_consume) begin
     r_sending_cw <= 1'b1;
     r_symbol_cnt <= r_symbol_cnt + 1;
     r_parity_cnt <= r_parity_cnt + 1;
     r_sending_parity <= 1'b1;
  end else begin
     r_symbol_cnt <= r_symbol_cnt; 
     r_parity_cnt <= r_parity_cnt; 
     r_sending_cw <= r_sending_cw;
     r_sending_parity <= r_sending_parity;
  end
end

let rst_state = !o_end_codeword && !o_end_codeword && !o_error && !o_valid;
let r_state = DUT.RS_CONTROL.r_state;

// REQ_RS_ENC_001: Initial state of RS Encoder. 
REQ_RS_ENC_001_CHECK_01: assert property (rst |-> rst_state);
REQ_RS_ENC_001_CHECK_02: assert property (rst |-> o_in_ready == i_consume);
REQ_RS_ENC_001_CHECK_03: assert property (rst |-> r_state == WAIT_SYMBOL);

// REQ_RS_ENC_002: Valid 'WAIT_SYMBOL' transitions
let w_state_error_in_wait_symbol = i_end_codeword && i_valid && !i_start_codeword && i_consume;
REQ_RS_ENC_002_CHECK_01: assert property (p(r_state == WAIT_SYMBOL && w_rx_start |=> r_state == START_CODEWORD));
REQ_RS_ENC_002_CHECK_02: assert property (p(r_state == WAIT_SYMBOL && w_state_error_in_wait_symbol |=> r_state == ERROR));
REQ_RS_ENC_002_CHECK_03: assert property (p(r_state == WAIT_SYMBOL && 
                                          !w_rx_start && 
                                          !w_state_error_in_wait_symbol |=> r_state == WAIT_SYMBOL));


let w_error_during_rx = i_valid && o_in_ready && (i_start_codeword || (r_symbol_cnt == K-1 && !i_end_codeword));
let w_generate_parity_condition = !o_in_ready && i_consume;
let w_process_symbols = !w_error_during_rx && !w_generate_parity_condition && i_consume && i_valid;

// REQ_RS_ENC_003: Valid 'START_CODEWORD' transitions
REQ_RS_ENC_003_CHECK_01: assert property (p(r_state == START_CODEWORD && w_error_during_rx |=> r_state == ERROR));
REQ_RS_ENC_003_CHECK_02: assert property (p(r_state == START_CODEWORD && w_generate_parity_condition |=> r_state == GENERATE_PARITY));
REQ_RS_ENC_003_CHECK_03: assert property (p(r_state == START_CODEWORD && w_process_symbols |=> r_state == PROCESS_SYMBOLS));

// REQ_RS_ENC_004: Valid 'PROCESS_SYMBOLS' transitions
REQ_RS_ENC_004_CHECK_01: assert property (p(r_state == PROCESS_SYMBOLS && w_error_during_rx |=> r_state == ERROR));
REQ_RS_ENC_004_CHECK_02: assert property (p(r_state == PROCESS_SYMBOLS && w_generate_parity_condition |=> r_state == GENERATE_PARITY));
REQ_RS_ENC_004_CHECK_03: assert property (p(r_state == PROCESS_SYMBOLS && w_process_symbols |=> r_state == PROCESS_SYMBOLS));
REQ_RS_ENC_004_CHECK_03c: cover property (p(r_symbol_cnt == 2));

// REQ_RS_ENC_005: Valid 'GENERATE_PARITY' transitions
let w_end_codeword_condition = r_parity_cnt == N-K-1 && i_consume;

REQ_RS_ENC_005_CHECK_01: assert property (p(r_state == GENERATE_PARITY && 
                                          w_end_codeword_condition |=> r_state == END_CODEWORD));
REQ_RS_ENC_005_CHECK_02: assert property (p(r_state == GENERATE_PARITY && 
                                          !w_end_codeword_condition |=> r_state == GENERATE_PARITY));

// REQ_RS_ENC_006: Valid 'END_CODEWORD' transitions
let w_error_during_end_cw = i_valid && !i_start_codeword && i_end_codeword && i_consume;
let w_valid_start = i_valid && i_start_codeword && i_consume;
REQ_RS_ENC_006_CHECK_01: assert property (p(r_state == END_CODEWORD && w_error_during_end_cw |=> r_state == ERROR));
REQ_RS_ENC_006_CHECK_02: assert property (p(r_state == END_CODEWORD && !w_error_during_end_cw && !i_consume |=> r_state == END_CODEWORD));
REQ_RS_ENC_006_CHECK_03: assert property (p(r_state == END_CODEWORD && w_valid_start |=> r_state == START_CODEWORD));
REQ_RS_ENC_006_CHECK_04: assert property (p(r_state == END_CODEWORD && 
                                            !w_error_during_end_cw && 
                                            w_valid_start |=> r_state == START_CODEWORD));

// REQ_RS_ENC_007: Valid 'ERROR' transitions
REQ_RS_ENC_007_CHECK_01: assert property (p(r_state == ERROR && !rst |=> r_state == ERROR));

// REQ_RS_ENC_008: 'WAIT_SYMBOL' values
let w_wait_symbol_values = !o_end_codeword && !o_error && o_in_ready == i_consume && !o_start_codeword && !o_valid;
REQ_RS_ENC_008_CHECK_01: assert property (p(r_state == WAIT_SYMBOL |-> w_wait_symbol_values));
// REQ_RS_ENC_009: 'START_CODEWORD' values
let w_start_codeword_values = !o_end_codeword && !o_error && (o_in_ready == i_consume || r_sending_parity);
REQ_RS_ENC_009_CHECK_01: assert property (p(r_state == START_CODEWORD |-> w_start_codeword_values));
// REQ_RS_ENC_010: 'PROCESS_SYMBOLS' values
let w_process_symbols_values = !o_end_codeword && !o_error && (o_in_ready == i_consume || r_sending_parity) && !o_start_codeword;
REQ_RS_ENC_010_CHECK_01: assert property (p(r_state == PROCESS_SYMBOLS |-> w_process_symbols_values));
// REQ_RS_ENC_011: 'GENERATE_PARITY' values
let w_generate_parity_values = !o_end_codeword && !o_error && !o_in_ready && !o_start_codeword && o_valid;
REQ_RS_ENC_011_CHECK_01: assert property (p(r_state == GENERATE_PARITY |-> w_generate_parity_values));
// REQ_RS_ENC_012: 'END_CODEWORD' values
let w_end_codeword_values = o_end_codeword && !o_error && o_in_ready == i_consume && !o_start_codeword && o_valid;
REQ_RS_ENC_012_CHECK_01: assert property (p(r_state == END_CODEWORD |-> w_end_codeword_values));
// REQ_RS_ENC_014: 'ERROR' values
let w_error_values = !o_end_codeword && o_error && !o_in_ready && !o_start_codeword && !o_valid;
REQ_RS_ENC_014_CHECK_01: assert property (p(r_state == ERROR |-> w_error_values));

// REQ_RS_ENC_015: Check o_symbol stability if i_consume is de-asserted.
REQ_RS_ENC_015_CHECK_01: assert property (p(o_valid && !o_error && !i_consume |=> $past(o_symbol) == o_symbol));
REQ_RS_ENC_015_CHECK_02: assert property (p(o_valid && !o_error && !i_consume && o_start_codeword |=> $past(o_start_codeword) == o_start_codeword));
REQ_RS_ENC_015_CHECK_03: assert property (p(o_valid && !o_error && !i_consume && o_end_codeword |=> $past(o_end_codeword) == o_end_codeword));

// REQ_RS_ENC_016: Invalid output condition
REQ_RS_ENC_016_CHECK_01: assert property (p(!i_valid && i_consume && r_state != GENERATE_PARITY && r_state != END_CODEWORD |=> !o_valid || r_state == GENERATE_PARITY));
REQ_RS_ENC_016_CHECK_02: assert property (p(i_valid && i_consume && $past(i_consume) && $past(i_valid) && r_state == (START_CODEWORD || PROCESS_SYMBOLS) |-> $past(i_symbol) == o_symbol || r_state == ERROR));


// REQ_RS_ENC_017: Functional requirement
REQ_RS_ENC_017_CHECK_01: assert property (p(o_end_codeword and i_consume |=> !RS_SYNDROME_UNIT_INST.o_syndrome));
REQ_RS_ENC_017_CHECK_02: assert property (p(o_end_codeword and i_consume |-> !DUT.rs_PROCESS_UNIT.r_cascade_outputs));

// REQ_RS_ENC_018: Checking stall mechanism
REQ_RS_ENC_018_CHECK_01: assert property (p(($past(!i_consume) || $past(!i_valid)) && !o_error && !i_consume |=> DUT.rs_PROCESS_UNIT.r_cascade_outputs == $past(DUT.rs_PROCESS_UNIT.r_cascade_outputs)));
REQ_RS_ENC_018_CHECK_02: assert property (p(!i_valid && !o_error && !DUT.RS_CONTROL.o_select_parity_symbols ##1 !DUT.RS_CONTROL.o_select_parity_symbols |=> DUT.rs_PROCESS_UNIT.r_cascade_outputs == $past(DUT.rs_PROCESS_UNIT.r_cascade_outputs)));

endmodule 
