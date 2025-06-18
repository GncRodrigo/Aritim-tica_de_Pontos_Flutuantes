onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb/clock_100kHz
add wave -noupdate /tb/reset
add wave -noupdate /tb/op_A_in
add wave -noupdate /tb/op_B_in
add wave -noupdate /tb/data_out
add wave -noupdate /tb/status_out
add wave -noupdate /tb/qual_lugar
add wave -noupdate -label mantissa_B /tb/dut/mantissa_B
add wave -noupdate -label mantissa_A /tb/dut/mantissa_A
add wave -noupdate -label mantissa_out /tb/dut/mantissa_out
add wave -noupdate -label expoente_A /tb/dut/mantissa_out expoente_A
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ns} 0}
quietly wave cursor active 0
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
WaveRestoreZoom {194999 ns} {195001 ns}