`timescale 1ns / 1ps

module tb_TOP_tpu;

    // Parameters for SRAM
    parameter ADDRESSSIZE = 10;  // Example: 10 bits for 1024 entries
    parameter WORDSIZE = 64;     // 64 bits per word

    // Testbench signals
    reg clk;
    reg rstn;
    reg start;
    wire end;

    // SRAM signals
    reg write_enable;
    reg [ADDRESSSIZE-1:0] address;
    reg [WORDSIZE-1:0] data_in;
    wire [WORDSIZE-1:0] data_out;

    // Instantiate the TOP_tpu module
    TOP_tpu uut (
        .clk(clk),
        .rstn(rstn),
        .start(start),
        .end(end)
    );

    // Instantiate the SRAM module directly for accessing in testbench
    SRAM_UnifiedBuffer #(
        .ADDRESSSIZE(ADDRESSSIZE),
        .WORDSIZE(WORDSIZE)
    ) sram_ub (
        .clk(clk),
        .write_enable(write_enable),
        .address(address),
        .data_in(data_in),
        .data_out(data_out)
    );

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk;

    // Array to hold data from the file
    reg [WORDSIZE-1:0] data_array [0:15];  // Assuming 16 lines of data
    integer i;

    // VCD file setup for waveform analysis
    initial begin
        $dumpfile("../sim/waveform_TOPtpu.vcd");
        $dumpvars(0, tb_TOP_tpu);   
    end

    // Testbench process
    initial begin
        // Load data from hex file into data_array
        $readmemh("../sim/vector_generator/hex/setup_result_hex.txt", data_array);

        // Initialize signals
        rstn = 0;
        start = 0;
        write_enable = 1;
        address = 0;

        // Reset pulse
        #10 rstn = 1;

        // Write each entry from data_array into SRAM
        for (i = 0; i < 16; i = i + 1) begin
            data_in = data_array[i];
            address = i;
            #10;  // Wait one clock cycle for each write
        end

        // Disable write enable after loading data
        write_enable = 0;

        // Apply start signal to trigger the TPU operation
        #20 start = 1;
        #10 start = 0;

        // Wait for end signal from the TPU
        @(posedge end);

        // Simulation complete
        $display("Simulation completed: End signal received.");
        $finish;
    end

endmodule
