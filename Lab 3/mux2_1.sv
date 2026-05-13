`timescale 1ns/10ps

module mux2_1(out, i0, i1, sel);
	output logic out;
	input logic i0, i1, sel;
	
	//assign out = (i1 & sel) | (i0 & ~sel);
   logic inv_sel, i1_sel, i0_inv_sel;
	
	not #0.05 stage0 (inv_sel, sel);
	and #0.05 stage1a (i1_sel, i1, sel);
	and #0.05 stage1b (i0_inv_sel, i0, inv_sel);
	or  #0.05 stage2 (out, i1_sel, i0_inv_sel);
	
endmodule
module mux2_1_testbench();
	logic i0, i1, sel;
	logic out;
	mux2_1 dut (.out, .i0, .i1, .sel);
	initial begin
		sel=0; i0=0; i1=0; #10; 
		sel=0; i0=0; i1=1; #10;
		sel=0; i0=1; i1=0; #10;
		sel=0; i0=1; i1=1; #10;
		sel=1; i0=0; i1=0; #10;
		sel=1; i0=0; i1=1; #10;
		sel=1; i0=1; i1=0; #10;
		sel=1; i0=1; i1=1; #10;
	end
endmodule