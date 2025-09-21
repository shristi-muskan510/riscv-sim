library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity control is
    port(opcode: in std_logic_vector(6 downto 0);
         func3: in std_logic_vector(2 downto 0);
         func7: in std_logic_vector(6 downto 0);
         isWb: out std_logic;
         isLd: out std_logic;
         isSt: out std_logic;
         isImm: out std_logic;
         isSB: out std_logic;
         isU: out std_logic;
         alu_s: out std_logic_vector(3 downto 0);
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
        isSB <= '0';

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

            when "0000011" =>
            isWb <= '1';
            isLd <= '1';
            isImm <= '1';
            alu_s <= "0000";

            when "0100011" => -- S Format
            isSt <= '1';
            isImm <= '1';
            alu_s <= "0000";

            when "0110111" => -- U Format (LUI)
            isU <= '1';
            isWb <= '1';

            when "0010111" => -- (AUIPC)
            isWb  <= '1';
            isImm <= '1';
            alu_s <= "0000";

            when "1100011" => -- SB Format
            isBranch <= '1';
            isImm <= '0';

            when "1101111" => -- UJ Format (JAL)
            isSB <= '1';
            isWb <= '1';

            when others =>      -- Anything else = NOP
                isWb <= '0';
                isImm <= '0';
                isSt  <= '0';
                isLd <= '0';
                alu_s  <= "1111";
        end case; 
    end process;
end rtl;