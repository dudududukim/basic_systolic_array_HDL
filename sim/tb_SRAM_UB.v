`timescale 1ns / 1ps

module tb_SRAM_UB;

    // Parameters
    parameter ADDRESSSIZE = 10;  // Example: 10 bits for 1024 entries
    parameter WORDSIZE = 64;     // 64 bits (8 bytes per word)

    // Testbench signals
    reg clk;
    reg write_enable;
    reg [ADDRESSSIZE-1:0] address;
    reg [WORDSIZE-1:0] data_in;
    wire [WORDSIZE-1:0] data_out;

    // Instantiate the SRAM_UnifiedBuffer
    SRAM_UnifiedBuffer #(
        .ADDRESSSIZE(ADDRESSSIZE),
        .WORDSIZE(WORDSIZE)
    ) uut (
        .clk(clk),
        .write_enable(write_enable),
        .address(address),
        .data_in(data_in),
        .data_out(data_out)
    );

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk;  // 10ns clock period

    // Array to hold data from the file
    reg [WORDSIZE-1:0] data_array [0:15];  // Assuming 16 lines of data
    integer i;

    initial begin
        $dumpfile("waveform.vcd");  // VCD 파일 이름 지정
        $dumpvars(0, tb_SRAM_UB);  // 최상위 모듈의 모든 신호를 덤프
    end

    // Testbench process
    initial begin
        // Load data from the hex file into data_array
        $readmemh("vector_generator/hex/setup_result_hex.txt", data_array);  

        // Initialize signals
        write_enable = 1;
        address = 0;

        // Write each entry from data_array into SRAM
        for (i = 0; i < 16; i = i + 1) begin
            data_in = data_array[i];
            address = i;
            #10;  // Wait one clock cycle for each write
        end

        // Disable write enable
        write_enable = 0;

        // Verify data by reading back
        #10;
        for (i = 0; i < 16; i = i + 1) begin
            address = i;
            #10;  // Wait for data_out to update
            $display("Address %0d: Data Out = %h", i, data_out);
        end

        $finish;
    end

endmodule
