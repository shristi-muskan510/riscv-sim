-- =============================================================================
--  instr_mem_tb.vhdl   -- Standalone ROM Unit Testbench
--  Tests every active slot (0-63) of instr_mem against known-good values.
--  Sections covered:
--    [A] slots  0- 9  Baseline ALU
--    [B] slots 10-15  RAW Chains
--    [C] slots 16-21  Load-Use
--    [D] slots 22-28  Branch-Heavy
--    [E] slots 29-36  Mixed Loop
--    [F] slots 37-44  Memory Bandwidth
--    [G] slots 45-59  NOP Sled
--    [H] slots 60-63  Halt JAL
--    [Z] slot  100    NOP (others-clause boundary check)
-- =============================================================================
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity instr_mem_tb is
end entity instr_mem_tb;

architecture sim of instr_mem_tb is

    signal pc    : std_logic_vector(31 downto 0) := (others => '0');
    signal instr : std_logic_vector(31 downto 0);

    -- Mirror of the ROM
    type rom_t is array (0 to 255) of std_logic_vector(31 downto 0);
    constant EXP : rom_t := (
        -- [A] Baseline ALU
         0 => x"00A00293",
         1 => x"01400313",
         2 => x"01E00393",
         3 => x"00628433",
         4 => x"405383B3",
         5 => x"00947533",
         6 => x"009465B3",
         7 => x"00B54633",
         8 => x"006292B3",
         9 => x"0053D333",
        -- [B] RAW Chains
        10 => x"00100293",
        11 => x"00528333",
        12 => x"005303B3",
        13 => x"00638433",
        14 => x"007403B3",
        15 => x"00848533",
        -- [C] Load-Use
        16 => x"00012283",
        17 => x"00028333",
        18 => x"00412383",
        19 => x"40638433",
        20 => x"00812483",
        21 => x"00847533",
        -- [D] Branch-Heavy
        22 => x"00000293",
        23 => x"00400313",
        24 => x"00628863",
        25 => x"00128293",
        26 => x"006283B3",
        27 => x"FF5FF06F",
        28 => x"00000013",
        -- [E] Mixed Loop
        29 => x"00000293",
        30 => x"00400313",
        31 => x"00000393",
        32 => x"00028403",
        33 => x"008383B3",
        34 => x"00428293",
        35 => x"FFF30313",
        36 => x"FE031CE3",
        -- [F] Memory Bandwidth
        37 => x"00512023",
        38 => x"00612223",
        39 => x"00712423",
        40 => x"00012503",
        41 => x"00412583",
        42 => x"00812603",
        43 => x"00B50533",
        44 => x"00C50533",
        -- [G] NOP Sled
        45 => x"00000013",  46 => x"00000013",  47 => x"00000013",
        48 => x"00000013",  49 => x"00000013",  50 => x"00000013",
        51 => x"00000013",  52 => x"00000013",  53 => x"00000013",
        54 => x"00000013",  55 => x"00000013",  56 => x"00000013",
        57 => x"00000013",  58 => x"00000013",  59 => x"00000013",
        -- [H] Halt
        60 => x"0000006F",  61 => x"0000006F",
        62 => x"0000006F",  63 => x"0000006F",
        others => x"00000013"
    );

    function make_pc(slot : integer) return std_logic_vector is
    begin
        return std_logic_vector(to_unsigned(slot * 4, 32));
    end function;

begin

    DUT: entity work.instr_mem
        port map (pc => pc, instr => instr);

    stim: process
        variable l      : line;
        variable pass   : boolean;
        variable total  : integer := 0;
        variable passed : integer := 0;
        variable failed : integer := 0;

        -- print one test row (sec_tag avoids 'label' reserved word)
        procedure check_slot(slot : integer; sec_tag : string) is
        begin
            pc <= make_pc(slot);
            wait for 10 ns;
            pass  := (instr = EXP(slot));
            total := total + 1;
            if pass then passed := passed + 1;
            else         failed := failed + 1;
            end if;
            write(l, string'("  ["));
            write(l, sec_tag);
            write(l, string'("] slot="));
            write(l, slot);
            write(l, string'(" PC=0x"));
            write(l, to_hstring(make_pc(slot)));
            write(l, string'("  got=0x"));
            write(l, to_hstring(instr));
            write(l, string'("  exp=0x"));
            write(l, to_hstring(EXP(slot)));
            if pass then write(l, string'("  PASS"));
            else         write(l, string'("  FAIL *** MISMATCH ***"));
            end if;
            writeline(output, l);
        end procedure;

        procedure print_sep(s : string) is
        begin
            write(l, string'(""));             writeline(output, l);
            write(l, string'("  --- ") & s);  writeline(output, l);
        end procedure;

    begin
        write(l, string'(""));
        writeline(output, l);
        write(l, string'("================================================================"));
        writeline(output, l);
        write(l, string'("  INSTR_MEM STANDALONE ROM UNIT TESTBENCH"));
        writeline(output, l);
        write(l, string'("  Checks all 64 active slots + 1 boundary slot"));
        writeline(output, l);
        write(l, string'("================================================================"));
        writeline(output, l);

        -- [A]
        print_sep("[A] BASELINE ALU  (slots 0-9)");
        for s in 0 to 9 loop check_slot(s, "A"); end loop;

        -- [B]
        print_sep("[B] RAW CHAINS    (slots 10-15)");
        for s in 10 to 15 loop check_slot(s, "B"); end loop;

        -- [C]
        print_sep("[C] LOAD-USE      (slots 16-21)");
        for s in 16 to 21 loop check_slot(s, "C"); end loop;

        -- [D]
        print_sep("[D] BRANCH-HEAVY  (slots 22-28)");
        for s in 22 to 28 loop check_slot(s, "D"); end loop;

        -- [E]
        print_sep("[E] MIXED LOOP    (slots 29-36)");
        for s in 29 to 36 loop check_slot(s, "E"); end loop;

        -- [F]
        print_sep("[F] MEM BANDWIDTH (slots 37-44)");
        for s in 37 to 44 loop check_slot(s, "F"); end loop;

        -- [G]
        print_sep("[G] NOP SLED      (slots 45-59)");
        for s in 45 to 59 loop check_slot(s, "G"); end loop;

        -- [H]
        print_sep("[H] HALT JAL      (slots 60-63)");
        for s in 60 to 63 loop check_slot(s, "H"); end loop;

        -- [Z] others-clause boundary
        print_sep("[Z] BOUNDARY      (slot 100 = others=>NOP)");
        check_slot(100, "Z");

        -- Summary
        write(l, string'(""));
        writeline(output, l);
        write(l, string'("================================================================"));
        writeline(output, l);
        write(l, string'("  INSTR_MEM TEST SUMMARY"));
        writeline(output, l);
        write(l, string'("  Total Tested : ")); write(l, total);   writeline(output, l);
        write(l, string'("  Passed       : ")); write(l, passed);  writeline(output, l);
        write(l, string'("  Failed       : ")); write(l, failed);  writeline(output, l);
        if failed = 0 then
            write(l, string'("  Result        : ALL PASS"));
        else
            write(l, string'("  Result        : FAILURES DETECTED"));
        end if;
        writeline(output, l);
        write(l, string'("================================================================"));
        writeline(output, l);

        std.env.stop;
    end process;

end architecture sim;
