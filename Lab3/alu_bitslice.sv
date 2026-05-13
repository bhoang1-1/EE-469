`timescale 1ns/10ps

module alu_bitslice(A, B, Cin, cntrl, Cout, out);
	input logic A, B, Cin;
	input logic [2:0] cntrl;
	output logic Cout, out;
	
	logic [7:0] results;
	
	
	
	//ALU_PASS_B=3'b000, ALU_ADD=3'b010, ALU_SUBTRACT=3'b011, ALU_AND=3'b100, ALU_OR=3'b101, ALU_XOR=3'b110;
	
	
	logic adder_result;
	logic B_input;
	xor #0.05 xinv(B_input, B, cntrl[0]); //if cntrl[0] == 1 == subtraction, will flip B, else B will stay the same
	
	full_adder adder(.A(A), .B(B_input), .Cin(Cin), .Cout(Cout), .sum(adder_result));
	
	
	logic and_result, or_result, xor_result;
	
	and #0.05 and1 (and_result, A, B);
	or #0.05 or1 (or_result, A, B);
	xor #0.05 xor1 (xor_result, A, B);
	
	
	assign results[0] = B;
	assign results[1] = 1'b0; // unused
	assign results[2] = adder_result;
	assign results[3] = adder_result;
	assign results[4] = and_result;
	assign results[5] = or_result;
	assign results[6] = xor_result;
	assign results[7] = 1'b0; // unused
	
	mux8_1 mux1(.out(out), .in(results), .sel(cntrl));
	
endmodule