module blackbox_fifo_data #(
    parameter WEIGHT_BW = 8,
    parameter NUM_PE_ROWS = 8,
    parameter MATRIX_SIZE = 8
)(
    input wire fifo_data_selection,
    output wire [WEIGHT_BW * NUM_PE_ROWS * MATRIX_SIZE - 1:0] fifo_data_in
);
    // 출력 데이터 생성: 선택 신호에 따라 모든 0 또는 1로 출력
    assign fifo_data_in = fifo_data_selection 
        ? {WEIGHT_BW * NUM_PE_ROWS * MATRIX_SIZE {1'b1}}
        : {WEIGHT_BW * NUM_PE_ROWS * MATRIX_SIZE {1'b0}};

endmodule
