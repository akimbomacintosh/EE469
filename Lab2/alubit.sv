`timescale 1ns/10ps

// This module computes every operation in parallel (logic gates, pass-B, adder) and then uses the 8:1 MUX
//   and control bits to select which operation to send to result.
// Example: Slice i takes ai, bi, the carryIni, and the shared control bits, and produces resulti
//    and the carryOut (ci + 1).
// Parameters:
//    - a: The ith bit of register a to operate on.
//    - b: The ith bit of register b to operate on.
//    - carryIn: A 0 or 1, representing if cout(i - 1) had a carry out bit. 
//    - control: The 3 control bits that tell the MUX which input to send to result
//      - control[0] is used to determine whether you need to add or "subtract"
// Outputs: 
//    - result: The ith bit of result, which will be modified using the input parameters. 
//    - carryOut: A 0 or 1 representing whether there was "overflow" on the addition of a, b, and carryIn
module alubit (result, carryOut, a, b, carryIn, control);
    output logic result, carryOut;
    input logic a, b, carryIn;
    input logic [2:0] control;
    logic toggleSub;
    logic sum;
    logic andOut, orOut, xorOut;
    logic [7:0] choices;
    parameter delay = 0.05;

    // If addition (control[0] = 0): result = A + B
    //      sumi = ai xor bi xor ci
    //      ci+1 = (ai and bi) or (ci and (ai and bi))
    // If subtraction (control[0] = 1): result = A + not(B) + 1
    //      sumi = ai xor not(bi) xor ci
    //      ci+1 = (ai and not(bi)) or (ci and (ai and not(bi)))

    // b inverter
    // flips b if control[0] is 1 to pass into the adder for subtraction
    xor #delay bInvert (toggleSub, b, control[0]); 

    // performs addition or subtraction of a and b based on the value of control[0]
    full_adder adder (.sum(sum), .cout(carryOut), .a(a), .b(toggleSub), .carryIn(carryIn)); 

    // basic logic gates that perform the operations when control is 100, 101, or 110.
    and #delay a1 (andOut, a, b); // control = 100
    or #delay o1 (orOut, a, b); // control = 101
    xor #delay xor1 (xorOut, a, b); // control = 110

    // 8:1 mux to select the output based on control[2:0]
    // order from: parameter ALU_PASS_B=3'b000, ALU_ADD=3'b010, ALU_SUBTRACT=3'b011, ALU_AND=3'b100, ALU_OR=3'b101, ALU_XOR=3'b110;
    assign choices[0] = b; // 000
    assign choices[1] = 1'b0; // 001 UNUSED
    assign choices[2] = sum; // 010 ADDER
    assign choices[3] = sum; // 011 SUBTRACTOR (uses ADDER)
    assign choices[4] = andOut; // 100 AND
    assign choices[5] = orOut; // 101 OR
    assign choices[6] = xorOut; // 110 XOR
    assign choices[7] = 1'b0; // 111 UNUSED

    // selects the ALU output based on the control signal
    mux8_1 mux (.out(result), .i(choices), .sel(control)); 
endmodule

module alubit_testbench();
	logic a, b, carryIn;
	logic [2:0] control;
	logic result, carryOut;

	alubit dut (.result, .carryOut, .a, .b, .carryIn, .control);

	integer i;
	initial begin
        // Loop through all 64 bit input combinations. i is split across 
        //  from MSB to LSB: i[5:3] = control, i[2] = a, i[1] = b, i[0] = carryIn.
		for (i = 0; i < 64; i++) begin
			{control, a, b, carryIn} = i; #10;
		end
		$stop;
	end
endmodule