`timescale 1ns/10ps

// This module is a 64-bit ARM ALU built from 64 chained alubit slices. Every slice computers
//    all operations in parallel and the 8:1 MUX picks which operation to send to the result output
//    using the control select bits. 
// Parameters:
//    - A: The 64 bit register A to operate on.
//    - B: The 64 bit register B to operate on. 
//    - control: The 3 control bits that select which operation to send to result. 
// Outputs:
//    - result: The 64 bit result of the selected operation.
//    - negative: 1 if result is negative when read as 2's comp (result[63] = 1), 0 otherwise.
//    - zero: 1 if all 64 bits are 0, 0 otherwise.
//    - overflow: 1 if an add or subtract overflowed when read as 2's comp, 0 otherwise.
//    - carryOut: 1 if an add or subtract produced a carry out of bit 63, 0 otherwise.
module alu (A, B, control, result, negative, zero, overflow, carryOut);
    input logic [63:0] A, B;
    input logic [2:0] control;
    output logic [63:0] result;
    output logic negative, zero, overflow, carryOut;
    parameter delay = 0.05;

    // 65-bit carryOut array that determines if carryOut is true.
    //   If carries[64] = 1, then the carryOut flag is 1 (carryOut of bit 63)
    //   This array is 65 bits long instead of 64 because you need a place to store carryOut[63]
    logic [64:0] carries;

    // For subtraction (control[0] = 1), A - B = A + not(B) + 1. Each alubit already inverts b
    //    when control[0] = 1, so the "+ 1" comes from assigning control[0] into the first carry in
    //    This works well in our code because we didn't code to include an edge case for slice 0
    assign carries[0] = control[0];

    // Build the 64 alubit slices, linking each carryOut into the next slice's carryIn
    genvar i;
    generate
        for (i = 0; i < 64; i++) begin : slices
            alubit bitSlice (.result(result[i]), .carryOut(carries[i + 1]), .a(A[i]), .b(B[i]),
                            .carryIn(carries[i]), .control(control));
        end
    endgenerate

    // Assign carryOut flag: the carry out of most significant slice
    assign carryOut = carries[64];

    // Assign overflow flag: 2's comp overflow when carryIn to MSB differs from carryOut of MSB
    xor #delay overflowXOR (overflow, carries[63], carries[64]);

    // Assign negative flag: The sign bit of the result = MSB of result
    assign negative = result[63];

    // Assigns zero flag: 1 only if every bit of result is 0
    detectzero zeroCheck (.zero(zero), .in(result));
endmodule


module alu_testbench();
    logic [63:0] A, B, result;
    logic [2:0] control;
    logic negative, zero, overflow, carryOut;

    alu dut (.A, .B, .control, .result, .negative, .zero, .overflow, .carryOut);

    integer i;
    initial begin
        // Run 8 edge cases through every operation (each operation runs in parallel for each test below):
        // 1 + 1, max positive + 1 (overflow), 0 - 1 (negative), 1 - 1 (zero), all 1's + 1 (carryOut)
        for (i = 0; i < 8; i++) begin : test
            control = i; // does all operations. 001 and 111 are unused and output 0.

            // Test 1: A = 1, B = 1;
            // ADD: result = 2; carryOut = 0 (all 64 bits fit); overflow = 0;
            // SUB: result = 0; zero = 1; carryOut = 1; overflow = 0;
            // AND = 1; OR = 1; XOR = 0;
            A = 64'h0000_0000_0000_0001; B = 64'h0000_0000_0000_0001; #20;

            // Test 2: A = max positive (2^63 - 1), B = 1
            // ADD: result = 0x8000...0; negative = 1. overflow = 1 (+ plus + = -);
            //       carryOut = 0;
            // SUB: result = 0x7FFF...E. carryOut = 1; overflow = 0;
            A = 64'h7FFF_FFFF_FFFF_FFFF; B = 64'h0000_0000_0000_0001; #20;

            // Test 3: A = 0; B = 1
            // ADD: result = 1. carryOut = 0; overflow = 0;
            // SUB: result = -1; negative = 1; carryOut = 0; overflow = 0;
            A = 64'h0000_0000_0000_0000; B = 64'h0000_0000_0000_0001; #20;

            // Test 4: A = all 1's (-1 in 2's comp), B = 1
            // ADD: reuslt = 0; zero = 1; carryOut = 1; overflow = 0;
            // SUB: result = -2; negative = 1; carryOut - 1; overflow = 0;
            A = 64'hFFFF_FFFF_FFFF_FFFF; B = 64'h0000_0000_0000_0001; #20;

            // Test 5: A = most negative, B = all 1's (-1) 
            // ADD: result = 0x7FFF...F, negative - 0; overflow = 1 (minus + minus = +)
            //      carryOut = 1
            // SUB: result = 0x8000...1; negative = 1; carryOut = 0; overflow = 0;
            // PASS_B: result = all 1's; negative = 1. AND = 0x8000...0, OR = all 1's, XOR = 0x7FFF...F;
            A = 64'h8000_0000_0000_0000; B = 64'hFFFF_FFFF_FFFF_FFFF; #20;

            // Test 6: A = most negative, B - 1
            // ADD: result = 0x800...1; negative = 1; carryOout = 0; overflow = 0;
            // SUB: result = 0x7FFF...F; negative = 0; overflow = 1 (minus - plus = plus);
            A = 64'h8000_0000_0000_0000; B = 64'h0000_0000_0000_0001; #20;

            // Test 7: A = 1010..., B = 0101... (every slice sees a = 1, b = 0 or a = 0, b = 1)
            // ADD: result = all 1's; negative = 1; carryOut = 0; overflow = 0;
            // SUB: result = 0x555...5; overflow = 1 (minus - + = +)
            A = 64'hAAAA_AAAA_AAAA_AAAA; B = 64'h5555_5555_5555_5555; #20;

            // Test 8: A = 0101; B = 1010 (swaps test 7, so every bit of B is checked as both 1 and 0)
            // ADD: result = all 1's; negative = 1; carryOut = 0; overflow = 0;
            // SUB: result = 0xAAAA...B; negative = 1; overflow = 1; carryOut = 0;
            // PASS_B = 0xAAAA...A (negative = 1); AND = 0 (zero = 1); OR = XOR = all 1's.
            A = 64'h5555_5555_5555_5555; B = 64'hAAAA_AAAA_AAAA_AAAA; #20;
        end
        $stop;
    end
endmodule