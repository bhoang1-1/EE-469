module regfile (
	 output [63:0] ReadData1, 
    output [63:0] ReadData2,
    input [4:0]  ReadRegister1, 
    input [4:0]  ReadRegister2, 
    input [4:0]  WriteRegister, 
    input [63:0] WriteData, 
    input        RegWrite,  
    input        clk,
	 input 		  reset
);
	 
	 logic [31:0] register_enable;
	 
	 decoder5_32 decoder(.out(register_enable), .in(WriteRegister), .en(RegWrite));
	 
	 logic [31:0][63:0] data;
	
	 register_32 registers(.q(data), .d(WriteData), .we(register_enable), .clk(clk), .reset(reset)); //create registers
	 
	 mux32_1_64 mux1(.out(ReadData1) , .in(data) , .sel(ReadRegister1));
	 mux32_1_64 mux2(.out(ReadData2) , .in(data) , .sel(ReadRegister2));
				 
endmodule