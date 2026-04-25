library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use work.pipeline_pkg.all;

entity core_pipeline_tb is
end entity;

architecture sim of core_pipeline_tb is
    -- Clock and Reset signals
    signal clk   : std_logic := '0';
    signal reset : std_logic := '1';
    signal cycle : integer := 0;

    -- Pipeline Stage Monitoring Signals (Mapped to Core Ports)
    signal pc_if, pc_id, pc_ex, pc_mem, pc_wb : std_logic_vector(31 downto 0);
    
    -- Debug register outputs
    signal dbg_x1, dbg_x2, dbg_x3, dbg_x4, dbg_x5 : std_logic_vector(31 downto 0);

    signal wb_instr : std_logic_vector(31 downto 0);
    signal instrs_completed : integer := 0;

begin

    -- 1. Unit Under Test (UUT)
    -- We map directly to the debug ports you added to core.vhdl
    uut: entity work.core
        port map (
            clk    => clk,
            reset  => reset,
            
            wb_instr => wb_instr,

            -- Debug PC Ports (Stable connection)
            if_pc  => pc_if,
            id_pc  => pc_id,
            ex_pc  => pc_ex,
            mem_pc => pc_mem,
            wb_pc  => pc_wb,

            -- Register File Debug
            dbg_x1 => dbg_x1,
            dbg_x2 => dbg_x2,
            dbg_x3 => dbg_x3,
            dbg_x4 => dbg_x4,
            dbg_x5 => dbg_x5
        );

    -- 2. Clock Generation (100MHz / 10ns period)
    clk <= not clk after 5 ns;

    -- 3. Cycle Counter
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '0' then
                cycle <= cycle + 1;
            end if;
        end if;
    end process;

    process(clk)
    begin
        if rising_edge(clk) and reset = '0' then
            -- We ignore NOP (0x13) and uninitialized (0x0)
            if wb_instr /= x"00000013" and wb_instr /= x"00000000" then
                instrs_completed <= instrs_completed + 1;
            end if;
        end if;
    end process;

    -- 4. Stimulus Process
    stim_proc: process
    begin
        -- Hold reset to initialize all pipeline stages
        reset <= '1';
        wait for 20 ns; 
        reset <= '0';
        
        -- Run long enough to see instructions exit the 5-stage pipe
        wait for 200 ns;
        
        report "--- ARCHITECTURAL EVALUATION ---";
        report "Total Cycles: " & integer'image(cycle);
        report "Real Instructions: " & integer'image(instrs_completed);
        report "Baseline IPC: " & real'image(real(instrs_completed) / real(cycle));
        report "---------------------------------";
        std.env.stop;
    end process;

    -- 5. PIPELINE MONITOR (Terminal Output)
    -- Prints the PC at every stage to visualize the 'staircase' flow
    process
        variable l : line;
    begin
        wait until rising_edge(clk);
        wait for 1 ns; -- Wait for delta cycles to settle

        if reset = '0' then
            write(l, string'("Cycle: "));
            write(l, cycle);
            write(l, string'(" | IF: "));
            write(l, to_integer(signed(pc_if)));
            write(l, string'(" | ID: "));
            write(l, to_integer(signed(pc_id)));
            write(l, string'(" | EX: "));
            write(l, to_integer(signed(pc_ex)));
            write(l, string'(" | MEM: "));
            write(l, to_integer(signed(pc_mem)));
            write(l, string'(" | WB: "));
            write(l, to_integer(signed(pc_wb)));
            write(l, string'(" | x1: "));
            write(l, to_integer(signed(dbg_x1)));
            write(l, string'(" | x2: "));
            write(l, to_integer(signed(dbg_x2)));
            write(l, string'(" | x3: "));
            write(l, to_integer(signed(dbg_x3)));
            write(l, string'(" | x4: "));
            write(l, to_integer(signed(dbg_x4)));
            write(l, string'(" | x5: "));
            write(l, to_integer(signed(dbg_x5)));
            
            writeline(output, l);
        end if;
    end process;

end architecture;