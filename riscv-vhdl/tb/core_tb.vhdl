-- =============================================================================
--  core_tb.vhdl  -- Full-Pipeline Testbench (ALL Sections A-G)
--  Single-process design: no multiple-driver conflicts.
--  Metrics: Cycles, Instrs, Stall, Flush, CPI, IPC + register dump per section.
-- =============================================================================
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use work.pipeline_pkg.all;

entity core_tb is
end entity core_tb;

architecture sim of core_tb is

    signal clk      : std_logic := '0';
    signal reset    : std_logic := '1';

    signal pc_if, pc_id, pc_ex, pc_mem, pc_wb : std_logic_vector(31 downto 0);
    signal wb_instr : std_logic_vector(31 downto 0);
    signal wb_valid : std_logic;

    signal dbg_x1  : std_logic_vector(31 downto 0);
    signal dbg_x2  : std_logic_vector(31 downto 0);
    signal dbg_x3  : std_logic_vector(31 downto 0);
    signal dbg_x4  : std_logic_vector(31 downto 0);
    signal dbg_x5  : std_logic_vector(31 downto 0);
    signal dbg_x6  : std_logic_vector(31 downto 0);
    signal dbg_x7  : std_logic_vector(31 downto 0);
    signal dbg_x8  : std_logic_vector(31 downto 0);
    signal dbg_x9  : std_logic_vector(31 downto 0);
    signal dbg_x10 : std_logic_vector(31 downto 0);

    -- Flush NOP token inserted by core.vhdl on branch flush
    constant PIPE_NOP : std_logic_vector(31 downto 0) := x"00100013";

    -- Section boundary byte-addresses (slot * 4)
    constant PC_B    : integer := 10 * 4;
    constant PC_C    : integer := 16 * 4;
    constant PC_D    : integer := 22 * 4;
    constant PC_E    : integer := 29 * 4;
    constant PC_F    : integer := 37 * 4;
    constant PC_G    : integer := 45 * 4;
    constant PC_HALT : integer := 60 * 4;

    constant TRACE_ON : boolean := true;

begin

    uut: entity work.core
        port map (
            clk      => clk,    reset    => reset,
            if_pc    => pc_if,  id_pc    => pc_id,
            ex_pc    => pc_ex,  mem_pc   => pc_mem,  wb_pc => pc_wb,
            wb_instr => wb_instr, wb_valid => wb_valid,
            dbg_x1   => dbg_x1,  dbg_x2  => dbg_x2,
            dbg_x3   => dbg_x3,  dbg_x4  => dbg_x4,
            dbg_x5   => dbg_x5,  dbg_x6  => dbg_x6,
            dbg_x7   => dbg_x7,  dbg_x8  => dbg_x8,
            dbg_x9   => dbg_x9,  dbg_x10 => dbg_x10
        );

    clk <= not clk after 5 ns;

    -- =========================================================================
    --  Single main process (no sensitivity list -> wait is legal everywhere)
    -- =========================================================================
    main: process
        variable l : line;

        -- Per-section accumulators
        variable s_cyc, s_ins, s_sta, s_flu : integer;
        -- Grand-total accumulators
        variable g_cyc, g_ins, g_sta, g_flu : integer;
        -- Previous IF-PC for stall detection
        variable pc_prev : std_logic_vector(31 downto 0);
        -- Previous WB-PC for retirement detection
        variable pc_wb_prev : std_logic_vector(31 downto 0) := x"FFFFFFFF";
        -- Global cycle counter for trace
        variable cyc_cnt : integer;
        -- Halt flag
        variable hv : boolean;

        -- ------------------------------------------------------------------
        -- Accumulate one rising-edge cycle into section + grand variables.
        -- ------------------------------------------------------------------
        procedure accum(
            variable sc : inout integer; variable si : inout integer;
            variable ss : inout integer; variable sf : inout integer;
            variable gc : inout integer; variable gi : inout integer;
            variable gs : inout integer; variable gf : inout integer;
            variable pp : inout std_logic_vector(31 downto 0);
            variable cc : inout integer;
            variable retired : out boolean
        ) is
            variable flu : boolean;
            variable stl : boolean;
            variable is_b_type : boolean;
            variable is_valid_instr : boolean;
        begin
            flu := (wb_instr = PIPE_NOP);
            stl := (not is_x(pc_if)) and (pc_if = pp) and (not flu);
            
            is_b_type := (wb_instr(6 downto 0) = "1100011");
            is_valid_instr := (wb_valid = '1') or is_b_type;

            -- Detect instruction retirement: PC changes, it's valid, and not a flush bubble
            retired := false;
            if (not is_x(pc_wb)) and (pc_wb /= pc_wb_prev) and 
               is_valid_instr and (wb_instr /= PIPE_NOP) and (wb_instr /= x"00000000") then
                retired := true;
            end if;

            sc := sc + 1;  gc := gc + 1;  cc := cc + 1;
            if retired then 
                si := si + 1; 
                gi := gi + 1; 
                pc_wb_prev := pc_wb;
            end if;
            if stl then ss := ss + 1; gs := gs + 1; end if;
            if flu then sf := sf + 1; gf := gf + 1; end if;
            
            pp := pc_if;

            if TRACE_ON then
                write(l, string'("  CLK ")); write(l, cc);
                write(l, string'(" | IF="));
                if is_x(pc_if) then write(l, string'("X"));
                else write(l, to_integer(unsigned(pc_if))); end if;
                write(l, string'("  WBp="));
                if is_x(pc_wb) then write(l, string'("X"));
                else write(l, to_integer(unsigned(pc_wb))); end if;
                write(l, string'("  WBi=0x")); write(l, to_hstring(wb_instr));
                if retired then write(l, string'("  [RET]")); end if;
                if stl then write(l, string'("  [STALL]")); end if;
                if flu then write(l, string'("  [FLUSH]")); end if;
                writeline(output, l);
            end if;
        end procedure;

        -- ------------------------------------------------------------------
        -- Run until WB-PC matches the target (the LAST instruction of the section)
        -- ------------------------------------------------------------------
        procedure run_to(
            target_wb_pc : integer;
            variable sc : inout integer; variable si : inout integer;
            variable ss : inout integer; variable sf : inout integer;
            variable gc : inout integer; variable gi : inout integer;
            variable gs : inout integer; variable gf : inout integer;
            variable pp : inout std_logic_vector(31 downto 0);
            variable cc : inout integer;
            variable h  : inout boolean
        ) is
            variable ret : boolean;
            variable is_b_type : boolean;
            variable is_valid_instr : boolean;
        begin
            loop
                if not is_x(pc_if) and
                   to_integer(unsigned(pc_if)) = PC_HALT then
                    h := true;
                end if;
                
                is_b_type := (wb_instr(6 downto 0) = "1100011");
                is_valid_instr := (wb_valid = '1') or is_b_type;

                exit when h;
                
                -- Exit when the FIRST instruction of the next section is in WB and valid.
                -- By exiting BEFORE accum, this exact cycle is handed off to the next section!
                exit when (not is_x(pc_wb)) and
                          (to_integer(unsigned(pc_wb)) = target_wb_pc) and
                          is_valid_instr and (wb_instr /= PIPE_NOP);
                          
                accum(sc,si,ss,sf, gc,gi,gs,gf, pp, cc, ret);
                
                wait until rising_edge(clk);
            end loop;
        end procedure;

        -- ------------------------------------------------------------------
        -- Print one section's metrics box
        -- ------------------------------------------------------------------
        procedure print_sec(
            sec_name   : string;
            slot_range : string;
            cyc : integer; ins : integer;
            sta : integer; flu : integer
        ) is
        begin
            write(l, string'("")); writeline(output, l);
            write(l, string'("  +--------------------------------------------+")); writeline(output, l);
            write(l, string'("  | ") & sec_name & string'("  slots ") & slot_range); writeline(output, l);
            write(l, string'("  +--------------------------------------------+")); writeline(output, l);
            write(l, string'("  | Cycles           : ")); write(l, cyc); writeline(output, l);
            write(l, string'("  | Instrs Committed : ")); write(l, ins); writeline(output, l);
            if ins > 0 then
                write(l, string'("  | CPI              : "));
                write(l, real(cyc) / real(ins)); writeline(output, l);
                write(l, string'("  | IPC              : "));
                write(l, real(ins) / real(cyc)); writeline(output, l);
            else
                write(l, string'("  | CPI/IPC          : N/A")); writeline(output, l);
            end if;
            write(l, string'("  | Stall Cycles     : ")); write(l, sta); writeline(output, l);
            write(l, string'("  | Flush Slots      : ")); write(l, flu); writeline(output, l);
            write(l, string'("  +--------------------------------------------+")); writeline(output, l);
        end procedure;

        -- ------------------------------------------------------------------
        -- Print register snapshot
        -- ------------------------------------------------------------------
        procedure print_regs is
        begin
            write(l, string'("  Regs (dec): x0=0"));
            write(l, string'(" x1=")); write(l, to_integer(signed(dbg_x1)));
            write(l, string'(" x2=")); write(l, to_integer(signed(dbg_x2)));
            write(l, string'(" x3=")); write(l, to_integer(signed(dbg_x3)));
            write(l, string'(" x4=")); write(l, to_integer(signed(dbg_x4)));
            writeline(output, l);
            write(l, string'("             x5="));  write(l, to_integer(signed(dbg_x5)));
            write(l, string'(" x6="));  write(l, to_integer(signed(dbg_x6)));
            write(l, string'(" x7="));  write(l, to_integer(signed(dbg_x7)));
            write(l, string'(" x8="));  write(l, to_integer(signed(dbg_x8)));
            write(l, string'(" x9="));  write(l, to_integer(signed(dbg_x9)));
            write(l, string'(" x10=")); write(l, to_integer(signed(dbg_x10)));
            writeline(output, l);
            write(l, string'("  Regs (hex):"));
            write(l, string'(" x5=0x")); write(l, to_hstring(dbg_x5));
            write(l, string'(" x6=0x")); write(l, to_hstring(dbg_x6));
            write(l, string'(" x7=0x")); write(l, to_hstring(dbg_x7));
            write(l, string'(" x8=0x")); write(l, to_hstring(dbg_x8));
            write(l, string'(" x9=0x")); write(l, to_hstring(dbg_x9));
            write(l, string'(" x10=0x")); write(l, to_hstring(dbg_x10));
            writeline(output, l);
        end procedure;

    begin
        -- Init variables
        s_cyc:=0; s_ins:=0; s_sta:=0; s_flu:=0;
        g_cyc:=0; g_ins:=0; g_sta:=0; g_flu:=0;
        pc_prev := x"FFFFFFFF";
        cyc_cnt := 0;
        hv := false;

        -- Header
        write(l, string'("")); writeline(output, l);
        write(l, string'("============================================================")); writeline(output, l);
        write(l, string'("  RISC-V 5-Stage Pipeline -- Full Benchmark Suite (A-G)")); writeline(output, l);
        write(l, string'("  Metrics per section + grand total + register dump")); writeline(output, l);
        write(l, string'("============================================================")); writeline(output, l);

        -- Reset
        reset <= '1'; wait for 20 ns; reset <= '0';

        -- ==== [A] Baseline ALU ================================================
        write(l, string'("  [A] Baseline ALU running...")); writeline(output, l);
        run_to(40, s_cyc,s_ins,s_sta,s_flu, g_cyc,g_ins,g_sta,g_flu, pc_prev, cyc_cnt, hv);
        print_sec("[A] Baseline ALU ", " 0- 9", s_cyc, s_ins, s_sta, s_flu);
        print_regs;
        s_cyc:=0; s_ins:=0; s_sta:=0; s_flu:=0;

        -- ==== [B] RAW Chains ==================================================
        write(l, string'("  [B] RAW Chains running...")); writeline(output, l);
        run_to(64, s_cyc,s_ins,s_sta,s_flu, g_cyc,g_ins,g_sta,g_flu, pc_prev, cyc_cnt, hv);
        print_sec("[B] RAW Chains   ", "10-15", s_cyc, s_ins, s_sta, s_flu);
        print_regs;
        s_cyc:=0; s_ins:=0; s_sta:=0; s_flu:=0;

        -- ==== [C] Load-Use ====================================================
        write(l, string'("  [C] Load-Use running...")); writeline(output, l);
        run_to(88, s_cyc,s_ins,s_sta,s_flu, g_cyc,g_ins,g_sta,g_flu, pc_prev, cyc_cnt, hv);
        print_sec("[C] Load-Use     ", "16-21", s_cyc, s_ins, s_sta, s_flu);
        print_regs;
        s_cyc:=0; s_ins:=0; s_sta:=0; s_flu:=0;

        -- ==== [D] Branch-Heavy ================================================
        write(l, string'("  [D] Branch-Heavy running (BEQ loop x4)...")); writeline(output, l);
        run_to(116, s_cyc,s_ins,s_sta,s_flu, g_cyc,g_ins,g_sta,g_flu, pc_prev, cyc_cnt, hv);
        print_sec("[D] Branch-Heavy ", "22-28", s_cyc, s_ins, s_sta, s_flu);
        print_regs;
        s_cyc:=0; s_ins:=0; s_sta:=0; s_flu:=0;

        -- ==== [E] Mixed Loop ==================================================
        write(l, string'("  [E] Mixed Loop running (BNE loop x4)...")); writeline(output, l);
        run_to(148, s_cyc,s_ins,s_sta,s_flu, g_cyc,g_ins,g_sta,g_flu, pc_prev, cyc_cnt, hv);
        print_sec("[E] Mixed Loop   ", "29-36", s_cyc, s_ins, s_sta, s_flu);
        print_regs;
        s_cyc:=0; s_ins:=0; s_sta:=0; s_flu:=0;

        -- ==== [F] Mem Bandwidth ===============================================
        write(l, string'("  [F] Mem Bandwidth running...")); writeline(output, l);
        run_to(180, s_cyc,s_ins,s_sta,s_flu, g_cyc,g_ins,g_sta,g_flu, pc_prev, cyc_cnt, hv);
        print_sec("[F] Mem Bandwidth", "37-44", s_cyc, s_ins, s_sta, s_flu);
        print_regs;
        s_cyc:=0; s_ins:=0; s_sta:=0; s_flu:=0;

        -- ==== [G] NOP Sled ====================================================
        write(l, string'("  [G] NOP Sled running...")); writeline(output, l);
        run_to(240, s_cyc,s_ins,s_sta,s_flu, g_cyc,g_ins,g_sta,g_flu, pc_prev, cyc_cnt, hv);
        print_sec("[G] NOP Sled     ", "45-59", s_cyc, s_ins, s_sta, s_flu);
        print_regs;

        -- ==== GRAND TOTAL =====================================================
        write(l, string'("")); writeline(output, l);
        write(l, string'("============================================================")); writeline(output, l);
        write(l, string'("  GRAND TOTAL -- All Sections A through G")); writeline(output, l);
        write(l, string'("============================================================")); writeline(output, l);
        write(l, string'("  Total Cycles           : ")); write(l, g_cyc); writeline(output, l);
        write(l, string'("  Total Instrs Committed : ")); write(l, g_ins); writeline(output, l);
        if g_ins > 0 then
            write(l, string'("  Overall CPI            : "));
            write(l, real(g_cyc) / real(g_ins)); writeline(output, l);
            write(l, string'("  Overall IPC            : "));
            write(l, real(g_ins) / real(g_cyc)); writeline(output, l);
        end if;
        write(l, string'("  Total Stall Cycles     : ")); write(l, g_sta); writeline(output, l);
        write(l, string'("  Total Flush Slots      : ")); write(l, g_flu); writeline(output, l);
        if g_cyc > 0 then
            write(l, string'("  Stall overhead %       : "));
            write(l, real(g_sta) / real(g_cyc) * 100.0); writeline(output, l);
            write(l, string'("  Flush overhead %       : "));
            write(l, real(g_flu) / real(g_cyc) * 100.0); writeline(output, l);
        end if;
        write(l, string'("------------------------------------------------------------")); writeline(output, l);
        write(l, string'("  FINAL REGISTER STATE:")); writeline(output, l);
        print_regs;
        write(l, string'("============================================================")); writeline(output, l);

        std.env.stop;
    end process main;

end architecture sim;