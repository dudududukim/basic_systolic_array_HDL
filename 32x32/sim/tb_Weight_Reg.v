`timescale 1ns / 1ps

module tb_weight_reg;
    parameter WEIGHT_BW = 8;

    reg clk;
    reg rstn;
    reg we_rl;
    reg signed [WEIGHT_BW-1:0] W;

    wire signed [WEIGHT_BW-1:0] weight;

    weight_reg #(
        .WEIGHT_BW(WEIGHT_BW)
    ) uut (
        .clk(clk),
        .rstn(rstn),
        .we_rl(we_rl),
        .W(W),
        .weight(weight)
    );

    initial begin
        clk = 1;
        forever #5 clk = ~clk;
    end

    initial begin
        rstn = 0;
        we_rl = 0;
        W = 0;

        #10 rstn = 1;
        #10 rstn = 0;
        #10 rstn = 1;

        #10 we_rl = 0;
        W = 8'h10;
        #10;

        $display("Time: %0dns, we_rl=0, W=%d, weight=%d", $time, W, weight);

        #10 we_rl = 1;
        W = 8'h20;
        #10;

        $display("Time: %0dns, we_rl=1, W=%d, weight=%d", $time, W, weight);

        #10 we_rl = 0;
        W = 8'h30;
        #10;

        $display("Time: %0dns, we_rl=0, W=%d, weight=%d", $time, W, weight);

        #10 rstn = 0;
        #10;

        $display("Time: %0dns, rstn=0, weight=%d", $time, weight);
        
        #10 $finish;
    end

    initial begin
        $dumpfile("../sim/waveform_WeightReg.vcd");
        $dumpvars(0, tb_weight_reg);
    end
endmodule
