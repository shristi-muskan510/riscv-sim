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
        memory := ( 0  => x"00A00093", -- addi x1, x0, 10 (PC 0)  [x1 = 10]
                    1  => x"00000013", -- nop (4)
                    2  => x"00000013", -- nop (8)
                    3  => x"00000013", -- nop (12)
                    4  => x"00C002EF", -- jal  x5, 12 (16)       [x5 = 20, jumps to PC 28]
                    5  => x"00000013", -- nop (20)
                    6  => x"00000013", -- nop (24)
                    7  => x"00000013", -- nop (28) [Target of JAL]
                    8  => x"00508093", -- addi x1, x1, 5 (32)    [x1 = 15]
                    9  => x"00000013", -- nop (36)
                    10 => x"00000013", -- nop (40)
                    11 => x"00000013", -- nop (44)
                    12 => x"00028067", -- jalr x0, x5, 0 (48)    [jumps to PC 20]

                    others => x"00000013"); -- Fill rest with NOPs); 
begin
            instr <= rom(to_integer(unsigned(pc(9 downto 2))));
end rtl;
