`timescale 1ns / 1ps

module tb_TOP_tpu;

    parameter ADDRESSSIZE = 10;
    parameter WORDSIZE = 8*32;
    parameter WEIGHT_BW = 8;
    parameter NUM_PE_ROWS = 32;
    parameter MATRIX_SIZE = 32;
    parameter FIFO_DEPTH = 4;
    parameter DATA_WIDTH = WEIGHT_BW * NUM_PE_ROWS * MATRIX_SIZE;       // FIFO 1 row size
    parameter PARTIAL_SUM_BW = 24;
    parameter DATA_BW = 8;
    parameter WORDSIZE_Result = MATRIX_SIZE*PARTIAL_SUM_BW;

    reg clk;
    reg rstn;
    reg mul_start;
    reg we_rl;          // temp
    reg valid_address;  // temp
    reg end_detected;
    wire end_;

    // SRAM 제어 신호
    reg sram_write_enable;
    reg [ADDRESSSIZE-1:0] sram_address;
    reg [WORDSIZE-1:0] sram_data_in;
    wire [WORDSIZE-1:0] sram_data_out;

    wire [PARTIAL_SUM_BW*MATRIX_SIZE-1 : 0] sram_result_data_out;

    // Weight FIFO 제어 신호
    reg fifo_write_enable;
    reg fifo_read_enable;
    reg [DATA_WIDTH-1:0] fifo_data_in;
    wire [DATA_WIDTH-1:0] fifo_data_out;
    wire fifo_empty;
    wire fifo_full;
    reg [PARTIAL_SUM_BW*MATRIX_SIZE-1:0] expected_results [0:MATRIX_SIZE-1];

    // SRAM과 FIFO 데이터 파일 로드용
    reg [WORDSIZE-1:0] sram_data_array [0:MATRIX_SIZE-1];
    reg [DATA_WIDTH-1:0] fifo_data_array [0:FIFO_DEPTH-1];
    reg [ADDRESSSIZE-1:0] sram_results_Address;
    integer i, j;

    // controller pins
    reg addr_ctrl_en;

    TOP_tpu #(
        .ADDRESSSIZE(ADDRESSSIZE),
        .WORDSIZE(WORDSIZE),
        .WEIGHT_BW(WEIGHT_BW),
        .FIFO_DEPTH(FIFO_DEPTH),
        .NUM_PE_ROWS(NUM_PE_ROWS),
        .MATRIX_SIZE(MATRIX_SIZE),
        .DATA_BW(DATA_BW),
        .WORDSIZE_Result(WORDSIZE_Result),
        .PARTIAL_SUM_BW(PARTIAL_SUM_BW)
    ) uut (
        .clk(clk),
        .rstn(rstn),
        .start(mul_start),
        .end_(end_),
        .sram_write_enable(sram_write_enable),
        .sram_address(sram_address),
        .sram_data_in(sram_data_in),
        .sram_data_out(sram_data_out),
        .fifo_write_enable(fifo_write_enable),
        .fifo_read_enable(fifo_read_enable),
        .fifo_data_in(fifo_data_in),
        .fifo_data_out(fifo_data_out),
        .we_rl(we_rl),
        .valid_address(valid_address),

        .sram_result_address(sram_results_Address),
        .sram_result_data_out(sram_result_data_out)
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
        mul_start = 0;
        we_rl = 0;
        valid_address = 0;
        fifo_write_enable = 0;
        addr_ctrl_en=0;
        sram_results_Address = 0;
        #10 rstn = 1;   // Reset 신호를 10ns 후에 설정
        #20;             // 추가 20ns 딜레이 후 SRAM과 FIFO 데이터 로드 시작
    end

    // SRAM 데이터 로드
    initial begin
        $display("Simulation started at time %0t", $time);
        sram_address = 0;
        // Reset 후 30ns 대기
        #30;
        // $readmemh("../../sim/vector_generator/hex/setup_result_hex.txt", sram_data_array);
        $readmemh("../../sim/vector_generator/hex/original_matrix_hex.txt", sram_data_array);

        // SRAM 초기화 신호
        sram_write_enable = 1;

        // Write data into SRAM
        for (i = 0; i < MATRIX_SIZE; i = i + 1) begin
            sram_data_in = sram_data_array[i];
            sram_address = i;
            #10;
        end

        // Disable SRAM write
        sram_write_enable = 0;
        #5
        mul_start = 1;
        #10;
        valid_address = 1;
        for(i=0; i< MATRIX_SIZE; i=i+1) begin
            sram_address  = i;
            #10;
        end
        sram_address = 100;         // invalid address number
        valid_address = 0;

        sram_write_enable = 1;
        addr_ctrl_en =1;
    end

    // FIFO 데이터 로드
    initial begin
        // Reset 후 30ns 대기
        #30;
        $readmemh("../../sim/vector_generator/hex/weight_matrix_concat.txt", fifo_data_array);
        // $display("readed data : %h", fifo_data_array[0]);

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

    // result matrix data load
    initial begin
        // result_matrix_hex.txt에서 예상 결과를 불러옴
        $readmemh("../../sim/vector_generator/hex/result_matrix_hex.txt", expected_results);
    end

    // TPU 시작 신호 및 시뮬레이션 종료
    initial begin
        // mul_Start TPU operation after SRAM and FIFO loading
        #115 
        fifo_read_enable = 1;
        #10
        we_rl = 1;
        // mul_start = 0;
        #10
        we_rl = 0;
        fifo_read_enable = 0;
    end

    // mat mul results check
    always @(posedge end_) begin
        end_detected <= 1'b1;
    end

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            sram_results_Address <= 0;
            end_detected <= 0;
        end else if (end_detected) begin
            if (sram_result_data_out !== expected_results[sram_results_Address]) begin
                $display("Error: Mismatch at address %d. Expected: %h, Got: %h", 
                         sram_results_Address, expected_results[sram_results_Address], sram_result_data_out);
            end else begin
                $display("Match at address %d: %h", sram_results_Address, sram_result_data_out);
            end
            sram_results_Address <= sram_results_Address + 1;
            if (sram_results_Address == 10'd31) begin // 여기서 'hFF는 종료하고 싶은 주소 값
                $display("Simulation finished at address %d", sram_results_Address);
                $finish;
            end
        end
    end

endmodule
