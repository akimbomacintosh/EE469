`timescale 1ns/10ps

// just running the benchmarks bro
module cpustim();
    parameter delay = 8000;
    parameter numCycles = 5000;
    logic reset, clk;
    
    cpu dut (.reset, .clk);

    initial begin
       clk <= 0;
       forever #(delay/2) clk <= ~clk; 
    end

    integer i;
    initial begin
        reset <= 1;
        @(posedge clk);
        reset <= 0;

        for (i = 0; i < numCycles; i++) begin
                @(posedge clk);
        end

        $stop;
    end


endmodule