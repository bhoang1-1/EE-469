module D_FF_64(q, d, we, clk, reset);
	output logic [63:0] q; // data stored
	input logic [63:0] d; // data we want to write
	input logic we; // write enabled
	input logic clk, reset;
	
	genvar i;
	generate
    for (i = 0; i < 64; i = i + 1) begin : bits
        logic d_in; // temporary variable 

		  mux2_1 m (.out(d_in), .i0(q[i]), .i1(d[i]), .sel(we)); // if we==0, output = q[i] (hold old value); if we==1, output = d[i] (write new value)

        D_FF ff_inst(.q(q[i]), .d(d_in), .clk(clk), .reset(reset));
		  
    end
	endgenerate
	
endmodule


module register_32(q, d, we, clk, reset);
	output logic [31:0][63:0] q; 
	input logic [63:0] d; // data we want to write
	input logic [31:0] we; // write enabled from decoder
	input logic clk, reset;
	
	genvar i;
	generate
    for (i = 0; i < 31; i = i + 1) begin : gen_reg
        D_FF_64 regs(.q(q[i]), .d(d), .we(we[i]), .clk(clk), .reset(reset));
    end
	endgenerate
	
	assign q[31] = 64'b0; // set 31st register to 0

endmodule


