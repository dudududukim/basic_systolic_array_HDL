// systolic array top assembler

module TOP_systolic_module #(
    parameter WEIGHT_BW = 8,
    parameter DATA_BW = 8,
    parameter PARTIAL_SUM_BW = 19,
    parameter MATRIX_SIZE = 8,          // MX column number
    parameter NUM_PE_ROWS = 8           // MX row number
) (
    input wire clk,
    input wire rstn,
    input wire we_rl,
    input wire signed [MATRIX_SIZE*DATA_BW-1:0] DIN,
    input wire signed [NUM_PE_ROWS*MATRIX_SIZE*WEIGHT_BW-1:0] WEIGHTS,
    output wire signed [PARTIAL_SUM_BW-1:0] result [0:NUM_PE_ROWS-1]
);

    wire signed [MATRIX_SIZE*DATA_BW-1:0] df_wire [0:NUM_PE_ROWS];      // in the generate block it interconnects the PEs

    assign df_wire[0] = DIN;                    // first PE gets the direct Data value

    genvar i;
    generate
        for (i = 0; i < NUM_PE_ROWS; i = i + 1) begin : pe_row
            PE_hori #(
                .WEIGHT_BW(WEIGHT_BW),
                .DATA_BW(DATA_BW),
                .PARTIAL_SUM_BW(PARTIAL_SUM_BW),
                .MATRIX_SIZE(MATRIX_SIZE)
            ) pe_hori_inst (
                .clk(clk),
                .rstn(rstn),
                .we_rl(we_rl),
                .DIN(df_wire[i]),
                .WEIGHTS(WEIGHTS[i*MATRIX_SIZE*WEIGHT_BW +: MATRIX_SIZE*WEIGHT_BW]),
                .DF(df_wire[i+1]),
                .result(result[i])
            );
        end
    endgenerate

endmodule
