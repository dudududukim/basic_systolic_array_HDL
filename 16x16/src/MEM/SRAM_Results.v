// Unified Buffer to store internal results or data inputs
// Datapath width = 8B

module SRAM_Results
#(
    parameter ADDRESSSIZE = 10,                // temp size (a hundred 8*8byte array can be stored)
    parameter WORDSIZE    = 8 * 20
)
(
    input                     clk,          
    input                     write_enable,
    input  [ADDRESSSIZE-1:0]  address,      
    input  [WORDSIZE-1:0]     data_in,      
    output reg [WORDSIZE-1:0] data_out      
);

    (* ram_style = "block" *) reg [WORDSIZE-1:0] mem_array [0:(1 << ADDRESSSIZE)-1];

    always @(posedge clk) begin
        if (write_enable) begin
            mem_array[address] <= data_in;  
        end else begin
            data_out <= mem_array[address];
        end
    end

endmodule
