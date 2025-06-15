onerror {resume}
quietly WaveActivateNextPane {} 0

add wave -noupdate -label reset /tb/dut/reset
add wave -noupdate -color Red -label {clock 100khz} /tb/dut/clock_100kHz
add wave -noupdate -label op_A_in -radix hex /tb/dut/op_A_in
add wave -noupdate -label op_B_in -radix hex /tb/dut/op_B_in
add wave -noupdate -label data_out -radix hex /tb/dut/data_out
add wave -noupdate -label status_out -radix binary /tb/dut/status_out
add wave -noupdate -label EA -radix symbolic /tb/dut/EA

TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {6347200 ps} 0}
quietly wave cursor active 1

configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
