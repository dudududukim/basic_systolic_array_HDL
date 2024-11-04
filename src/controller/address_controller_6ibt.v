/*
    This address controller is made for 8x8 matrix output address management.
    It can be further used as the input data setup if possible.
    The key concept is too have circular shifter and combination of fixed hard wiring 3bit number.
*/

module address_controller_6bit #(
    parameter DATA_BW = 8
) (
    input wire clk, rstn, enable,
    output reg [6*8-1 : 0] address_6bit         // 8 6bit address
);
    wire [2:0] num [0:7];
    assign {num[7], num[6], num[5], num[4], num[3], num[2], num[1], num[0] } = {24'b111_110_101_100_011_010_001_000};

    always @(posedge clk  or negedge rstn) begin
        if(!rstn) begin                                         // setting for the first y11 output
            address_6bit[6*0 +: 6] <= {num[0], num[7]};
            address_6bit[6*1 +: 6] <= {num[7], num[6]};
            address_6bit[6*2 +: 6] <= {num[6], num[5]};
            address_6bit[6*3 +: 6] <= {num[5], num[4]};
            address_6bit[6*4 +: 6] <= {num[4], num[3]};
            address_6bit[6*5 +: 6] <= {num[3], num[2]};
            address_6bit[6*6 +: 6] <= {num[2], num[1]};
            address_6bit[6*7 +: 6] <= {num[1], num[0]};
        end
        else if (!enable) begin
            address_6bit <= address_6bit;
        end
        else begin
            address_6bit[6*0 +: 6] <= {address_6bit[6*7 +3 +: 3], num[7]};              // {front ciruclar address MSB 3bit, fixe hard wiring 3bit}
            address_6bit[6*1 +: 6] <= {address_6bit[6*0 +3 +: 3], num[6]};
            address_6bit[6*2 +: 6] <= {address_6bit[6*1 +3 +: 3], num[5]};
            address_6bit[6*3 +: 6] <= {address_6bit[6*2 +3 +: 3], num[4]};
            address_6bit[6*4 +: 6] <= {address_6bit[6*3 +3 +: 3], num[3]};
            address_6bit[6*5 +: 6] <= {address_6bit[6*4 +3 +: 3], num[2]};
            address_6bit[6*6 +: 6] <= {address_6bit[6*5 +3 +: 3], num[1]};
            address_6bit[6*7 +: 6] <= {address_6bit[6*6 +3 +: 3], num[0]};
        end
    end

endmodule