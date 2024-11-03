# Check if a TCL file is provided as an argument
if [ -z "$1" ]; then
    echo "Usage: $0 <synthesis_tcl_file>"
    echo "Please provide the TCL script for synthesis (e.g., synthesis.tcl)."
    exit 1
fi

# Run Vivado in batch mode with the provided TCL file
vivado -mode batch -source "$1"