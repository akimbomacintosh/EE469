`timescale 1ns/10ps

// uses a mux to select the value going into the flipflop using an enable signal from a 2:1 mux 
module dff_en_reset(outBit, inBit, enable, reset, clk);
	output logic outBit;
	input logic inBit, enable, reset, clk;

	logic dmux; // what is queued going into the flipflop

    // what is going into the flipflop after the mux
	mux2_1 m (.out(dmux), .i0(outBit), .i1(inBit), .sel(enable));

    // stores what the mux picked on the rising clock edge
	D_FF ff (.q(outBit), .d(dmux), .reset(reset), .clk(clk));
endmodule

// builds a 4 bit register out of 4 flip flops that hold one but and can be enabled to write to a register, used to store flag values
module register4(bitsOut, bitsIn, enable, clk, reset);
	output logic [3:0] bitsOut; // the registers 4 bit value
	input logic [3:0] bitsIn; // the 4 bit value to write to the register
	input logic enable, clk, reset;

	genvar i;
	generate
		for (i = 0; i < 4; i++) begin : eachBit // place 4 copies of the flipflop with the enable and lock and the input and outpit
			dff_en_reset b (.outBit(bitsOut[i]), .inBit(bitsIn[i]), .enable(enable), .reset(reset), .clk(clk));
		end
	endgenerate
endmodule