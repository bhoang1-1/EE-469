`timescale 1ns/10ps

module decoder2_4(out, in, en);
	output logic [3:0] out;
	input logic [1:0] in;
	input logic en;
	
	logic inv_0, inv_1;
	
	not  #0.05 n0 (inv_0, in[0]);
	not  #0.05 n1 (inv_1, in[1]);
	
	and  #0.05 a0 (out[0], inv_0, inv_1, en);
	and  #0.05 a1 (out[1], in[0], inv_1, en);
	and  #0.05 a2 (out[2], inv_0, in[1], en);
	and  #0.05 a3 (out[3], in[0], in[1], en);
endmodule
	
	
module decoder3_8(out, in, en);
	output logic [7:0] out;
	input logic [2:0] in;
	input logic en;
	
	logic inv_0, inv_1, inv_2;
	
	not  #0.05 n0 (inv_0, in[0]);
	not  #0.05 n1 (inv_1, in[1]);
	not  #0.05 n2 (inv_2, in[2]);
	
	and  #0.05 a0 (out[0], inv_0, inv_1, inv_2, en);
	and  #0.05 a1 (out[1], in[0], inv_1, inv_2, en);
	and  #0.05 a2 (out[2], inv_0, in[1], inv_2, en);
	and  #0.05 a3 (out[3], in[0], in[1], inv_2, en);
	and  #0.05 a4 (out[4], inv_0, inv_1, in[2], en);
	and  #0.05 a5 (out[5], in[0], inv_1, in[2], en);
	and  #0.05 a6 (out[6], inv_0, in[1], in[2], en);
	and  #0.05 a7 (out[7], in[0], in[1], in[2], en);

endmodule
	
module decoder5_32(out, in, en);
	output logic [31:0] out;
	input logic [4:0] in;
	input logic en;
	
	logic [3:0] middle;
	
	decoder2_4 d0(.out(middle), .in(in[4:3]), .en(en));
	
	decoder3_8 d1(.out(out[7:0]), .in(in[2:0]), .en(middle[0]));
	decoder3_8 d2(.out(out[15:8]), .in(in[2:0]), .en(middle[1]));
	decoder3_8 d3(.out(out[23:16]), .in(in[2:0]), .en(middle[2]));
	decoder3_8 d4(.out(out[31:24]), .in(in[2:0]), .en(middle[3]));

endmodule
	
		
	
	
	
	

