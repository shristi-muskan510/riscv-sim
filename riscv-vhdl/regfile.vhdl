library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity regfile is
    port(clk: in std_logic;
         we: in std_logic;
         rs1: in std_logic_vector(4 downto 0);
         rs2: in std_logic_vector(4 downto 0);
         rd: in std_logic_vector(4 downto 0);
         wd: in std_logic_vector(31 downto 0);
         rd1: out std_logic_vector(31 downto 0);
         rd2: out std_logic_vector(31 downto 0);
         -- 
         dbg_x1 : out std_logic_vector(31 downto 0);
         dbg_x2 : out std_logic_vector(31 downto 0);
         dbg_x3 : out std_logic_vector(31 downto 0);
         dbg_x4 : out std_logic_vector(31 downto 0)
    );
end regfile;

architecture rtl of regfile is
    type reg_array is array (0 to 31) of std_logic_vector(31 downto 0); -- array of 32 registers, each of 32 bits
    signal regs: reg_array := (others => (others => '0'));  -- set every element of every register in array to 0;

begin
    -- Read logic
        rd1 <= regs(to_integer(unsigned(rs1)));
        rd2 <= regs(to_integer(unsigned(rs2)));

    -- Write logic
    process(clk)
    begin
        if rising_edge(clk) then
            if we = '1' and rd /= "00000" then -- If write is enabled and dest_reg != 0 (x0).
                regs(to_integer(unsigned(rd))) <= wd;
            end if;
        end if;
    end process;

    -- Debug taps
    dbg_x1 <= regs(1);
    dbg_x2 <= regs(2);
    dbg_x3 <= regs(3);
    dbg_x4 <= regs(4);
end rtl;