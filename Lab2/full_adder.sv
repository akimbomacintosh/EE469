`timescale 1ns/10ps

// full adder for one bit of addition with carry in and carry out bits
module full_adder (sum, cout, a, b, cin);
    output logic sum, cout;
    input logic a, b, cin;
    parameter delay = 0.05;
    logic ab, acin, bcin; 

    // full adder logic with carry in and carry out bits
    xor #delay x0 (sum, a, b, cin);
    and #delay a0 (ab, a, b);
    and #delay a1 (acin, a, cin);
    and #delay a2 (bcin, b, cin);
    or #delay o0 (cout, ab, acin, bcin); // carry out is true if a and b are true or a and cin are true or b and cin are true
endmodule

module full_adder_testbench();
    logic a, b, cin;
    logic sum, cout;

    full_adder dut (.sum(sum), .cout(cout), .a(a), .b(b), .cin(cin));

    integer i;
    initial begin
        for (i = 0; i < 8; i++) begin
            {a, b, cin} = i; // loop through all 8 combinations of a, b, and cin
            #10;
        end
        $stop;
    end
endmodule