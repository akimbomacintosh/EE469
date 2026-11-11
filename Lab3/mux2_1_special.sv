`timescale 1ns/10ps
// a special 2:1 mux that allows us to parameterize our width so we can use it for 64 bit registers and 4 bit registers
module mux2_1_special #(parameter WIDTH = 64) (out, i0, i1, select);
    output logic [(WIDTH - 1):0] out;
    input logic [(WIDTH - 1):0] i0, i1;
    input logic select;

    // one 2:1 mux for every bit with every copy using the same select signal. 
    // the mux needs two 64 bit signals so the nth mux picks between the nth bit of each 64 bit input
    genvar i;
    generate
        for (i = 0; i < WIDTH; i++) begin : onebit
            mux2_1 mux (.out(out[i]), .i0(i0[i]), .i1(i1[i]), .sel(select));
        end
    endgenerate
endmodule

module mux2_1_special_testbench();
	logic [3:0] i0, i1;
	logic sel;
	logic [3:0] out;

	mux2_1_special #(.WIDTH(4)) dut (.out, .i0, .i1, .sel);

	initial begin
		i0 = 4'b1010; i1 = 4'b0101; sel = 0; #10; sel = 1; #10;
		i0 = 4'b1111; i1 = 4'b0000; sel = 0; #10; sel = 1; #10;
		$stop;
	end
endmodule

