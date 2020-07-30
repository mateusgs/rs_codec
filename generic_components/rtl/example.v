
// Generated by Cadence Genus(TM) Synthesis Solution 17.20-p003_1
// Generated on: Jun 26 2020 23:56:25 -03 (Jun 27 2020 02:56:25 UTC)

// Verification Directory fv/sync_ld_dff 

module sync_ld_dff(rst, clk, ld, i_data, o_data);
  input rst, clk, ld;
  input [3:0] i_data;
  output [3:0] o_data;
  wire rst, clk, ld;
  wire [3:0] i_data;
  wire [3:0] o_data;
  wire n_0, n_1, n_2, n_3, n_4, n_5, n_6, n_7;
  wire n_8, n_9, n_10, n_11, n_12, n_13, n_14, n_15;
  wire n_16, n_17, n_18, n_19, n_20;
  fflopd \o_data_reg[0] (.CK (clk), .D (n_17), .Q (o_data[0]));
  fflopd \o_data_reg[1] (.CK (clk), .D (n_18), .Q (o_data[1]));
  fflopd \o_data_reg[3] (.CK (clk), .D (n_19), .Q (o_data[3]));
  fflopd \o_data_reg[2] (.CK (clk), .D (n_20), .Q (o_data[2]));
  nor2 g19(.A (n_16), .B (rst), .Y (n_20));
  nor2 g20(.A (n_15), .B (rst), .Y (n_19));
  nor2 g17(.A (n_14), .B (rst), .Y (n_18));
  nor2 g18(.A (n_13), .B (rst), .Y (n_17));
  inv1 g25(.A (n_12), .Y (n_16));
  inv1 g26(.A (n_11), .Y (n_15));
  inv1 g21(.A (n_10), .Y (n_14));
  inv1 g22(.A (n_9), .Y (n_13));
  nand2 g27(.A (n_5), .B (n_3), .Y (n_12));
  nand2 g28(.A (n_4), .B (n_2), .Y (n_11));
  nand2 g23(.A (n_7), .B (n_1), .Y (n_10));
  nand2 g24(.A (n_8), .B (n_0), .Y (n_9));
  nand2 g29(.A (o_data[0]), .B (n_6), .Y (n_8));
  nand2 g30(.A (o_data[1]), .B (n_6), .Y (n_7));
  nand2 g31(.A (o_data[2]), .B (n_6), .Y (n_5));
  nand2 g32(.A (o_data[3]), .B (n_6), .Y (n_4));
  nand2 g36(.A (ld), .B (i_data[2]), .Y (n_3));
  nand2 g33(.A (ld), .B (i_data[3]), .Y (n_2));
  nand2 g34(.A (ld), .B (i_data[1]), .Y (n_1));
  nand2 g35(.A (ld), .B (i_data[0]), .Y (n_0));
  inv1 g37(.A (ld), .Y (n_6));
endmodule

