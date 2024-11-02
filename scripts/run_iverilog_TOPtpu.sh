#!/bin/bash

# Define output file for the compiled simulation
output_file="../sim/tb_TOP.vvp"
waveform_file="../sim/waveform_TOPtpu.vcd"

# Compile Verilog files with iverilog
iverilog -Wall -o $output_file \
    ../sim/tb_TOP.v \
    ../src/basic_modules/*.v \
    ../src/MEM/*.v \
    ../src/SysArr/*.v \
    ../src/TOP_tpu.v \
    # ../src/controller/*.v \

# Run the compiled simulation with vvp
vvp $output_file

# Check if the waveform file was generated
# if [ -f $waveform_file ]; then
#     echo "Opening waveform in GTKWave..."
#     gtkwave $waveform_file &
# else
#     echo "Error: Waveform file not generated."
# fi