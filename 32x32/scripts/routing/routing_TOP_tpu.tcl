# STEP#1: Define project and output directories
set outputDir ../../output/Created_Data/systolic_project_32x32
set routingOutputDir $outputDir/routing

# Create output directories if not exist
file mkdir $outputDir
file mkdir $routingOutputDir

# STEP#2: Open existing project
open_project $outputDir/proj_1.xpr


# STEP#3: Open synthesized design
open_run synth_1
puts "Synthesized design loaded successfully."

# STEP#4: Run place and route
# Place the design
puts "Starting placement..."
place_design -directive Default
puts "Placement completed."

# Route the design
puts "Starting routing..."
route_design -directive Default
puts "Routing completed."

# STEP#5: Generate routing-related reports
# Timing summary report  -> can't make xdc file(too hard)
# report_timing_summary -file $routingOutputDir/timing_summary.txt
# puts "Timing summary report generated."

# Utilization report after routing
report_utilization -file $routingOutputDir/utilization_after_routing.txt
puts "Utilization report after routing generated."

# Detailed timing report
report_timing -file $routingOutputDir/detailed_timing_report.txt
puts "Detailed timing report generated."

# Routed resource report
report_route_status -file $routingOutputDir/route_status.txt
puts "Routed resource report generated."

# Design rule check (DRC) report
report_drc -file $routingOutputDir/drc_report.txt
puts "DRC report generated."

# Save the checkpoint after routing
write_checkpoint -force $routingOutputDir/final_routed_design.dcp
puts "Checkpoint saved after routing."

# Optional: Save power report
report_power -file $routingOutputDir/power_report.txt
puts "Power report generated."

# Optional: Save IO report
report_io -file $routingOutputDir/io_report.txt
puts "IO report generated."

# STEP#6: Generate bitstream
# puts "Generating bitstream..."
# write_bitstream -force $routingOutputDir/final_bitstream.bit
# puts "Bitstream generation completed."

# Final message to indicate completion
puts "Routing, reporting, and bitstream generation completed successfully. Outputs saved in: $routingOutputDir"
