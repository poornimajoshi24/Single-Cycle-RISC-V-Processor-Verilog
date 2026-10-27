// ============================================================
// instruction_memory.v
// Stores the program (machine code). Give it an address,
// it gives back the 32-bit instruction stored there.
// It is read-only: the processor never writes to it.
// ============================================================
module instruction_memory (
    input  [31:0] addr,         // byte address (comes from the PC)
    output [31:0] instr         // instruction stored at that address
);

    reg [31:0] mem [0:63];      // 64 slots, each 32 bits wide

    // Each instruction is 4 bytes, so slot number = addr / 4.
    // addr[7:2] means "bits 7 down to 2" = addr divided by 4.
    assign instr = mem[addr[7:2]];

    integer i;
    initial begin
        // Fill all slots with 0 first (0 = empty)
        for (i = 0; i < 64; i = i + 1)
            mem[i] = 32'h00000000;

        // ---------- Our test program ----------
        //   slot      machine code       PC   assembly
        mem[0]  = 32'h00c00093;  //  0  addi x1, x0, 12
        mem[1]  = 32'h00a00113;  //  4  addi x2, x0, 10
        mem[2]  = 32'h002081b3;  //  8  add  x3, x1, x2   -> 22
        mem[3]  = 32'h40208233;  // 12  sub  x4, x1, x2   -> 2
        mem[4]  = 32'h0020f2b3;  // 16  and  x5, x1, x2   -> 8
        mem[5]  = 32'h0020e333;  // 20  or   x6, x1, x2   -> 14
        mem[6]  = 32'h00302023;  // 24  sw   x3, 0(x0)    mem[0] = 22
        mem[7]  = 32'h00002383;  // 28  lw   x7, 0(x0)    x7 = 22
        mem[8]  = 32'h00718463;  // 32  beq  x3, x7, 8    equal -> jump to 40
        mem[9]  = 32'h00100413;  // 36  addi x8, x0, 1    (SKIPPED by beq)
        mem[10] = 32'h06300493;  // 40  addi x9, x0, 99
        mem[11] = 32'h00000063;  // 44  beq  x0, x0, 0    loop forever (stop)
    end

endmodule
