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
    parameter DATA_BW = 8,
    parameter MATRIX_SIZE = 8
) (
    input wire clk, rstn,
    input wire [DATA_BW*MATRIX_SIZE  -1 : 0] data_in,
    output wire [DATA_BW*MATRIX_SIZE -1 : 0] data_setup
);
    
    // the first 8bit directly connect to the first component witout delay
    assign data_setup[DATA_BW*7 +: DATA_BW] = data_in[DATA_BW*7 +: DATA_BW];

    genvar i, j;
    generate
        for (i = 0; i <= 6; i = i + 1) begin : dff_gen
            wire [DATA_BW-1:0] temp_dff [0:(7-i)-1];

            dff #(.WIDTH(DATA_BW)) dff_first (
                .clk(clk),
                .rstn(rstn),
                .d(data_in[DATA_BW*i +: DATA_BW]),
                .q(temp_dff[0])
            );

            for (j = 1; j < (7 - i); j = j + 1) begin : dff_chain
                dff #(.WIDTH(DATA_BW)) dff_stage (
                    .clk(clk),
                    .rstn(rstn),
                    .d(temp_dff[j-1]),
                    .q(temp_dff[j])
                );
            end
            assign data_setup[DATA_BW * i +: DATA_BW] = temp_dff[(7-i)-1];
        end
    endgenerate



endmodule