`timescale 1ns / 1ps

module tb_TOP_tpu;

    parameter ADDRESSSIZE = 10;
    parameter WORDSIZE = 64;
    parameter WEIGHT_BW = 8;
    parameter NUM_PE_ROWS = 8;
    parameter MATRIX_SIZE = 8;
    parameter FIFO_DEPTH = 4;
    parameter DATA_WIDTH = WEIGHT_BW * NUM_PE_ROWS * MATRIX_SIZE;       // FIFO 1 row size

    reg clk;
    reg rstn;
    reg start;
    reg we_rl;          // temp
    reg valid_address;  // temp
    wire end_;

    // SRAM 제어 신호
    reg sram_write_enable;
    reg [ADDRESSSIZE-1:0] sram_address;
    reg [WORDSIZE-1:0] sram_data_in;
    wire [WORDSIZE-1:0] sram_data_out;

    // Weight FIFO 제어 신호
    reg fifo_write_enable;
    reg fifo_read_enable;
    reg [DATA_WIDTH-1:0] fifo_data_in;
    wire [DATA_WIDTH-1:0] fifo_data_out;
    wire fifo_empty;
    wire fifo_full;

    // SRAM과 FIFO 데이터 파일 로드용
    reg [WORDSIZE-1:0] sram_data_array [0:15];
    reg [DATA_WIDTH-1:0] fifo_data_array [0:FIFO_DEPTH-1];
    integer i, j;

    TOP_tpu #(
        .ADDRESSSIZE(ADDRESSSIZE),
        .WORDSIZE(WORDSIZE),
        .WEIGHT_BW(WEIGHT_BW),
        .FIFO_DEPTH(FIFO_DEPTH),
        .NUM_PE_ROWS(NUM_PE_ROWS),
        .MATRIX_SIZE(MATRIX_SIZE)
    ) uut (
        .clk(clk),
        .rstn(rstn),
        .start(start),
        .end_(end_),
        .sram_write_enable(sram_write_enable),
        .sram_address(sram_address),
        .sram_data_in(sram_data_in),
        .sram_data_out(sram_data_out),
        .fifo_write_enable(fifo_write_enable),
        .fifo_read_enable(fifo_read_enable),
        .fifo_data_in(fifo_data_in),
        .fifo_data_out(fifo_data_out),
        .fifo_empty(fifo_empty),
        .fifo_full(fifo_full),
        .we_rl(we_rl),
        .valid_address(valid_address)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        $dumpfile("../../sim/waveform_TOPtpu.vcd");
        $dumpvars(0, tb_TOP_tpu);
    end

    // Reset 설정 및 초기화
    initial begin
        rstn = 0;
        start = 0;
        we_rl = 0;
        valid_address = 0;
        fifo_write_enable = 0;
        #10 rstn = 1;   // Reset 신호를 10ns 후에 설정
        #20;             // 추가 20ns 딜레이 후 SRAM과 FIFO 데이터 로드 시작
    end

    // SRAM 데이터 로드
    initial begin
        sram_address = 0;
        // Reset 후 30ns 대기
        #30;
        $readmemh("../../sim/vector_generator/hex/setup_result_hex.txt", sram_data_array);

        // SRAM 초기화 신호
        sram_write_enable = 1;

        // Write data into SRAM
        for (i = 0; i <= 14; i = i + 1) begin
            sram_data_in = sram_data_array[i];
            sram_address = i;
            #10;
        end

        // Disable SRAM write
        sram_write_enable = 0;
        #5;
        valid_address = 1;
        for(i=0; i<=15; i=i+1) begin
            sram_address = i;
            #10;
        end
        valid_address = 0;
    end

    // FIFO 데이터 로드
    initial begin
        // Reset 후 30ns 대기
        #30;
        $readmemh("../../sim/vector_generator/hex/weight_matrix_concat.txt", fifo_data_array);
        $display("readed data : %h", fifo_data_array[1]);

        // FIFO 초기화 신호
        fifo_write_enable = 0;
        fifo_read_enable = 0;

        // Write data into FIFO
        for (j = 0; j < FIFO_DEPTH; j = j + 1) begin
            fifo_data_in = fifo_data_array[j];
            fifo_write_enable = 1;
            #10;
            fifo_write_enable = 0;
            #10;
        end
    end

    // TPU 시작 신호 및 시뮬레이션 종료
    initial begin
        // Start TPU operation after SRAM and FIFO loading
        #105 
        start = 1;
        fifo_read_enable = 1;
        #10
        we_rl = 1;
        start = 0;
        #10
        we_rl = 0;
        fifo_read_enable = 0;


        // Wait for TPU end signal
        #500
        $display("Simulation completed: End signal received.");
        $finish;
    end

endmodule
