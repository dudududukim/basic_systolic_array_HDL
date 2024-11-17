module PE_hori #(
    parameter WEIGHT_BW = 8,            // 8bit weight
    parameter DATA_BW = 8,              // 8bit inputs
    parameter PARTIAL_SUM_BW = 24,      // 24-bit partial sum for expansion
    parameter MATRIX_SIZE = 128         // column number (default: 128)
) (
    input wire clk, rstn,
    input wire we_rl,
    input wire signed [DATA_BW*MATRIX_SIZE-1 : 0] DIN,
    input wire signed [MATRIX_SIZE*WEIGHT_BW-1 : 0] WEIGHTS,
    output wire signed [MATRIX_SIZE*DATA_BW-1 : 0] DF,
    output wire signed [PARTIAL_SUM_BW-1 : 0] result
);

    // 개별 psum_out 신호 및 din, w, df 신호 선언 및 연결
    genvar i;
    generate
        for (i = 0; i < MATRIX_SIZE; i = i + 1) begin : PE_GEN
            // Partial sum outputs
            wire signed [PARTIAL_SUM_BW-1 : 0] psum_out;

            // Input and output wires for each PE
            wire signed [DATA_BW-1 : 0] din;
            wire signed [WEIGHT_BW-1 : 0] w;
            wire signed [DATA_BW-1 : 0] df;

            // Assign sliced input values dynamically
            assign din = DIN[(i+1)*DATA_BW-1 : i*DATA_BW];
            assign w = WEIGHTS[(i+1)*WEIGHT_BW-1 : i*WEIGHT_BW];
            assign DF[(i+1)*DATA_BW-1 : i*DATA_BW] = df;

            // PE instances
            if (i == 0) begin
                // 첫 번째 PE의 PSUM_IN은 0으로 초기화
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
                // 나머지 PE는 이전 PSUM_OUT을 PSUM_IN으로 받음
                PE #(
                    .PARTIAL_SUM_BW(PARTIAL_SUM_BW), 
                    .DATA_IN_BW(DATA_BW), 
                    .WEIGHT_BW(WEIGHT_BW)
                ) PE_inst (
                    .clk(clk), 
                    .we_rl(we_rl), 
                    .rstn(rstn), 
                    .DIN(din), 
                    .PSUM_IN(PE_GEN[i-1].psum_out), // 이전 PE의 psum_out을 입력으로 사용
                    .W(w), 
                    .DF_COL(df), 
                    .PSUM_OUT(psum_out)
                );
            end
        end
    endgenerate

    // 최종 결과를 result로 전달
    assign result = PE_GEN[MATRIX_SIZE-1].psum_out;

endmodule
