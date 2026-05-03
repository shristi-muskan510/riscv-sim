library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity instr_mem is
    port(pc: in std_logic_vector(31 downto 0);
         instr: out std_logic_vector(31 downto 0)
    );
end instr_mem;

architecture rtl of instr_mem is
    type memory is array (0 to 255) of std_logic_vector(31 downto 0);
    signal rom:  -- Some sample instructions
        memory := (
        --   [A] Baseline ALU  (IPC ceiling — no hazards)
        --   [B] RAW chains    (data hazard stress — stalls vs forwarding)
        --   [C] Load-use      (hardest 1-cycle stall even with forwarding)
        --   [D] Branch-heavy  (control hazard — flush penalty)
        --   [E] Mixed loop    (realistic CPI — all hazard types together)
        --   [F] Memory access (memory bottleneck / bandwidth)
        --   [G] NOP sled      (pipeline drain — total exec time baseline)
        -- =============================================================================


        -- =====================================================================
        -- [A] BASELINE ALU — independent instructions, no hazards
        --     Ideal CPI=1 on pipelined. Compare non-pipe vs pipe IPC directly.
        -- =====================================================================

        -- 0: ADDI x5, x0, 10       # t0 = 10
        0  => x"00A00293",
        -- 1: ADDI x6, x0, 20       # t1 = 20
        1  => x"01400313",
        -- 2: ADDI x7, x0, 30       # t2 = 30
        2  => x"01E00393",
        -- 3: ADD  x8, x5, x6       # s0 = t0 + t1   (no RAW: x5/x6 ready)
        3  => x"00628433",
        -- 4: SUB  x9, x7, x5       # s1 = t2 - t0   (no RAW: x7/x5 ready)
        4  => x"405383B3",
        -- 5: AND  x10, x8, x9      # a0 = s0 & s1   (no RAW: x8/x9 ready)
        5  => x"00947533",
        -- 6: OR   x11, x8, x9      # a1 = s0 | s1
        6  => x"009465B3",
        -- 7: XOR  x12, x10, x11    # a2 = a0 ^ a1
        7  => x"00B54633",
        -- 8: SLL  x5, x5, x6       # t0 = t0 << t1  (shift stress)
        8  => x"006292B3",
        -- 9: SRL  x6, x7, x5       # t1 = t2 >> t0
        9  => x"0053D333",

        -- =====================================================================
        -- [B] RAW CHAINS — back-to-back dependent instructions
        --     Non-pipe : normal execution
        --     Pipe no-fwd : stalls 2 cycles per chain  → CPI >> 1
        --     Pipe + fwd  : forward resolves most      → CPI ~1
        -- =====================================================================

        -- 10: ADDI x5,  x0,  1     # t0 = 1   (chain root)
        10 => x"00100293",
        -- 11: ADD  x6,  x5,  x5    # t1 = t0+t0  RAW on x5 (1-apart)
        11 => x"00528333",
        -- 12: ADD  x7,  x6,  x5    # t2 = t1+t0  RAW on x6 (1-apart)
        12 => x"005303B3",
        -- 13: ADD  x8,  x7,  x6    # s0 = t2+t1  RAW on x7 (1-apart)
        13 => x"00638433",
        -- 14: ADD  x9,  x8,  x7    # s1 = s0+t2  RAW on x8 (1-apart)
        14 => x"007403B3",   -- note: intentional tight chain
        -- 15: ADD  x10, x9,  x8    # a0 = s1+s0  RAW on x9 (1-apart)
        15 => x"00848533",

        -- =====================================================================
        -- [C] LOAD-USE — LW immediately followed by dependent instruction
        --     This causes a mandatory 1-cycle bubble even with full forwarding.
        --     Best metric: compare stall count non-pipe vs pipelined.
        -- =====================================================================

        -- 16: LW   x5,  0(x2)      # t0 = mem[sp+0]
        16 => x"00012283",
        -- 17: ADD  x6,  x5,  x0    # t1 = t0   ← load-use hazard on x5
        17 => x"00028333",
        -- 18: LW   x7,  4(x2)      # t2 = mem[sp+4]
        18 => x"00412383",
        -- 19: SUB  x8,  x7,  x6    # s0 = t2-t1  ← load-use hazard on x7
        19 => x"40638433",
        -- 20: LW   x9,  8(x2)      # s1 = mem[sp+8]
        20 => x"00812483",
        -- 21: AND  x10, x9,  x8    # a0 = s1&s0  ← load-use hazard on x9
        21 => x"00847533",

        -- =====================================================================
        -- [D] BRANCH-HEAVY — stress control hazard / flush penalty
        --     Non-pipe : branch resolves in decode, no penalty
        --     Pipelined: 1-3 cycle flush depending on resolve stage
        --     Use taken vs not-taken mix to measure branch penalty realistically
        -- =====================================================================

        -- 22: ADDI x5, x0, 0       # t0 = 0  (loop counter)
        22 => x"00000293",
        -- 23: ADDI x6, x0, 4       # t1 = 4  (loop limit)
        23 => x"00400313",
        -- 24: BEQ  x5, x6, +16     # if t0==t1 skip to [28]  ← BRANCH TAKEN eventually
        --    imm=16: offset in bytes → +4 instructions ahead
        --    B-encoding: imm=0x10 → 000000 | 00110 | 00101 | 000 | 1000 | 0 | 1100011
        24 => x"00628863",
        -- 25: ADDI x5, x5, 1       # t0++
        25 => x"00128293",
        -- 26: ADD  x7, x5, x6      # t2 = t0+t1  (work inside loop)
        26 => x"006283B3",
        -- 27: JAL  x0, -12         # jump back to [24]  ← BACKWARD BRANCH
        --    imm=-12: JAL encoding imm=0xFFFFFF4 trimmed to 20-bit signed
        --    JAL x0: rd=x0 so return addr discarded (unconditional loop)
        27 => x"FF5FF06F",
        -- 28: NOP (ADDI x0,x0,0)   # branch target — pipeline re-fill point
        28 => x"00000013",

        -- =====================================================================
        -- [E] MIXED REALISTIC LOOP — all hazards, simulates real workload CPI
        --     Loop: accumulate sum of array in memory (classic benchmark kernel)
        --     x5=base_addr  x6=loop_count  x7=accumulator  x8=temp
        -- =====================================================================

        -- 29: ADDI x5,  x0,  0     # base = 0 (array starts at addr 0)
        29 => x"00000293",
        -- 30: ADDI x6,  x0,  4     # count = 4 iterations
        30 => x"00400313",
        -- 31: ADDI x7,  x0,  0     # acc = 0
        31 => x"00000393",
        -- 32: LW   x8,  0(x5)      # x8 = mem[base]        ← load
        32 => x"00028403",
        -- 33: ADD  x7,  x7,  x8    # acc += x8             ← load-use RAW
        33 => x"008383B3",
        -- 34: ADDI x5,  x5,  4     # base += 4             ← no hazard
        34 => x"00428293",
        -- 35: ADDI x6,  x6,  -1    # count--               ← no hazard
        35 => x"FFF30313",
        -- 36: BNE  x6,  x0,  -16   # if count!=0 goto [32] ← control hazard
        --    imm=-16: BNE backward branch
        36 => x"FE031CE3",

        -- =====================================================================
        -- [F] MEMORY BANDWIDTH — alternating loads/stores, stress data memory
        --     Measures whether memory latency creates pipeline bubbles
        -- =====================================================================

        -- 37: SW   x5,  0(x2)      # mem[sp+0]  = t0
        37 => x"00512023",
        -- 38: SW   x6,  4(x2)      # mem[sp+4]  = t1
        38 => x"00612223",
        -- 39: SW   x7,  8(x2)      # mem[sp+8]  = t2
        39 => x"00712423",
        -- 40: LW   x10, 0(x2)      # a0 = mem[sp+0]
        40 => x"00012503",
        -- 41: LW   x11, 4(x2)      # a1 = mem[sp+4]
        41 => x"00412583",
        -- 42: LW   x12, 8(x2)      # a2 = mem[sp+8]
        42 => x"00812603",
        -- 43: ADD  x10, x10, x11   # a0 = a0+a1  (use loaded values)
        43 => x"00B50533",
        -- 44: ADD  x10, x10, x12   # a0 = a0+a2
        44 => x"00C50533",

        -- =====================================================================
        -- [G] NOP SLED — pipeline drain / total exec time baseline
        --     Run this alone to get clean cycle-count for N instructions.
        --     CPI should → 1.0 on pipelined. Any deviation = pipeline overhead.
        -- =====================================================================

        -- 45-59: 15× NOP
        45 => x"00000013",
        46 => x"00000013",
        47 => x"00000013",
        48 => x"00000013",
        49 => x"00000013",
        50 => x"00000013",
        51 => x"00000013",
        52 => x"00000013",
        53 => x"00000013",
        54 => x"00000013",
        55 => x"00000013",
        56 => x"00000013",
        57 => x"00000013",
        58 => x"00000013",
        59 => x"00000013",

        -- 60-63: Halt loop (JAL x0, 0 — spin in place)
        60 => x"0000006F",
        61 => x"0000006F",
        62 => x"0000006F",
        63 => x"0000006F",
        others => x"00000013"
    );
begin
            instr <= rom(to_integer(unsigned(pc(9 downto 2))));
end rtl;
