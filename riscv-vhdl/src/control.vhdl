library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity control is
    port(opcode: in std_logic_vector(6 downto 0);
         func3: in std_logic_vector(2 downto 0);
         func7: in std_logic_vector(6 downto 0);
         isWb: out std_logic;   -- Register writeback
         isLd: out std_logic;   -- Load
         isSt: out std_logic;   -- Store
         isImm: out std_logic;  -- is Immediate being used
         ra: out std_logic;     -- for return address
         alu_s: out std_logic_vector(3 downto 0);   -- signal for alu operations
         isBranch: out std_logic);
end control;

architecture rtl of control is
begin
    process(opcode, func3, func7)
    begin
        isWb <= '0';
        isLd <= '0';
        isSt <= '0';
        isImm <= '0';
        alu_s <= "1111";
        isBranch <= '0';
        isUJ <= '0';
        isLUI <= '0';
        isAUIPC <= '0';
        ra <= '0';

        case opcode is
            when "0110011" => -- R Format
            isWb <= '1';
            isImm <= '0';
            case func3 is
                when "000" =>
                    if func7 = "0000000" then 
                        alu_s <= "0000";
                    else 
                        alu_s <= "0001";
                    end if;
                when "001" => alu_s <= "0010";
                when "010" => alu_s <= "0011";
                when "011" => alu_s <= "0100";
                when "100" => alu_s <= "0101";
                when "101" => 
                    if func7 = "0000000" then
                        alu_s <= "0110";
                    else
                        alu_s <= "0111";
                    end if;
                when "110" => alu_s <= "1000";
                when "111" => alu_s <= "1001";
                when others => alu_s <= "1111";
            end case;

            when "0010011" => -- I Format
            isWb <= '1';
            isImm <= '1';
            case func3 is
                when "000" => alu_s <= "0000";
                when "001" => alu_s <= "0010";
                when "010" => alu_s <= "0011";
                when "011" => alu_s <= "0100";
                when "100" => alu_s <= "0101";
                when "101" => 
                    if func7 = "0000000" then
                        alu_s <= "0110";
                    else
                        alu_s <= "0111";
                    end if;
                when "110" => alu_s <= "1000";
                when "111" => alu_s <= "1001";
                when others => alu_s <= "1111";
            end case;

            when "0000011" => -- (Load)
            isWb <= '1';
            isLd <= '1';
            isImm <= '1';
            alu_s <= "0000";

            when "0100011" => -- S Format
            isSt <= '1';
            isImm <= '1';
            alu_s <= "0000";

            when "0110111" => -- U Format (LUI)
            alu_s <= "1010";
            isWb <= '1';

            when "0010111" => -- (AUIPC)
            isWb  <= '1';
            alu_s <= "1011";

            when "1100011" => -- SB Format
            isBranch <= '1';
            isImm <= '0';
            case func3 is
                when "000" => alu_s <= "0000"; --BEQ
                when "001" => alu_s <= "0001"; --BNE
                when "100" => alu_s <= "0010"; --BLT
                when "101" => alu_s <= "0011"; --BGE
                when "110" => alu_s <= "0100"; --BLTU
                when "111" => alu_s <= "0101"; --BGEU
                when others => alu_s <= "1111";
            end case;

            when "1101111" => -- UJ Format (JAL)
            alu_s <= "1100";
            isWb <= '1';

            when "1100111" => -- (JALR)
            isImm <= '1';
            isWb <= '1';
            ra <= '1';
            alu_s <= "0000";

            when others => -- Anything else = NOP
                isWb <= '0';
                isImm <= '0';
                isSt  <= '0';
                isLd <= '0';
                alu_s  <= "1111";
        end case; 
    end process;

end rtl;
