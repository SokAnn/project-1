vlib work

vlog -sv serializer.sv
vlog -sv serializer_tb.sv

vsim serializer_tb
add log -r /*
add wave -r *
run -all