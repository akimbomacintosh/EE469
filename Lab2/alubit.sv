`timescale 1ns/10ps

module alubit (result, carryOut, a, b, carryIn, control);
    output logic result, carryOut;
    input logic a, b, carryIn;
    input logic [2:0] control;
    logic toggleSub;
    logic sum;
    logic andOut, orOut, xorOut;
    logic [7:0] choices;

    // b inverter
    xor #delay bInvert (toggleSub, b, control[0]); // flips b if control[0] is 1 to pass into the adder for subtraction

    // addition or subtraction
    full_adder adder (.sum(sum), .cout(carryOut), .a(a), .b(toggleSub), .cin(carryIn)); // performs addition or subtraction of a and b based on the value of control[0]

    // basic logic gates
    and #delay 1and (andOut, a, b);
    or #delay 1or (orOut, a, b);
    xor #delay 1xor (xorOut, a, b);

    // 8:1 mux to select the output based on control[2:0]
    // order from: parameter ALU_PASS_B=3'b000, ALU_ADD=3'b010, ALU_SUBTRACT=3'b011, ALU_AND=3'b100, ALU_OR=3'b101, ALU_XOR=3'b110;
    assign choices[0] = b; // 000
    assign choices[1] = 1'b0; // 001 UNUSED
    assign choices[2] = sum; // 010 ADDER
    assign choices[3] = sumSub; // 011 SUBTRACTOR
    assign choices[4] = andOut; // 100 AND
    assign choices[5] = orOut; // 101 OR
    assign choices[6] = xorOut; // 110 XOR
    assign choices[7] = 1'b0; // 111 UNUSED

    mux8_1 mux (.out(result), .i(choices), .sel(control)); // selects the output based on the control signal
endmodule

module alubit_testbench();
	logic a, b, carryIn;
	logic [2:0] control;
	logic result, carryOut;

	alubit dut (.result, .carryOut, .a, .b, .carryIn, .control);

	integer i;
	initial begin
		for (i = 0; i < 64; i++) begin
			{control, a, b, carryIn} = i; #10;
		end
		$stop;
	end
endmodule