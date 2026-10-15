# Create work library
vlib work

# Compile Verilog
#     All Verilog files that are part of this design should have
#     their own "vlog" line below.
vlog "./d_ff.sv"
vlog "./mux2_1.sv"
vlog "./mux32_1.sv"
vlog "./decoder5_32.sv"
vlog "./regfile.sv"
vlog "./regstim.sv"

# Call vsim to invoke simulator
#     Make sure the last item on the line is the name of the
<<<<<<< HEAD
#     testbench module you want to execute. poopie scoop
=======
#     testbench module you want to execute. poopie scoopie
>>>>>>> 54b2e9aae4b0a304cb33329f0b67b378be8c60e2
vsim -voptargs="+acc" -t 1ps -lib work regstim
# Source the wave do file
#     This should be the file that sets up the signal window for
#     the module you are testing.
do regstim_wave.do

# Set the window types
view wave
view structure
view signals

# Run the simulation
run -all

# End
