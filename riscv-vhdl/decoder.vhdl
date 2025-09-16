library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity decoder is
    port(instr: in std_logic_vector(31 downto 0);
         opcode  : out std_logic_vector(6 downto 0);
         rd      : out std_logic_vector(4 downto 0);
         rs1     : out std_logic_vector(4 downto 0);
         rs2     : out std_logic_vector(4 downto 0);
         func3  : out std_logic_vector(2 downto 0);
         func7  : out std_logic_vector(6 downto 0);
         imm     : out std_logic_vector(31 downto 0));
end decoder;

architecture rtl of decoder is
begin
    -- Extract possible combinations
    opcode <= instr(6 downto 0);
    rd <= instr(11 downto 7);
    func3 <= instr(14 downto 12);
    rs1 <= instr(19 downto 15);
    rs2 <= instr(24 downto 20);
    func7 <= instr(31 downto 25);

    -- Extract and Calculate immediate
    process(instr)
    begin
        case instr(6 downto 0) is
            -- I-type
            when "0010011" | "0000011" =>
                imm <= std_logic_vector(resize(signed(instr(31 downto 20)), 32));

            -- S-type
            when "0100011" =>
                imm <= std_logic_vector(resize(
                        signed(instr(31 downto 25) & instr(11 downto 7)), 32));

            -- SB-type
            when "1100011" =>
                imm <= std_logic_vector(resize(
                        signed(instr(31) & instr(7) & instr(30 downto 25) & instr(11 downto 8) & "0"), 32));

            -- U-type
            when "0110111" | "0010111" =>
                imm <= instr(31 downto 12) & (11 downto 0 => '0');

            -- UJ-type
            when "1101111" =>
                imm <= std_logic_vector(resize(
                        signed(instr(31) & instr(19 downto 12) & instr(20) & instr(30 downto 21) & "0"), 32));

            when others =>
                imm <= (others => '0');
        end case;
    end process;
end rtl;