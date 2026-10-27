// ============================================================
// riscv_cpu.v  (TOP MODULE)
// Connects all the parts with wires to make the full processor.
// The three multiplexers (MUX) are written here directly using
// the "? :" operator, so we don't need a separate mux module.
// ============================================================
module riscv_cpu (
    input clk,
    input reset
);

    // ---------------- Wires (connections) ----------------
    wire [31:0] pc, pc_next, pc_plus4, pc_branch;
    wire [31:0] instr;
    wire [31:0] read_data1, read_data2, imm;
    wire [31:0] alu_b, alu_result, mem_data, write_back;
    wire        zero;

    // control signals
    wire       reg_write, alu_src, mem_write, mem_to_reg, branch;
    wire [2:0] alu_ctrl;

    // ---------------- 1. FETCH ----------------
    program_counter pc_reg (
        .clk(clk), .reset(reset), .pc_next(pc_next), .pc(pc)
    );

    instruction_memory imem (
        .addr(pc), .instr(instr)
    );

    // ---------------- 2. DECODE ----------------
    // Split the instruction into its fields and send them out.
    control_unit cu (
        .opcode(instr[6:0]),
        .funct3(instr[14:12]),
        .funct7_5(instr[30]),
        .reg_write(reg_write),
        .alu_src(alu_src),
        .mem_write(mem_write),
        .mem_to_reg(mem_to_reg),
        .branch(branch),
        .alu_ctrl(alu_ctrl)
    );

    register_file rf (
        .clk(clk),
        .reg_write(reg_write),
        .rs1(instr[19:15]),
        .rs2(instr[24:20]),
        .rd(instr[11:7]),
        .write_data(write_back),
        .read_data1(read_data1),
        .read_data2(read_data2)
    );

    imm_gen ig (
        .instr(instr), .imm(imm)
    );

    // ---------------- 3. EXECUTE ----------------
    // MUX 1: ALU's second input = rs2 value OR immediate
    assign alu_b = (alu_src == 1) ? imm : read_data2;

    alu alu_unit (
        .a(read_data1), .b(alu_b), .alu_ctrl(alu_ctrl),
        .result(alu_result), .zero(zero)
    );

    // ---------------- 4. MEMORY ----------------
    data_memory dmem (
        .clk(clk),
        .mem_write(mem_write),
        .addr(alu_result),
        .write_data(read_data2),
        .read_data(mem_data)
    );

    // ---------------- 5. WRITE BACK ----------------
    // MUX 2: value written into rd = ALU result OR memory data
    assign write_back = (mem_to_reg == 1) ? mem_data : alu_result;

    // ---------------- 6. NEXT PC ----------------
    assign pc_plus4  = pc + 32'd4;        // normal: next instruction
    assign pc_branch = pc + imm;          // BEQ target

    // MUX 3: jump only if it is a BEQ AND the two registers were equal
    assign pc_next = (branch && zero) ? pc_branch : pc_plus4;

endmodule
