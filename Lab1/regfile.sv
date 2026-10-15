`timescale 1ns/10ps
module dff_en(q, d, en, clk);
	output logic q;
	input logic d, en, clk;

	logic dmux;

	mux2_1 m  (.out(dmux), .i0(q), .i1(d), .sel(en));
	D_FF   ff (.q(q), .d(dmux), .reset(1'b0), .clk(clk));
endmodule

module register64(q, d, en, clk);
	output logic [63:0] q;
	input logic [63:0] d;
	input logic en, clk;

	genvar i;
	generate
		for (i = 0; i < 64; i++) begin : eachBit
			dff_en b (.q(q[i]), .d(d[i]), .en(en), .clk(clk));
		end
	endgenerate
endmodule

module mux64x32_1(out, regs, sel);
	output logic [63:0] out;
	input logic [31:0][63:0] regs;
	input logic [4:0] sel;

	logic [63:0][31:0] cols;

	genvar b, r;
	generate
		for (b = 0; b < 64; b++) begin : eachBit
			for (r = 0; r < 32; r++) begin : eachReg
				assign cols[b][r] = regs[r][b];
			end
			mux32_1 m (.out(out[b]), .i(cols[b]), .sel(sel));
		end
	endgenerate
endmodule

module regfile(ReadData1, ReadData2, WriteData, ReadRegister1, ReadRegister2, WriteRegister, RegWrite, clk);
	output logic [63:0] ReadData1, ReadData2;
	input logic [63:0] WriteData;
	input logic [4:0] ReadRegister1, ReadRegister2, WriteRegister;
	input logic RegWrite, clk;

	logic [31:0] enable;
	logic [31:0][63:0] regs;

	decoder5_32 dec (.out(enable), .writereg(WriteRegister), .regwrite(RegWrite));

	genvar r;
	generate
		for (r = 0; r < 31; r++) begin : eachReg
			register64 x (.q(regs[r]), .d(WriteData), .en(enable[r]), .clk(clk));
		end
	endgenerate

	assign regs[31] = 64'b0;

	mux64x32_1 port1 (.out(ReadData1), .regs(regs), .sel(ReadRegister1));
	mux64x32_1 port2 (.out(ReadData2), .regs(regs), .sel(ReadRegister2));
endmodule