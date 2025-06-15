catch {vdel -all -lib work}
vlib work
vmap work work

set TOP_ENTITY {work.tb}

vlog -work work Pontos.sv
vlog -work work tb_Pontos.sv

vsim -voptargs=+acc work.PontosFlutuantes

quietly set StdArithNoWarnings 1
quietly set StdVitalGlitchNoWarnings 1


run 20ms