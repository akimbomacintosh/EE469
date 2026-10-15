//32:1 mux built from 2:1 muxes
`timescale 1ns/10ps
module mux32_1(out, i, sel);
    output logic out;
    input logic [31:0] i;
    input logic [4:0] sel;

    logic [15:0] a; // first level 
    logic [7:0] b; // second level
    logic [3:0] c; // third level
    logic [1:0] d; // fourth level

    genvar j;
    generate
        for (j = 0; j < 16; j = j + 1) begin : sixteen_mux
            mux2_1 m0 (.out(a[j]), .i0(i[2*j]), .i1(i[2*j+1]), .sel(sel[0]));
        end

        for (j = 0; j < 8; j = j + 1) begin : eight_mux
            mux2_1 m1 (.out(b[j]), .i0(a[2*j]), .i1(a[2*j+1]), .sel(sel[1]));
        end

        for (j = 0; j < 4; j = j + 1) begin : four_mux
            mux2_1 m2 (.out(c[j]), .i0(b[2*j]), .i1(b[2*j+1]), .sel(sel[2]));
        end

        for (j = 0; j < 2; j = j + 1) begin : two_mux
            mux2_1 m3 (.out(d[j]), .i0(c[2*j]), .i1(c[2*j+1]), .sel(sel[3]));
        end
    endgenerate

    mux2_1 finalmux (.out(out), .i0(d[0]), .i1(d[1]), .sel(sel[4]));
endmodule

module mux32_1_testbench();
	logic [31:0] i;
	logic [4:0] sel;
	logic out;

	mux32_1 dut (.out, .i, .sel);

	integer k;
	initial begin
		// Pattern 1: set all 32 inputs once, then try every select value
		i = 32'b1010_0101_1100_0011_0000_1111_0110_1001;
		for (k = 0; k < 32; k++) begin
			sel = k; #10;
		end

		// Pattern 2: the opposite of pattern 1 (every bit flipped)
		i = 32'b0101_1010_0011_1100_1111_0000_1001_0110;
		for (k = 0; k < 32; k++) begin
			sel = k; #10;
		end

		$stop;
	end
endmodule