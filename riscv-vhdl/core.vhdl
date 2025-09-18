library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity core is
    port(clk   : in std_logic;
         reset : in std_logic
    );
end entity core;

architecture rtl of core is
    -- PC 
    signal pc_next: std_logic_vector(31 downto 0);
    signal pc_curr: std_logic_vector(31 downto 0);

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
    signal isImm, isBranch, isWb, isLd, isSt: std_logic;
    signal alu_s: std_logic_vector(3 downto 0);

    -- ALU
    signal alu_result: std_logic_vector(31 downto 0);
    signal isBranchTaken: std_logic;

    -- Data memory
    signal data_mem_out: std_logic_vector(31 downto 0);

    -- MUX signals
    signal a_mux: std_logic_vector(31 downto 0);
    signal result_mux: std_logic_vector(31 downto 0);
    signal pc_plus4: std_logic_vector(31 downto 0);
    signal pc_branch: std_logic_vector(31 downto 0);

begin

    -- MUX Logics
    a_mux <= imm when isImm = '1' else rd2;
    result_mux <= data_mem_out when isLd = '1' else alu_result;
    pc_plus4  <= std_logic_vector(unsigned(pc_curr) + 4);
    pc_branch <= std_logic_vector(unsigned(pc_curr) + unsigned(imm));
    pc_next <= pc_branch when (isBranch = '1' and isBranchTaken = '1') else pc_plus4;

    pc_inst: entity work.pc
        port map (
            clk => clk,
            reset => reset,
            pc_next => pc_next,
            pc_curr => pc_curr
        );

    imem_inst: entity work.instr_mem
        port map (
            clk => clk,
            pc => pc_curr,
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

    register_inst: entity work.register
        port map (
            clk => clk,
            we => isWb,
            rs1 => rs1,
            rs2 => rs2,
            rd => rd,
            wd => result_mux,
            rd1 => rd1,
            rd2 => rd2,
        );

    alu_inst: entity work.alu
        port map (
            op1 => rd1,
            op2 => a_mux,
            alu_s => alu_s,
            alu_result => alu_result,
            isBranchTaken => isBranchTaken
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
            alu_s => alu_s,
            isBranch => isBranch
        );

    dmem_inst: entity work.data_mem
        port map(
            clk => clk, 
            address => result_mux,
            we => isSt,
            wd => rd2,
            rd => data_mem_out
        );

end rtl;