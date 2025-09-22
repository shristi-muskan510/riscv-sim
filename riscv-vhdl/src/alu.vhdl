library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity alu is
    port(op1: in std_logic_vector(31 downto 0);
         op2: in std_logic_vector(31 downto 0);
         alu_s: in std_logic_vector(3 downto 0);
         alu_result: out std_logic_vector(31 downto 0));
end alu;

architecture rtl of alu is
    begin
        process(op1, op2, alu_s)
        variable res : signed(31 downto 0);
        variable zero: std_logic;
        begin
            res := (others => '0');
            case alu_s is
                when "0000" => res := signed(op1) + signed(op2); -- ADD/ADDI/(EMA for load store)/(Return address for JAL)
                when "0001" => res := signed(op1) - signed(op2); -- SUB
                when "0010" => res := shift_left(signed(op1), to_integer(unsigned(op2(4 downto 0)))); -- SLL/SLLI
                when "0011" => -- SLT/SLTI
                    if signed(op1) < signed(op2) then
                        res := (others => '0');
                        res(0) := '1';
                    else 
                        res := (others => '0');
                    end if;
                when "0100"=> -- SLTU/SLTIU
                    if unsigned(op1) < unsigned(op2) then
                        res := (others => '0');
                        res(0) := '1';
                    else 
                        res := (others => '0');
                    end if;
                when "0101" => res := signed(op1) xor signed(op2); -- XOR/XORI
                when "0110" => res := signed( shift_right(unsigned(op1), to_integer(unsigned(op2(4 downto 0)))) ); -- SRL/SRLI
                when "0111" => res := shift_right(signed(op1), to_integer(unsigned(op2(4 downto 0)))); -- SRA/SRAI
                when "1000" => res := signed(op1) or signed(op2); -- OR/ORI
                when "1001" => res := signed(op1) and signed(op2); -- AND/ANDI
                when others => res := (others => '0');
            end case;

            alu_result <= std_logic_vector(res);
        end process;
end rtl;