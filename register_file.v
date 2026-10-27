// ============================================================
// register_file.v
// 32 registers (x0 ... x31), each 32 bits.
// - Two READ ports  : read rs1 and rs2 at the same time (instant)
// - One WRITE port  : write rd on the rising clock edge
// - x0 is always 0 in RISC-V
// ============================================================
module register_file (
    input         clk,
    input         reg_write,    // 1 = write the result into rd
    input  [4:0]  rs1,          // number of 1st source register
    input  [4:0]  rs2,          // number of 2nd source register
    input  [4:0]  rd,           // number of destination register
    input  [31:0] write_data,   // value to write into rd
    output [31:0] read_data1,   // value of register rs1
    output [31:0] read_data2    // value of register rs2
);

    reg [31:0] regs [0:31];     // the 32 registers

    // Start every register at 0
    integer i;
    initial begin
        for (i = 0; i < 32; i = i + 1)
            regs[i] = 32'd0;
    end

    // Reading: happens immediately (combinational).
    // If someone asks for x0, always give 0.
    assign read_data1 = (rs1 == 5'd0) ? 32'd0 : regs[rs1];
    assign read_data2 = (rs2 == 5'd0) ? 32'd0 : regs[rs2];

    // Writing: happens only on the rising clock edge.
    // Never write into x0.
    always @(posedge clk) begin
        if (reg_write && rd != 5'd0)
            regs[rd] <= write_data;
    end

endmodule
