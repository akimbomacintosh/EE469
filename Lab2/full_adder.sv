`timescale 1ns/10ps

// full adder for one bit of addition with carry in and carry out bits
module full_adder (sum, cout, a, b, carryIn);
    output logic sum, cout;
    input logic a, b, carryIn;
    parameter delay = 0.05;
    logic a&b, acarryIn, bcarryIn; 

    // full adder logic with carry in and carry out bits
    xor #delay 1xor (sum, a, b, carryIn);
    and #delay 1and (a&b, a, b);
    and #delay 2and (acarryIn, a, carryIn);
    and #delay 3and (bcarryIn, b, carryIn);
    or #delay 1or (cout, a&b, acarryIn, bcarryIn); // carry out is true if a and b are true or a and carryIn are true or b and carryIn are true
endmodule

module full_adder_testbench();
    logic a, b, carryIn;
    logic sum, carryOut;

    full_adder dut (.sum(sum), .cout(carryOut), .a(a), .b(b), .cin(carryIn));

    integer i;
    initial begin
        for (i = 0; i < 8; i++) begin
            {a, b, carryIn} = i; // loop through all 8 combinations of a, b, and carryIn
            #10;
        end
        $stop;
    end
endmodule