module flags(clk, reset, FlagWrite, negative_in, zero_in, overflow_in, carry_out_in, negative_out, zero_out, overflow_out, carry_out_out);
    input  logic clk, reset;
    input  logic FlagWrite; // control logic
    input  logic negative_in, zero_in, overflow_in, carry_out_in; // new flags
    output logic negative_out, zero_out, overflow_out, carry_out_out; // current flags
    
    logic neg_d, zero_d, over_d, carry_d;
    
    // only update flags if FlagWrite is set
    mux2_1 m0(.out(neg_d), .i0(negative_out), .i1(negative_in), .sel(FlagWrite));
    mux2_1 m1(.out(zero_d), .i0(zero_out), .i1(zero_in), .sel(FlagWrite));
    mux2_1 m2(.out(over_d), .i0(overflow_out), .i1(overflow_in), .sel(FlagWrite));
    mux2_1 m3(.out(carry_d), .i0(carry_out_out), .i1(carry_out_in), .sel(FlagWrite));
    
    // store flags in flip flops
    D_FF ff0(.q(negative_out), .d(neg_d), .reset(reset), .clk(clk));
    D_FF ff1(.q(zero_out), .d(zero_d), .reset(reset), .clk(clk));
    D_FF ff2(.q(overflow_out), .d(over_d), .reset(reset), .clk(clk));
    D_FF ff3(.q(carry_out_out), .d(carry_d), .reset(reset), .clk(clk));

endmodule