create_clock -period 10 [get_ports clk] -name sys_clk

# clock fan out delay가 너무 심함
set_property CLOCK_BUFFER_TYPE BUFG [get_nets clk]
set_property MAX_FANOUT 500 [get_nets clk]

set_param place.clock_region_auto_optimize true
