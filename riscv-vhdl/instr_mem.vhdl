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
        memory := ( 0 => x"00500093", -- addi x1, x0, 5  (0)
                    1 => x"0080016F", -- jal x2, +8      (4)
                    2 => x"00A08093", -- addi x1, x1, 10 (8)
                    3 => x"01408093", -- addi x1, x1, 20 (12)
                    4 => x"000001EF", -- jal x3, +0      (16)
                    others => (others => '0')); 
begin
            instr <= rom(to_integer(unsigned(pc(9 downto 2))));
end rtl;
