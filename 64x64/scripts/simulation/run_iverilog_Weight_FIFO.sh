#!/bin/bash

# Define output file for the compiled simulation
output_file="../sim/tb_Weight_FIFO.vvp"
waveform_file="../sim/waveform_WeightFIFO.vcd"

# Compile Verilog files with iverilog
iverilog -o $output_file ../sim/tb_Weight_FIFO.v ../src/MEM/Weight_FIFO.v

# Run the compiled simulation with vvp
vvp $output_file

# Check if the waveform file was generated
if [ -f $waveform_file ]; then
    echo "Opening waveform in GTKWave..."
    gtkwave $waveform_file &
else
    echo "Error: Waveform file not generated."
fi