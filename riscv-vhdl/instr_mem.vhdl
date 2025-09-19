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
        memory := ( 0 => x"00500093", -- addi x1, x0, 5
                    1 => x"00A00113", -- addi x2, x0, 10
                    2 => x"002081B3", -- add x3, x1, x2
                    3 => x"00302023", -- sw x3, 0(x0)
                    4 => x"00002203",
                    others => (others => '0')); -- lw x4, 0(x0)
begin
    process(clk)
    begin
        if rising_edge(clk) then
            instr <= rom(to_integer(unsigned(pc(9 downto 2))));
        end if;
    end process;
end rtl;
