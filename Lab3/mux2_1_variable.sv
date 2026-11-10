module mux2_1_variable #(parameter WIDTH = 64) (out, in0, in1, sel);
    output logic [WIDTH-1:0] out;
    input logic [WIDTH-1:0] in0, in1;
    input logic select;

    // one 2:1 mux for every bit with every copy using the same select signal
    genvar i;
    generate
        for (i = 0; i < WIDTH; i++) begin : onebit
            mux2_1 mux (.out(out[i]), .in0(in0[i]), .in1(in1[i]), .sel(select));
        end
    endgenerate
endmodule

module mux2_1_variable_testbench();
	logic [3:0] i0, i1;
	logic sel;
	logic [3:0] out;

	mux2_1_variable #(.WIDTH(4)) dut (.out, .i0, .i1, .sel);

	initial begin
		i0 = 4'b1010; i1 = 4'b0101; sel = 0; #10; sel = 1; #10;
		i0 = 4'b1111; i1 = 4'b0000; sel = 0; #10; sel = 1; #10;
		$stop;
	end
endmodule