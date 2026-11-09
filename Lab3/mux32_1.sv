`timescale 1ns/10ps

// 32:1 multiplexer built as a 5-level binary tree of 2:1 muxes.
// Each level of muxes cuts the remaining inputs in half, using one bit
//     of sel per level, from sel[0] (right-most) to sel[4] (left-most).
// Ports:
//    out - the selected data bit
//    i   - 32 data inputs (one bit from each register)
//    sel - 5-bit select (register number 0-31) that picks which input drives out
// Given a register number on sel, the muxes pass that register's data bit
// to out (out = i[sel]).
module mux32_1(out, i, sel);
    output logic out;
    input logic [31:0] i;
    input logic [4:0] sel;

    // Each level of the tree that cuts remaining inputs in half.
    logic [15:0] a; // first level 
    logic [7:0] b; // second level
    logic [3:0] c; // third level
    logic [1:0] d; // fourth level

    // Build levels 1-4 of the tree; each loop creates one level of 2:1 muxes.
    genvar j;
    generate
        //Level 1: sel[0] chooses whether input is even or odd from 32->16.
        for (j = 0; j < 16; j = j + 1) begin : sixteen_mux
            mux2_1 m0 (.out(a[j]), .i0(i[2*j]), .i1(i[2*j+1]), .sel(sel[0]));
        end

        //Level 2: sel[1] picks one of each pair of level-1 outputs: 16->8
        for (j = 0; j < 8; j = j + 1) begin : eight_mux
            mux2_1 m1 (.out(b[j]), .i0(a[2*j]), .i1(a[2*j+1]), .sel(sel[1]));
        end

        //Level 3: sel[2] picks one of each pair of level-2 outputs: 8->4
        for (j = 0; j < 4; j = j + 1) begin : four_mux
            mux2_1 m2 (.out(c[j]), .i0(b[2*j]), .i1(b[2*j+1]), .sel(sel[2]));
        end

        //Level 4: sel[3] picks one of each pair of level-3 outputs: 4->2
        for (j = 0; j < 2; j = j + 1) begin : two_mux
            mux2_1 m3 (.out(d[j]), .i0(c[2*j]), .i1(c[2*j+1]), .sel(sel[3]));
        end
    endgenerate

    //Assigns the final bit given the previous results. 
    //If MSB is 0, then code knows to select the corresponding 0-15 value.
    //If MSB is 1, then code knows to select the corresponding 16-31 value.
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