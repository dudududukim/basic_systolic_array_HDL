module CTRL_result_reverser #(
    parameter WORDSIZE = 8*20, // 전체 비트 수
    parameter PARTIAL_SUM_BW = 20   // 역순으로 바꿀 그룹의 크기
) (
    input wire [WORDSIZE-1 : 0] d,
    output wire [WORDSIZE-1 : 0] d_reverse
);

    genvar i;
    generate
        for (i = 0; i < WORDSIZE / PARTIAL_SUM_BW; i = i + 1) begin
            // 각 20비트 그룹을 역순으로 배치
            assign d_reverse[i*PARTIAL_SUM_BW +: PARTIAL_SUM_BW] = d[(WORDSIZE - PARTIAL_SUM_BW) - i*PARTIAL_SUM_BW +: PARTIAL_SUM_BW];
        end
    endgenerate

endmodule
