library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.pipeline_pkg.all;

entity EX_MEM is
    port(
        clk: in std_logic;
        reset: in std_logic;
        EX_MEM_in: in EX_MEM_type;
        EX_MEM_out: out EX_MEM_type
    );
end EX_MEM;

architecture behavioral of EX_MEM is
begin
    process(clk, reset)
    begin
        if reset = '1' then
            EX_MEM_out.alu_result <= (others => '0');
            EX_MEM_out.rd <= (others => '0');
            EX_MEM_out.op2 <= (others => '0');
            EX_MEM_out.pc <= (others => '0');
            EX_MEM_out.pc_plus4 <= (others => '0');
            EX_MEM_out.isWb <= '0';
            EX_MEM_out.isLd <= '0';
            EX_MEM_out.isSt <= '0';
            EX_MEM_out.ra <= '0';
            EX_MEM_out.isBranch <= '0';
            EX_MEM_out.instr    <= (others => '0');
        elsif rising_edge(clk) then
            EX_MEM_out <= EX_MEM_in;
        end if;
    end process;
end behavioral;