library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity data_mem is
    port(clk: in std_logic;
         address: in std_logic_vector(31 downto 0);
         we: in std_logic;
         wd: in std_logic_vector(31 downto 0);
         rd: out std_logic_vector(31 downto 0);
         --
         dbg_mem0 : out std_logic_vector(31 downto 0));
end data_mem;

architecture rtl of  data_mem is
    type ram_t is array (0 to 255) of std_logic_vector(31 downto 0);
    signal ram: ram_t := (others => (others => '0'));
begin
    -- write
    process(clk)
    begin
        if rising_edge(clk) then
            if  we = '1' then
                ram(to_integer(unsigned(address(9 downto 2)))) <= wd;
            end if;
        end if;
    end process;

    -- read
            rd <= ram(to_integer(unsigned(address(9 downto 2))));

    -- Debug tap
    dbg_mem0 <= ram(0);
end rtl;