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
        memory := ( 0 => x"00500093", -- addi x1, x0, 5 (0)
                    1 => x"00500113", -- addi x2, x0, 5 (4)
                    2 => x"00208463", -- beq x1, x2, +8 (8)
                    3 => x"002081B3", -- add x3, x1, x2 (12)
                    4 => x"00208233", -- add x4, x1, x2 (16)
                    5 => x"00402023", -- sw x4, 0(x0) (20)
                    others => (others => '0')); 
begin
            instr <= rom(to_integer(unsigned(pc(9 downto 2))));
end rtl;
