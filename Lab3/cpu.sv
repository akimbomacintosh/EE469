// instruction parameter from instruction[31:21], make it "opcode"

// Top level file for Single-Cycle CPU. 
// This file essentially just connects all the wires between stages. 
//      iFetch --> decode --> execute --> mem --> wb
module cpu(clk, reset);

    input logic clk, reset;

    //Set control wires/signals
    logic Reg2Loc, Link, RegWrite, ImmSelect, ALUSrc, ALUOp, SetFlags, MemWrite, MemRead,
            MemToReg, Link, branchRegister, branchTaken, unconditionalBranch;
    logic [2:0] aluOp;

    //wires between stages:
    logic [63:0] programCounter, pcPlus4;
    logic [31:0] instruction;
    logic [63:0] dataA, dataB;
    logic [63:0] signExtend9, zeroExtend12, signExtend19, signExtend26;
    logic [63:0] branchTaken;
    logic dataBZero;
    logic [63:0] aluResult;
    logic [3:0] flags;
    logic [63:0] memData;
    logic [63:0] writeData;

    control ctrl (.opcode(instruction[31:21]), .cond(instruction[4:0]), .zero(dataBZero), .storedNegative(flags[3]),
                  .storedOverflow(flags[0]), .Reg2Loc, .aluSource, .ImmSelect, .aluOp, .RegWrite, .MemToReg, .Link,
                  .MemWrite, .MemRead, .unconditionalBranch, .branchTaken, .branchRegister, .setFlags);

    iFetch fetchStage (.programCounter, .pcPlus4, .instruction, .signExtend19, .signExtend26, .dataB, .unconditionalBranch,
                  .branchTaken, .branchRegister, .reset, .clk);

    decode decodeStage(.dataA, .dataB, .signExtend19, .signExtend26, .signExtend9, .zeroExtend12, .instruction, .writeData,
                       .Reg2Loc, .Link, .RegWrite, .clk);

    execute execStage(.aluResult, .aluZero(flags[2]), .storedNegative(flags[3]), .storedOverflow(flags[0]), .dataA, .dataB,
                      .signExtend9, .zeroExtend12, .aluSource, .aluOp, .setFlags, .reset, .clk);

    mem memoryStage (.memData, .aluResult, .dataB, .MemWrite, .MemRead, .clk);

    wb wbStage (.writeData, .aluResult, .memoryData, .pcPlus4, .MemtoReg, .Link);

endmodule



module cpu_testbench();


endmodule