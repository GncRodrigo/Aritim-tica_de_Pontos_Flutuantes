onerror {resume}
quietly WaveActivateNextPane {} 0
    
    
add wave -label reset       /tb/dut/reset
add wave -label op_A_in     /tb/dut/op_A_in
add wave -label op_B_in     /tb/dut/op_B_in
add wave -label data_out    /tb/dut/data_out
add wave -label status_out  /tb/dut/status_out
add wave -label EA          /tb/dut/EA



TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {6347200 ps} 0}
quietly wave cursor active 1

configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0