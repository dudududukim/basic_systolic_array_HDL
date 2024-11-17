module TOP_systolic_module #(
    parameter WEIGHT_BW = 8,
    parameter DATA_BW = 8,
    parameter PARTIAL_SUM_BW = 24,
    parameter MATRIX_SIZE = 128, // 128x128 확장
    parameter NUM_PE_ROWS = 128
) (
    input wire clk,
    input wire rstn,
    input wire we_rl,
    input wire signed [MATRIX_SIZE*DATA_BW-1:0] DIN,
    input wire signed [NUM_PE_ROWS*MATRIX_SIZE*WEIGHT_BW-1:0] WEIGHTS,
    output wire signed [(NUM_PE_ROWS*PARTIAL_SUM_BW)-1:0] result
);

    // 각 행 간 데이터를 전달할 신호를 `df_wire`로 선언
    wire signed [MATRIX_SIZE*DATA_BW-1:0] df_wire [0:NUM_PE_ROWS];

    // 첫 번째 PE의 입력에 `DIN`을 직접 연결
    assign df_wire[0] = DIN;

    genvar i, j;
    generate
        for (i = 0; i < NUM_PE_ROWS; i = i + 1) begin : pe_row
            // 행 별로 사용할 가중치 슬라이싱
            wire [MATRIX_SIZE*WEIGHT_BW-1 : 0] selected_weights;
            
            for (j = 0; j < MATRIX_SIZE; j = j + 1) begin : weight_slicing
                assign selected_weights[(j+1)*WEIGHT_BW-1 -: WEIGHT_BW] =
                    WEIGHTS[((i*MATRIX_SIZE) + j + 1)*WEIGHT_BW-1 -: WEIGHT_BW];
            end

            // PE_hori 인스턴스 생성
            PE_hori #(
                .WEIGHT_BW(WEIGHT_BW),
                .DATA_BW(DATA_BW),
                .PARTIAL_SUM_BW(PARTIAL_SUM_BW),
                .MATRIX_SIZE(MATRIX_SIZE)
            ) pe_hori_inst (
                .clk(clk),
                .rstn(rstn),
                .we_rl(we_rl),
                .DIN(df_wire[i]),  // 현재 행의 데이터
                .WEIGHTS(selected_weights),  // 슬라이싱된 가중치
                .DF(df_wire[i+1]),  // 다음 행으로 데이터 전달
                .result(result[(i+1)*PARTIAL_SUM_BW-1 -: PARTIAL_SUM_BW])
            );
        end
    endgenerate

endmodule
