library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity IF_ID is
    port(
        clk: in std_logic;
        reset: in std_logic;
        pc_in: in std_logic_vector(31 downto 0);
        instr_in: in std_logic_vector(31 downto 0);

        pc_out: out std_logic_vector(31 downto 0);
        instr_out: out std_logic_vector(31 downto 0)
    );
end IF_ID;

architecture behavioral of IF_ID is
begin
    process(clk, reset)
    begin
        if reset = '1' then
            pc_out <= (others => '0');
            instr_out <= (others => '0');
        elsif rising_edge(clk) then
            pc_out <= pc_in;
            instr_out <= instr_in;
        end if;
    end process;
end behavioral;