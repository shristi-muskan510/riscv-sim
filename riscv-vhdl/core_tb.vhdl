library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity core_tb is
end entity;

architecture sim of core_tb is
    -- Clock and reset
    signal clk   : std_logic := '0';
    signal reset : std_logic := '1';

    -- Debug outputs from core
    signal dbg_x1   : std_logic_vector(31 downto 0);
    signal dbg_x2   : std_logic_vector(31 downto 0);
    signal dbg_x3   : std_logic_vector(31 downto 0);
    signal dbg_x4   : std_logic_vector(31 downto 0);
    signal dbg_mem0 : std_logic_vector(31 downto 0);
    signal dbg_pc   : std_logic_vector(31 downto 0);

    -- Core internal signals for diagnostics
    signal pc_curr : std_logic_vector(31 downto 0);
    signal pc_next   : std_logic_vector(31 downto 0);
    signal pc_plus4  : std_logic_vector(31 downto 0);
    signal pc_branch : std_logic_vector(31 downto 0);
    signal isBranch  : std_logic;
    signal isBranchTaken : std_logic;
begin

    -- Clock generator: 10 ns period
    clk <= not clk after 5 ns;

    -- Instantiate instruction memory
    instr_mem_inst: entity work.instr_mem
        port map (
            clk => clk,
            pc  => dbg_pc
        );

    -- Instantiate your core
    uut: entity work.core
        port map (
            clk      => clk,
            reset    => reset,
            dbg_x1   => dbg_x1,
            dbg_x2   => dbg_x2,
            dbg_x3   => dbg_x3,
            dbg_x4    => dbg_x4,
            dbg_mem0 => dbg_mem0,
            dbg_pc   => dbg_pc,
            -- Optional: internal diagnostic signals, if core exposes them
            pc_next => pc_next,
            pc_plus4 => pc_plus4,
            pc_branch => pc_branch,
            isBranch => isBranch,
            isBranchTaken => isBranchTaken
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
        assert unsigned(dbg_x1) = 25 report "X1 mismatch" severity error;
        assert unsigned(dbg_x2) = 8 report "X2 mismatch" severity error;
        assert unsigned(dbg_x3) = 20 report "Branch jumped" severity error;
        assert unsigned(dbg_x4) = 0 report "X4 mismatch" severity error;
        assert unsigned(dbg_mem0) = 0 report "MEM0 mismatch" severity error;

        report "All checks passed!" severity note;
        std.env.stop;
    end process;

    -- PC and branch monitoring process
    pc_monitor: process
begin
    wait until rising_edge(clk);
    wait for 1 ns;
            report "PC debug: pc_curr = " & integer'image(to_integer(unsigned(dbg_pc))) &
       " | pc_plus4 = " & integer'image(to_integer(unsigned(pc_plus4))) &
       " | pc_branch = " & integer'image(to_integer(unsigned(pc_branch))) &
       " | pc_next = " & integer'image(to_integer(unsigned(pc_next))) &
       " | isBranch = " & std_logic'image(isBranch) &
       " | isBranchTaken = " & std_logic'image(isBranchTaken)  &
                   " | x1 = " & integer'image(to_integer(unsigned(dbg_x1))) &
                   " | x2 = " & integer'image(to_integer(unsigned(dbg_x2))) &
                   " | x3 = " & integer'image(to_integer(unsigned(dbg_x3))) &
                   " | x4 = " & integer'image(to_integer(unsigned(dbg_x4))) &
                   " | mem[0] = " & integer'image(to_integer(unsigned(dbg_mem0)));
    end process;

end architecture;