library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.pipeline_pkg.all;

entity ID_EX is
    port(
        clk: in std_logic;
        reset: in std_logic;
        ID_EX_in: in ID_EX_type;
        ID_EX_out: out ID_EX_type
    );
end ID_EX;

architecture behavioral of ID_EX is
begin
    process(clk, reset)
    begin
        if reset = '1' then
            ID_EX_out.op1 <= (others => '0');
            ID_EX_out.op2 <= (others => '0');
            ID_EX_out.imm <= (others => '0');
            ID_EX_out.rd <= (others => '0');
            ID_EX_out.pc <= (others => '0'); 
            ID_EX_out.pc_plus4 <=  (others => '0');
            ID_EX_out.isWb <=  '0';
            ID_EX_out.isLd <= '0'; 
            ID_EX_out.isSt <= '0'; 
            ID_EX_out.isImm <= '0'; 
            ID_EX_out.ra <= '0';
            ID_EX_out.alu_s <= (others => '0'); 
            ID_EX_out.isBranch <= '0'; 
            ID_EX_out.instr    <= (others => '0');
        elsif rising_edge(clk) then
            ID_EX_out <= ID_EX_in;
        end if;
    end process;
end behavioral;