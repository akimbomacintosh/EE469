# Create work library
vlib work

# Compile Verilog
#     All Verilog files that are part of this design should have
#     their own "vlog" line below.
vlog "./full_adder.sv"
vlog "./d_ff.sv"
vlog "./mux2_1.sv"
vlog "./mux8_1.sv"
vlog "./alubit.sv"
vlog "./detectzero.sv"
vlog "./alu.sv"
vlog "./iFetch.sv"
vlog "./mux2_1_special.sv"
vlog "./instructmem.sv"


# Call vsim to invoke simulator
#     Make sure the last item on the line is the name of the
#     testbench module you want to execute.
vsim -voptargs="+acc" -t 1ps -lib work iFetch_testbench
# Source the wave do file
#     This should be the file that sets up the signal window for
#     the module you are testing.
do iFetch_testbench_wave.do

# Set the window types
view wave
view structure
view signals

# Run the simulation
run -all

# End