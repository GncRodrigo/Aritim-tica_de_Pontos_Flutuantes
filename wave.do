onerror {resume}
quietly WaveActivateNextPane {} 0
    
    
add wave -label reset /tb/PontosFlutuantes/reset
add wave -label clock_100kHz /tb/PontosFlutuantes/clock_100kHz
add wave -label op_A_in /tb/PontosFlutuantes/op_A_in
add wave -label op_B_in /tb/PontosFlutuantes/op_B_in
add wave -label data_out /tb/PontosFlutuantes/data_out
add wave -label status_out /tb/PontosFlutuantes/status_out
add wave -label EA /tb/PontosFlutuantes/EA


TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {6347200 ps} 0}
quietly wave cursor active 1

configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0