`timescale 1ns/10ps

module decode (dataA, dataB, signExtend19, signExtend26, signExtend9, zeroExtend12, instruction, writeData, Reg2Loc, Link, RegWrite, clk);
    output logic [63:0] dataA, dataB, signExtend19, signExtend26, signExtend9, zeroExtend12;
    // data A is the valude in register Rn (the first register)
    // data B is the value in register Rm or Rd which goes to the alu, data mem, and fetch
    // signextend19 and 26 are the branch offsets that go back to fetch to calculate the next instruction address
    // sign extend9 is the LDUR and STUR address offset and zeroextend12 is the offset for ADDI which both go to execute

    input logic [31:0] instruction;
    input logic [63:0] writeData;
    input logic Reg2Loc, Link, RegWrite, clk;
    // instruction is the 32 bit instuction from fetch
    // write data is the data coming back from a writeback to be written to a register
    // Reg2Loc picks between Rd and Rm
    // Link picks between Rd and x30 for BL
    // RegWrite is the write enable signal for the register file

    logic [4:0] readRegister2, writeRegister;
    // read register 2 is the second register in the instruction Rm or Rd depending on Reg2Loc, this logic is the registers number

    // sign extends ensure that the top bit is filled with the same sign bit so negatives stay negative and positive stay positive
    //                      45 copies of bit 23   23 down to 5 (19 bits)                19+45= 64 bits
    assign signExtend19 = {{45{instruction[23]}}, instruction[23:5]}; // sign extend the 19 bit offset for B.LT and CBZ
    assign signExtend26 = {{38{instruction[25]}}, instruction[25:0]}; // sign extend the 26 bit offset for B and BL
    assign signExtend9 = {{55{instruction[20]}}, instruction[20:12]}; // sign extend the 9 bit offset for LDUR and STUR
    assign zeroExtend12 = {52'b0, instruction[21:10]}; // zero extend the 12 bit offset for ADDI, fill supper bits with zeros since immediates are always positive for ADDI

     // pick between Rd and Rm for the second register
    mux2_1_special #(.WIDTH(5)) regMux1 (.out(readRegister2), .i0(instruction[4:0]), .i1(instruction[20:16]), .select(Reg2Loc));
    // pick between Rd and x30 for BL
    mux2_1_special #(.WIDTH(5)) regMux2 (.out(writeRegister), .i0(instruction[4:0]), .i1(5'd30), .select(Link));
    // read and write to the register file
    regfile registers (.ReadData1(dataA), .ReadData2(dataB), .WriteData(writeData), .ReadRegister1(instruction[9:5]),
                       .ReadRegister2(readRegister2), .WriteRegister(writeRegister), .RegWrite(RegWrite), .clk(clk)); 
endmodule

module decode_testbench();
    logic [63:0] dataA, dataB, signExtend19, signExtend26, signExtend9, zeroExtend12, writeData;
    logic [31:0] instruction;
    logic Reg2Loc, Link, RegWrite, clk;
    parameter delay = 5000;

    initial begin // set up clock
        clk <= 0;
        forever #(delay/2) clk <= ~clk;
    end

    decode dut (.dataA, .dataB, .signExtend19, .signExtend26, .signExtend9, .zeroExtend12, .instruction, .writeData, .Reg2Loc, .Link, .RegWrite, .clk);

    initial begin
        // write 5 into x1
        //                opcode(ADDI)   Imm12       Rn    Rd
        instruction <= 32'b1001000100_000000000101_11111_00001;
        writeData <= 64'd5;
        Reg2Loc <= 0;
        Link <= 0;
        RegWrite <= 1;
        @(posedge clk);

        // set Link to one so 100 is written into x30 instead of x1
        //                 opcode         brAddr26
        instruction <= 32'b100101_00000000000000000000000000;
        writeData <= 64'd100;
        Link <= 1;
        @(posedge clk);

        // ADDS X2, X1, X30, dataA should be 5 and dataB should be 100
        //                opcode(ADDS)  Rm    shamt  Rn    Rd 
        instruction <= 32'b10101011000_11110_000000_00001_00010;
        RegWrite <= 0;
        Link <= 0;
        Reg2Loc <= 1;
        @(posedge clk);

        // STUR X1, [X1, #-7], dataA should be zero, B should be 5, and signExtend9 should be -7
        //                opcode          DAddr9      Rn    Rd
        instruction <= 32'b11111000000_111111000_00_11111_00001;
        Reg2Loc <= 0;
        @(posedge clk);

        // EXTENDERS
        // ADDI X3, X1, 2005, zeroextend should be 2005 and stay positive
        //                opcode(ADDI)   Imm12       Rn    Rd
        instruction <= 32'b1001000100_000110100111_00001_00011;
        Reg2Loc <= 0;
        @(posedge clk);

        // B.lT to go back three instrictions, signextend19 should be -3
        //                 opcode         condAddr19    cond
        instruction <= 32'b01010100_1111111111111111101_01011;
        @(posedge clk);

        // B back 2 instructions, signExtend should be -2
        //                 opcode         brAddr26
        instruction <= 32'b000101_11111111111111111111111110;
        @(posedge clk);

        $stop;
    end
endmodule