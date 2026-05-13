`timescale 1ns/10ps

module alu(A, B, cntrl, result, negative, zero, overflow, carry_out);
	input  logic [63:0] A;
   input  logic [63:0] B;
   input  logic [2:0]  cntrl;
   output logic [63:0] result;
   output logic        negative, zero, overflow, carry_out;
	
	logic overflow_res;
	logic zero_res;
	logic [64:0] carry_bitslice;
   assign carry_bitslice[0] = cntrl[0]; // set first carryout to 1 if subtract, 0 if add, HANDLES ADD OR SUBTRACT, -B = ~B + 1
	
	genvar i;
	generate
		for(i = 0; i < 64; i = i + 1) begin: bitslices
			
			alu_bitslice slice(.A(A[i]), .B(B[i]), .Cin(carry_bitslice[i]), .cntrl(cntrl),.Cout(carry_bitslice[i+1]), .out(result[i]));
			
		end
	endgenerate
	
	//CARRY IS FOR UNSIGNED
	assign carry_out = carry_bitslice[64];
	assign negative = result[63];
	

	xor #0.05 xor1(overflow_res, carry_bitslice[64], carry_bitslice[63]);
	assign overflow = overflow_res;
	
	zero_checker zcheck(.out(zero_res), .data(result));
	assign zero = zero_res;
	
	
endmodule


module zero_checker(out, data);
	input logic [63:0] data;
	output logic out;
	
	logic [0:15] zero_stage1;
	logic [0:3] zero_stage2;
	logic zero_stage3;
	
	// loops need to be generate, b/c need to physically create 16 gates that run parallel
	// Basically, do a bunch of OR gates, if a 1 is found, output is 0, which means result is not all zeros
	
	genvar i;
	generate
		for(i = 0; i < 16; i = i + 1) begin: stage1
			or #0.05 or1(zero_stage1[i], data[i*4], data[(i*4) + 1], data[(i*4) + 2], data[(i*4) + 3]);
		end
	endgenerate
	
	
	generate
		for(i = 0; i < 4; i = i + 1) begin: stage2
			or #0.05 or2(zero_stage2[i], zero_stage1[i*4], zero_stage1[(i*4) + 1], zero_stage1[(i*4) + 2], zero_stage1[(i*4) + 3]);
		end
	endgenerate
	
	
	or #0.05 or3(zero_stage3, zero_stage2[0], zero_stage2[1], zero_stage2[2], zero_stage2[3]);
	
	not #0.05 (out, zero_stage3);
	
endmodule
