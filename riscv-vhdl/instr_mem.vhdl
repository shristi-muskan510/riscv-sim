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
        memory := ( 0 => x"00A00093", -- addi x1, x0, 10 (0)
                    1 => x"00C002EF", -- jal x5, +12     (4)
                    2 => x"06308093", -- addi x1, x1, 99 (8)
                    3 => x"0000016F", -- ebreak          (12)
                    4 => x"00508093", -- addi x1, x1, 5  (16)
                    5 => x"00028067", -- jalr x0, x5, 0  (20)
                    others => (others => '0')); 
begin
            instr <= rom(to_integer(unsigned(pc(9 downto 2))));
end rtl;
