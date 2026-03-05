library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.pipeline_pkg.all;

entity MEM_WB is
    port(
        clk: in std_logic;
        reset: in std_logic;
        MEM_WB_in: in MEM_WB_type;
        MEM_WB_out: out MEM_WB_type
    );
end MEM_WB;

architecture behavioral of MEM_WB is
begin
    process(clk, reset)
    begin
        if reset = '1' then
            MEM_WB_out.alu_result <= (others => '0');
            MEM_WB_out.rd <= (others => '0');
            MEM_WB_out.mem_data <= (others => '0');
            MEM_WB_out.pc <= (others => '0');
            MEM_WB_out.pc_plus4 <= (others => '0');
            MEM_WB_out.isWb <= '0';
            MEM_WB_out.isLd <= '0';
            MEM_WB_out.ra <= '0';
        elsif rising_edge(clk) then
            MEM_WB_out <= MEM_WB_in;
        end if;
    end process;

end behavioral;