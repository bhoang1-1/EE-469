module signextend(
    input logic [31:0] instruction,
    output logic [63:0] CondAddr19,
    output logic [63:0] BrAddr26,
    output logic [63:0] DAddr9,
    output logic [63:0] Imm12
);

	
	// DAddr9 - sign extend bits [20:12] to 64 bits
    assign DAddr9  = {{55{instruction[20]}}, instruction[20:12]};
    
    // CondAddr19 - sign extend bits [23:5] to 64 bits
    assign CondAddr19 = {{45{instruction[23]}}, instruction[23:5]};
    
    // BrAddr26 - sign extend bits [25:0] to 64 bits
    assign BrAddr26 = {{38{instruction[25]}}, instruction[25:0]};
    
    // Imm12 - zero extend bits [21:10] to 64 bits (ADDI)
    assign Imm12 = {{52{1'b0}}, instruction[21:10]};

endmodule