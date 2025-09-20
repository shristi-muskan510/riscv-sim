library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pc is
    port(clk: in std_logic;
         reset: in std_logic;
         pc_next: in std_logic_vector(31 downto 0);
         pc_curr: out std_logic_vector(31 downto 0)
    );
end pc;

architecture rtl of pc is
    signal pc_reg: std_logic_vector(31 downto 0) := (others => '0');

begin
    process(clk, reset)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                pc_reg <= (others => '0');
            else
                pc_reg <= pc_next;
            end if;
        end if;
    end process;
    pc_curr <= pc_reg;
end rtl;