`timescale 1ns/10ps

module detectzero (zero, in);
    output logic zero;
    input logic [63:0] in;
    parameter delay = 0.05;

    // detectzero logic with 2 levels of or gates to determine if the input is zero
    logic [15:0] level1;
    logic [3:0] level2;

    genvar i;
    generate
        for (i = 0; i < 16; i++) begin : level1or
            // first level of or gates, checks in groups of 4 bits
            or #delay or1 (level1[i], in[4*i], in[4*i+1], in[4*i+2], in[4*i+3]);
        end

        for (i = 0; i < 4; i++) begin : level2or
            // second level of or gates, checks the outputs of the first level in groups of 4
            or #delay or2 (level2[i], level1[4*i], level1[4*i+1], level1[4*i+2], level1[4*i+3]);
        end
    endgenerate

    // final or gate to check the outputs of the second level
    nor #delay or3 (zero, level2[0], level2[1], level2[2], level2[3]);
endmodule

module detectzero_testbench();
    logic [63:0] in;
    logic zero;

    detectzero dut (.zero(zero), .in(in));

    integer i;
    initial begin // test all 64 bits of the input as a 1
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