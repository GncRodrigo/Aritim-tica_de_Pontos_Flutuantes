onerror {resume}
quietly WaveActivateNextPane {} 0

# Sinais de controle
add wave -noupdate -label clock_100kHz /PontosFlutuantes/clock_100kHz
add wave -noupdate -label reset        /PontosFlutuantes/reset

# Entradas e saídas principais
add wave -noupdate -label op_A_in      /PontosFlutuantes/op_A_in
add wave -noupdate -label op_B_in      /PontosFlutuantes/op_B_in
add wave -noupdate -label data_out     /PontosFlutuantes/data_out
add wave -noupdate -label status_out   /PontosFlutuantes/status_out

# Estado atual
add wave -noupdate -label EA           /PontosFlutuantes/EA

# Atualizar e mostrar
WaveUpdate
