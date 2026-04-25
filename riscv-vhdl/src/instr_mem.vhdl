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
        memory := ( 0 => x"00A00093", -- addi x1, x0, 10 (0)  (Initial Write to x1)
                    1 => x"00100113", -- addi x2, x0, 1  (4)  (Base address for load)
                    2 => x"00112183", -- lw   x3, 1(x2)  (8)  (LOAD instruction - writes to x3)
                    3 => x"00308233", -- add  x4, x1, x3 (12) (LOAD-USE + RAW HAZARD)
                    4 => x"004002B3", -- add  x5, x0, x4 (16) (RAW HAZARD - forwarding only)
                    others => x"00000013"); -- Fill rest with NOPs);
begin
            instr <= rom(to_integer(unsigned(pc(9 downto 2))));
end rtl;
