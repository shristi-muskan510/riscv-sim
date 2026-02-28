library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

type ID_EX_type is record
    op1: std_logic_vector(31 downto 0);
    op2: std_logic_vector(31 downto 0);
    imm: std_logic_vector(31 downto 0);
    rd: std_logic_vector(4 downto 0);
    pc: std_logic_vector(31 downto 0);

    isWb: std_logic;   -- Register writeback
    isLd: std_logic;   -- Load
    isSt: std_logic;   -- Store
    isImm: std_logic;  -- is Immediate being used
    ra: std_logic;     -- for return address
    alu_s: std_logic_vector(3 downto 0);   -- signal for alu operations
    isBranch: std_logic;
end record;

entity ID_EX is
    port(
        clk: in std_logic;
        reset: in std_logic;
        ID_EX_in: in ID_EX_type;
        ID_EX_out: out ID_EX_out
    );
end ID_EX;

architecture behavioral of ID_EX is
    signal ID_EX_reg : ID_EX_type;
begin
    process(clk, reset)
    begin
        if reset = '1' then
            ID_EX_reg <= (others => '0');
        elsif rising_edge(clk) then
            ID_EX_reg <= ID_EX_in;
        end if;
    end process;

    ID_EX_out <= ID_EX_reg;
end behavioral;