module blackbox_fifo_data(
    input wire fifo_data_selection,
    output wire [WEIGHT_BW * NUM_PE_ROWS * MATRIX_SIZE - 1:0] fifo_data_in
);

    // 내부 신호 선언 (선택 동작을 기반으로 값을 결정)
    assign fifo_data_in = (fifo_data_selection) ? 
                          {WEIGHT_BW * NUM_PE_ROWS * MATRIX_SIZE{1'b1}} : 
                          {WEIGHT_BW * NUM_PE_ROWS * MATRIX_SIZE{1'b0}};

endmodule
