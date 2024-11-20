// module Weight_FIFO #(
//     parameter WEIGHT_BW = 8,
//     parameter FIFO_DEPTH = 4,
//     parameter NUM_PE_ROWS = 8,
//     parameter MATRIX_SIZE = 8
// ) (
//     input wire clk,
//     input wire rstn, // 동기 리셋으로 수정
//     input wire write_enable,
//     input wire read_enable,
//     input wire [WEIGHT_BW*NUM_PE_ROWS*MATRIX_SIZE-1:0] data_in,
//     output reg [WEIGHT_BW*NUM_PE_ROWS*MATRIX_SIZE-1:0] data_out,
//     output wire empty,
//     output wire full
// );

//     // FIFO 메모리를 BRAM으로 강제 매핑
//     (* ram_style = "block" *) reg [WEIGHT_BW*NUM_PE_ROWS*MATRIX_SIZE-1:0] fifo_mem [0:FIFO_DEPTH-1];
//     reg [$clog2(FIFO_DEPTH)-1:0] read_ptr, write_ptr;
//     reg [$clog2(FIFO_DEPTH+1)-1:0] count;

//     assign empty = (count == 0);
//     assign full = (count == FIFO_DEPTH);

//     // 동기 리셋으로 리셋 로직 변경
//     always @(posedge clk) begin
//         if (!rstn) begin
//             write_ptr <= 0;
//             read_ptr <= 0;
//             count <= 0;
//             data_out <= 0;
//         end else begin
//             // Write operation
//             if (write_enable && !full) begin
//                 fifo_mem[write_ptr] <= data_in;
//                 write_ptr <= write_ptr + 1;
//                 count <= count + 1;
//             end

//             // Read operation
//             if (read_enable && !empty) begin
//                 data_out <= fifo_mem[read_ptr];
//                 read_ptr <= read_ptr + 1;
//                 count <= count - 1;
//             end
//         end
//     end

// endmodule


module Weight_FIFO #(
    parameter WEIGHT_BW = 8,
    parameter FIFO_DEPTH = 4,
    parameter NUM_PE_ROWS = 8,
    parameter MATRIX_SIZE = 8
)(
    input wire clk,
    input wire rstn,                // 동기 리셋
    input wire write_enable,        // 쓰기 신호
    input wire read_enable,         // 읽기 신호
    input wire [WEIGHT_BW*NUM_PE_ROWS*MATRIX_SIZE-1:0] data_in,  // 입력 데이터
    output wire [WEIGHT_BW*NUM_PE_ROWS*MATRIX_SIZE-1:0] data_out  // 출력 데이터
);

    // FIFO 메모리 및 포인터
    (* ram_style = "block" *) reg [WEIGHT_BW*NUM_PE_ROWS*MATRIX_SIZE-1:0] fifo_mem [0:FIFO_DEPTH-1];
    reg [WEIGHT_BW*NUM_PE_ROWS*MATRIX_SIZE-1:0] data_out_reg;  // 출력 데이터
    reg [$clog2(FIFO_DEPTH):0] write_ptr;  // 쓰기 포인터
    reg [$clog2(FIFO_DEPTH):0] read_ptr;   // 읽기 포인터
    reg [$clog2(FIFO_DEPTH+1):0] fifo_count; // FIFO 내 데이터 개수

    // 동기 리셋 처리
    always @(posedge clk) begin
        if (!rstn) begin
            // 리셋 신호가 활성화되면 모든 레지스터 초기화
            write_ptr <= 0;
            read_ptr <= 0;
            fifo_count <= 0;
            data_out_reg <= 0;
        end else begin
            // 쓰기 동작: write_enable이 활성화되고 FIFO가 가득 차지 않았을 때
            if (write_enable && (fifo_count < FIFO_DEPTH)) begin
                fifo_mem[write_ptr] <= data_in;
                write_ptr <= write_ptr + 1;
                fifo_count <= fifo_count + 1;
            end

            // 읽기 동작: read_enable이 활성화되고 FIFO가 비어있지 않을 때
            if (read_enable && (fifo_count > 0)) begin
                data_out_reg <= fifo_mem[read_ptr];
                read_ptr <= read_ptr + 1;
                fifo_count <= fifo_count - 1;
            end
        end
    end

    assign data_out = data_out_reg;

endmodule
