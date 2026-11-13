`timescale 1ns/10ps

// just running the benchmarks bro

// when you are uncommenting a test here in cpu stim to run, ensure that you
// also have the same benchmark UNCOMMENTED in instructmem.sv!!!
// never comment out anything from line 9 to 29 as that keeps the cpu running

module cpustim();
    parameter delay = 8000;
    parameter numCycles = 5000;
    logic reset, clk;
    parameter TESTNUM = 4; // enssure you change the testbench in instructmem.sv
    
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
        #100;

        // leave everything above this line uncommented //

        // used the dut.decodeStage.registers.regs to access data in lower levels of our code
        // since cpu only has a clock and a reset port, we dont have access to the memory and
        // register files at the cpu level, so we need to access it. we could technically wire the
        // data through all of our files, but that would require a lot of unnessary wiring.
        // we chose to use this syntax to enhance the cpu testbench readability, run tests all 
        // in one file (we would have to do asserts in our other files if not here), and be able
        // to test all blocks at once. 

        if (TESTNUM == 1) begin
            // TEST 1 ADDI-B
            $display("Running test 1: ADDI-B");
            assert(dut.decodeStage.registers.regs[0] == 64'd0);
            assert(dut.decodeStage.registers.regs[1] == 64'd1);
            assert(dut.decodeStage.registers.regs[2] == 64'd2);
            assert(dut.decodeStage.registers.regs[3] == 64'd3);
            assert(dut.decodeStage.registers.regs[4] == 64'd4);
        end
        if (TESTNUM == 2) begin
            // TEST 2 ADDSUBS
            $display("Running test 2: ADDSUBS");
            assert(dut.decodeStage.registers.regs[0] == 64'd1);
            assert(dut.decodeStage.registers.regs[1] == -64'd1);
            assert(dut.decodeStage.registers.regs[2] == 64'd2);
            assert(dut.decodeStage.registers.regs[3] == -64'd3);
            assert(dut.decodeStage.registers.regs[4] == -64'd2);
            assert(dut.decodeStage.registers.regs[5] == -64'd5);
            assert(dut.decodeStage.registers.regs[6] == 64'd0);
            assert(dut.decodeStage.registers.regs[7] == -64'd6);
            assert(dut.execStage.flags == 4'b1010);
        end
        if (TESTNUM == 3) begin
            // TEST 3 CBZB
            $display("Running test 3: ADDSUBS");
            assert(dut.decodeStage.registers.regs[0] == 64'd1);
            assert(dut.decodeStage.registers.regs[1] == 64'd0);
            assert(dut.decodeStage.registers.regs[2] == 64'd0);
            assert(dut.decodeStage.registers.regs[3] == 64'd1);
            assert(dut.decodeStage.registers.regs[4] == 64'd31);
            assert(dut.decodeStage.registers.regs[5] == 64'd0);
        end
        if (TESTNUM == 4) begin
            // TEST 4 LDUR STUR
            $display("Running test 4: LDURSTUR");
            assert(dut.decodeStage.registers.regs[0] == 64'd1);
            assert(dut.decodeStage.registers.regs[1] == 64'd2);
            assert(dut.decodeStage.registers.regs[2] == 64'd3);
            assert(dut.decodeStage.registers.regs[3] == 64'd8);
            assert(dut.decodeStage.registers.regs[4] == 64'd11);
            assert(dut.decodeStage.registers.regs[5] == 64'd1);
            assert(dut.decodeStage.registers.regs[6] == 64'd2);
            assert(dut.decodeStage.registers.regs[7] == 64'd3);
            assert({dut.memoryStage.dataMemory.mem[7],
                    dut.memoryStage.dataMemory.mem[6],
                    dut.memoryStage.dataMemory.mem[5], 
                    dut.memoryStage.dataMemory.mem[4],
                    dut.memoryStage.dataMemory.mem[3], 
                    dut.memoryStage.dataMemory.mem[2],
                    dut.memoryStage.dataMemory.mem[1], 
                    dut.memoryStage.dataMemory.mem[0]} == 64'd1);
            assert({dut.memoryStage.dataMemory.mem[15],
                    dut.memoryStage.dataMemory.mem[14],
                    dut.memoryStage.dataMemory.mem[13], 
                    dut.memoryStage.dataMemory.mem[12],
                    dut.memoryStage.dataMemory.mem[11], 
                    dut.memoryStage.dataMemory.mem[10],
                    dut.memoryStage.dataMemory.mem[9], 
                    dut.memoryStage.dataMemory.mem[8]} == 64'd2);
            assert({dut.memoryStage.dataMemory.mem[23],
                    dut.memoryStage.dataMemory.mem[22],
                    dut.memoryStage.dataMemory.mem[21], 
                    dut.memoryStage.dataMemory.mem[20],
                    dut.memoryStage.dataMemory.mem[19], 
                    dut.memoryStage.dataMemory.mem[18],
                    dut.memoryStage.dataMemory.mem[17], 
                    dut.memoryStage.dataMemory.mem[16]} == 64'd3);
        end
        if (TESTNUM == 5) begin
            // TEST 5 BLT yum
            $display("Running test 5: BLT");
            assert(dut.decodeStage.registers.regs[0] == 64'd1);
            assert(dut.decodeStage.registers.regs[1] == 64'd1);
        end
        if (TESTNUM == 6) begin
            // Test 6 BL, BR
            $display("Running Test 6: BL, BR");
            assert(dut.decodeStage.registers.regs[0] == 64'd1);
            assert(dut.decodeStage.registers.regs[1] == 64'd0);
            assert(dut.decodeStage.registers.regs[2] == 64'd0); //anything else indicates error
            assert(dut.decodeStage.registers.regs[3] == 64'd1); //signifies program end was reached
            assert(dut.decodeStage.registers.regs[4] == 64'd52);
            assert(dut.decodeStage.registers.regs[5] == 64'd64);
            assert(dut.decodeStage.registers.regs[30] == 64'd68);
        end
        if(TESTNUM == 10) begin
            //Test 10: Forwarding
            $display("Running Test 10: Forwarding");
            assert(dut.decodeStage.registers.regs[0] == 64'd0);
            assert(dut.decodeStage.registers.regs[1] == 64'd8);
            assert(dut.decodeStage.registers.regs[2] == 64'd0); // 0 for single-cycle cpu, 4 for pipelined
            assert(dut.decodeStage.registers.regs[3] == 64'd5);
            assert(dut.decodeStage.registers.regs[4] == 64'd7);
            assert(dut.decodeStage.registers.regs[5] == 64'd2);
            assert(dut.decodeStage.registers.regs[6] == -64'd2);
            assert(dut.decodeStage.registers.regs[7] == -64'd2);
            assert(dut.decodeStage.registers.regs[8] == 64'd0);
            assert(dut.decodeStage.registers.regs[9] == 64'd1);
            assert(dut.decodeStage.registers.regs[10] == -64'd4);
            assert(dut.decodeStage.registers.regs[14] == 64'd5);
            assert(dut.decodeStage.registers.regs[15] == 64'd8);
            assert(dut.decodeStage.registers.regs[16] == 64'd9);
            assert(dut.decodeStage.registers.regs[17] == 64'd1);
            assert(dut.decodeStage.registers.regs[18] == 64'd99);
            assert({dut.memoryStage.dataMemory.mem[7],
                    dut.memoryStage.dataMemory.mem[6],
                    dut.memoryStage.dataMemory.mem[5], 
                    dut.memoryStage.dataMemory.mem[4],
                    dut.memoryStage.dataMemory.mem[3], 
                    dut.memoryStage.dataMemory.mem[2],
                    dut.memoryStage.dataMemory.mem[1], 
                    dut.memoryStage.dataMemory.mem[0]} == 64'd8);
            assert({dut.memoryStage.dataMemory.mem[15],
                    dut.memoryStage.dataMemory.mem[14],
                    dut.memoryStage.dataMemory.mem[13], 
                    dut.memoryStage.dataMemory.mem[12],
                    dut.memoryStage.dataMemory.mem[11], 
                    dut.memoryStage.dataMemory.mem[10],
                    dut.memoryStage.dataMemory.mem[9], 
                    dut.memoryStage.dataMemory.mem[8]} == 64'd5);
        end
        if(TESTNUM == 11) begin
            // Test 11: Sort
            $display("Running Test 11: Sort");
            assert(dut.decodeStage.registers.regs[11] == 64'd1);
            assert(dut.decodeStage.registers.regs[12] == 64'd2);
            assert(dut.decodeStage.registers.regs[13] == 64'd3);
            assert(dut.decodeStage.registers.regs[14] == 64'd4);
            assert(dut.decodeStage.registers.regs[15] == 64'd5);
            assert(dut.decodeStage.registers.regs[16] == 64'd6);
            assert(dut.decodeStage.registers.regs[17] == 64'd7);
            assert(dut.decodeStage.registers.regs[18] == 64'd8);
            assert(dut.decodeStage.registers.regs[19] == 64'd9);
            assert(dut.decodeStage.registers.regs[20] == 64'd10);
        end 
        if(TESTNUM == 12) begin
            // Test 12: Fibonacci
            $display("Running Test 12: Fibonacci");
            assert(dut.decodeStage.registers.regs[0] == 64'd6); // N
            assert(dut.decodeStage.registers.regs[1] == 64'd8); //result of fibonacci with N = 6
            assert(dut.decodeStage.registers.regs[28] == 64'd8);
            assert(dut.decodeStage.registers.regs[30] == 64'd196);
        end
        $stop;
    end
endmodule