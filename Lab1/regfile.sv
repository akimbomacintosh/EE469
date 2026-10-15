`timescale 1ns/10ps

// uses a mux to select the value going into the flipflop using an enable signal from a 2:1 mux 
module dff_en(outBit, inBit, enable, clk);
	output logic outBit;
	input logic inBit, enable, clk;

	logic dmux; // what is qeued going into the flipflop

    // what is going into the flipflop after the mux
	mux2_1 m  (.out(dmux), .i0(outBit), .i1(inBit), .sel(enable));

    // stores what the mux picked on the rising clock edge
	D_FF ff (.q(outBit), .d(dmux), .reset(1'b0), .clk(clk));
endmodule

// builds a 64 bit register out of 64 flip flops that hold one but and can be enabled to write to a register
module register64(bitsOut, bitsIn, enable, clk);
	output logic [63:0] bitsOut; // the registers 64 bit value
	input logic [63:0] bitsIn; // the 64 bit value to write to the register
	input logic enable, clk;

	genvar i;
	generate
		for (i = 0; i < 64; i++) begin : eachBit // place 64 copies of the flipflop with the enable and lock and the input and outpit
			dff_en b (.outBit(bitsOut[i]), .inBit(bitsIn[i]), .enable(enable), .clk(clk));
		end
	endgenerate
endmodule

// give the register number and this module outputs the 64 bits of that register
module mux64x32_1(out, regs, sel);
	output logic [63:0] out; // all 64 bits of the selected register
	input logic [31:0][63:0] regs; // all 32 registers with 64 bits each
	input logic [4:0] sel; //the select signal to pick register 0-31

	logic [63:0][31:0] cols; // the 64 bits of each register in a column

	genvar bitPos, register;
	generate
		for (bitPos = 0; bitPos < 64; bitPos++) begin : eachBit // loop thru each bit of the register
			for (register = 0; register < 32; register++) begin : eachReg // loop thru the same bit of each register
				assign cols[bitPos][register] = regs[register][bitPos]; // write the bit of each register into a column
			end
			mux32_1 m (.out(out[bitPos]), .i(cols[bitPos]), .sel(sel));  // use a 32:1 mux to select the bit of the selected register
		end
	endgenerate
endmodule

// takes a 5 bit input and outputs 2 64 bit register outputs
module regfile(ReadData1, ReadData2, WriteData, ReadRegister1, ReadRegister2, WriteRegister, RegWrite, clk);
	output logic [63:0] ReadData1, ReadData2; // the two 64 bit outputs of the selected registers
	input logic [63:0] WriteData; // the 64 bit value to write to the register but the register is selected by the WriteRegister input
	input logic [4:0] ReadRegister1, ReadRegister2, WriteRegister; // the two registers to read and the one to write to, ex. SUBS X1, X2, X3, where X1 and X2 are read and X3 is written t0
	input logic RegWrite, clk; // the write enable signal and the clock signal

	logic [31:0] enable; // enable for each register
	logic [31:0][63:0] regs; // output for each register

	decoder5_32 decoder (.out(enable), .writereg(WriteRegister), .regwrite(RegWrite)); // uses the decoder to pick which register to write to (needs enable signal)

	genvar r;

    // builds 31 registers with data that can be read and written with register 31 always being zero
	generate
		for (r = 0; r < 31; r++) begin : eachReg
			register64 oneRegister (.bitsOut(regs[r]), .bitsIn(WriteData), .enable(enable[r]), .clk(clk));
		end
	endgenerate

    // make register 31 always be zero
	assign regs[31] = 64'b0;

    // two copies to read two register at the same time, uses a 32:1 mux to select the register to read
	mux64x32_1 port1 (.out(ReadData1), .regs(regs), .sel(ReadRegister1));
	mux64x32_1 port2 (.out(ReadData2), .regs(regs), .sel(ReadRegister2));
endmodule