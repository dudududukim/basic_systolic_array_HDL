# Define directories
set outputDir ../../output/Created_Data/systolic_project_32x32
set routingOutputDir $outputDir/routing

# Create directories
file mkdir $outputDir
file mkdir $routingOutputDir

# Open project
open_project $outputDir/proj_1.xpr

# Open synthesized design
open_run synth_1
puts "Synthesized design loaded."

# Placement
place_design -directive Default
puts "Placement completed."

# Routing
route_design -directive Default
puts "Routing completed."

# Timing summary report  -> can't make xdc file(hard)
set clk_pin [get_ports clk]
create_clock -period 10.0 $clk_pin
report_timing_summary -file $routingOutputDir/timing_summary.txt
puts "Timing summary report generated."

# Generate reports
report_utilization -file $routingOutputDir/utilization_after_routing.txt
puts "Utilization report done."

report_timing -delay_type min_max -from $clk_pin -file $routingOutputDir/detailed_timing_report.txt
puts "Timing report done."

report_route_status -file $routingOutputDir/route_status.txt
puts "Route status report done."

report_drc -file $routingOutputDir/drc_report.txt
puts "DRC report done."

write_checkpoint -force $routingOutputDir/final_routed_design.dcp
puts "Checkpoint saved."

report_power -file $routingOutputDir/power_report.txt
puts "Power report done."

report_io -file $routingOutputDir/io_report.txt
puts "IO report done."

# Optional bitstream generation
# write_bitstream -force $routingOutputDir/final_bitstream.bit
# puts "Bitstream generation done."

puts "Process completed. Outputs in: $routingOutputDir"
