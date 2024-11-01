// Unified Buffer to store internal results or data inputs
// Datapath width = 8B

module SRAM_UnifiedBuffer
#(
    parameter ADDRESSSIZE = 15,          // 주소 크기
    parameter WORDSIZE    = 8 * 8      // 8바이트 = 64비트
)
(
    input                     clk,          // 클럭
    input                     write_enable, // 쓰기 활성화
    input  [ADDRESSSIZE-1:0]  address,      // 주소
    input  [WORDSIZE-1:0]     data_in,      // 입력 데이터 (256바이트)
    output reg [WORDSIZE-1:0] data_out      // 출력 데이터 (256바이트)
);


    // 메모리 배열 선언
    reg [WORDSIZE-1:0] mem_array [0:(1 << ADDRESSSIZE)-1];

    // 동작 정의
    always @(posedge clk) begin
        if (write_enable) begin
            mem_array[address] <= data_in;  // 쓰기 동작
        end else begin
            data_out <= mem_array[address]; // 읽기 동작
        end
    end

endmodule
