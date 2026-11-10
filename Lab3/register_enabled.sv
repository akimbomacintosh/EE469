module register_enabled #(parameter WIDTH = 64) (out, in, enable, reset, clk);
    output logic [WIDTH-1:0] out;
    input logic [WIDTH-1:0] in;
    input logic enable, reset, clk;
    
    logic [WIDTH-1:0] inMux; // wire to hold the input to the D flip-flops
    // one D flip-flop for every bit with every copy using the same enable signal

    mux2_1_variable #(.WIDTH(WIDTH)) enableMux (.out(inMux), .i0(q), .i1(in), .sel(enable));

    genvar i;
    generate
    for (i = 0; i < WIDTH; i++) begin : onebit
        D_FF dff (.q(out[i]), .d(in[i]), .enable(enable), .reset(reset), .clk(clk));
    end
    endgenerate
endmodule

module register_enabled_testbench();
	logic [3:0] d;
	logic enable, reset, clk;
	logic [3:0] q;

	register_enabled #(.WIDTH(4)) dut (.q, .d, .enable, .reset, .clk);

	parameter PERIOD = 100;
	initial begin
		clk <= 0;
		forever #(PERIOD/2) clk <= ~clk;
	end

	initial begin
		reset <= 1; enable <= 0; d <= 4'b0000; @(posedge clk);
		reset <= 0;                            @(posedge clk);
		            enable <= 1; d <= 4'b1010; @(posedge clk); // loads 1010
		            enable <= 0; d <= 4'b0101; @(posedge clk); // holds 1010
		                                       @(posedge clk);
		            enable <= 1;               @(posedge clk); // loads 0101
		                                       @(posedge clk);
		$stop;
	end
endmodule