module CTRL_random_gen #(
    parameter WEIGHT_BW = 8,
    parameter NUM_PE_ROWS = 8,
    parameter MATRIX_SIZE = 8
) (
    input wire clk,          // Clock signal
    input wire reset,        // Reset signal
    output reg [WEIGHT_BW*NUM_PE_ROWS*MATRIX_SIZE -1:0] random_out // 512-bit random output
);

    // Internal LFSR state (64-bit for simplicity, can expand if needed)
    reg [63:0] lfsr;

    // Feedback polynomial (primitive polynomial for maximal length)
    wire feedback = lfsr[63] ^ lfsr[62] ^ lfsr[60] ^ lfsr[59];

    // Random generation process
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            lfsr <= 64'hACE1; // Initial seed value (non-zero)
            random_out <= 512'b0;
        end else begin
            // Update LFSR
            lfsr <= {lfsr[62:0], feedback};
            // Generate new 512-bit random value
            random_out <= {random_out[447:0], lfsr}; // Shift in new 64 bits
        end
    end

endmodule
