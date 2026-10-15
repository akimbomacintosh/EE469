`timescale 1ns/10ps;
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

module decoder5_32(out, writereg, regwrite);
    output logic [31:0] out;
    input logic [4:0] writereg;
    input logic regwrite;

    parameter delay = 0.05;

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