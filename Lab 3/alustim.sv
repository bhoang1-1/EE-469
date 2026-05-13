// Test bench for ALU
`timescale 1ns/10ps

// Meaning of signals in and out of the ALU:

// Flags:
// negative: whether the result output is negative if interpreted as 2's comp.
// zero: whether the result output was a 64-bit zero.
// overflow: on an add or subtract, whether the computation overflowed if the inputs are interpreted as 2's comp.
// carry_out: on an add or subtract, whether the computation produced a carry-out.

// cntrl			Operation						Notes:
// 000:			result = B						value of overflow and carry_out unimportant
// 010:			result = A + B
// 011:			result = A - B
// 100:			result = bitwise A & B		value of overflow and carry_out unimportant
// 101:			result = bitwise A | B		value of overflow and carry_out unimportant
// 110:			result = bitwise A XOR B	value of overflow and carry_out unimportant

module alustim();

	parameter delay = 100000;

	logic		[63:0]	A, B;
	logic		[2:0]		cntrl;
	logic		[63:0]	result;
	logic					negative, zero, overflow, carry_out ;

	parameter ALU_PASS_B=3'b000, ALU_ADD=3'b010, ALU_SUBTRACT=3'b011, ALU_AND=3'b100, ALU_OR=3'b101, ALU_XOR=3'b110;
	

	alu dut (.A, .B, .cntrl, .result, .negative, .zero, .overflow, .carry_out);

	// Force %t's to print in a nice format.
	initial $timeformat(-9, 2, " ns", 10);

	integer i;
	logic [63:0] test_val;
	initial begin
	
		$display("%t testing PASS_B operations", $time);
		cntrl = ALU_PASS_B;
		for (i=0; i<100; i++) begin
			A = $random(); B = $random();
			#(delay);
			assert(result == B && negative == B[63] && zero == (B == '0));
		end
		
		$display("%t testing addition", $time);
		cntrl = ALU_ADD;
		A = 64'h0000000000000001; B = 64'h0000000000000001;
		#(delay);
		assert(result == 64'h0000000000000002 && carry_out == 0 && overflow == 0 && negative == 0 && zero == 0);
		
		
		#(delay*3);
		
		
		// ADD 1 TO ALL 1s (wraparound)
		$display("%t testing carry_out and zero", $time);
		cntrl = ALU_ADD;
		A = 64'hFFFFFFFFFFFFFFFF; B = 64'h0000000000000001;
		#(delay);
		assert(result == 64'h0000000000000000 && carry_out == 1 && overflow == 0 && negative == 0 && zero == 1);
		
		
		#(delay*3);
		
		
		// SIGNED OVERFLOW (Positive + Positive = Negative)
      // Max Positive (011...) + 1 should flip the sign bit and trigger overflow.
      $display("%t testing positive overflow", $time);
      cntrl = ALU_ADD;
      A = 64'h7FFFFFFFFFFFFFFF; B = 64'h0000000000000001;
      #(delay);
      assert(result == 64'h8000000000000000 && overflow == 1 && negative == 1);
		
		
		#(delay*3);
		
		
		// SIGNED OVERFLOW (Negative - Positive = Positive) 
      // Max Negative (100...) - 1 should wrap around to Max Positive.
		// this is max negative bc 10000...., flip all bits, and add 1
		// 8 in hex  = 1000, 7 in hex = 0111
      $display("%t testing negative overflow", $time);
      cntrl = ALU_SUBTRACT;
      A = 64'h8000000000000000; B = 64'h0000000000000001;
      #(delay);
      assert(result == 64'h7FFFFFFFFFFFFFFF && overflow == 1 && negative == 0);
		
		
		#(delay*3);
		
		
		// Test AND/OR/XOR
      $display("%t testing gate logic", $time);
      A = 64'hF0F0F0F0F0F0F0F0; B = 64'h0F0F0F0F0F0F0F0F;
        
      cntrl = ALU_AND; #(delay); 
		assert(result == 64'h0);
      cntrl = ALU_OR;  #(delay); 
		assert(result == 64'hFFFFFFFFFFFFFFFF);
      cntrl = ALU_XOR; #(delay); 
		assert(result == 64'hFFFFFFFFFFFFFFFF);
		
		
		#(delay*3);
		
		
		// Test subtraction and checkzero and carry_out
		// carry_out is one bc when u flip B and add 1, you will get a carryout
		$display("%t testing subtraction zero: 1 - 1", $time);
		cntrl = ALU_SUBTRACT;
		A = 64'h0000000000000001; B = 64'h0000000000000001;
		#(delay);
		assert(result == 64'h0000000000000000 && zero == 1 && carry_out == 1); 
		
		
		#(delay*3);
		
		
		// Test large number addition
		// Carry Out is 1 because the unsigned sum exceeded the 64-bit capacity
		// Overflow is 0 because the signed math works correctly
		$display("%t testing large unsigned addition (no overflow)", $time);
		cntrl = ALU_ADD;
		A = 64'hF000000000000000; B = 64'hF000000000000000;
		#(delay);
		assert(carry_out == 1 && overflow == 0);
		
	end
endmodule
