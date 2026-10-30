`timescale 1ns/10ps

// This module serves as the zero flag, which uses a multitude of gates to figure whether
//    the result of any operation was 0. This module essentially functions as an OR gate
//    for all 64 result bits. 
// Paramters:
//    - in: The current 64 bit result register. 
// Outputs: 
//    - zero: A 0 or 1 corresponding to whether the result register = 0 or not.
module detectzero (zero, in);
    output logic zero;
    input logic [63:0] in;
    parameter delay = 0.05;

    // detectzero logic with 2 levels of OR gates to determine if the input is zero
    // First level puts the register bits in 16 groups of 4: 0 - 3, 4 - 7, etc.
    logic [15:0] level1;
    // Second level puts the 16 groups of 4 into 4 groups of four.
    logic [3:0] level2;

    genvar i;
    generate
        for (i = 0; i < 16; i++) begin : level1or
            // First level of OR gates, checks in groups of 4 bits
            or #delay or1 (level1[i], in[4*i], in[4*i+1], in[4*i+2], in[4*i+3]);
        end

        for (i = 0; i < 4; i++) begin : level2or
            // Second level of OR gates, checks the outputs of the first level in groups of 4
            or #delay or2 (level2[i], level1[4*i], level1[4*i+1], level1[4*i+2], level1[4*i+3]);
        end
    endgenerate

    // Final or gate to check the outputs of the second level
    // The "zero" output will be true if all of the result bits were 0.
    nor #delay or3 (zero, level2[0], level2[1], level2[2], level2[3]);
endmodule

module detectzero_testbench();
    logic [63:0] in;
    logic zero;

    detectzero dut (.zero(zero), .in(in));

    integer i;
    initial begin 
        // Test that all 64 bits of the input as a 1
        in = 64'b0; #10;
        for (i = 0; i < 64; i++) begin
            in = 64'b0;
			in[i] = 1'b1;
			#10;
		end

        in = 64'hFFFF_FFFF_FFFF_FFFF; // testing all 1s
        #10;
        in = 64'b0; // testing all 0s again
        #10;
        $stop;
    end
endmodule