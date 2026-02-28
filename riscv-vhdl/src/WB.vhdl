library IEEE;
use IEEE.std_logic_1164.all;

entity WB is
    port(
        -- Inputs from MEM/WB pipeline register
        alu_result : in  std_logic_vector(31 downto 0);
        mem_data : in  std_logic_vector(31 downto 0);
        isLd : in  std_logic; 
        isWb_in: in  std_logic;
        rd_in : in  std_logic_vector(4 downto 0);

        -- Outputs to regfile
        wb_data : out std_logic_vector(31 downto 0);
        isWb_out : out std_logic;
        rd_out : out std_logic_vector(4 downto 0)
    );
end WB;

architecture rtl of WB is
begin

    -- Result selection mux
    process(alu_result, mem_data, isLd)
    begin
        if isLd = '1' then
            wb_data <= mem_data;
        else
            wb_data <= alu_result;
        end if;
    end process;

    -- Pass control signals forward
    isWb_out <= isWb_in;
    rd_out <= rd_in;

end rtl;