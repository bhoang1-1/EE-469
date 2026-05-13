`timescale 1ns/10ps
module full_adder(A, B, Cin, Cout, sum);
	input logic A, B, Cin;
	output logic Cout, sum;
	
	logic stage0, stage1, stage2;
	
	xor #0.05 xor1 (stage0, A, B);
	and #0.05 and1 (stage1, A, B);
	
	xor #0.05 xor2 (sum, stage0, Cin);
	and #0.05 and2 (stage2, stage0, Cin);
	
	or #0.05 or1 (Cout, stage2, stage1);

endmodule