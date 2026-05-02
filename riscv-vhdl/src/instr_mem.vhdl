library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity instr_mem is
    port(pc: in std_logic_vector(31 downto 0);
         instr: out std_logic_vector(31 downto 0)
    );
end instr_mem;

architecture rtl of instr_mem is
    type memory is array (0 to 255) of std_logic_vector(31 downto 0);
    signal rom:  -- Some sample instructions
        memory := ( 0 => x"00500093", -- x1 = 5
                    1 => x"00500113", -- x2 = 5
                    2 => x"00208463", -- branch taken (PC+8)
                    3 => x"00A00193",
                    4 => x"01400213", 
                    5 => x"00100293", -- x5 = 1
                    others => x"00000013"); -- Fill rest with NOPs);
begin
            instr <= rom(to_integer(unsigned(pc(9 downto 2))));
end rtl;
