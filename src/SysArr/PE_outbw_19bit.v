module PE_outbw_19bit #(
    parameter PARTIAL_SUM_BW = 19,
    parameter DATA_IN_BW = 8,
    parameter WEIGHT_BW = 8
) (
    input wire clk, we_rl, rstn,                                    // WE_RL : weight_reloading signal -> when this turned on the weight is chagned
    input wire signed [DATA_IN_BW-1 : 0] DIN,                       // data that should be multplied
    input wire signed [PARTIAL_SUM_BW-1 : 0] PSUM_IN,               // partial sum input (19bit in 8x8 MXU)
    input wire signed[WEIGHT_BW-1 : 0] W,                           // weight that stays constant and refreshed with the WE_RL signal
    output wire signed [DATA_IN_BW-1 : 0] DF_COL,                    // column direction data flow (DF_COL)
    output wire signed [PARTIAL_SUM_BW-1 : 0] PSUM_OUT               // partial sum that flows to right direction
);
    wire signed [WEIGHT_BW-1 : 0] weight;
    wire signed [DATA_IN_BW+WEIGHT_BW-1 : 0] wx;
    wire signed [3+DATA_IN_BW+WEIGHT_BW-1 : 0] partial_sum;         // 3 is for the bit width that sum 16bit for 8 times

    // sequential part
    dff #(.WIDTH(DATA_IN_BW)) dff_DIN (
        .clk(clk), 
        .rstn(rstn), 
        .d(DIN), 
        .q(DF_COL)
    );
    
    dff #(.WIDTH(PARTIAL_SUM_BW)) dff_PSUM_OUT (
        .clk(clk), 
        .rstn(rstn), 
        .d(partial_sum), 
        .q(PSUM_OUT)
    );

    // sequential part for weight reloading
    weight_reg #(.WEIGHT_BW(WEIGHT_BW)) u_weight_reg (
        .clk(clk),
        .rstn(rstn),
        .we_rl(we_rl),
        .W(W),
        .weight(weight)
    );

    // combinational part
    assign wx = DIN * weight;
    assign partial_sum = PSUM_IN + wx;

endmodule