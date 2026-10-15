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

	//--------------------------------- our tests

	task writeReg(input logic [4:0] r, input logic [63:0] data);
		WriteRegister <= r;
		WriteData <= data;
		RegWrite <= 1;
		@(posedge clk);
		RegWrite <= 0;
		@(posedge clk);
	endtask

	task checkRegs(input logic [4:0] r1, input logic [63:0] exp1,
	               input logic [4:0] r2, input logic [63:0] exp2);
		ReadRegister1 <= r1;
		ReadRegister2 <= r2;
		@(posedge clk);
		if (ReadData1 !== exp1)
			$display("%t ERROR: port 1 X%0d = %h, expected %h", $time, r1, ReadData1, exp1);
		if (ReadData2 !== exp2)
			$display("%t ERROR: port 2 X%0d = %h, expected %h", $time, r2, ReadData2, exp2);
	endtask

	// --------------------------------- end of our tests

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

		$display("%t Test 1: all 64 bits", $time);
		writeReg(5, 64'hFFFFFFFFFFFFFFFF);
		checkRegs(5, 64'hFFFFFFFFFFFFFFFF, 5, 64'hFFFFFFFFFFFFFFFF);
		writeReg(5, 64'hAAAAAAAAAAAAAAAA);
		checkRegs(5, 64'hAAAAAAAAAAAAAAAA, 5, 64'hAAAAAAAAAAAAAAAA);
		writeReg(5, 64'h5555555555555555);
		checkRegs(5, 64'h5555555555555555, 5, 64'h5555555555555555);

		$display("%t Test 2: neighbors unchanged", $time);
		checkRegs(4, 4*64'h0000010204080001, 6, 6*64'h0000010204080001);

		$display("%t Test 3: X31 always zero", $time);
		writeReg(31, 64'hFFFFFFFFFFFFFFFF);
		checkRegs(31, 64'b0, 31, 64'b0);

		$display("%t Tests finished. No ERROR lines means everything passed.", $time);
	// --------------------------------- end of our tests
		$stop;
	end
endmodule
