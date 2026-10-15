`timescale 1ns/10ps
module mux2_1 (out, i0, i1, sel);
    output logic out;
    input logic i0, i1, sel;
    parameter delay = 0.05;
    logic sel_n, t0, t1;

    not #delay n0 (sel_n, sel);
    and #delay a0 (t0, i0, sel_n);
    and #delay a1 (t1, i1, sel);
    or  #delay o0 (out, t0, t1);
endmodule

module mux2_1_testbench();
	logic i0, i1, sel;
	logic out;

	mux2_1 dut (.out, .i0, .i1, .sel);

	integer i;
	initial begin
		for (i = 0; i < 8; i++) begin
			{sel, i0, i1} = i; #10;
		end
		$stop;
	end
endmodule