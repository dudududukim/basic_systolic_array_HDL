module PE_hori #(
    parameter WEIGHT_BW = 8,            // 8bit weight
    parameter DATA_BW = 8,              // 8bit inputs
    parameter PARTIAL_SUM_BW = 20,      // 24-bit partial sum for expansion
    parameter MATRIX_SIZE = 8           // column number (default: 8 for 8x8)
) (
    input wire clk, rstn,
    input wire we_rl,
    input wire signed [DATA_BW*MATRIX_SIZE-1 : 0] DIN,
    input wire signed [MATRIX_SIZE*WEIGHT_BW-1 : 0] WEIGHTS,
    output wire signed [MATRIX_SIZE*DATA_BW-1 : 0] DF,
    output wire signed [PARTIAL_SUM_BW-1 : 0] result
);

    // Individual psum_out, din, w, df signals
    genvar i;
    generate
        for (i = 0; i < MATRIX_SIZE; i = i + 1) begin : PE_GEN
            // Partial sum output for each PE
            wire signed [PARTIAL_SUM_BW-1 : 0] psum_out;

            // Input and output wires for each PE
            wire signed [DATA_BW-1 : 0] din;
            wire signed [WEIGHT_BW-1 : 0] w;
            wire signed [DATA_BW-1 : 0] df;

            // Dynamically assign sliced input values
            assign din = DIN[(MATRIX_SIZE-i-1)*DATA_BW +: DATA_BW];
            assign w = WEIGHTS[(MATRIX_SIZE-i-1)*WEIGHT_BW +: WEIGHT_BW];
            assign DF[(MATRIX_SIZE-i-1)*DATA_BW +: DATA_BW] = df;

            // PE instances
            if (i == 0) begin
                // First PE, initialize PSUM_IN to 0
                PE #(
                    .PARTIAL_SUM_BW(PARTIAL_SUM_BW), 
                    .DATA_IN_BW(DATA_BW), 
                    .WEIGHT_BW(WEIGHT_BW)
                ) PE_inst (
                    .clk(clk), 
                    .we_rl(we_rl), 
                    .rstn(rstn), 
                    .DIN(din), 
                    .PSUM_IN({PARTIAL_SUM_BW{1'b0}}), 
                    .W(w), 
                    .DF_COL(df), 
                    .PSUM_OUT(psum_out)
                );
            end else begin
                // Other PEs take previous PE's psum_out as PSUM_IN
                PE #(
                    .PARTIAL_SUM_BW(PARTIAL_SUM_BW), 
                    .DATA_IN_BW(DATA_BW), 
                    .WEIGHT_BW(WEIGHT_BW)
                ) PE_inst (
                    .clk(clk), 
                    .we_rl(we_rl), 
                    .rstn(rstn), 
                    .DIN(din), 
                    .PSUM_IN(PE_GEN[i-1].psum_out), 
                    .W(w), 
                    .DF_COL(df), 
                    .PSUM_OUT(psum_out)
                );
            end
        end
    endgenerate

    // Pass the final result
    assign result = PE_GEN[MATRIX_SIZE-1].psum_out;

endmodule
