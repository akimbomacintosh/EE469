`timescale 1ns/10ps

// instruction fetch state of the CPU that holds the proram counter, reads the current instruction and picks the next program counter
module iFetch (programCounter, pcPlus4, instruction, signExtend19, signExtend26, dataB, unconditionalBranch, branchTaken, branchRegister, reset, clk);
    output logic [63:0] programCounter, pcPlus4;
    // programcounter is the address we are currently running in the cpu
    // pcPlus4 is the address of the next instruction in the cpu

    output logic [31:0] instruction;
    input logic [63:0] signExtend19, signExtend26, dataB;
    input logic unconditionalBranch, branchTaken, branchRegister, reset, clk;
    // unconditionalBranch is on pcmux1 and picks between the 19 bit offset for B.LT or CBZ, or the 26 bit offset for B or BL
    // branchTaken is on pcmux2 and picks between the next instruction or the branch target
    // branchRegister is on pcmux3 and picks between the next instruction or the value in dataB

    logic [63:0] nextPC, branchOffset, branchOffsetShift, branchTarget, pcAfterBranch;
    // branchOffset holds how far we would need to jump for a branch instrcution
    // branchOffsetShift holds the branchOffset shifted left by 2 to get the byte offset which could be something like 5 rows * 4 bytes = 20 bytes
    // branchTarget hold the address we would jump to, pc + offset
    // pcAfterBranch holds the next instrcution in the case we do not branch, brTaken picks between branch target or pc + 4, 
    // nextPC holds the final next instruction, the 64 flip flips move this into programCounter on the next clock edge

    // assign branchOffsetShift = signExtend26 << 2; // shift the 26 bit offset left by 2 to get byte offset
    assign branchOffsetShift = {branchOffset[61:0], 2'b00};
    genvar i;
	generate
		for (i = 0; i < 64; i++) begin : eachBit // place 64 copies of the flipflop with the enable and lock and the input and outpit
			D_FF pcflipflop (.q(programCounter[i]), .d(nextPC[i]), .reset(reset), .clk(clk));
		end
	endgenerate

    instructmem instructionMemory (.instruction(instruction), .address(programCounter), .clk(clk));

    // does pc + 4 to get next instruction address
    alu pcadder (.A(programCounter), .B(64'b100), .cntrl(3'b010), .result(pcPlus4));
    // does the 19 bit offset address for B.LT or CBZ, or the 26 bit offset for B or BL
    mux2_1_special #(.WIDTH(64)) pcMux1 (.out(branchOffset), .i0(signExtend19), .i1(signExtend26), .select(unconditionalBranch));
    // new target is pc + offset
    alu branchAdder (.A(programCounter), .B(branchOffsetShift), .cntrl(3'b010), .result(branchTarget));
    // pick between PC + 4 or the branch target
    mux2_1_special #(.WIDTH(64)) pcMux2 (.out(pcAfterBranch), .i0(pcPlus4), .i1(branchTarget), .select(branchTaken));
    // pick between the next instruction or the value in dataB
    mux2_1_special #(.WIDTH(64)) pcMux3 (.out(nextPC), .i0(pcAfterBranch), .i1(dataB), .select(branchRegister));
endmodule

module iFetch_testbench();
    logic [63:0] programCounter, pcPlus4, signExtend19, signExtend26, dataB;
    logic [31:0] instruction;
    logic unconditionalBranch, branchTaken, branchRegister, reset, clk;
    parameter delay = 5000;

    initial begin // set up clock
		clk <= 0;
		forever #(delay/2) clk <= ~clk;
	end

    iFetch dut (.programCounter, .pcPlus4, .instruction, .signExtend19, .signExtend26, .dataB, .unconditionalBranch, .branchTaken, .branchRegister, .reset, .clk);

	initial begin
		// initialize all values to 0 and reset the CPU
		signExtend19 <= 64'd0;
		signExtend26 <= 64'd0;
		dataB <= 64'd0;
		unconditionalBranch <= 0;
		branchTaken <= 0;
		branchRegister <= 0;
		reset <= 1;
		@(posedge clk);
        reset <= 0;
        @(posedge clk);

        // test the PC incrementing 3 times by 4
        @(posedge clk);
		@(posedge clk);
		@(posedge clk);

        // B or BL jump 2 instrcutions ahead, pc is 16 + 8 = 24
        unconditionalBranch <= 1;
		branchTaken <= 1;
		signExtend26 <= 64'd2;
		@(posedge clk);

        // B.LT or CBZ, jump 1 instrcution so pc is 24 - 4 = 20
        unconditionalBranch <= 0;
        signExtend19 <= -64'd1;
		@(posedge clk);

        // BR which is jumping to address in dataB, pc should go to 40
        branchTaken <= 0;
		branchRegister <= 1;
		dataB <= 64'd40;
		@(posedge clk);

        // go back to normal clock increments, pc should go to 44
        branchRegister <= 0;
        @(posedge clk);
        @(posedge clk);

        $stop;
    end
endmodule


