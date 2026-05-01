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
        memory := ( 0 => x"00000093", -- li x1, 0         (Load immediate 0 into x1)
                    1 => x"0000A103", -- lw x2, 0(x1)      (Load address 0 -> x2 should become 10)
                    2 => x"002081B3", -- add x3, x1, x2    (STALL + FORWARD: x3 should become 10)
                    3 => x"0040A203", -- lw x4, 4(x1)      (Load address 4 -> x4 should become 20)
                    4 => x"004182B3", -- add x5, x3, x4    (STALL + FORWARD: x5 should become 30)
                    5 => x"0080A303", -- lw x6, 8(x1)      (Load address 8 -> x6 should become 2)
                    6 => x"033303B3", -- add x7, x6, x6    (STALL + FORWARD: x7 should become 4)
                    others => x"00000013"); -- Fill rest with NOPs);
begin
            instr <= rom(to_integer(unsigned(pc(9 downto 2))));
end rtl;
