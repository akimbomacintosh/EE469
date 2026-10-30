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
	
		$display("%t testing PASS_A operations", $time);
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

		// ------- our tests -------- \\

		// test that the zero flag is set when two empty registers are added
		$display("%t testing zero flag", $time);
		A = 64'h0000000000000000; B = 64'h0000000000000000;
		#(delay);
		assert(result == 64'h0000000000000000 && carry_out == 0 && overflow == 0 && negative == 0 && zero == 1);

		// largest possible postitive number plus a positive gives a negative with overflow
		$display("%t testing max positive number added with positive to give overflow", $time);
		A = 64'h7FFFFFFFFFFFFFFF; B = 64'h0000000000000001;
		#(delay);
		assert(result == 64'h8000000000000000 && carry_out == 0 && overflow == 1 && negative == 1 && zero == 0);

		// -1 + 1 = 0, carry flows out through the top
		$display("%t testing -1 + 1 = 0 with carry out", $time);
		A = 64'hFFFFFFFFFFFFFFFF; B = 64'h0000000000000001;
		#(delay);
		assert(result == 64'h0000000000000000 && carry_out == 1 && overflow == 0 && negative == 0 && zero == 1);

		$display("%t testing subtraction", $time);
		cntrl = ALU_SUBTRACT;

		// 5 - 3 = 2, carry out is 1
		$display("%t testing 5 - 3 = 2 with carry out", $time);
		A = 64'h0000000000000005; B = 64'h0000000000000003;
		#(delay);
		assert(result == 64'h0000000000000002 && carry_out == 1 && overflow == 0 && negative == 0 && zero == 0);

		// 0 - 1 = -1, no carry
		$display("%t testing 0 - 1 = -1 with no carry", $time);
		A = 64'h0000000000000000; B = 64'h0000000000000001;
		#(delay);
		assert(result == 64'hFFFFFFFFFFFFFFFF && carry_out == 0 && overflow == 0 && negative == 1 && zero == 0);

		// greatest negative - 1, negative - positive gives a positive answer, overflow is 1
		$display("%t testing 0 - 1 = -1 with no carry", $time);
		A = 64'h8000000000000000; B = 64'h0000000000000001;
		#(delay);
		assert(result == 64'h7FFFFFFFFFFFFFFF && carry_out == 1 && overflow == 1 && negative == 0 && zero == 0);

		// testing AND gate functionality
		$display("%t testing AND", $time);
		cntrl = ALU_AND;
		A = 64'h0000000000000000; B = 64'h0000000000000000;		// 0 AND 0 = 0
		#(delay);
		assert(result == 64'h0000000000000000 && negative == 0 && zero == 1);
		A = 64'hFFFFFFFFFFFFFFFF; B = 64'h0000000000000000;		// 1 AND 0 = 0
		#(delay);
		assert(result == 64'h0000000000000000 && negative == 0 && zero == 1);
		A = 64'hFFFFFFFFFFFFFFFF; B = 64'hFFFFFFFFFFFFFFFF;		// 1 AND 1 = 1
		#(delay);
		assert(result == 64'hFFFFFFFFFFFFFFFF && negative == 1 && zero == 0);

		// testing or gate functionality
		$display("%t testing OR", $time);
		cntrl = ALU_OR;
		A = 64'h0000000000000000; B = 64'h0000000000000000;		// 0 OR 0 = 0
		#(delay);
		assert(result == 64'h0000000000000000 && negative == 0 && zero == 1);
		A = 64'hFFFFFFFFFFFFFFFF; B = 64'h0000000000000000;		// 1 OR 0 = 1
		#(delay);
		assert(result == 64'hFFFFFFFFFFFFFFFF && negative == 1 && zero == 0);
		A = 64'hFFFFFFFFFFFFFFFF; B = 64'hFFFFFFFFFFFFFFFF;		// 1 OR 1 = 1
		#(delay);
		assert(result == 64'hFFFFFFFFFFFFFFFF && negative == 1 && zero == 0);

		// testing XOR gate functionality
		$display("%t testing XOR", $time);
		cntrl = ALU_XOR;
		A = 64'h0000000000000000; B = 64'h0000000000000000;		// 0 XOR 0 = 0
		#(delay);
		assert(result == 64'h0000000000000000 && negative == 0 && zero == 1);
		A = 64'hFFFFFFFFFFFFFFFF; B = 64'h0000000000000000;		// 1 XOR 0 = 1
		#(delay);
		assert(result == 64'hFFFFFFFFFFFFFFFF && negative == 1 && zero == 0);
		A = 64'hFFFFFFFFFFFFFFFF; B = 64'hFFFFFFFFFFFFFFFF;		// 1 XOR 1 = 0
		#(delay);
		assert(result == 64'h0000000000000000 && negative == 0 && zero == 1);
	end
endmodule
