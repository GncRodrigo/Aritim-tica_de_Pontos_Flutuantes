if {[file isdirectory work]} {vdel -all -lib work}
vlib work
vmap work work

vlog -work work PontosFlutuantes.sv
vlog -work work tb_Pontos.sv

vsim -voptargs=+acc work.tb

quietly set StdArithNoWarnings 1
quietly set StdVitalGlitchNoWarnings 1

do wave.do
run 25ms