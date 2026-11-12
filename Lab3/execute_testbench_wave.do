onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix decimal /execute_testbench/aluResult
add wave -noupdate -radix decimal /execute_testbench/dataA
add wave -noupdate -radix decimal /execute_testbench/dataB
add wave -noupdate -radix decimal /execute_testbench/signExtend9
add wave -noupdate -radix decimal /execute_testbench/zeroExtend12
add wave -noupdate -radix decimal /execute_testbench/aluZero
add wave -noupdate -radix decimal /execute_testbench/storedNegative
add wave -noupdate -radix decimal /execute_testbench/storedOverflow
add wave -noupdate -radix decimal /execute_testbench/aluSource
add wave -noupdate -radix decimal /execute_testbench/aluOp
add wave -noupdate -radix decimal /execute_testbench/setFlags
add wave -noupdate -radix decimal /execute_testbench/reset
add wave -noupdate -radix symbolic /execute_testbench/clk
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {18123137 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {54788096 ps}
