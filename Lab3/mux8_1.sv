`timescale 1ns/10ps
// Ports:
//    out - the selected data bit
//    i   - 8 data inputs (one bit from each register)
//    sel - 2-bit select (register number 0-7) that picks which input drives out
// Given a register number on sel, the muxes pass that register's data bit
module mux8_1(out, i, sel);
    output logic out;
    input logic [7:0] i;
    input logic [2:0] sel;

    logic [3:0] a; // first level 
    logic [1:0] b; // second level

    genvar j;
    generate
        //Level 1: sel[0] chooses whether input is even or odd from 8 to 4
        for (j = 0; j < 4; j = j + 1) begin : four_mux
            mux2_1 m0 (.out(a[j]), .i0(i[2*j]), .i1(i[2*j+1]), .sel(sel[0]));
        end

        //Level 2: sel[1] picks one of each pair of level-1 outputs: 4 to 2
        for (j = 0; j < 2; j = j + 1) begin : two_mux
            mux2_1 m1 (.out(b[j]), .i0(a[2*j]), .i1(a[2*j+1]), .sel(sel[1]));
        end
    endgenerate

    // Assigns the final bit
    // If MSB is 0, then code knows to select the corresponding 0-3 value
    // If MSB is 1, then code knows to select the corresponding 4-7 value
    mux2_1 finalmux (.out(out), .i0(b[0]), .i1(b[1]), .sel(sel[2]));
endmodule

module mux8_1_testbench();
    logic [7:0] i;
    logic [2:0] sel;
    logic out;

    mux8_1 dut (.out(out), .i(i), .sel(sel));

    integer j;
    initial begin
        i = 8'b1010_0110;
        for (j = 0; j < 8; j++) begin
            sel = j;
            #10;
            end
        i = 8'b0101_1001;
        for (j = 0; j < 8; j++) begin
            sel = j;
            #10;
        end
        $stop;
    end
endmodule