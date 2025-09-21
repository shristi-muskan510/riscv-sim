library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity core is
    port(clk   : in std_logic;
         reset : in std_logic;
         dbg_x1 : out std_logic_vector(31 downto 0);
         dbg_x2 : out std_logic_vector(31 downto 0);
         dbg_x3 : out std_logic_vector(31 downto 0);
         dbg_x4 : out std_logic_vector(31 downto 0);
         dbg_mem0: out std_logic_vector(31 downto 0);
         dbg_pc : out std_logic_vector(31 downto 0);
         pc_next : out std_logic_vector(31 downto 0);
         pc_plus4 : out std_logic_vector(31 downto 0);
         pc_branch : out std_logic_vector(31 downto 0);
         pc_jump: out std_logic_vector(31 downto 0);
         isBranch : out std_logic;
         isBranchTaken : out std_logic
    );
end entity core;

architecture rtl of core is
    -- PC 
    -- signal pc_next: std_logic_vector(31 downto 0);
    -- signal pc_curr: std_logic_vector(31 downto 0);

    -- Instr_mem
    signal instr: std_logic_vector(31 downto 0);

    -- Decoder
    signal opcode: std_logic_vector(6 downto 0);
    signal func3: std_logic_vector(2 downto 0);
    signal func7: std_logic_vector(6 downto 0);
    signal rs1, rs2, rd: std_logic_vector(4 downto 0);
    signal imm: std_logic_vector(31 downto 0);

    -- Register file
    signal rd1, rd2: std_logic_vector(31 downto 0);

    -- Control Unit
    signal isImm, isSB, isWb, isLd, isSt: std_logic;
    signal alu_s: std_logic_vector(3 downto 0);

    -- ALU
    signal alu_result: std_logic_vector(31 downto 0);
    -- signal isBranchTaken: std_logic;

    -- Data memory
    signal data_mem_out: std_logic_vector(31 downto 0);

    -- MUX signals
    signal a_mux: std_logic_vector(31 downto 0);
    signal result_mux: std_logic_vector(31 downto 0);
    -- signal pc_plus4: std_logic_vector(31 downto 0);
    -- signal pc_branch: std_logic_vector(31 downto 0);

begin

    -- MUX Logics
    a_mux <= imm when isImm = '1' else rd2;

    pc_plus4  <= std_logic_vector(unsigned(dbg_pc) + to_unsigned(4, 32));
    pc_branch <= std_logic_vector(signed(dbg_pc) + signed(imm));
    pc_jump <= std_logic_vector(signed (dbg_pc)+ signed(imm));

    process(data_mem_out, alu_result, isLd)
    begin
        if isLd = '1' then
            result_mux <= data_mem_out;
        elsif isSB = '1' then
            result_mux <= pc_plus4;
        else
            result_mux <= alu_result;
        end if;
    end process;

    -- Combinational branch decision
    process(opcode, func3, rd1, rd2)
    begin
        isBranchTaken <= '0';  -- default

        if opcode = "1100011" then  -- SB-type (branches)
            case func3 is
                when "000" =>  -- BEQ
                    if signed(rd1) = signed(rd2) then
                        isBranchTaken <= '1';
                    end if;

                when "001" =>  -- BNE
                    if signed(rd1) /= signed(rd2) then
                        isBranchTaken <= '1';
                    end if;

                when "100" =>  -- BLT
                    if signed(rd1) < signed(rd2) then
                        isBranchTaken <= '1';
                    end if;

                when "101" =>  -- BGE
                    if signed(rd1) >= signed(rd2) then
                        isBranchTaken <= '1';
                    end if;

                when "110" =>  -- BLTU
                    if unsigned(rd1) < unsigned(rd2) then
                        isBranchTaken <= '1';
                    end if;

                when "111" =>  -- BGEU
                    if unsigned(rd1) >= unsigned(rd2) then
                        isBranchTaken <= '1';
                    end if;

                when others =>
                    isBranchTaken <= '0';
            end case;
        end if;
    end process;

    -- PC update logic
    process(pc_plus4, pc_branch, pc_jump, isBranchTaken, isSB)
    begin
        if isBranchTaken = '1' then
            pc_next <= pc_branch;
        elsif isSB = '1' then
            pc_next <= pc_jump;
        else
            pc_next <= pc_plus4;
        end if;
    end process;

    pc_inst: entity work.pc
        port map (
            clk => clk,
            reset => reset,
            pc_next => pc_next,
            pc_curr => dbg_pc
        );

    imem_inst: entity work.instr_mem
        port map (
            clk => clk,
            pc => dbg_pc,
            instr => instr
        );

    decoder_inst: entity work.decoder
        port map (
            instr => instr,
            opcode => opcode,
            rd => rd,
            rs1 => rs1,
            rs2 => rs2,
            func3 => func3,
            func7 => func7,
            imm => imm
        );

    regfile_inst: entity work.regfile
        port map (
            clk => clk,
            we => isWb,
            rs1 => rs1,
            rs2 => rs2,
            rd => rd,
            wd => result_mux,
            rd1 => rd1,
            rd2 => rd2,
            dbg_x1 => dbg_x1,
            dbg_x2 => dbg_x2,
            dbg_x3 => dbg_x3,
            dbg_x4 => dbg_x4
        );

    alu_inst: entity work.alu
        port map (
            op1 => rd1,
            op2 => a_mux,
            alu_s => alu_s,
            alu_result => alu_result
        );

    control_inst: entity work.control
        port map (
            opcode => opcode,
            func3 => func3,
            func7 => func7,
            isWb => isWb,
            isLd => isLd,
            isSt => isSt,
            isImm => isImm,
            isSB => isSB,
            alu_s => alu_s,
            isBranch => isBranch
        );

    dmem_inst: entity work.data_mem
        port map(
            clk => clk, 
            address => alu_result,
            we => isSt,
            wd => rd2,
            rd => data_mem_out,
            dbg_mem0 => dbg_mem0
        );

end rtl;