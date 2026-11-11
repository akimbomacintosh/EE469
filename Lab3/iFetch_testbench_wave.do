onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /iFetch_testbench/programCounter
add wave -noupdate /iFetch_testbench/pcPlus4
add wave -noupdate /iFetch_testbench/signExtend19
add wave -noupdate /iFetch_testbench/signExtend26
add wave -noupdate /iFetch_testbench/datab
add wave -noupdate /iFetch_testbench/instruction
add wave -noupdate /iFetch_testbench/unconditionalBranch
add wave -noupdate /iFetch_testbench/branchTaken
add wave -noupdate /iFetch_testbench/branchRegister
add wave -noupdate /iFetch_testbench/reset
add wave -noupdate /iFetch_testbench/clk
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
WaveRestoreZoom {0 ps} {792 ps}
