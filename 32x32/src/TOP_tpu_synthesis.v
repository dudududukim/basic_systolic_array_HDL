/*
TOP tpu module composition

1) Unified Buffer
2) Weight FIFO
3) Systolic Array
4) Controllers

*/

module TOP_tpu_synthesis #(
    parameter ADDRESSSIZE = 10,
    parameter WORDSIZE = 8*32,
    parameter WEIGHT_BW = 8,
    parameter FIFO_DEPTH = 4,
    parameter NUM_PE_ROWS = 32,
    parameter MATRIX_SIZE = 32,
    parameter PARTIAL_SUM_BW = 24,
    parameter DATA_BW = 8,
    parameter WORDSIZE_Result = 24*32

) (
    input wire clk, rstn, start, we_rl,
    output wire end_,

    // UB pins
    input wire sram_write_enable,
    input wire [ADDRESSSIZE-1:0] sram_address,
    input wire [WORDSIZE-1:0] sram_data_in,
    // output wire [WORDSIZE-1:0] sram_data_out,

    // FIFO pins
    input wire fifo_write_enable,
    input wire fifo_read_enable,
    // input wire [WEIGHT_BW * NUM_PE_ROWS * MATRIX_SIZE - 1:0] fifo_data_in,
    // output wire [WEIGHT_BW * NUM_PE_ROWS * MATRIX_SIZE - 1:0] fifo_data_out,
    // output wire fifo_empty,
    // output wire fifo_full,

    //
    input wire valid_address,
    output wire done
    // output wire [PARTIAL_SUM_BW*MATRIX_SIZE-1 : 0] sram_result_data_out
);
    wire [PARTIAL_SUM_BW*MATRIX_SIZE-1 : 0] sram_result_data_out;
    wire [WEIGHT_BW * NUM_PE_ROWS * MATRIX_SIZE - 1:0] fifo_data_out;
    wire [WORDSIZE-1:0] sram_data_out;
    wire signed [PARTIAL_SUM_BW*NUM_PE_ROWS-1:0] result;
    wire [5:0] count6;                  // for sensing the results timing
    wire [DATA_BW*MATRIX_SIZE -1 : 0] data_set;
    wire [PARTIAL_SUM_BW*MATRIX_SIZE-1 : 0] result_sync, result_sync_rev;
    wire [6:0] state_count;             // checking the cycle

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

    SRAM_Results #(
        .ADDRESSSIZE(ADDRESSSIZE),
        .WORDSIZE(WORDSIZE_Result)
    ) SRAM_Results(
        .clk(clk),
        .write_enable(count6[5]),
        .address({5'b0,count6[4:0]}),
        .data_in(result_sync_rev),
        .data_out(sram_result_data_out)
    );

    temp_end #(
        .MATRIX_SIZE(MATRIX_SIZE),
        .PARTIAL_SUM_BW(PARTIAL_SUM_BW)
    ) result_done(
        .din(sram_result_data_out),
        .dout(done)
    );

    Weight_FIFO #(
        .WEIGHT_BW(WEIGHT_BW),
        .FIFO_DEPTH(FIFO_DEPTH),
        .NUM_PE_ROWS(NUM_PE_ROWS),
        .MATRIX_SIZE(MATRIX_SIZE)
    ) weight_fifo (
        .clk(clk),
        .rstn(rstn),
        .write_enable(fifo_write_enable),
        .read_enable(fifo_read_enable),
        .data_in(),
        .data_out(fifo_data_out)
        // .empty(fifo_empty),
        // .full(fifo_full)
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
        .DIN(data_set),                         // top data flow : MATRIX_SIZE * DATA_BW-bit data input (8byte)
        .WEIGHTS(fifo_data_out),                 // whole weight supply chain : NUM_PE_ROWS * MATRIX_SIZE * WEIGHT_BW-bit weight input (64byte)
        .result(result)                    // NUM_PE_ROWS * PARTIAL_SUM_BW-bit output array (8*19bit)
    );

    counter_6bit_en counter_6bit(
        .clk(clk),
        .rstn(rstn),
        .enable(!valid_address),
        .count(count6)
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

    CTRL_result_reverser #(                 // not sequencial but wiring
        .WORDSIZE(MATRIX_SIZE*PARTIAL_SUM_BW),
        .PARTIAL_SUM_BW(PARTIAL_SUM_BW)
    ) result_reverser(
        .d(result_sync),
        .d_reverse(result_sync_rev)
    );

    CTRL_state_machine state_coutner(
        .clk(clk), .rstn(rstn), .start(start),
        .state_count(state_count), .end_signal(end_)
    );

endmodule