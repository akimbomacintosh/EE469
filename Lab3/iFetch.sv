`timescale 1ns/10ps

// instruction fetch state of the CPU that holds the proram counter, reads the current instruction and picks the next program counter
module iFetch (programCounter, instruction, signExtend19, signExtend26, datab, unconditionalBranch, branchTaken, branchRegister, reset, clk);
    output logic [63:0] programCounter, pcPlus4;
    output logic [31:0] instruction;
    input logic [63:0] nextPC, signExtend19, signExtend26, datab;
    input logic unconditionalBranch, branchTaken, branchRegister, reset, clk;
    logic [63:0] pcPlus4, pcPlusSignExtend19, pcPlusSignExtend26, pcPlusDatab;

    genvar i;
	generate
		for (i = 0; i < 64; i++) begin : eachBit // place 64 copies of the flipflop with the enable and lock and the input and outpit
			D_FF register (.q(bitsOut[i]), .d(bitsIn[i]), .reset(reset), .clk(clk));
		end
	endgenerate

    instructmem instructionMemory (.instruction(instruction), .address(programCounter), .clk(clk));

    alu adder1 (.result(pcPlus4), .A(programCounter), .B(64'b100), .cntrl(3'b010));
endmodule
