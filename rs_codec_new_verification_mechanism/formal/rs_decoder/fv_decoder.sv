module fv_decoder #(word_length=8, n=15, k=11) (
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

input			clk;
input		  	rst;
input		  	i_start_codeword;
input		  	i_end_codeword;
input		  	i_valid;
input		  	i_consume;
input [word_length-1'b1:0]	i_symbol;
input		  	o_start_codeword;
input		  	o_end_codeword;
input		  	o_error;
input		  	o_in_ready;
input		  	o_valid;
input [word_length-1'b1:0]	o_symbol;


reg[n>>2:0] i_count,i_count_s, o_count,o_count_s;
reg i_sending_codeword;	
reg o_sending_codeword;

reg[n-k:0] count_send;



/*************Signal input**************/
always @(posedge clk) begin
  if (rst) 
    i_sending_codeword <= 0;
  else if (i_valid && i_start_codeword && !(i_end_codeword) && o_in_ready)
    i_sending_codeword <= 1;
  else if (i_valid && i_end_codeword && o_in_ready)
    i_sending_codeword <= 0;
end 


assign i_count_s = i_count;
/*************Count input**************/
always @(posedge clk) begin
  if (rst) 
    i_count <= 0;
  else if (i_valid && i_sending_codeword)
    i_count <= i_count+1'b1;
  else if (i_valid && !i_sending_codeword)
    i_count <= 0;
  else
    i_count <= i_count_s;
end 

/*************Signal output**************/
always @(posedge clk) begin
  if (rst) 
    o_sending_codeword <= 0;
  else if (o_valid && o_start_codeword && !(o_end_codeword) && i_consume)
    o_sending_codeword <= 1;
  else if (o_valid && o_end_codeword && i_consume)
    o_sending_codeword <= 0;
end 

assign o_count_s = o_count;

/************* Count output**************/
always @(posedge clk) begin
  if (rst) 
    o_count <= 0;
  else if (o_valid && i_consume && o_sending_codeword)
    o_count <= o_count+1'b1;
  else if (o_valid && !o_sending_codeword)
    o_count <= 0;
  else
    o_count <= o_count_s;
end 




/*************FIFO**************/
reg [n>>2:0] mem [0:15];
reg [n>>2:0] counter_out;
wire [n>>2:0] counter_out_s;
reg [n>>2:0] count,rd_pointer,wr_pointer;


always @(posedge clk) begin
  if (rst) begin
    for (int i=0; i<n>>2; i=i+1'b1)
      mem[i] <= 0;
  end 
  else if (i_sending_codeword && i_end_codeword && i_valid) 
    mem[wr_pointer] <= i_count+1'b1;
end 

always @ (posedge clk) begin
  if (rst) begin
    rd_pointer <= 0;
  end 
  else if (o_valid && o_start_codeword && i_consume) begin
    rd_pointer <= rd_pointer+1'b1;
  end 
  else
    rd_pointer <= rd_pointer;
end

always @ (posedge clk) begin
  if (rst)
    wr_pointer <= 0;
  else if (i_sending_codeword && i_end_codeword && i_valid)
    wr_pointer <= wr_pointer+1'b1;
  //else if (o_valid && o_end_codeword)
  //  wr_pointer <= wr_pointer-1'b1;
  else 
    wr_pointer <= wr_pointer;
end

always @(posedge clk) begin
  if (rst)
    counter_out <= 0;
  else if (o_valid && o_start_codeword)
    counter_out <= mem[rd_pointer];
  else
    counter_out <= counter_out_s;
end

assign counter_out_s = counter_out;

  






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
 
