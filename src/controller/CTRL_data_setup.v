/* 
Data setup controller is for setting diagonal data flow,
it gets data from Unified Buffer and make diagonal data setup.

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

*/

module CTRL_data_setup #(
    // parameters
) (
    // ports
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
        .we_rl(we_rl),                     
        .DIN(DIN),                         // top data flow : MATRIX_SIZE * DATA_BW-bit data input (8byte)
        .WEIGHTS(WEIGHTS),                 // whole weight supply chain : NUM_PE_ROWS * MATRIX_SIZE * WEIGHT_BW-bit weight input (64byte)
        .result(result)                    // NUM_PE_ROWS * PARTIAL_SUM_BW-bit output array (8*19bit)
    );


endmodule