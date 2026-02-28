library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

type MEM_WB_type is record 
    alu_result: std_logic_vector(31 downto 0);
    rd: std_logic_vector(4 downto 0);
    mem_data: std_logic_vector(31 downto 0);

    isWb: std_logic;   -- Register writeback
    isLd: std_logic;   -- Load
    ra: std_logic;     -- for return address
end record;

entity MEM_WB is
    port(
        clk: in std_logic;
        reset: in std_logic;
        MEM_WB_in: in MEM_WB_type;
        MEM_WB_out: out MEM_WB_type
    );
end MEM_WB;

architecture behavioral of MEM_WB is
    signal MEM_WB_reg : MEM_WB_type;
begin
    process(clk, reset)
    begin
        if reset = '1' then
            MEM_WB_reg <= (others => '0');
        elsif rising_edge(clk) then
            MEM_WB_reg <= MEM_WB_in;
        end if;
    end process;

    MEM_WB_out <= MEM_WB_reg;
end behavioral;