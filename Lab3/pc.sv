module pc(clk, reset, next_pc, current_pc);
    input logic clk, reset;
    input logic [63:0] next_pc;
    output logic [63:0] current_pc;
    
    genvar i;
    generate
        for(i = 0; i < 64; i = i + 1) begin : pc_bits
            D_FF ff(
                .q(current_pc[i]),
                .d(next_pc[i]),
                .reset(reset),
                .clk(clk)
            );
        end
    endgenerate
endmodule