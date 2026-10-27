// ============================================================
// testbench.v
// NOT part of the processor. It is a "virtual lab bench":
// it gives the CPU a clock, presses reset, lets it run,
// and then checks whether the answers are correct.
// ============================================================
// Note: "#10" means "wait 10 time units". We imagine 1 unit = 1 ns.

module testbench;

    reg clk;
    reg reset;
    integer errors;

    // Put one processor on the bench
    riscv_cpu cpu (
        .clk(clk),
        .reset(reset)
    );

    // Clock: flip every 5 ns -> one full cycle every 10 ns
    initial clk = 0;
    always #5 clk = ~clk;

    // Print what happens on every clock cycle
    always @(posedge clk) begin
        if (!reset)
            $display("PC=%2d  instr=%h  x1=%0d x2=%0d x3=%0d x4=%0d x5=%0d x6=%0d x7=%0d x8=%0d x9=%0d  mem[0]=%0d",
                     cpu.pc, cpu.instr,
                     cpu.rf.regs[1], cpu.rf.regs[2], cpu.rf.regs[3],
                     cpu.rf.regs[4], cpu.rf.regs[5], cpu.rf.regs[6],
                     cpu.rf.regs[7], cpu.rf.regs[8], cpu.rf.regs[9],
                     cpu.dmem.mem[0]);
    end

    // Small helper: compare a value with what we expect
    task check;
        input [8*8-1:0] name;   // up to 8 characters of text
        input [31:0] got;
        input [31:0] expected;
        begin
            if (got == expected)
                $display("  PASS  %0s = %0d", name, got);
            else begin
                $display("  FAIL  %0s = %0d (expected %0d)", name, got, expected);
                errors = errors + 1;
            end
        end
    endtask

    initial begin
        // Save all signals so we can view waveforms in GTKWave
        $dumpfile("cpu.vcd");
        $dumpvars(0, testbench);

        errors = 0;
        reset  = 1;          // hold reset for the first cycle
        #10;
        reset  = 0;          // let the processor run

        #150;                // 15 cycles: enough for 12 instructions

        $display("");
        $display("========== FINAL CHECK ==========");
        check("x1",     cpu.rf.regs[1], 12);
        check("x2",     cpu.rf.regs[2], 10);
        check("x3",     cpu.rf.regs[3], 22);   // ADD
        check("x4",     cpu.rf.regs[4], 2);    // SUB
        check("x5",     cpu.rf.regs[5], 8);    // AND
        check("x6",     cpu.rf.regs[6], 14);   // OR
        check("mem[0]", cpu.dmem.mem[0], 22);  // SW
        check("x7",     cpu.rf.regs[7], 22);   // LW
        check("x8",     cpu.rf.regs[8], 0);    // skipped by BEQ
        check("x9",     cpu.rf.regs[9], 99);   // BEQ target ran
        check("PC",     cpu.pc, 44);           // stuck in final loop

        if (errors == 0)
            $display(">>> ALL TESTS PASSED <<<");
        else
            $display(">>> %0d TEST(S) FAILED <<<", errors);

        $finish;
    end

endmodule
