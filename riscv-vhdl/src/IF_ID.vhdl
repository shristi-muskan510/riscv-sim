library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.pipeline_pkg.all;

entity IF_ID is
    port(
        clk: in std_logic;
        reset: in std_logic;
        en: in std_logic;
        IF_ID_in: in IF_ID_type;
        IF_ID_out: out IF_ID_type
    );
end IF_ID;

architecture behavioral of IF_ID is
begin
    process(clk, reset)
    begin
        if reset = '1' then
            IF_ID_out.pc       <= (others => '0');
            IF_ID_out.pc_plus4 <= (others => '0');
            IF_ID_out.instr    <= (others => '0');
        elsif rising_edge(clk) then
            if en = '1' then
                IF_ID_out <= IF_ID_in;
            end if;
        end if;
    end process;
end behavioral;