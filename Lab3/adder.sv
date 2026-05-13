module adder(A, B, result); // 64 adders combined
    input logic [63:0] A, B;
    output logic [63:0] result;
    
    logic [64:0] carry;
    assign carry[0] = 1'b0;
    
    genvar i;
    generate
        for(i = 0; i < 64; i = i + 1) begin : adder_bits
            full_adder fa(
                .A(A[i]),
                .B(B[i]),
                .Cin(carry[i]),
                .Cout(carry[i+1]),
                .sum(result[i])
            );
        end
    endgenerate
endmodule