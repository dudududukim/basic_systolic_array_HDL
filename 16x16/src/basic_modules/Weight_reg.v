// weight_reg.v
module weight_reg #(
    parameter WEIGHT_BW = 8
) (
    input wire clk,
    input wire rstn,
    input wire we_rl,
    input wire signed [WEIGHT_BW-1:0] W,
    output reg signed [WEIGHT_BW-1:0] weight
);
    always @(posedge clk or negedge rstn) begin
        if (!rstn)
            weight <= 0;
        else if (we_rl)
            weight <= W;
    end
endmodule
