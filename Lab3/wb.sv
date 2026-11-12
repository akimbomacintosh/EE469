`timescale 1ns/10ps

// write back is the final stage of the cpu which picks the data that gets written back into the register file
module wb (writeData, aluResult, memoryData, pcPlus4, memToReg, link);
    output logic [63:0] writeData;
    // write data at the very end of the cpu, that goes back to the register file in decode
    input logic [63:0] aluResult, memoryData, pcPlus4;
    input logic memToReg, link;
    // aluresult is the output from the alu for addi, adds, and subs
    // memdata is the value read from data memory
    // pcplus4 is the return from fetch for bl
    // memtoreg picks between aluresult or memorydata
    // link picks betwen the first mux or pcplus4

    // the output is either alureult or memorydata which is picked by memtoreg
    logic [63:0] out;

    // picks between tje alu or data memory
    mux2_1_special #(.WIDTH(64)) writeBackMux1 (.out(out), .i0(aluResult), .i1(memoryData), .select(memToReg));
    // picks between the result of the previous mux of pc+4
    mux2_1_special #(.WIDTH(64)) writeBackMux2 (.out(writeData), .i0(out), .i1(pcPlus4), .select(link));
endmodule

module wb_testbench();
    logic [63:0] writeData, aluResult, memoryData, pcPlus4;
    logic memToReg, link;

    wb dut (.writeData, .aluResult, .memoryData, .pcPlus4, .memToReg, .link);

    initial begin
        // give each input a different value so writeData shows which was picked
        aluResult <= 64'd67;
        memoryData <= 64'd76;
        pcPlus4 <= 64'd69;

        // ADDI, ADDS or SUBS, writeData is aluResult = 5
        memToReg <= 0;
        link <= 0;
        #10;

        // test 2: LDUR, writeData should be memData = 1234
        memToReg <= 1;
        #10;

        // test 3: BL, writeData should be pcPlus4 = 44
        memToReg <= 0;
        link <= 1;
        #10;

        $stop;
    end
endmodule