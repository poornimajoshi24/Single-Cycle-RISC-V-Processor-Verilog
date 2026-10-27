// ============================================================
// imm_gen.v  (Immediate Generator)
// Some instructions carry a constant number inside them
// (e.g. the 12 in "addi x1, x0, 12"). Different instruction
// types store this number in different bit positions.
// This module collects those bits and makes a 32-bit number.
//
// {20{instr[31]}} means "copy bit 31 twenty times". This is
// called SIGN EXTENSION: it keeps negative numbers negative.
// ============================================================
module imm_gen (
    input      [31:0] instr,
    output reg [31:0] imm
);

    always @(*) begin
        case (instr[6:0])   // look at the opcode

            // I-type (ADDI, LW): immediate is in bits 31:20
            7'b0010011,
            7'b0000011: imm = {{20{instr[31]}}, instr[31:20]};

            // S-type (SW): immediate is split into bits 31:25 and 11:7
            7'b0100011: imm = {{20{instr[31]}}, instr[31:25], instr[11:7]};

            // B-type (BEQ): bits are scattered; last bit is always 0
            // because branch targets are always even addresses
            7'b1100011: imm = {{19{instr[31]}}, instr[31], instr[7],
                               instr[30:25], instr[11:8], 1'b0};

            default:    imm = 32'd0;   // R-type has no immediate
        endcase
    end

endmodule
