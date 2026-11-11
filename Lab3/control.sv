`timescale 1ns/10ps 

// Control logic for our single cycle processor (in RTL)
// PARAMETERS --> INPUTS: 
// - opcode: The operation code for each instruction we're required to implement.
    // - 11 bits long because we have to account for the longest opcode.
// - cond: 
// - zero: The zero flag from the most recent ALU operation (required for CBZ)
// - flagN: Stored negative flag from most recent operation that computed a value for this.
// - flagV: Stored overflow flag from most recent operation that computed a value for this.
// PARAMETERS --> OUTPUTS: 
// - Reg2Loc: Location of Register 2. Determines whether you 
// - ALUSrc: ALU Source; determiens whether the 'B' register in ALU gets its value from RegFile or an extender.
// - ImmSelect: Select which immediate (Imm9 or Imm12) to extend to 64 bits and send to ALUSrc mux. 
// - ALUOp: 3 bit control to tell the ALU which operation to execute (only 2 used in this lab)
// - RegWrite: Determines whether a register value is getting changed/written to. 
// - MemToReg: Determines if a register value in memory is getting sent back to RegFile. 
// - Link: For BL command, determines if BL is the command, and then allows X30 = PC + 4.
// - MemWrite: Determines if you're writing a value to memory.
// - MemRead: Determines if you're taking a value from memory.
// - UncondBr: Determines which branch you're taking (dependent on immediate extenders)
// - branchTaken: Determines if there was a branch command, or to just do PC + 4.
// - branchRegister: For BR only (PC = Reg[Rd]), helps determine what new PC value to send back to PC. 
// - SetFlags: Determines if you need to create new flags from the ALU output. 
module control (opcode, cond, zero, flagN, flagV, Reg2Loc, ALUSrc, ImmSelect, ALUOp,
                RegWrite, MemToReg, Link, MemWrite, MemRead, unconditionalBranch, 
                branchTaken, branchRegister, SetFlags);

    input logic [10:0] opcode;
    input logic [4:0] cond;
    input logic zero, flagN, flagV;
    output logic Reg2Loc, ALUSrc, ImmSelect, RegWrite, MemToReg, Link, MemWrite, MemRead,
                    unconditionalBranch, branchTaken, branchRegister, SetFlags;
    output logic [2:0] ALUOp;

    always_comb begin
        // set default cases: a "harmless no-operation"
            ALUOp = 3'b000; Reg2Loc = 1'b0; ALUSrc = 1'b0; ImmSelect = 1'b0;
            RegWrite = 1'b0; MemToReg = 1'b0; Link = 1'b0; MemWrite = 1'b0;
            MemRead = 1'b0; unconditionalBranch = 1'b0; branchTaken = 1'b0;
            branchRegister = 1'b0; SetFlags = 1'b0;

            //For conditionals below, only change what values from the default case get changed.

            //ADDI Instruction
            if(opcode[10:1] == 10'b1001000100) begin
            //Values that get changed:
                RegWrite = 1'b1; ALUOp = 3'b010; ImmSelect = 1'b1; ALUSrc = 1'b1;
            end

            //ADDS Instruction
            else if(opcode[10:0] == 11'b10101011000)begin
                RegWrite = 1'b1; SetFlags = 1'b1; Reg2Loc = 1'b1; ALUOp = 3'b010;
            end

            //B Instruction
            else if(opcode[10:5] == 6'b000101) begin
                unconditionalBranch = 1'b1; branchTaken = 1'b1;
            end
            
            //B.LT Instruction (opcode = B.cond)
            else if(opcode[10:3] == 8'b01010100)begin
                branchTaken = (cond == 5'b01011) & (flagN ^ flagV);
                unconditionalBranch = 1'b0;
            end

            //BL Instruction
            else if(opcode[10:5] == 6'b100101)begin
                unconditionalBranch = 1'b1; branchTaken = 1'b1;
                Link = 1'b1; RegWrite = 1'b1;
            end

            //BR Instruction
            else if(opcode[10:0] == 11'b11010110000)begin
                Reg2Loc = 1'b0; branchRegister = 1'b1;
            end

            //CBZ Instruction
            else if(opcode[10:3] == 8'b10110100)begin
                unconditionalBranch = 1'b0; branchTaken = zero;
                Reg2Loc = 1'b0;
            end

            //LDUR Instruction
            else if(opcode[10:0] == 11'b11111000010)begin
                ImmSelect = 1'b0; ALUSrc = 1'b1; ALUOp = 3'b010;
                MemRead = 1'b1; MemToReg = 1'b1; RegWrite = 1'b1;
            end

            //STUR Instruction
            else if(opcode[10:0] == 11'b11111000000)begin
                ImmSelect = 1'b0; ALUSrc = 1'b1; ALUOp = 3'b010; 
                MemWrite = 1'b1; Reg2Loc = 1'b0;
            end

            //SUBS Instruction
            else if(opcode[10:0] == 11'b11101011000)begin
                RegWrite = 1'b1; Reg2Loc = 1'b1; ALUOp = 3'b011;
                SetFlags = 1'b1;
            end
    end
endmodule

module control_testbench();
    logic [10:0] opcode;
    logic [4:0] cond;
    logic zero, flagN, flagV;
    logic Reg2Loc, ALUSrc, ImmSelect, RegWrite, MemToReg, Link, MemWrite, MemRead,
                    unconditionalBranch, branchTaken, branchRegister, SetFlags;
    logic [2:0] ALUOp;

    control dut(.opcode, .cond, .zero, .flagN, .flagV, .Reg2Loc, .ALUSrc, .ImmSelect, .ALUOp,
                .RegWrite, .MemToReg, .Link, .MemWrite, .MemRead, .unconditionalBranch, 
                .branchTaken, .branchRegister, .SetFlags);

    initial begin
        // Check all opcodes and make sure the values update accordingly, 
        // and correspond to our processor block diagram.
        cond = 5'b01011; zero = 1'b0; flagN = 1'b0; flagV = 1'b0;

        opcode = 11'b10101011000; #10 //ADDI
        opcode = 11'b10101011000; #10 //ADDS
        opcode = 11'b11111000010; #10 //LDUR
        opcode = 11'b11111000000; #10 //STUR
        opcode = 11'b11101011000; #10 //SUBS
        opcode = 11'b00010100000; #10 //B
        opcode = 11'b00010110101; #10 //B again, with different bottom opcode bits.
        opcode = 11'b01010100000; #10 //B.cond (B.LT), Branch not taken
        flagN = 1'b1;             #10 //B. cond (B.LT), Branch taken
        opcode = 11'b10010100000; #10 //BL
        opcode = 11'b11010110000; #10 //BR
        opcode = 11'b10110100000; #10 //CBZ, not taken
        zero = 1'b1;              #10 //CBZ, taken        
    end

endmodule 