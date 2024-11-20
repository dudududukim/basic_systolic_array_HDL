create_clock -period 10 [get_ports clk] -name sys_clk

# set_property DONT_TOUCH true [get_cells bufg_ub]
# set_property DONT_TOUCH true [get_cells bufg_fifo]
# set_property DONT_TOUCH true [get_cells bufg_systolic]
# set_property DONT_TOUCH true [get_cells bufg_ctrl]


# clock fan out delay가 너무 심함
# set_property CLOCK_BUFFER_TYPE BUFG [get_nets clk]

# clock fan out problem resolver
# set_property MAX_FANOUT 500 [get_nets clk]

# set_param place.clock_region_auto_optimize true

# set_property CLOCK_REGION X0Y0 [get_cells SRAM_UB]

# FIFO를 Region X1Y0에 배치
# set_property CLOCK_REGION X1Y0 [get_cells weight_fifo]

# Systolic Array를 Region X2Y0에 배치
# set_property CLOCK_REGION X2Y0 [get_cells systolic_array]

# Controllers를 Region X3Y0에 배치
# set_property CLOCK_REGION X3Y0 [get_cells data_setup_controller]