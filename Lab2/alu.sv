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
module alu (A, B, cntrl, result, negative, zero, overflow, carry_out);
    input logic [63:0] A, B;
    input logic [2:0] cntrl;
    output logic [63:0] result;
    output logic negative, zero, overflow, carry_out;
    parameter delay = 0.05;

    // 65-bit carryOut array that determines if carryOut is true.
    //   If carries[64] = 1, then the carryOut flag is 1 (carryOut of bit 63)
    //   This array is 65 bits long instead of 64 because you need a place to store carryOut[63]
    logic [64:0] carries;

    // For subtraction (cntrl[0] = 1), A - B = A + not(B) + 1. Each alubit already inverts b
    //    when cntrl[0] = 1, so the "+ 1" comes from assigning cntrl[0] into the first carry in
    //    This works well in our code because we didn't code to include an edge case for slice 0
    assign carries[0] = cntrl[0];

    // Build the 64 alubit slices, linking each carryOut into the next slice's carryIn
    genvar i;
    generate
        for (i = 0; i < 64; i++) begin : slices
            alubit bitSlice (.result(result[i]), .carryOut(carries[i + 1]), .a(A[i]), .b(B[i]),
                            .carryIn(carries[i]), .control(cntrl));
        end
    endgenerate

    // Assign carry_out flag: the carry out of most significant slice
    assign carry_out = carries[64];

    // Assign overflow flag: 2's comp overflow when carryIn to MSB differs from carryOut of MSB
    xor #delay overflowXOR (overflow, carries[63], carries[64]);

    // Assign negative flag: The sign bit of the result = MSB of result
    assign negative = result[63];

    // Assigns zero flag: 1 only if every bit of result is 0
    detectzero zeroCheck (.zero(zero), .in(result));
endmodule


module alu_testbench();
    logic [63:0] A, B, result;
    logic [2:0] cntrl;
    logic negative, zero, overflow, carry_out;

    alu dut (.A, .B, .cntrl, .result, .negative, .zero, .overflow, .carry_out);

    integer i;
    initial begin
        // Run 8 edge cases through every operation (each operation runs in parallel for each test below):
        for (i = 0; i < 8; i++) begin : test
            cntrl = i; // does all operations. 001 and 111 are unused and output 0.

            // Test 1: A = 1, B = 1;
            // ADD: result = 2; carryOut = 0; overflow = 0;
            // SUB: result = 0; zero = 1; carryOut = 1; overflow - 0;
            // AND = 1; OR = 1; XOR = 0; PASS_B = 1;
            A = 64'h0000_0000_0000_0001; B = 64'h0000_0000_0000_0001; #20;

            // Test 2: A = max positive (2^63 - 1), B = 1
            // ADD: result = 0x8000...0; negative = 1; overflow = 1 (positive + positive = negative);
            //       carryOut = 0;
            // SUB: result - 0x7FFF...E; carryOut = 1; overflow = 0;
            // AND = 1; OR = 0x7FFF...F; XOR = 0x7FFF...E; PASS_B = 1;
            A = 64'h7FFF_FFFF_FFFF_FFFF; B = 64'h0000_0000_0000_0001; #20;

            // Test 3: A = 0; B = 1
            // ADD: result = 1; negative = 0; carryOut = 0; overflow = 0; 
            // SUB: result = -1; negative = 1; carryOut = 0; overflow = 0;
            // AND = 0; OR = 1; XOR = 1; PASS_B = 1;
            A = 64'h0000_0000_0000_0000; B = 64'h0000_0000_0000_0001; #20;

            // Test 4: A = all 1's (-1 in 2's comp), B = 1
            // ADD: result = 0; zero = 1; carryOut = 1; overflow = 0;
            // SUB: result = -2; negative = 1; carryOut - 1; overflow = 0;
            // AND = 1; OR = -1; XOR = -2; PASS_B = 1;
            A = 64'hFFFF_FFFF_FFFF_FFFF; B = 64'h0000_0000_0000_0001; #20;

            // Test 5: A = most negative, B = -1
            // ADD: result = 0x7FFF...F, negative - 0; overflow = 1; carryOut = 1
            // SUB: result = 0x8000...1; negative = 1; carryOut = 0; overflow = 0;
            // AND = 0x800...0; OR = -1; XOR = 0x7FFF...F; PASS_B = -1;
            A = 64'h8000_0000_0000_0000; B = 64'hFFFF_FFFF_FFFF_FFFF; #20;

            // Test 6: A = most negative, B - 1
            // ADD: result = 0x800...1; negative = 1; carryOout = 0; overflow = 0;
            // SUB: result = 0x7FFF...F; negative = 0; overflow = 1; carryOut = 1; 
            // AND = 0; OR = 0x800...1; XOR = 0x800...1; PASS_B = 1;
            A = 64'h8000_0000_0000_0000; B = 64'h0000_0000_0000_0001; #20;

            // Test 7: A = 1010..., B = 0101... (every slice sees a = 1, b = 0 or a = 0, b = 1)
            // ADD: result = all 1's; negative = 1; carryOut = 0; overflow = 0;
            // SUB: result = 0x555...5; negative = 0; carryOut = 1; overflow = 1;
            // AND = 0; OR = -1; XOR = -1; PASS_B = 0x555...5;
            A = 64'hAAAA_AAAA_AAAA_AAAA; B = 64'h5555_5555_5555_5555; #20;

            // Test 8: A = 0101...; B = 1010... (opposite of Test 7)
            // ADD: result = -1; negative = 1; carryOut = 0; overflow = 0;
            // SUB: result = 0xAAAA...B; negative = 1; overflow = 1; carryOut = 0;
            // AND = 0; OR = -1; XOR = -1 PASS_B = 0xAAA...A;
            A = 64'h5555_5555_5555_5555; B = 64'hAAAA_AAAA_AAAA_AAAA; #20;
        end
        $stop;
    end
endmodule