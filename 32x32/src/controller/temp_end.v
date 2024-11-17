module temp_end #(
    parameter PARTIAL_SUM_BW = 24,
    parameter MATRIX_SIZE = 32
)(
    input wire [PARTIAL_SUM_BW*MATRIX_SIZE-1 : 0] din,
    output wire dout
);
    assign dout = &din;
endmodule
