`timescale 1ns/10ps;

// 2:4 decoder with enable. Turns a 2-bit number into 4 output lines,
// where only the line matching the number is 1 (e.g. writereg = 2 -> out = 0100).
// If regwrite is 0, all outputs are 0.
// Ports:
//    out      - 4 output lines, at most one is 1
//    writereg - 2-bit number picking which output line to turn on
//    regwrite - enable; must be 1 for any output to turn on
//input    output    which wire is on
// 00   -> 0001      group_out[0]  (registers 0-7)
// 01   -> 0010      group_out[1]  (registers 8-15)
// 10   -> 0100      group_out[2]  (registers 16-23)
// 11   -> 1000      group_out[3]  (registers 24-31)
module decoder2_4(out, writereg, regwrite);
    output logic [3:0] out;
    input logic [1:0] writereg;
    input logic regwrite;

    parameter delay = 0.05;

    logic writereg_n0, writereg_n1;
    not #delay n0 (writereg_n0, writereg[0]);
    not #delay n1 (writereg_n1, writereg[1]);

    and #delay a0 (out[0], writereg_n1, writereg_n0, regwrite);
    and #delay a1 (out[1], writereg_n1, writereg[0], regwrite);
    and #delay a2 (out[2], writereg[1], writereg_n0, regwrite);
    and #delay a3 (out[3], writereg[1], writereg[0], regwrite);
endmodule


// 3:8 decoder with enable. Same idea as decoder2_4, but turns a 3-bit
// number into 8 output lines (e.g. writereg = 5 -> out[5] = 1).
// If regwrite is 0, all outputs are 0.
// Ports:
//    out      - 8 output lines, at most one is 1
//    writereg - 3-bit number picking which output line to turn on
//    regwrite - enable; must be 1 for any output to turn on
//input    output       which wire is on
// 000  -> 0000_0001    out[0]
// 001  -> 0000_0010    out[1]
// 010  -> 0000_0100    out[2]
// 011  -> 0000_1000    out[3]
// 100  -> 0001_0000    out[4]
// 101  -> 0010_0000    out[5]
// 110  -> 0100_0000    out[6]
// 111  -> 1000_0000    out[7]
module decoder3_8(out, writereg, regwrite);
    output logic [7:0] out;
    input logic [2:0] writereg;
    input logic regwrite;

    parameter delay = 0.05;

    logic writereg_n0, writereg_n1, writereg_n2;

    not #delay n0 (writereg_n0, writereg[0]);
    not #delay n1 (writereg_n1, writereg[1]);
    not #delay n2 (writereg_n2, writereg[2]);

    and #delay a0 (out[0], writereg_n2, writereg_n1, writereg_n0, regwrite);
    and #delay a1 (out[1], writereg_n2, writereg_n1, writereg[0], regwrite);
    and #delay a2 (out[2], writereg_n2, writereg[1], writereg_n0, regwrite);
    and #delay a3 (out[3], writereg_n2, writereg[1], writereg[0], regwrite);
    and #delay a4 (out[4], writereg[2], writereg_n1, writereg_n0, regwrite);
    and #delay a5 (out[5], writereg[2], writereg_n1, writereg[0], regwrite);
    and #delay a6 (out[6], writereg[2], writereg[1], writereg_n0, regwrite);
    and #delay a7 (out[7], writereg[2], writereg[1], writereg[0], regwrite);
endmodule


// 5:32 decoder: takes a 5-bit register number and turns on the write-enable
// line for that register. Built from one 2:4 decoder (top 2 bits pick a group
// of 8 registers) and four 3:8 decoders (bottom 3 bits pick a register in the group).
// Ports:
//      out      - 32 write-enable lines, one per register; at most one bit is 1,
//                 marking the register to write to
//      writereg - 5-bit unsigned register number (0-31) to write to
//      regwrite - enable; if 0, all outputs are 0 and nothing is written.
//                 If 1, the selected register's line is turned on.
//input      output                                    which wire is on
// 00000  -> 0000_0000_0000_0000_0000_0000_0000_0001    out[0]
// 00001  -> 0000_0000_0000_0000_0000_0000_0000_0010    out[1]
// ...
// 10101  -> 0000_0000_0010_0000_0000_0000_0000_0000    out[21]
// ...
// 11111  -> 1000_0000_0000_0000_0000_0000_0000_0000    out[31]
module decoder5_32(out, writereg, regwrite);
    output logic [31:0] out;
    input logic [4:0] writereg;
    input logic regwrite;

    logic [3:0] group_out;

    decoder2_4 group_decoder (.out(group_out), .writereg(writereg[4:3]), .regwrite(regwrite));

    decoder3_8 decoder0 (.out(out[7:0]), .writereg(writereg[2:0]), .regwrite(group_out[0]));
    decoder3_8 decoder1 (.out(out[15:8]), .writereg(writereg[2:0]), .regwrite(group_out[1]));
    decoder3_8 decoder2 (.out(out[23:16]), .writereg(writereg[2:0]), .regwrite(group_out[2]));
    decoder3_8 decoder3 (.out(out[31:24]), .writereg(writereg[2:0]), .regwrite(group_out[3]));
endmodule

module decoder2_4_testbench();
	logic [1:0] writereg;
	logic regwrite;
	logic [3:0] out;

	decoder2_4 dut (.out, .writereg, .regwrite);

	integer k;
	initial begin
		for (k = 0; k < 8; k++) begin
			{regwrite, writereg} = k; #10; // glues bits together to form 3 bits to test all possible combinations 
		end
		$stop;
	end
endmodule


module decoder3_8_testbench();
	logic [2:0] writereg;
	logic regwrite;
	logic [7:0] out;

	decoder3_8 dut (.out, .writereg, .regwrite);

	integer k;
	initial begin
		for (k = 0; k < 16; k++) begin
			{regwrite, writereg} = k; #10;
		end
		$stop;
	end
endmodule

module decoder5_32_testbench();
	logic [4:0] writereg;
	logic regwrite;
	logic [31:0] out;

	decoder5_32 dut (.out, .writereg, .regwrite);

	integer k;
	initial begin
		for (k = 0; k < 64; k++) begin
			{regwrite, writereg} = k; #10;
		end
		$stop;
	end
endmodule