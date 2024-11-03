/*
TOP tpu module composition

1) Unified Buffer
2) Weight FIFO
3) Systolic Array
4) Controllers

*/

module TOP_tpu #(
    parameter ADDRESSSIZE = 10,
    parameter WORDSIZE = 64,
    parameter WEIGHT_BW = 8,
    parameter FIFO_DEPTH = 4,
    parameter NUM_PE_ROWS = 8,
    parameter MATRIX_SIZE = 8,
    parameter PARTIAL_SUM_BW = 19,
    parameter DATA_BW = 8

) (
    input wire clk, rstn, start, we_rl,
    output wire end_,

    // UB pins
    input wire sram_write_enable,
    input wire [ADDRESSSIZE-1:0] sram_address,
    input wire [WORDSIZE-1:0] sram_data_in,
    output wire [WORDSIZE-1:0] sram_data_out,

    // FIFO pins
    input wire fifo_write_enable,
    input wire fifo_read_enable,
    input wire [WEIGHT_BW * NUM_PE_ROWS * MATRIX_SIZE - 1:0] fifo_data_in,
    output wire [WEIGHT_BW * NUM_PE_ROWS * MATRIX_SIZE - 1:0] fifo_data_out,
    output wire fifo_empty,
    output wire fifo_full,

    //
    input wire valid_address
);

    wire signed [PARTIAL_SUM_BW*NUM_PE_ROWS-1:0] result;
    wire [2:0] count3;                  // for sensing the results timing

    SRAM_UnifiedBuffer #(
        .ADDRESSSIZE(ADDRESSSIZE),
        .WORDSIZE(WORDSIZE)
    ) SRAM_UB (
        .clk(clk),
        .write_enable(sram_write_enable),
        .address(sram_address),
        .data_in(sram_data_in),
        .data_out(sram_data_out)
    );

    Weight_FIFO #(
        .WEIGHT_BW(WEIGHT_BW),
        .FIFO_DEPTH(4)
    ) weight_fifo (
        .clk(clk),
        .rstn(rstn),
        .write_enable(fifo_write_enable),
        .read_enable(fifo_read_enable),
        .data_in(fifo_data_in),
        .data_out(fifo_data_out),
        .empty(fifo_empty),
        .full(fifo_full)
    );

    TOP_systolic_module #(
        .WEIGHT_BW(WEIGHT_BW),             
        .DATA_BW(DATA_BW),                 
        .PARTIAL_SUM_BW(PARTIAL_SUM_BW),  
        .MATRIX_SIZE(MATRIX_SIZE),         
        .NUM_PE_ROWS(NUM_PE_ROWS)          
    ) systolic_array (
        .clk(clk),                         
        .rstn(rstn),                       
        .we_rl(we_rl),                     // weight reload signal 
        .DIN(sram_data_out),                         // top data flow : MATRIX_SIZE * DATA_BW-bit data input (8byte)
        .WEIGHTS(fifo_data_out),                 // whole weight supply chain : NUM_PE_ROWS * MATRIX_SIZE * WEIGHT_BW-bit weight input (64byte)
        .result(result)                    // NUM_PE_ROWS * PARTIAL_SUM_BW-bit output array (8*19bit)
    );

    counter_3bit_en counter_3bit(
        .clk(clk),
        .rstn(rstn),
        .enable(!valid_address),
        .count(count3)
    );

endmodule