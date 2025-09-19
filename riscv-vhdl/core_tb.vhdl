library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity core_tb is
end entity;

architecture sim of core_tb is
    signal clk   : std_logic := '0';
    signal reset : std_logic := '1';
    signal dbg_x1   : std_logic_vector(31 downto 0);
    signal dbg_x2   : std_logic_vector(31 downto 0);
    signal dbg_x3   : std_logic_vector(31 downto 0);
    signal dbg_x4   : std_logic_vector(31 downto 0);
    signal dbg_mem0 : std_logic_vector(31 downto 0);

    -- Instantiate DUT
    component core
        port(
            clk   : in std_logic;
            reset : in std_logic;
            dbg_x1  : out std_logic_vector(31 downto 0);
            dbg_x2  : out std_logic_vector(31 downto 0);
            dbg_x3  : out std_logic_vector(31 downto 0);
            dbg_x4  : out std_logic_vector(31 downto 0);
            dbg_mem0: out std_logic_vector(31 downto 0)
        );
    end component;

begin
    -- Clock generator: 10 ns period
    clk <= not clk after 5 ns;

    -- DUT instance
    uut: core
        port map (
            clk      => clk,
            reset    => reset,
            dbg_x1   => dbg_x1,
            dbg_x2   => dbg_x2,
            dbg_x3   => dbg_x3,
            dbg_x4   => dbg_x4,
            dbg_mem0 => dbg_mem0
        );

    -- Stimulus process
    stim_proc: process
    begin
        -- Hold reset for a few cycles
        reset <= '1';
        wait for 20 ns;
        reset <= '0';

        -- Let the CPU run for some cycles
        wait for 200 ns;

        assert unsigned(dbg_x1) = 5 report "X1 mismatch" severity error;

        assert unsigned(dbg_x2) = 10 report "X2 mismatch" severity error;

        assert unsigned(dbg_x3) = 15 report "X3 mismatch" severity error;

        assert unsigned(dbg_mem0) = 15 report "MEM0 mismatch" severity error;

        assert unsigned(dbg_x4) = 15 report "X4 mismatch" severity error;

        report "All checks passed!" severity note;
        std.env.stop;
    end process;
end architecture;