// Processing Element
// sequence of PE => PE0 -> PE1 -> ... -> PE7 -> results

module PE_hori #(
    parameter WEIGHT_BW = 8,            // 8bit weight
    parameter DATA_BW = 8,              // 8bit inputs
    parameter PARTIAL_SUM_BW = 19,
    parameter MATRIX_SIZE = 8           // column number
) (
    input wire clk, rstn,
    input wire we_rl,
    input wire signed [DATA_BW*MATRIX_SIZE-1 : 0] DIN,
    input wire signed [MATRIX_SIZE*WEIGHT_BW-1 : 0] WEIGHTS,                            // 64bit weight should be divided into 8*byte weights
    output wire signed [MATRIX_SIZE*DATA_BW -1 : 0] DF,                                 // DF0-7 flows through PEs
    output wire signed [PARTIAL_SUM_BW-1 : 0] result
);
    // wire declaration
    wire [PARTIAL_SUM_BW-1 : 0] psum_out0, psum_out1, psum_out2, psum_out3, psum_out4, psum_out5, psum_out6, psum_out7;
    wire [DATA_BW-1 : 0] din0, din1, din2, din3, din4, din5, din6, din7;
    wire [WEIGHT_BW-1 : 0] w0, w1, w2, w3, w4, w5, w6, w7;
    wire [DATA_BW-1 : 0] df0, df1, df2, df3, df4, df5, df6, df7;
    
    // weight wiring
    assign {w0, w1, w2, w3, w4, w5, w6, w7} = WEIGHTS;
    assign {din0, din1, din2, din3, din4, din5, din6, din7} = DIN;
    assign DF = {df0, df1, df2, df3, df4, df5, df6, df7};

    // PE combination part
    PE_outbw_19bit #(.PARTIAL_SUM_BW(19), .DATA_IN_BW(8), .WEIGHT_BW(8))
        PE0 (.clk(clk), .we_rl(we_rl), .rstn(rstn), .DIN(din0), .PSUM_IN(19'b0), .W(w0), .DF_COL(df0), .PSUM_OUT(psum_out0));

    PE_outbw_19bit #(.PARTIAL_SUM_BW(19), .DATA_IN_BW(8), .WEIGHT_BW(8))
        PE1 (.clk(clk), .we_rl(we_rl), .rstn(rstn), .DIN(din1), .PSUM_IN(psum_out0), .W(w1), .DF_COL(df1), .PSUM_OUT(psum_out1));

    PE_outbw_19bit #(.PARTIAL_SUM_BW(19), .DATA_IN_BW(8), .WEIGHT_BW(8))
        PE2 (.clk(clk), .we_rl(we_rl), .rstn(rstn), .DIN(din2), .PSUM_IN(psum_out1), .W(w2), .DF_COL(df2), .PSUM_OUT(psum_out2));

    PE_outbw_19bit #(.PARTIAL_SUM_BW(19), .DATA_IN_BW(8), .WEIGHT_BW(8))
        PE3 (.clk(clk), .we_rl(we_rl), .rstn(rstn), .DIN(din3), .PSUM_IN(psum_out2), .W(w3), .DF_COL(df3), .PSUM_OUT(psum_out3));
    
    PE_outbw_19bit #(.PARTIAL_SUM_BW(19), .DATA_IN_BW(8), .WEIGHT_BW(8))
        PE4 (.clk(clk), .we_rl(we_rl), .rstn(rstn), .DIN(din4), .PSUM_IN(psum_out3), .W(w4), .DF_COL(df4), .PSUM_OUT(psum_out4));

    PE_outbw_19bit #(.PARTIAL_SUM_BW(19), .DATA_IN_BW(8), .WEIGHT_BW(8))
        PE5 (.clk(clk), .we_rl(we_rl), .rstn(rstn), .DIN(din5), .PSUM_IN(psum_out4), .W(w5), .DF_COL(df5), .PSUM_OUT(psum_out5));
    
    PE_outbw_19bit #(.PARTIAL_SUM_BW(19), .DATA_IN_BW(8), .WEIGHT_BW(8))
        PE6 (.clk(clk), .we_rl(we_rl), .rstn(rstn), .DIN(din6), .PSUM_IN(psum_out5), .W(w6), .DF_COL(df6), .PSUM_OUT(psum_out6));
    
    PE_outbw_19bit #(.PARTIAL_SUM_BW(19), .DATA_IN_BW(8), .WEIGHT_BW(8))
        PE7 (.clk(clk), .we_rl(we_rl), .rstn(rstn), .DIN(din7), .PSUM_IN(psum_out6), .W(w7), .DF_COL(df7), .PSUM_OUT(result));

endmodule