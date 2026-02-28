library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity EX is
    port(op1: in std_logic_vector(31 downto 0);
         op2: in std_logic_vector(31 downto 0);
         imm: in std_logic_vector(31 downto 0);
         pc_curr: in std_logic_vector(31 downto 0);
         pc_plus4: in std_logic_vector(31 downto 0);
         is_imm: in std_logic;
         isBranch: in std_logic;
         alu_s: in std_logic_vector(3 downto 0);
         alu_result: out std_logic_vector(31 downto 0);
         isBranchTaken: out std_logic;
         pc_branch: out std_logic_vector(31 downto 0));
end EX;

architecture rtl of EX is
    begin
        process(op1, op2, alu_s, imm, is_imm, isBranch)
        variable res : signed(31 downto 0);
        variable a_mux: signed(31 downto 0);
        begin

            res := (others => '0');
            isBranchTaken <= '0';

            if is_imm = '1' then
                a_mux := signed(imm);
            else
                a_mux := signed(op2);
            end if;

            case isBranch is
                when '0' =>
                case alu_s is
                    when "0000" => res := signed(op1) + (a_mux); -- ADD/ADDI/(EMA for load store)
                    when "0001" => res := signed(op1) - (a_mux); -- SUB
                    when "0010" => res := shift_left(signed(op1), to_integer(unsigned(a_mux(4 downto 0)))); -- SLL/SLLI
                    when "0011" => -- SLT/SLTI
                        if signed(op1) < signed(a_mux) then
                            res := (others => '0');
                            res(0) := '1';
                        else 
                            res := (others => '0');
                        end if;
                    when "0100"=> -- SLTU/SLTIU
                        if unsigned(op1) < unsigned(a_mux) then
                            res := (others => '0');
                            res(0) := '1';
                        else 
                            res := (others => '0');
                        end if;
                    when "0101" => res := signed(op1) xor (a_mux); -- XOR/XORI
                    when "0110" => res := signed( shift_right(unsigned(op1), to_integer(unsigned(a_mux(4 downto 0)))) ); -- SRL/SRLI
                    when "0111" => res := shift_right(signed(op1), to_integer(unsigned(a_mux(4 downto 0)))); -- SRA/SRAI
                    when "1000" => res := signed(op1) or (a_mux); -- OR/ORI
                    when "1001" => res := signed(op1) and (a_mux); -- AND/ANDI
                    when "1010" => res := signed(a_mux); -- LUI
                    when "1011" => res := signed(pc_curr) + signed(a_mux); -- AUIPC
                    when "1100" => 
                        res := signed(pc_plus4); -- JAL
                        isBranchTaken <= '1';
                    when others => res := (others => '0');
                end case;

                -- ============== BRANCH INSTRUCTIONS =============== -- 
                when '1' =>
                case alu_s is
                    when "0000" =>  -- BEQ
                    if signed(op1) = signed(a_mux) then
                        isBranchTaken <= '1';
                    end if;

                when "0001" =>  -- BNE
                    if signed(op1) /= signed(a_mux) then
                        isBranchTaken <= '1';
                    end if;

                when "0010" =>  -- BLT
                    if signed(op1) < signed(a_mux) then
                        isBranchTaken <= '1';
                    end if;

                when "0011" =>  -- BGE
                    if signed(op1) >= signed(a_mux) then
                        isBranchTaken <= '1';
                    end if;

                when "0100" =>  -- BLTU
                    if unsigned(op1) < unsigned(a_mux) then
                        isBranchTaken <= '1';
                    end if;

                when "0101" =>  -- BGEU
                    if unsigned(op1) >= unsigned(a_mux) then
                        isBranchTaken <= '1';
                    end if;

                when others =>
                    isBranchTaken <= '0';
                end case;    

            end case;
            alu_result <= std_logic_vector(res);
            pc_branch <= std_logic_vector(signed(pc_curr) + signed(imm));
        end process;
end rtl;