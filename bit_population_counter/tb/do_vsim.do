vlib work

vlog -sv bit_population_counter.sv
vlog -sv bit_population_counter_tb.sv

vsim bit_population_counter_tb
add log -r /*
add wave -r *
run -all