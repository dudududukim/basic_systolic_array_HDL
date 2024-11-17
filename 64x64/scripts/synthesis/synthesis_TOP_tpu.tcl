#
# STEP#1: define the output directory area.
#
set outputDir ../../output/Created_Data/systolic_project_32x32
file mkdir $outputDir
create_project proj_1 $outputDir \
  -part xcu250-figd2104-2L-e -force

#
# STEP#2: setup design sources and constraints
#

set_property source_mgmt_mode None [current_project]

# Add Verilog source files from src directory
source ./file_list.tcl

# top module includeing
add_files -norecurse ../../src/TOP_tpu_synthesis.v
set_property top TOP_tpu_synthesis [current_fileset]
update_compile_order -fileset sources_1

#
# STEP#3: run synthesis and the default utilization report.
#
launch_runs synth_1 -jobs 16

# synth_design 실행 후 TOP_systolic_module이 포함되었는지 확인
# report_compile_order -fileset sources_1

# 각 모듈별 cell count, area, utilization을 포함한 report
wait_on_run synth_1
open_run synth_1
report_hierarchy -cell_count -area -utilization -show_leaves -file $outputDir/module_utilization_report.txt