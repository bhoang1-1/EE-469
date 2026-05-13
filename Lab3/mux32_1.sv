module mux4_1(out, i00, i01, i10, i11, sel0, sel1);
	output logic out;
	input logic i00, i01, i10, i11, sel0, sel1;
	logic v0, v1;
	mux2_1 m0(.out(v0), .i0(i00), .i1(i01), .sel(sel0));
	mux2_1 m1(.out(v1), .i0(i10), .i1(i11), .sel(sel0));
	mux2_1 m (.out(out), .i0(v0), .i1(v1), .sel(sel1));
endmodule

module mux8_1(out, in, sel);
	output logic out;
	input logic [7:0] in;
	input logic [2:0] sel;
	
	logic v0, v1;
	
	mux4_1 m0(.out(v0), .i00(in[0]), .i01(in[1]), .i10(in[2]), .i11(in[3]), .sel0(sel[0]), .sel1(sel[1]));
	mux4_1 m1(.out(v1), .i00(in[4]), .i01(in[5]), .i10(in[6]), .i11(in[7]), .sel0(sel[0]), .sel1(sel[1]));
	mux2_1 m (.out(out), .i0(v0), .i1(v1), .sel(sel[2]));
endmodule



module mux32_1(out, in, sel);
    output logic out;
    input logic [31:0] in;
    input logic [4:0] sel;

    // Intermediate wires to hold the results from the four 8:1 muxes
    logic v0, v1, v2, v3;

    // Stage 1: Four 8:1 Muxes
    // pass the lowest 3 bits of 'sel' to these
    mux8_1 m0 (.out(v0), .in(in[7:0]),   .sel(sel[2:0]));
    mux8_1 m1 (.out(v1), .in(in[15:8]),  .sel(sel[2:0]));
    mux8_1 m2 (.out(v2), .in(in[23:16]), .sel(sel[2:0]));
    mux8_1 m3 (.out(v3), .in(in[31:24]), .sel(sel[2:0]));

    // Stage 2: One 4:1 Mux to pick the final bit
    // pass the highest 2 bits of 'sel' here
    mux4_1 final_mux (.out(out), .i00(v0), .i01(v1), .i10(v2), .i11(v3), .sel0(sel[3]), .sel1(sel[4]));
endmodule

module mux32_1_64(out, in , sel);
	output logic [63:0] out;
	input  logic [31:0][63:0] in;
   input  logic [4:0] sel;
	
	genvar i;

    generate
        for (i = 0; i < 64; i = i + 1) begin : muxes
            mux32_1 m (
                .out(out[i]),
                .in({
							 in[31][i], in[30][i], in[29][i], in[28][i],
							 in[27][i], in[26][i], in[25][i], in[24][i],
							 in[23][i], in[22][i], in[21][i], in[20][i],
							 in[19][i], in[18][i], in[17][i], in[16][i],
							 in[15][i], in[14][i], in[13][i], in[12][i],
							 in[11][i], in[10][i], in[9][i],  in[8][i],
							 in[7][i],  in[6][i],  in[5][i],  in[4][i],
							 in[3][i],  in[2][i],  in[1][i],  in[0][i]
						}),
                .sel(sel)
            );	
        end
    endgenerate
	
endmodule
