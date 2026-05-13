module mux2_1_5(out, i0, i1, sel);
    output logic [4:0] out;
    input logic [4:0] i0, i1;
    input logic sel;
    
    genvar i;
    generate
        for(i = 0; i < 5; i = i + 1) begin : mux_bits
            mux2_1 m (
                .out(out[i]),
                .i0(i0[i]),
                .i1(i1[i]),
                .sel(sel)
            );
        end
    endgenerate
endmodule