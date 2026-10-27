// ============================================================
// data_memory.v
// The processor's "RAM" for variables.
// - LW reads from it (instantly, combinational)
// - SW writes into it (on the rising clock edge)
// ============================================================
module data_memory (
    input         clk,
    input         mem_write,    // 1 = store write_data at addr
    input  [31:0] addr,         // byte address (from the ALU)
    input  [31:0] write_data,   // value to store (from rs2)
    output [31:0] read_data     // value stored at addr
);

    reg [31:0] mem [0:63];      // 64 words

    integer i;
    initial begin
        for (i = 0; i < 64; i = i + 1)
            mem[i] = 32'd0;
    end

    // word number = addr / 4  (same idea as instruction memory)
    assign read_data = mem[addr[7:2]];

    always @(posedge clk) begin
        if (mem_write)
            mem[addr[7:2]] <= write_data;
    end

endmodule
