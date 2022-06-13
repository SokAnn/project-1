set_time_format -unit ns -decimal_places 3

create_clock -name {clk_7} -period 7.000 -waveform { 0.000 3.500 } [get_ports {clk_i}]

derive_clock_uncertainty