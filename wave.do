onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /PontosFlutuantes/clock_100kHz
add wave -noupdate /PontosFlutuantes/reset
add wave -noupdate /PontosFlutuantes/op_A_in
add wave -noupdate /PontosFlutuantes/op_B_in
add wave -noupdate /PontosFlutuantes/data_out
add wave -noupdate /PontosFlutuantes/status_out
add wave -noupdate /PontosFlutuantes/EA
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
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
WaveRestoreZoom {19999999050 ps} {20000000050 ps}
