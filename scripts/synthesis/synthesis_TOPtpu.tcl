#
# STEP#1: define the output directory area.
#
set outputDir ../../output/Created_Data/systolic_project
file mkdir $outputDir
create_project proj_1 $outputDir \
  -part xcu250-figd2104-2L-e -force

#
# STEP#2: setup design sources and constraints
#

set_property source_mgmt_mode None [current_project]

# Add Verilog source files from src directory
foreach file [file search ../../src/basic_modules *.v] {
    add_files -norecurse $file
}

foreach file [file search ../../src/controller *.v] {
    add_files -norecurse $file
}

foreach file [file search ../../src/counter *.v] {
    add_files -norecurse $file
}

foreach file [file search ../../src/MEM *.v] {
    add_files -norecurse $file
}

foreach file [file search ../../src/SysArr *.v] {
    add_files -norecurse $file
}

# top module includeing
add_files -norecurse ../../src/TOP_tpu.v
set_property top TOP_tpu [current_fileset]
update_compile_order -fileset sources_1

#
# STEP#3: run synthesis and the default utilization report.
#
launch_runs synth_1 -jobs 16
