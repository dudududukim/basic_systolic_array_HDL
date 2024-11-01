#!/bin/bash

# Define output file for the compiled simulation
output_file="tb_SRAM_UB.vvp"
waveform_file="waveform.vcd"

# Compile Verilog files with iverilog
iverilog -o $output_file tb_SRAM_UB.v ../src/MEM/SRAM_UnifiedBuffer.v

# Run the compiled simulation with vvp
vvp $output_file

# Check if the waveform file was generated
if [ -f $waveform_file ]; then
    echo "Opening waveform in GTKWave..."
    gtkwave $waveform_file &
else
    echo "Error: Waveform file not generated."
fi