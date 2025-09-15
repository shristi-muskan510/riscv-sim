library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity instr_mem is
    port(clk: in std_logic;
         pc: in std_logic_vector(31 downto 0);
         instr: out std_logic_vector(31 downto 0)
    );
end instr_mem;

architecture rtl of instr_mem is
    type memory is array (0 to 255) of std_logic_vector(31 downto 0);
    signal rom:  -- Some sample instructions
        memory := ( 0 => x"00000013",
                    1 => x"00100093", 
                    2 => x"00200113", 
                    3 => x"00308193",
                    4 => x"00418213");
begin
    process(clk)
    begin
        if rising_edge(clk) then
            instr <= rom(to_integer(unsigned(pc(9 downto 2))));
        end if;
    end process;
end rtl;
