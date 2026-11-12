// Top level file for Single-Cycle CPU. 
// This file essentially just connects all the wires between stages. 
//      iFetch --> decode --> execute --> mem --> wb
module cpu(clk, reset);

    input logic clk, reset;

    //Set control wires/signals
    logic Reg2Loc, RegWrite, ImmSelect, aluSource, aluOp, setFlags, MemWrite, MemRead,
            MemToReg, Link, branchRegister, branchTaken, unconditionalBranch;
    logic [2:0] aluOp;

    //wires between stages:
    logic [63:0] programCounter, pcPlus4;   //iFetch --> decode, wb
    logic [31:0] instruction;               //iFetch --> decode, control
    logic [63:0] dataA, dataB;              //decode --> exec (dataB --> mem, iFetch)
    logic [63:0] signExtend9, zeroExtend12; //decode --> exec
    logic [63:0] signExtend19, signExtend26;//decode --> iFetch (branch offsets)
    logic aluZero, storedOverflow, storedNegative;//execute --> control
    logic [63:0] aluResult;                 //exec --> mem, wb
    logic [63:0] memData;                   //mem --> wb
    logic [63:0] writeData;                 //wb --> decode (RegFile)

    control ctrl (.opcode(instruction[31:21]), .cond(instruction[4:0]), .aluZero, .storedNegative,
                  .storedOverflow, .Reg2Loc, .aluSource, .ImmSelect, .aluOp, .RegWrite, .MemToReg, .Link,
                  .MemWrite, .MemRead, .unconditionalBranch, .branchTaken, .branchRegister, .setFlags);

    iFetch fetchStage (.programCounter, .pcPlus4, .instruction, .signExtend19, .signExtend26, .dataB, .unconditionalBranch,
                  .branchTaken, .branchRegister, .reset, .clk);

    decode decodeStage(.dataA, .dataB, .signExtend19, .signExtend26, .signExtend9, .zeroExtend12, .instruction, .writeData,
                       .Reg2Loc, .Link, .RegWrite, .clk);

    execute execStage(.aluResult, .aluZero, .storedNegative, .storedOverflow, .dataA, .dataB,
                      .signExtend9, .zeroExtend12, .aluSource, .ImmSelect, .aluOp, .setFlags, .reset, .clk);

    mem memoryStage (.memData, .aluResult, .dataB, .MemWrite, .MemRead, .clk);

    wb wbStage (.writeData, .aluResult, .memoryData, .pcPlus4, .MemtoReg, .Link);

endmodule



module cpu_testbench();
    logic clk, reset;

    parameter ClockDelay = 5000;

    cpu dut (.clk, .reset);

    initial begin 
        clk <= 0;
        forever #(ClockDelay/2) clk <= ~clk;
    end

    integer i
    initial begin
        //reset CPU so all data starts at 0
        reset <= 1;
        //Give CPU time to reset
        @(posedge clk);
        @(posedge clk);
        reset <= 0;

        //run program 1000 times, long enough for benchmarks to do their thing.
        for(i = 0; i < 1000; i++)
            @(posedge clk);
        $stop;
    end

endmodule