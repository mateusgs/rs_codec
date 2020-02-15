module fv_encod #(word_length=8, n=15, k=11) (
		  clk,
		  rst,
		  i_start_codeword,
		  i_end_codeword,
		  i_valid,
		  i_symbol,
		  o_start_codeword,
		  o_end_codeword,
		  o_error,
		  o_in_ready,
		  o_valid,
		  o_symbol);

input			clk;
input		  	rst;
input		  	i_start_codeword;
input		  	i_end_codeword;
input		  	i_valid;
input [word_length-1:0]	i_symbol;
input		  	o_start_codeword;
input		  	o_end_codeword;
input		  	o_error;
input		  	o_in_ready;
input		  	o_valid;
input [word_length-1:0]	o_symbol;


localparam WAIT_SYMBOL 		= 3'b000;
localparam START_CODEWORD 	= 3'b001;
localparam PROCESS_SYMBOLS 	= 3'b010;
localparam GENERATE_PARITY 	= 3'b011;
localparam END_CODEWORD		= 3'b100;
localparam STALL		= 3'b101;
localparam ERROR 		= 3'b110;


reg sending_codeword_i;	
reg sending_codeword_o;

reg[n-k:0] count_send;


/*************Signal input**************/
always @(posedge clk) begin
  if (rst) begin
    sending_codeword_i 	<= 0;
  end 
  else if (i_valid && i_start_codeword && !(i_end_codeword)) begin
    sending_codeword_i <= 1;
  end 
  else if (i_end_codeword && i_valid) begin
    sending_codeword_i 	<= 0;
  end
  else if (count_send > n-k+1) begin
    sending_codeword_i 	<= 0;
  end    
end


always @(posedge clk) begin
  if (rst) 
    count_send 		<= 0; 
  else if (i_valid && i_start_codeword && !(i_end_codeword)) 
    count_send <= count_send +1;
  else if (i_end_codeword && i_valid) begin
    count_send		<= 0;
  end
  else
    count_send <= count_send+1;
end




/*************Signal Output**************/
always @(posedge clk) begin
  if (rst) 
    sending_codeword_o <= 0;
  else if (o_valid && o_start_codeword && !(o_end_codeword))
    sending_codeword_o <= 1;
  else if (o_end_codeword && o_valid) 
    sending_codeword_o <= 0;
end



//* **********ASSERTIONS**********
// In the cycle subsequent to 'START_CODEWORD' transition, 'o_start_codeword', 'o_valid' and 'o_in_ready' shall be set to '1'. Other output control signal shall be '0'.
/*ASRT_o_start_codeword			: assert property (@(posedge clk) (i_start_codeword && i_valid) |=> (o_start_codeword && o_valid && o_in_ready));


// REQ_rs_ENC_017: 'o_start_codeword' or 'o_end_codeword' should always be interleaved
ASRT_o_start_codeword_intervalent	: assert property (@(posedge clk) sending_codeword_o |-> (!o_start_codeword));
//ASRT_one_cycle_start 			: assert property (@(posedge clk) o_valid && o_start_codeword |=> !o_start_codeword);
ASRT_o_end_codeword_intervalent	: assert property (@(posedge clk) !sending_codeword_o |-> (!o_end_codeword));


// In the cycle subsequent to 'END_CODEWORD' transition, 'o_valid' and 'o_end_codeword' are assigned \ '1', and the other output control signal are assigned to zero."
ASRT_o_end_codeword_transition		: assert property (@(posedge clk) (i_end_codeword && i_valid) |=> (o_end_codeword && o_valid)); 
ASRT_o_end_codeword_transition_3	: assert property (@(posedge clk) (i_end_codeword && i_valid) |=> (!o_in_ready)); 

// Checking if o_end_codeword is only lasting one cycle
ASRT_one_cycle_end			: assert property (@(posedge clk) o_valid && o_end_codeword |=> !o_end_codeword);
ASRT_o_erro				: assert property (@(posedge clk) o_start_codeword |=> not(o_error));

*/


// The valid 'i_symbols' should be at 'o_symbol' with the delay of 1 cycle

/*jasper_scoreboard_3 #(
  .CHUNK_WIDTH	(8),
  .IN_CHUNKS 	(1),
  .OUT_CHUNKS	(1),
 // .MAX_PENDING  (254),
 // .LATENCY_CHECK(1),
  .LATENCY 	(1)
  ) scoreboard (
  .clk 		(clk),
  .rstN		(!rst),
  .incoming_vld	(i_valid & i_start_codeword),
  .incoming_data(i_symbol),
  .outgoing_vld (o_valid && o_in_ready & o_start_codeword),
  .outgoing_data(o_symbol)
);
*/


endmodule 
