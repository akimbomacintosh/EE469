// Test bench for Register file
`timescale 1ns/10ps

module regstim(); 		

	parameter ClockDelay = 5000;

	logic	[4:0] 	ReadRegister1, ReadRegister2, WriteRegister;
	logic [63:0]	WriteData;
	logic 			RegWrite, clk;
	logic [63:0]	ReadData1, ReadData2;

	integer i;

	// Your register file MUST be named "regfile".
	// Also you must make sure that the port declarations
	// match up with the module instance in this stimulus file.
	regfile dut (.ReadData1, .ReadData2, .WriteData, 
					 .ReadRegister1, .ReadRegister2, .WriteRegister,
					 .RegWrite, .clk);

	// Force %t's to print in a nice format.
	initial $timeformat(-9, 2, " ns", 10);

	initial begin // Set up the clock
		clk <= 0;
		forever #(ClockDelay/2) clk <= ~clk;
	end

	initial begin
		// Try to write the value 0xA0 into register 31.
		// Register 31 should always be at the value of 0.
		RegWrite <= 5'd0;
		ReadRegister1 <= 5'd0;
		ReadRegister2 <= 5'd0;
		WriteRegister <= 5'd31;
		WriteData <= 64'h00000000000000A0;
		@(posedge clk);
		
		$display("%t Attempting overwrite of register 31, which should always be 0", $time);
		RegWrite <= 1;
		@(posedge clk);

		// Write a value into each  register.
		$display("%t Writing pattern to all registers.", $time);
		for (i=0; i<31; i=i+1) begin
			RegWrite <= 0;
			ReadRegister1 <= i-1;
			ReadRegister2 <= i;
			WriteRegister <= i;
			WriteData <= i*64'h0000010204080001;
			@(posedge clk);
			
			RegWrite <= 1;
			@(posedge clk);
		end

		// Go back and verify that the registers
		// retained the data.
		$display("%t Checking pattern.", $time);
		for (i=0; i<32; i=i+1) begin
			RegWrite <= 0;
			ReadRegister1 <= i-1;
			ReadRegister2 <= i;
			WriteRegister <= i;
			WriteData <= i*64'h0000000000000100+i;
			@(posedge clk);
			if (i < 31 && ReadData2 !== i*64'h0000010204080001)
				$display("%t ERROR: X%0d = %h", $time, i, ReadData2);
			if (i == 31 && ReadData2 !== 64'b0)
				$display("%t ERROR: X31 is not 0", $time);
		end

    // --------------------------------- our tests

        // write 64 bits to a register, trys all 1's and alternating 1's and zeros and see if they match at the end
        $display("%t Test 1: all 64 bits", $time);
        for (i=0; i<3; i=i+1) begin
            if (i == 0) WriteData <= 64'hFFFFFFFFFFFFFFFF;
            if (i == 1) WriteData <= 64'hAAAAAAAAAAAAAAAA;
            if (i == 2) WriteData <= 64'h5555555555555555;
            WriteRegister <= 5;
            RegWrite <= 1;
            @(posedge clk); 
            RegWrite <= 0;
            ReadRegister1 <= 5;
            ReadRegister2 <= 5;
            @(posedge clk);
            @(posedge clk);
            if (ReadData1 !== WriteData || ReadData2 !== WriteData) // both ports should read the same value
                $display("%t ERROR: X5 = %h / %h, expected %h", $time, ReadData1, ReadData2, WriteData);
        end

        // write to register 31 and check that it is still zero
        $display("%t Test 2: X31 always zero", $time);
        WriteRegister <= 31;
        WriteData <= 64'hFFFFFFFFFFFFFFFF;
        RegWrite <= 1;
        @(posedge clk);
        RegWrite <= 0;
        ReadRegister1 <= 31;
        ReadRegister2 <= 31;
        @(posedge clk);
        @(posedge clk);
        if (ReadData1 !== 64'b0 || ReadData2 !== 64'b0) // both ports should read zero
            $display("%t ERROR: X31 = %h / %h, expected 0", $time, ReadData1, ReadData2);

		// RegWrite glitches high between clock edges so nothing should be written
        $display("%t Test 3: RegWrite glitch between clock edges", $time);
        WriteRegister <= 5;
        WriteData <= 64'hFFFFFFFFFFFFFFFF;
		ReadRegister1 <= 5; 
        #(ClockDelay/4) RegWrite <= 1;
        #(ClockDelay/4) RegWrite <= 0;
        @(posedge clk);
        @(posedge clk);
        if (ReadData1 !== 64'h5555555555555555) // X5 should still hold 5555 from test 1
            $display("%t ERROR: X5 changed from a RegWrite glitch: %h", $time, ReadData1);

    // --------------------------------- end of our tests
		$display("%t all tests pass if no error lines above", $time);
		$stop;
	end
endmodule
