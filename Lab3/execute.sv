`timescale 1ns/10ps

module execute (aluResult, aluZero, storedNegative, storedOverflow, dataA, dataB, signExtend9, zeroExtend12, aluSource, ImmSelect, aluOp, setFlags, reset, clk);
    output logic [63:0] aluResult;
    output logic aluZero, storedNegative, storedOverflow;
    // aluresult is the output of the alu
    // aluzero is the zero flag directly from the alu in the current cycle
    // storedNegative and storedoerlow are the saved flags from the operations, control uses them for b.lt

    input logic [63:0] dataA, dataB, signExtend9, zeroExtend12;
    input logic aluSource, ImmSelect;
    input logic [2:0] aluOp;
    input logic setFlags, reset, clk;
    // data a and data b are the register values from decode
    // signextend9 is the LDUR STUR address offset and zeroextend12 is the addi immediate
    // alusrc picks the second alu input
    //         - 00: dataB
    //         - 01: signExtend9
    //         - 10: zeroExtend12
    // THE ABOVE IS WRONG AND WAS CHANGED, NOW TWO ONE BIT SELECTS ALUSOURCE AND IMMSELECT
    // aluop is the control for the ALU
    //        - 000: passes b
    //        - 010: adds
    //        - 011: subtracts
    // setflags lets the flag register save new flags on the clock edge

    logic negative, zero, overflow, carryOut; // flags from the alu this cycle, built in lab 2
    logic [63:0] immediate, aluB;
    logic [3:0] flags;
    //aluSourceOut is datab or signextend9 based on alusrc
    // alub is the final additional input into the alu, picked by alusrc
    // storedFlags are what the flag register hold for future clock cycles if needed

    // the alus input A is always dataA (Rn), but for input b there could be 3 different possible choices, which are se9, ze12, or dataB.
    // there are two 2:1 muxes to account for the 3 possible choices (see drawing)
    // picks between the two immediates, ze12 or se9 
    mux2_1_special #(.WIDTH(64)) immediateMux (.out(immediate), .i0(signExtend9), .i1(zeroExtend12), .select(ImmSelect));
    // picks between the sign extended immediates or the data from port b on the register
    mux2_1_special #(.WIDTH(64)) aluSourceMux (.out(aluB), .i0(dataB), .i1(immediate), .select(aluSource));

    // alu from lab 2
    alu gigaAlu (.A(dataA), .B(aluB), .cntrl(aluOp), .result(aluResult), .negative(negative), .zero(zero), .overflow(overflow), .carry_out(carryOut));

    // zero flag for CBZ because it is used right away, comes from alu 
    assign aluZero = zero;

    // the flag resgister that only saves the alu flags when setflags is true so they can be used on a branch later on
    register4 flagRegister (.bitsOut(flags), .bitsIn({negative, aluZero, carryOut, overflow}), .enable(setFlags), .clk(clk), .reset(reset));

    // single bits to be output for negatives and overflows 
    assign storedNegative = flags[3];
    assign storedOverflow = flags[0];
endmodule

module execute_testbench();
    logic [63:0] aluResult, dataA, dataB, signExtend9, zeroExtend12;
    logic aluZero, storedNegative, storedOverflow;
    logic aluSource, ImmSelect;
    logic [2:0] aluOp;
    logic setFlags, reset, clk;
    parameter ClockDelay = 5000;

    initial begin
        clk <= 0;
        forever #(ClockDelay/2) clk <= ~clk;
    end

    execute dut (.aluResult, .aluZero, .storedNegative, .storedOverflow, .dataA, .dataB,
                 .signExtend9, .zeroExtend12, .aluSource, .ImmSelect, .aluOp, .setFlags, .reset, .clk);
    
    initial begin 
        // reset flags register, initialize the hardware with se9 = -8, ze12 = 3
        dataA <= 64'd5; // dataA = 5
        dataB <= 64 'd7; // dataB = 7
        signExtend9 <= -64'd8; // se9 = -8
        zeroExtend12 <= 64'd3; // ze12 = 3
        aluSource <= 0; 
        aluOp <= 3'b000;
        setFlags <= 0;
        reset <= 1;
        @(posedge clk);
        reset <= 0;

        // test addi but picking zero extend, dataA + ze12 = 5 + 3 = 8
        aluSource <= 1;
        aluOp <= 3'b010;
        ImmSelect <= 1;
        @(posedge clk);

        // test ldur or stur, alusource picks se9, so 5 + -8 = -3
        aluSource <= 1;
        ImmSelect <= 0;
        @(posedge clk);

        //test alu source qualling zero, so it picks dataB. 5 - 7 = -2
        aluSource <= 2'b00;
        aluOp <= 3'b011;
        setFlags <= 1;
        @(posedge clk);

        // test cbz, no data and alu passes b so aluzero should be 1 but stored negative is still 1
        dataB <= 64'd0;
        aluOp <= 3'b000;
        setFlags <= 0;
        @(posedge clk);

        $stop;
    end
endmodule

