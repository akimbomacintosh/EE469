`timescale 1ns/10ps

// Top level file for Single-Cycle CPU. 
// This file essentially just connects all the wires between stages. 
//      iFetch --> decode --> execute --> mem --> wb
module cpu(clk, reset);

    input logic clk, reset;

    //Set control wires/signals
    logic Reg2Loc, aluSource, ImmSelect, RegWrite, MemToReg, Link, MemWrite, MemRead,
          unconditionalBranch, branchTaken, branchRegister, setFlags;
    logic [2:0] aluOp;

    //wires between stages:
    logic [63:0] programCounter, pcPlus4;
    logic [31:0] instruction;
    logic [63:0] dataA, dataB;
    logic [63:0] signExtend9, zeroExtend12, signExtend19, signExtend26;
    logic [63:0] aluResult;
    logic aluZero, storedNegative, storedOverflow;
    logic [63:0] memData;
    logic [63:0] writeData;

    control ctrl       (.opcode(instruction[31:21]), .cond(instruction[4:0]), .aluZero, .storedNegative, .storedOverflow,
                        .Reg2Loc, .aluSource, .ImmSelect, .aluOp, .RegWrite, .MemToReg, .Link,
                        .MemWrite, .MemRead, .unconditionalBranch, .branchTaken, .branchRegister, .setFlags);

    iFetch fetchStage  (.programCounter, .pcPlus4, .instruction, .signExtend19, .signExtend26, .dataB, .unconditionalBranch,
                        .branchTaken, .branchRegister, .reset, .clk);

    decode decodeStage (.dataA, .dataB, .signExtend19, .signExtend26, .signExtend9, .zeroExtend12, .instruction, .writeData,
                        .Reg2Loc, .Link, .RegWrite, .clk);

    execute execStage  (.aluResult, .aluZero, .storedNegative, .storedOverflow, .dataA, .dataB,
                        .signExtend9, .zeroExtend12, .aluSource, .ImmSelect, .aluOp, .setFlags, .reset, .clk);

    mem memoryStage    (.memData, .aluResult, .dataB, .MemWrite, .MemRead, .clk);

    wb wbStage         (.writeData, .aluResult, .memoryData(memData), .pcPlus4, .MemToReg, .Link);

endmodule