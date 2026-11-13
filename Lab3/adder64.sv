`timescale 1ns/10ps
// adder that livs outside of alu to be as simple as possible, alu ful_adder has 5 gates
// an extra mux, and xor for the negative. this is just a simple adder
module adder64 (sum, a, b);
    output logic [63:0] sum;
    input logic [63:0] a, b;

    logic [64:0] carries;
    assign carries[0] = 1'b0;
    genvar i;
    
    generate
        for (i = 0; i < 64; i++) begin : eachbit
            full_adder adder (.sum(sum[i]), .cout(carries[i + 1]), .a(a[i]), .b(b[i]), .carryIn(carries[i]));
        end
    endgenerate
endmodule