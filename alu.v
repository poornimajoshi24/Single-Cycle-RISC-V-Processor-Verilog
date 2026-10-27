// ============================================================
// alu.v  (Arithmetic Logic Unit)
// Does the actual calculation. The control unit tells it
// WHICH calculation to do using a 3-bit code (alu_ctrl).
//
//   alu_ctrl | operation
//   ---------+-----------
//     000    |  a + b
//     001    |  a - b
//     010    |  a & b
//     011    |  a | b
//
// zero = 1 when the result is 0 (used by BEQ to test a == b)
// ============================================================
module alu (
    input      [31:0] a,          // first number
    input      [31:0] b,          // second number
    input      [2:0]  alu_ctrl,   // which operation to do
    output reg [31:0] result,     // answer
    output            zero        // 1 if result == 0
);

    always @(*) begin
        case (alu_ctrl)
            3'b000:  result = a + b;   // ADD  (also used by ADDI, LW, SW)
            3'b001:  result = a - b;   // SUB  (also used by BEQ)
            3'b010:  result = a & b;   // AND
            3'b011:  result = a | b;   // OR
            default: result = 32'd0;
        endcase
    end

    assign zero = (result == 32'd0);

endmodule
