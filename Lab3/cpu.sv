module cpu(input logic clk, reset);
	
	// PC 
	logic [63:0] current_pc;
	logic [63:0] next_pc;
	logic [63:0] pc_plus4; // output of adder 1 (PC + 4)
	
	
	// INSTRUCTION
	logic [31:0] instruction;
	
	// BRANCH
	logic [63:0] CondAddr19_shifted;
	logic [63:0] BrAddr26_shifted;
	logic [63:0] branch_offset;   // output of UncondBr mux (selects CondAddr19 or BrAddr26)
	logic [63:0] branch_target;   // output of branch adder
	logic        BrTaken;         // final signal to select next PC
	
	
	// BL AND BR
	logic [63:0] next_pc_pre; // what the next pc would be if it wasn't BR instruction
	logic [63:0] WriteData_pre; // WriteData before BL mux
	
	
	// CONTROL
	logic Reg2Loc, ALUSrc, MemWrite, MemRead, MemtoReg, RegWrite, Branch, UncondBr, FlagWrite, ImmSrc, BrReg, BrLT, BL;
	logic [2:0] ALUOp;
	
	// REGISTER
	logic [63:0] ReadData1, ReadData2;
	logic [4:0]  ReadRegister1, ReadRegister2;
   logic [4:0]  WriteRegister;
   logic [63:0] WriteData;
	
	// SIGNEXTEND
   logic [63:0] CondAddr19;
   logic [63:0] BrAddr26;
   logic [63:0] DAddr9;
   logic [63:0] Imm12;
	
	// ALU
	logic [63:0] ALUresult;
   logic negative, zero, overflow, carry_out;
	
	// FLAGS
	logic negative_out, zero_out, overflow_out, carry_out_out;
	
	// DATA MEMORY
	logic	[63:0] ReadDataMem;
	
	// OTHER
	logic [63:0] ImmExt;  // output of ImmSrc mux (selects DAddr9 or Imm12)
	logic [63:0] ALU_B;  // output of ALUSrc mux (selects ReadData2 or ImmExt)
	
	
	// INSTANTIATING
	
	//assign ReadRegister1 = instruction[9:5]; // Rn
	//assign ReadRegister1 = (BrReg) ? instruction[4:0] : instruction[9:5];
	mux2_1_5 BrReadAddrMux (.out(ReadRegister1), .i0(instruction[9:5]), .i1(instruction[4:0]), .sel(BrReg)); // DETERMINE READREGISTER1 BASED ON BR
	//assign WriteRegister = instruction[4:0]; // Rd
	assign CondAddr19_shifted = CondAddr19 << 2;
	assign BrAddr26_shifted = BrAddr26 << 2;
	assign BrTaken = UncondBr 
               | (Branch & ~BrLT & zero)  // handles for CBZ
               | (Branch & BrLT & (negative_out ^ overflow_out));  // handles for B.LT, negative != overflow, ^ is xor, which equals != for 1 bit signals
	
	
	// MEMORY PATH
	
	pc ProgramCounter(.clk(clk), .reset(reset), .next_pc(next_pc), .current_pc(current_pc));
	
	instructmem instrmemory( .address(current_pc), .instruction(instruction), .clk(clk));
	
	control ctrl(.instruction(instruction[31:21]), .Reg2Loc(Reg2Loc), .ALUSrc(ALUSrc), .MemWrite(MemWrite), .MemRead(MemRead), .MemtoReg(MemtoReg), 
				    .RegWrite(RegWrite), .Branch(Branch), .UncondBr(UncondBr), .FlagWrite(FlagWrite), .ImmSrc(ImmSrc), .BrReg(BrReg), .BrLT(BrLT), .BL(BL), .ALUOp(ALUOp));
	
	mux2_1_5 Reg2LocMux(.out(ReadRegister2), .i0(instruction[4:0]), .i1(instruction[20:16]), .sel(Reg2Loc));
	

	regfile RegFile(.ReadData1(ReadData1), .ReadData2(ReadData2), .ReadRegister1(ReadRegister1), .ReadRegister2(ReadRegister2), 
						 .WriteRegister(WriteRegister), .WriteData(WriteData), .RegWrite(RegWrite), .clk(clk), .reset(reset));
	
	signextend Extender(.instruction(instruction), .CondAddr19(CondAddr19), .BrAddr26(BrAddr26), .DAddr9(DAddr9), .Imm12(Imm12));
	
	mux2_1_64 ImmSrcMux(.out(ImmExt), .i0(DAddr9), .i1(Imm12), .sel(ImmSrc));
	
	mux2_1_64 ALUSrcMux(.out(ALU_B), .i0(ReadData2), .i1(ImmExt), .sel(ALUSrc));
	
	alu ALU(.A(ReadData1), .B(ALU_B), .cntrl(ALUOp), .result(ALUresult), .negative(negative), .zero(zero), .overflow(overflow), .carry_out(carry_out));
	
	flags Flags(.clk(clk), .reset(reset), .FlagWrite(FlagWrite), .negative_in(negative), .zero_in(zero), .overflow_in(overflow), .carry_out_in(carry_out), 
				   .negative_out(negative_out), .zero_out(zero_out), .overflow_out(overflow_out), .carry_out_out(carry_out_out));
	
	datamem dmem(.address(ALUresult), .write_enable(MemWrite), .read_enable(MemRead), .write_data(ReadData2), .clk(clk), .xfer_size(4'd8), .read_data(ReadDataMem));
	
	mux2_1_64 MemtoRegMux(.out(WriteData_pre), .i0(ALUresult), .i1(ReadDataMem), .sel(MemtoReg)); 
	
	// PROGRAM COUNTER PATH
	
	mux2_1_64 UncondBrMux(.out(branch_offset), .i0(CondAddr19_shifted), .i1(BrAddr26_shifted), .sel(UncondBr));
	
	adder branchAdder(.A(branch_offset), .B(current_pc), .result(branch_target));
	
	adder pcAdder(.A(current_pc), .B(64'd4), .result(pc_plus4));
	
	mux2_1_64 BrTakenMux(.out(next_pc_pre), .i0(pc_plus4), .i1(branch_target), .sel(BrTaken)); // output next_pc_pre is either +4, or branch
	
	
	
	// BR and BL Muxes

	mux2_1_64 BrRegMux(.out(next_pc), .i0(next_pc_pre), .i1(ReadData1), .sel(BrReg)); // if BR is the instruction, next pc address is the data in register1 from regfile
	
	mux2_1_64 BLDataMux(.out(WriteData), .i0(WriteData_pre), .i1(pc_plus4), .sel(BL)); // if BL is instruction, WriteData output is PC + 4, else it is normal
	
	mux2_1_5 BLRegMux(.out(WriteRegister), .i0(instruction[4:0]), .i1(5'd30), .sel(BL)); // if BL is instruction, register to write on will be X30, else its normal
	
	
	/*
	MEMORY PATH:
	
	program counter, output address
	
	instructmem input is address, outputs instructions
	
	control, input is first 10 bits of instruction, outputs all control signals
	
	mux2_1_5 input is Rd and Rm, selects which register to read for 2nd register, 0 = stur and cbz, 1 = R-type
	
	Instantiate regfile, output is readdata1 and 2, write data is from memtoreg mux, writeregister is Rd
	
	signextend everything
	
	mux2_1_64 for choosing between daddr9 and Imm12, ImmSrc control, -> ImmExt
	
	mux2_1_64 for alusrc, output is ALU_B
	
	instantiate alu, inputs are ALU_B and ReadData1, ALUOp determines operations, ouput is ALUResult and NEW flags
	
	instantiate flags, input is NEW flags from alu, output are flags_out, these are the stored/current flags
	
	instantiate data mem, input is ALUResult, writeenable, readenable, , readdata2, clk, hardwire xfer to 4'b1000 (8), output is ReadDataMem
	
	mux2_1_64, sel is memtoreg, input is ALUResult and ReadDataMem, output is WriteData
	
	
	PROGRAM COUNTER PATH:
	
	Note: offsets are multiplied by 4, (shifted 2 left)
	
	mux2_1_64 input are the conditional shift and unconditional shift, output chooses which type of shift, branch_offset is output
	
	adder branchAdder, calculates next PC with branch offset
	
	adder pcADder, calculates next PC + 4
	
	mux2_1_64, decides whether branch is valid, i.e. there is unconditional branch, or conditional branch was met, else use PC +4, output is next_pc
	
	
	*/

endmodule