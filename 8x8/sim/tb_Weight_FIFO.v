`timescale 1ns / 1ps

module tb_Weight_FIFO;

    parameter WEIGHT_BW = 8;
    parameter NUM_PE_ROWS = 8;
    parameter MATRIX_SIZE = 8;
    parameter FIFO_DEPTH = 4;
    parameter DATA_WIDTH = WEIGHT_BW * NUM_PE_ROWS * MATRIX_SIZE;

    reg clk;
    reg rstn;
    reg write_enable;
    reg read_enable;
    reg [DATA_WIDTH-1:0] data_in;
    wire [DATA_WIDTH-1:0] data_out;
    wire empty;
    wire full;

    reg [DATA_WIDTH-1:0] memory_data [0:FIFO_DEPTH-1];

    Weight_FIFO #(
        .WEIGHT_BW(WEIGHT_BW),
        .FIFO_DEPTH(FIFO_DEPTH),
        .NUM_PE_ROWS(NUM_PE_ROWS),
        .MATRIX_SIZE(MATRIX_SIZE)
    ) uut (
        .clk(clk),
        .rstn(rstn),
        .write_enable(write_enable),
        .read_enable(read_enable),
        .data_in(data_in),
        .data_out(data_out),
        .empty(empty),
        .full(full)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        $dumpfile("../sim/waveform_WeightFIFO.vcd");
        $dumpvars(0, tb_Weight_FIFO);
        $readmemh("../sim/vector_generator/hex/weight_matrix_concat.txt", memory_data);
    end

    integer i;
    initial begin
        rstn = 0;
        write_enable = 0;
        read_enable = 0;

        #10 rstn = 1;

        for (i = 0; i < FIFO_DEPTH; i = i + 1) begin
            data_in = memory_data[i];
            write_enable = 1;
            #10;
            write_enable = 0;
            #10;
        end

        #20;

        for (i = 0; i < FIFO_DEPTH; i = i + 1) begin
            read_enable = 1;
            #10;
            $display("Read Data %0d: %h", i, data_out);
            read_enable = 0;
            #10;
        end

        #50;
        $finish;
    end

endmodule
