module Weight_FIFO #(
    parameter WEIGHT_BW = 8,
    parameter FIFO_DEPTH = 4,
    parameter NUM_PE_ROWS = 8,
    parameter MATRIX_SIZE = 8
) (
    input wire clk,
    input wire rstn, // 동기 리셋으로 수정
    input wire write_enable,
    input wire read_enable,
    input wire [WEIGHT_BW*NUM_PE_ROWS*MATRIX_SIZE-1:0] data_in,
    output reg [WEIGHT_BW*NUM_PE_ROWS*MATRIX_SIZE-1:0] data_out,
    output wire empty,
    output wire full
);

    // FIFO 메모리를 BRAM으로 강제 매핑
    (* ram_style = "block" *) reg [WEIGHT_BW*NUM_PE_ROWS*MATRIX_SIZE-1:0] fifo_mem [0:FIFO_DEPTH-1];
    reg [$clog2(FIFO_DEPTH)-1:0] read_ptr, write_ptr;
    reg [$clog2(FIFO_DEPTH+1)-1:0] count;

    assign empty = (count == 0);
    assign full = (count == FIFO_DEPTH);

    // 동기 리셋으로 리셋 로직 변경
    always @(posedge clk) begin
        if (!rstn) begin
            write_ptr <= 0;
            read_ptr <= 0;
            count <= 0;
            data_out <= 0;
        end else begin
            // Write operation
            if (write_enable && !full) begin
                fifo_mem[write_ptr] <= data_in;
                write_ptr <= write_ptr + 1;
                count <= count + 1;
            end

            // Read operation
            if (read_enable && !empty) begin
                data_out <= fifo_mem[read_ptr];
                read_ptr <= read_ptr + 1;
                count <= count - 1;
            end
        end
    end

endmodule
