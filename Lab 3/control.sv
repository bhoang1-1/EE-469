module control(
    input logic [10:0] instruction,
    output logic Reg2Loc, ALUSrc, MemWrite, MemRead, MemtoReg, RegWrite, Branch, UncondBr, FlagWrite,
	 output logic ImmSrc, // for immediates
	 output logic BrReg, // New signal specifically for BR
	 output logic BrLT,
	 output logic BL,
    output logic [2:0] ALUOp
);

    always_comb begin
        Reg2Loc = 0;      // Determines which instruction bits specify the second register to read
        UncondBr = 0;     // No condition, always jump to a relative offset, B, BL
        Branch = 0;		  // Enable conditional branch logic, conditionally jump, 1 = branch if condition is true, CBZ, B.LT
        MemRead = 0;      // Read data from memory at the address from the ALU, LDUR
        MemtoReg = 0;     // Select what gets written back to register, 0 = ALU result, 1 = memory data
        ALUOp  = 3'b000; 
        MemWrite = 0;     // Write data into memory at the address from the ALU
        ALUSrc = 0;		  // Select ALU operand 2 source, 0 = register value, 1 = immediate value
        RegWrite = 0;     // Enables writing to the Register File
        FlagWrite = 0;
		  ImmSrc = 0;		  // Tells the hardware which bits of the instruction contain the immediate value, 1 = 12-bit immediate ADDI, 0 = 9-bit for LDUR and STUR
		  BrReg = 0;  		  // A special signal for BR. When 1, tell the PC to ignore adders and jump directly to the value stored in a register (like X30).
		  BrLT = 0; 		  // A special signal for BrLT, 0 = CBZ instruction, 1 = B.LT instruction
		  BL = 0; 			  // for BL
        
        casez(instruction)
            // ADDI: 1001000100?
            11'b1001000100?: begin
                ALUSrc  = 1;
                RegWrite = 1;
                ALUOp = 3'b010; // ADD
					 ImmSrc = 1;
            end

            // ADDS: 10101011000
            11'b10101011000: begin
                Reg2Loc = 1;
                RegWrite = 1;
                ALUOp = 3'b010; // ADD
                FlagWrite = 1;      // Set flags
            end

            // B (Unconditional): 000101?????
            11'b000101?????: begin
                UncondBr = 1;      // PC = PC + SignExtend(Imm26 << 2)
					 ALUOp = 3'b000;
            end

            // B.LT (Conditional): 01010100???
            11'b01010100???: begin
                Branch = 1;      // Logic in CPU.sv: (flags.negative != flags.overflow)
					 BrLT = 1;
					 ALUOp = 3'b000;
            end

            // BL (Branch and Link) (Unconditional): 100101?????
            11'b100101?????: begin
                UncondBr = 1;
                RegWrite = 1;      // X30 = PC + 4 - handle in cpu
					 BL = 1;
					 ALUOp = 3'b000;
            end

            // BR (Branch Register): 11010110000
            11'b11010110000: begin
                BrReg = 1;
                ALUOp = 3'b000; // Pass through Reg[Rd] to PC
            end

            // CBZ (Compare and Branch if Zero): 10110100???
            11'b10110100???: begin
                Reg2Loc = 0;      // Read Rd
                Branch = 1;      // Logic in CPU.sv: (Reg[Rd] == 0)
                ALUOp = 3'b000; // PASS_B
            end

            // LDUR: 11111000010
            11'b11111000010: begin
                ALUSrc = 1;
                MemtoReg = 1;
                RegWrite = 1;
                MemRead = 1;
                ALUOp = 3'b010; // ADD for address calc
					 ImmSrc = 0;
            end

            // STUR: 11111000000
            11'b11111000000: begin
                Reg2Loc = 0;      // Route Rd address to ReadRegister2
                ALUSrc = 1;
                MemWrite = 1;
                ALUOp = 3'b010; // ADD
					 ImmSrc = 0;
            end

            // SUBS: 11101011000
            11'b11101011000: begin
                Reg2Loc = 1;
                RegWrite = 1;
                ALUOp = 3'b011; // SUB
                FlagWrite = 1;      // Set flags
            end
        endcase
    end
endmodule