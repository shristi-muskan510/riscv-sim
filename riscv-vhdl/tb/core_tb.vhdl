library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity core_tb is
end entity;

architecture sim of core_tb is
    -- Clock and reset
    signal clk   : std_logic := '0';
    signal reset : std_logic := '1';
    signal pc_curr : std_logic_vector(31 downto 0);
begin

    -- Clock generator: 10 ns period
    clk <= not clk after 5 ns;

    -- Instantiate instruction memory
    instr_mem_inst: entity work.instr_mem
        port map (
            clk => clk,
            pc  => pc_curr
        );

    -- Instantiate your core
    uut: entity work.core
        port map (
            clk      => clk,
            reset    => reset,
            dbg_x1   => dbg_x1,
            dbg_x2   => dbg_x2,
            dbg_x3   => dbg_x3,
            dbg_x4   => dbg_x4,
            dbg_x5    => dbg_x5
        );

    -- Stimulus process
    stim_proc: process
    begin
        -- Apply reset
        reset <= '1';
        wait for 20 ns;
        reset <= '0';

        -- Let CPU run for enough cycles
        wait for 100 ns;

        -- Assertions
        assert unsigned(dbg_x1) = 114 report "X1 mismatch" severity error;
        assert unsigned(dbg_x2) = 16 report "X2 mismatch" severity error;
        assert unsigned(dbg_x3) = 0 report "Branch jumped" severity error;
        assert unsigned(dbg_x4) = 0 report "X4 mismatch" severity error;
        assert unsigned(dbg_x5) = 8 report "X5 mismatch" severity error;

        report "All checks passed!" severity note;
        std.env.stop;
    end process;

    pc_monitor: process
begin
    wait until rising_edge(clk);
    wait for 1 ns;
            report 
                   " | x1 = " & integer'image(to_integer(unsigned(dbg_x1))) &
                   " | x2 = " & integer'image(to_integer(unsigned(dbg_x2))) &
                   " | x3 = " & integer'image(to_integer(unsigned(dbg_x3))) &
                   " | x4 = " & integer'image(to_integer(unsigned(dbg_x4))) &
                   " | x5 = " & integer'image(to_integer(unsigned(dbg_x5)));
    end process;

end architecture;