onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -label reset /tb_Pontos/reset
add wave -noupdate -color Red -label {clock 100khz} /tb_Pontos/clock_100KHZ
add wave -noupdate -label op_A_in -radix hex /tb_Pontos/op_A_in
add wave -noupdate -label op_B_in -radix hex /tb_Pontos/op_B_in
add wave -noupdate -label data_out -radix hex /tb_Pontos/data_out
add wave -noupdate -label status_out -radix binary /tb_Pontos/status_out
add wave -noupdate -label EA -radix symbolic /tb_Pontos/dut/EA


TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {6347200 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0