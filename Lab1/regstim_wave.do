add wave -noupdate /regstim/clk
add wave -noupdate /regstim/RegWrite
add wave -noupdate -radix unsigned /regstim/WriteRegister
add wave -noupdate -radix hex /regstim/WriteData
add wave -noupdate -radix unsigned /regstim/ReadRegister1
add wave -noupdate -radix hex /regstim/ReadData1
add wave -noupdate -radix unsigned /regstim/ReadRegister2
add wave -noupdate -radix hex /regstim/ReadData2
add wave -noupdate -radix hex -expand /regstim/dut/regs