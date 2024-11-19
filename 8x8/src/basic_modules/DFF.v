// dff.v - Parameterized D Flip-Flop
module dff #(
    parameter WIDTH = 8
) (
    input wire clk,
    input wire rstn,
    input wire [WIDTH-1:0] d,
    output reg [WIDTH-1:0] q
);
    always @(posedge clk or negedge rstn) begin
        if (!rstn)
            q <= 0;
        else
            q <= d;
    end
endmodule
