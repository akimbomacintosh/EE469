`timescale 1ns/10ps

//Memory stage of the CPU: Programmed for LDUR and STUR
// PARAMETERS --> INPUTS:
// - aluResult: The result of the ALU operation
// - dataB: The result from RegFile's B output port.
// - MemWrite: Input signal whether you need to write/replace a value in datamem.
// - MemRead: Input signal whether you need to obtain data from memory.
// - clk: Clock.
// PARAMETERS --> OUTPUTS:
// - memData: Dout of memory, the data that was retrieved/needed. 
module mem(memData, aluResult, dataB, MemWrite, MemRead, clk);
    output logic [63:0] memData;
    input logic [63:0] aluResult, dataB;
    input logic MemWrite, MemRead, clk;

    datamem dataMemory (.address(aluResult), .write_enable(MemWrite), .read_enable(MemRead), 
                        .write_data(dataB), .clk(clk), .xfer_size(4'd8), .read_data(memData));

endmodule


module mem_testbench();
    logic [63:0] memData, aluResult, dataB;
    logic MemWrite, MemRead, clk;  

    mem dut(.memData, .aluResult, .dataB, .MemWrite, .MemRead, .clk);

    parameter PERIOD = 100;
    initial begin 
        clk <= 0;
        forever #(PERIOD/2) clk <= ~clk;
    end

    initial begin
        MemWrite <= 1'b0; MemRead <= 1'b0; aluResult <= 64'd16; dataB <= 64'd1234;
        @(posedge clk);
        MemWrite <= 1; //STUR
        @(posedge clk); 
        MemWrite <= 0; MemRead <= 1; //LDUR
        #10; //give values time to settle
        //memData result should be 1234 (shows little endian memory assembled in new correct order)
        $stop; 
    end

endmodule