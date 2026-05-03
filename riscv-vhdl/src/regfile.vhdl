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

         dbg_x1 : out std_logic_vector(31 downto 0);
         dbg_x2 : out std_logic_vector(31 downto 0);
         dbg_x3 : out std_logic_vector(31 downto 0);
         dbg_x4 : out std_logic_vector(31 downto 0);
         dbg_x5 : out std_logic_vector(31 downto 0);
         dbg_x6 : out std_logic_vector(31 downto 0);
         dbg_x7 : out std_logic_vector(31 downto 0);
         dbg_x8 : out std_logic_vector(31 downto 0);
         dbg_x9 : out std_logic_vector(31 downto 0);
         dbg_x10 : out std_logic_vector(31 downto 0)
    );
end regfile;

architecture rtl of regfile is
    type reg_array is array (0 to 31) of std_logic_vector(31 downto 0); -- array of 32 registers, each of 32 bits
    signal regs: reg_array := (others => (others => '0'));  -- set every element of every register in array to 0;

begin

    -- Write logic
    process(clk)
    begin
        if rising_edge(clk) then
            if we = '1' and rd /= "00000" then -- If write is enabled and dest_reg != 0 (x0).
                regs(to_integer(unsigned(rd))) <= wd;
            end if;
        end if;
    end process;

    -- Read logic
    -- If rs1 = rd, don't wait: just read directly 
    rd1 <= wd when (we = '1' and rs1 = rd and rs1 /= "00000") else
        regs(to_integer(unsigned(rs1)));
    
    rd2 <= wd when (we = '1' and rs2 = rd and rs2 /= "00000") else
        regs(to_integer(unsigned(rs2)));

    -- Debug taps --
    dbg_x1 <= wd when (we = '1' and rd = "00001") else regs(1);
    dbg_x2 <= wd when (we = '1' and rd = "00010") else regs(2);
    dbg_x3 <= wd when (we = '1' and rd = "00011") else regs(3);
    dbg_x4 <= wd when (we = '1' and rd = "00100") else regs(4);
    dbg_x5 <= wd when (we = '1' and rd = "00101") else regs(5);
    dbg_x6 <= wd when (we = '1' and rd = "00110") else regs(6);
    dbg_x7 <= wd when (we = '1' and rd = "00111") else regs(7);
    dbg_x8 <= wd when (we = '1' and rd = "01000") else regs(8);
    dbg_x9 <= wd when (we = '1' and rd = "01001") else regs(9);
    dbg_x10 <= wd when (we = '1' and rd = "01010") else regs(10);


end rtl;