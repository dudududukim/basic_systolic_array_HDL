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

module CTRL_result_sync #(
    parameter PARTIAL_SUM_BW = 19,
    parameter MATRIX_SIZE = 8
) (
    input wire clk, rstn,
    input wire [PARTIAL_SUM_BW*MATRIX_SIZE  -1 : 0] data_in,
    output wire [PARTIAL_SUM_BW*MATRIX_SIZE -1 : 0] result_sync
);
    
    // the first 8bit directly connect to the first component witout delay
    assign result_sync[PARTIAL_SUM_BW*0 +: PARTIAL_SUM_BW] = data_in[PARTIAL_SUM_BW*0 +: PARTIAL_SUM_BW];

    genvar i, j;
    generate
    for (i = 1; i <= 7; i = i + 1) begin : dff_gen
        wire [PARTIAL_SUM_BW-1:0] temp_dff [0:i-1];

        dff #(.WIDTH(PARTIAL_SUM_BW)) dff_first (
            .clk(clk),
            .rstn(rstn),
            .d(data_in[PARTIAL_SUM_BW * i +: PARTIAL_SUM_BW]),
            .q(temp_dff[0])
        );

        for (j = 1; j < i; j = j + 1) begin : dff_chain
            dff #(.WIDTH(PARTIAL_SUM_BW)) dff_stage (
                .clk(clk),
                .rstn(rstn),
                .d(temp_dff[j-1]),
                .q(temp_dff[j])
            );
        end

        assign result_sync[PARTIAL_SUM_BW*i +: PARTIAL_SUM_BW] = temp_dff[i-1];
    end
    endgenerate




endmodule