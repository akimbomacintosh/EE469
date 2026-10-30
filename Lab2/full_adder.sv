`timescale 1ns/10ps

// This module represents a full adder for one bit of addition with carry-in
//    and carry out bits. 
// Parameters:
//    - a: represents the ith (current) bit of register A to operate on.
//    - b: represents the ith (current) bit of register B to operate on.
//    - carryIn: represents if the operation on i - 1 had a carry out. 
//      - 1 if there was a cout on the ith - 1 operation, 0 otherwise. 
// Outputs:
//    - sum: The sum of the ith (current) a and b bits. 
//    - cout: 1 if there is a carry out when you add a and b, 0 otherwise.
// Scenarios: 
//    - If a and b = 1, and cin = 0, then sum = 0 and cout = 1 (because there was "overflow")
//    - If a and b = 0, and cin = 1, then sum = 1 and cout = 0 (because no "overflow")
module full_adder (sum, cout, a, b, carryIn);
    output logic sum, cout;
    input logic a, b, carryIn;
    parameter delay = 0.05;
    logic aAndb, acarryIn, bcarryIn; 

    // full adder logic with carry in and carry out bits
    // Logically: 
    // sum (at i) = (a xor b xor carryIn)
    // cout (at i) = carryIn (i + 1) = (a and b) or (carryIn and (a xor b))

    // Calculation of sum (the sum of the current a and b bits)
    xor #delay xor1 (sum, a, b, carryIn);

    //Calculation of cout (whether there is overflow, given the above equation)
    and #delay a1 (aAndb, a, b);
    and #delay a2 (acarryIn, a, carryIn);
    and #delay a3 (bcarryIn, b, carryIn);
    or #delay o1 (cout, aAndb, acarryIn, bcarryIn); // carry out is true if a and b are true or a and carryIn are true or b and carryIn are true
endmodule

module full_adder_testbench();
    logic a, b, carryIn;
    logic sum, carryOut;

    full_adder dut (.sum(sum), .cout(carryOut), .a(a), .b(b), .carryIn(carryIn));

    integer i;
    initial begin
        for (i = 0; i < 8; i++) begin
            {a, b, carryIn} = i; // loop through all 8 combinations of a, b, and carryIn
            #10;
        end
        $stop;
    end
endmodule