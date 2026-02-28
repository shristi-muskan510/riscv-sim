library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

type EX_MEM_type is record 
    alu_result: std_logic_vector(31 downto 0);
    rd: std_logic_vector(4 downto 0);
    op2: std_logic_vector(31 downto 0);
    pc: std_logic_vector(31 downto 0);

    isWb: std_logic;   -- Register writeback
    isLd: std_logic;   -- Load
    isSt: std_logic;   -- Store
    ra: std_logic;     -- for return address
    isBranch: std_logic;
end record;

entity EX_MEM is
    port(
        clk: in std_logic;
        reset: in std_logic;
        EX_MEM_in: in EX_MEM_type;
        EX_MEM_out: out EX_MEM_type
    );
end EX_MEM;

architecture behavioral of EX_MEM is
    signal EX_MEM_reg : EX_MEM_type;
begin
    process(clk, reset)
    begin
        if reset = '1' then
            EX_MEM_reg <= (others => '0');
        elsif rising_edge(clk) then
            EX_MEM_reg <= EX_MEM_in;
        end if;
    end process;

    EX_MEM_out <= EX_MEM_reg;
end behavioral;