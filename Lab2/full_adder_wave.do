onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /full_adder_testbench/a
add wave -noupdate /full_adder_testbench/b
add wave -noupdate /full_adder_testbench/cin
add wave -noupdate /full_adder_testbench/sum
add wave -noupdate /full_adder_testbench/cout
add wave -noupdate /full_adder_testbench/dut/ab
add wave -noupdate /full_adder_testbench/dut/acin
add wave -noupdate /full_adder_testbench/dut/bcin
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {481 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
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
WaveRestoreZoom {0 ps} {1423 ps}
