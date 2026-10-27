// ============================================================
// control_unit.v
// The "brain". Looks at the instruction and decides what every
// other part of the processor should do for this instruction.
//
// Inputs come straight from the instruction bits:
//   opcode (bits 6:0)  -> what TYPE of instruction
//   funct3 (bits 14:12)-> which operation inside that type
//   funct7_5 (bit 30)  -> tells ADD (0) apart from SUB (1)
// ============================================================
module control_unit (
    input      [6:0] opcode,
    input      [2:0] funct3,
    input            funct7_5,
    output reg       reg_write,   // 1 = write a result into rd
    output reg       alu_src,     // 0 = ALU uses rs2, 1 = ALU uses immediate
    output reg       mem_write,   // 1 = store into data memory (SW)
    output reg       mem_to_reg,  // 0 = write ALU result, 1 = write memory data (LW)
    output reg       branch,      // 1 = this is a BEQ instruction
    output reg [2:0] alu_ctrl     // which operation the ALU should do
);

    always @(*) begin
        // Default values: "do nothing". Every case below
        // only changes the signals it needs.
        reg_write  = 0;
        alu_src    = 0;
        mem_write  = 0;
        mem_to_reg = 0;
        branch     = 0;
        alu_ctrl   = 3'b000;

        case (opcode)

            7'b0110011: begin              // R-type: ADD, SUB, AND, OR
                reg_write = 1;
                alu_src   = 0;             // second operand is rs2
                case (funct3)
                    3'b000: alu_ctrl = (funct7_5 == 1) ? 3'b001 : 3'b000; // SUB : ADD
                    3'b111: alu_ctrl = 3'b010;  // AND
                    3'b110: alu_ctrl = 3'b011;  // OR
                    default: alu_ctrl = 3'b000;
                endcase
            end

            7'b0010011: begin              // ADDI
                reg_write = 1;
                alu_src   = 1;             // second operand is the immediate
                alu_ctrl  = 3'b000;        // add
            end

            7'b0000011: begin              // LW
                reg_write  = 1;
                alu_src    = 1;            // address = rs1 + immediate
                mem_to_reg = 1;            // write the value read from memory
                alu_ctrl   = 3'b000;       // add
            end

            7'b0100011: begin              // SW
                alu_src   = 1;             // address = rs1 + immediate
                mem_write = 1;             // write rs2 into memory
                alu_ctrl  = 3'b000;        // add
            end

            7'b1100011: begin              // BEQ
                branch   = 1;
                alu_src  = 0;              // compare rs1 with rs2
                alu_ctrl = 3'b001;         // subtract: zero = 1 if equal
            end

        endcase
    end

endmodule
