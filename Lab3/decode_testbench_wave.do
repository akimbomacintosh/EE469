onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /decode_testbench/dataA
add wave -noupdate /decode_testbench/dataB
add wave -noupdate /decode_testbench/signExtend19
add wave -noupdate /decode_testbench/signExtend26
add wave -noupdate /decode_testbench/signExtend9
add wave -noupdate /decode_testbench/zeroExtend12
add wave -noupdate /decode_testbench/writeData
add wave -noupdate /decode_testbench/instruction
add wave -noupdate /decode_testbench/reg2Loc
add wave -noupdate /decode_testbench/link
add wave -noupdate /decode_testbench/regWrite
add wave -noupdate /decode_testbench/clk
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
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
WaveRestoreZoom {0 ps} {837 ps}
