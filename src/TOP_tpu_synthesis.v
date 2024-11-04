/*
TOP tpu module composition

1) Unified Buffer
2) Weight FIFO
3) Systolic Array
4) Controllers

*/

module TOP_tpu_synthesis #(
    parameter ADDRESSSIZE = 10,
    parameter WORDSIZE = 64,
    parameter WEIGHT_BW = 8,
    parameter FIFO_DEPTH = 4,
    parameter NUM_PE_ROWS = 8,
    parameter MATRIX_SIZE = 8,
    parameter PARTIAL_SUM_BW = 20,
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
    input wire valid_address, addr_ctrl_en
);

    wire signed [PARTIAL_SUM_BW*NUM_PE_ROWS-1:0] result;
    wire [2:0] count3;                  // for sensing the results timing
    wire [6*8 -1 : 0] w_addr;
    wire [DATA_BW*MATRIX_SIZE -1 : 0] data_set;
    wire [PARTIAL_SUM_BW*MATRIX_SIZE-1 : 0] result_sync;
    wire q_we_rl;

    dff#(
        .WIDTH(1)
    ) dff_we_rl(
        .clk(clk),
        .rstn(rstn),
        .d(we_rl),
        .q(q_we_rl)
    )

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
        .we_rl(q_we_rl),                     // weight reload signal 
        .DIN(data_set),                         // top data flow : MATRIX_SIZE * DATA_BW-bit data input (8byte)
        .WEIGHTS(fifo_data_out),                 // whole weight supply chain : NUM_PE_ROWS * MATRIX_SIZE * WEIGHT_BW-bit weight input (64byte)
        .result(result)                    // NUM_PE_ROWS * PARTIAL_SUM_BW-bit output array (8*19bit)
    );

    counter_3bit_en counter_3bit(
        .clk(clk),
        .rstn(rstn),
        .enable(!valid_address),
        .count(count3)
    );

    address_controller_6bit #(
        .DATA_BW(DATA_BW)
    ) addr_controller_6bit (
        .clk(clk),
        .rstn(rstn),
        .enable(addr_ctrl_en),
        .address_6bit(w_addr)
    );

    CTRL_data_setup #(
        .DATA_BW(DATA_BW),
        .MATRIX_SIZE(MATRIX_SIZE)
    ) data_setup_controller(
        .clk(clk),
        .rstn(rstn),
        .data_in(sram_data_out),
        .data_setup(data_set)
    );

    CTRL_data_setup #(
        .DATA_BW(PARTIAL_SUM_BW),
        .MATRIX_SIZE(MATRIX_SIZE)
    ) result_sync_controller (
        .clk(clk),
        .rstn(rstn),
        .data_in(result),
        .data_setup(result_sync)
    );

endmodule