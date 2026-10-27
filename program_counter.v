// ============================================================
// program_counter.v
// Holds the address of the instruction we are executing now.
// On every rising clock edge it loads the "next PC" value.
// If reset = 1, it goes back to address 0 (start of program).
// ============================================================
module program_counter (
    input             clk,      // clock signal
    input             reset,    // 1 = restart from address 0
    input      [31:0] pc_next,  // address of the next instruction
    output reg [31:0] pc        // address of the current instruction
);

    always @(posedge clk) begin
        if (reset)
            pc <= 32'd0;        // start of program
        else
            pc <= pc_next;      // move to the next instruction
    end

endmodule
