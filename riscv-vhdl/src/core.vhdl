library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.pipeline_pkg.all;

entity core is
    port(clk   : in std_logic;
         reset : in std_logic;
         dbg_x1 : out std_logic_vector(31 downto 0);
         dbg_x2 : out std_logic_vector(31 downto 0);
         dbg_x3 : out std_logic_vector(31 downto 0);
         dbg_x4 : out std_logic_vector(31 downto 0);
         dbg_x5 : out std_logic_vector(31 downto 0);
         if_pc  : out std_logic_vector(31 downto 0);
         id_pc  : out std_logic_vector(31 downto 0);
         ex_pc  : out std_logic_vector(31 downto 0);
         mem_pc : out std_logic_vector(31 downto 0);
         wb_pc  : out std_logic_vector(31 downto 0);
         wb_instr: out std_logic_vector(31 downto 0)
    );
end entity core;

architecture rtl of core is
    -- =============== IF stage =============== --
    signal pc_next: std_logic_vector(31 downto 0);
    signal pc_curr: std_logic_vector(31 downto 0);
    signal pc_plus4: std_logic_vector(31 downto 0);

    -- Instr_mem
    signal instr: std_logic_vector(31 downto 0);

    -- =============== ID stage =============== --
    signal opcode: std_logic_vector(6 downto 0);
    signal func3: std_logic_vector(2 downto 0);
    signal func7: std_logic_vector(6 downto 0);
    signal rs1, rs2, rd: std_logic_vector(4 downto 0);
    signal imm: std_logic_vector(31 downto 0);

    -- Register file
    signal rd1, rd2: std_logic_vector(31 downto 0);

    -- Control Unit
    signal isImm, ra, isWb, isLd, isSt, isBranch: std_logic;
    signal alu_s: std_logic_vector(3 downto 0);

    -- =============== EX stage =============== --
    signal alu_result: std_logic_vector(31 downto 0);
    signal isBranchTaken: std_logic;
    signal pc_branch: std_logic_vector(31 downto 0);

    -- =============== MEM stage =============== --
    signal data_mem_out: std_logic_vector(31 downto 0);

    -- =============== WB stage =============== --
    signal wb_data: std_logic_vector(31 downto 0);

    -- ========= Pipeline registers ========= --

    signal IF_ID_in: IF_ID_type;
    signal IF_ID_out: IF_ID_type;

    signal ID_EX_in: ID_EX_type;
    signal ID_EX_out: ID_EX_type;

    signal EX_MEM_in: EX_MEM_type;
    signal EX_MEM_out: EX_MEM_type;

    signal MEM_WB_in: MEM_WB_type;
    signal MEM_WB_out: MEM_WB_type;

begin

    if_pc  <= pc_curr;
    id_pc  <= IF_ID_out.pc;
    ex_pc  <= ID_EX_out.pc;
    mem_pc <= EX_MEM_out.pc;
    wb_pc  <= MEM_WB_out.pc;

    wb_instr <= MEM_WB_out.instr;

    -- ======= Pipeline record packaging ====== --
    IF_ID_in.pc <= pc_curr;
    IF_ID_in.pc_plus4 <= pc_plus4;
    IF_ID_in.instr <= instr;

    ID_EX_in.op1 <= rd1;
    ID_EX_in.op2 <= rd2;
    ID_EX_in.imm <= imm;
    ID_EX_in.rd <= rd;
    ID_EX_in.pc <= IF_ID_out.pc;
    ID_EX_in.pc_plus4 <= IF_ID_out.pc_plus4;
    ID_EX_in.isWb <= isWb;
    ID_EX_in.isLd <= isLd;
    ID_EX_in.isSt <= isSt;
    ID_EX_in.isImm <= isImm;
    ID_EX_in.ra <= ra;
    ID_EX_in.alu_s <= alu_s;
    ID_EX_in.isBranch <= isBranch;
    ID_EX_in.instr <= IF_ID_out.instr;

    EX_MEM_in.alu_result <= alu_result;
    EX_MEM_in.rd <= ID_EX_out.rd;
    EX_MEM_in.op2 <= ID_EX_out.op2;
    EX_MEM_in.pc <= ID_EX_out.pc;
    EX_MEM_in.pc_plus4 <= ID_EX_out.pc_plus4;
    EX_MEM_in.isWb <= ID_EX_out.isWb;
    EX_MEM_in.isLd <= ID_EX_out.isLd;
    EX_MEM_in.isSt <= ID_EX_out.isSt;
    EX_MEM_in.ra <= ID_EX_out.ra;
    EX_MEM_in.isBranch <= ID_EX_out.isBranch;
    EX_MEM_in.instr <= ID_EX_out.instr;

    MEM_WB_in.alu_result <= EX_MEM_out.alu_result;
    MEM_WB_in.rd <= EX_MEM_out.rd;
    MEM_WB_in.mem_data <= data_mem_out; 
    MEM_WB_in.pc <= EX_MEM_out.pc;
    MEM_WB_in.pc_plus4 <= EX_MEM_out.pc_plus4; 
    MEM_WB_in.isWb <= EX_MEM_out.isWb;
    MEM_WB_in.isLd <= EX_MEM_out.isLd;
    MEM_WB_in.ra <= EX_MEM_out.ra;
    MEM_WB_in.instr <= EX_MEM_out.instr;

    -- ========= pc_mux logic ========= --

    process(pc_plus4, pc_branch, alu_result, ID_EX_out.ra, isBranchTaken)
    begin
        if isBranchTaken = '1' then
            pc_next <= pc_branch;
        elsif ID_EX_out.ra = '1' then
            pc_next <= alu_result;
        else
            pc_next <= pc_plus4;
        end if;
    end process;

    -- ===== Data forwarding logic ===== --

    process(ID_EX_out, EX_MEM_out, MEM_WB_out, reg_file_out1, reg_file_out2)
    begin
        op1 <= ID_EX_out.read_data1;
        op2 <= ID_EX_out.read_data2;

        -- 1. Forwarding for rs1
        if (EX_MEM_out.we = '1' and EX_MEM_out.rd /= "00000" and EX_MEM_out.rd = ID_EX_out.rs1) then
            op1 <= EX_MEM_out.alu_result; 
        elsif (MEM_WB_out.we = '1' and MEM_WB_out.rd /= "00000" and MEM_WB_out.rd = ID_EX_out.rs1) then
            op1 <= MEM_WB_out.write_data;
        end if;

        -- 2. Forwarding for rs2
        if (EX_MEM_out.we = '1' and EX_MEM_out.rd /= "00000" and EX_MEM_out.rd = ID_EX_out.rs2) then
            op2 <= EX_MEM_out.alu_result;
        elsif (MEM_WB_out.we = '1' and MEM_WB_out.rd /= "00000" and MEM_WB_out.rd = ID_EX_out.rs2) then
            op2 <= MEM_WB_out.write_data;
        end if;
    end process;

    -- ================================= --

    stageIF_inst: entity work.stageIF
        port map (
            clk => clk,
            reset => reset,
            pc_next => pc_next,
            pc_curr => pc_curr,
            pc_plus4 => pc_plus4
        );

    imem_inst: entity work.instr_mem
        port map (
            pc => pc_curr,
            instr => instr
        );

    IF_ID_inst: entity work.IF_ID
        port map(
            clk => clk,
            reset => reset,
            IF_ID_in => IF_ID_in,
            IF_ID_out => IF_ID_out
        );

    ID_inst: entity work.ID
        port map (
            instr => IF_ID_out.instr,
            opcode => opcode,
            rd => rd,
            rs1 => rs1,
            rs2 => rs2,
            func3 => func3,
            func7 => func7,
            imm => imm
        );

    control_inst: entity work.control
        port map (
            opcode => opcode,
            func3 => func3,
            func7 => func7,
            isWb => isWb,
            isLd => isLd,
            isSt => isSt,
            ra => ra,
            isImm => isImm,
            alu_s => alu_s,
            isBranch => isBranch
        );

    regfile_inst: entity work.regfile
        port map (
            clk => clk,
            we => MEM_WB_out.isWb,
            rs1 => rs1,
            rs2 => rs2,
            rd => MEM_WB_out.rd,
            wd => wb_data,
            rd1 => rd1,
            rd2 => rd2,

            dbg_x1 => dbg_x1,
            dbg_x2 => dbg_x2,
            dbg_x3 => dbg_x3,
            dbg_x4 => dbg_x4,
            dbg_x5 => dbg_x5
        );

    ID_EX_inst: entity work.ID_EX
        port map(
            clk => clk,
            reset => reset,
            ID_EX_in => ID_EX_in,
            ID_EX_out => ID_EX_out
        );

    EX_inst: entity work.EX
        port map (
            op1 => ID_EX_out.op1,
            op2 => ID_EX_out.op2,
            imm => ID_EX_out.imm,
            pc_curr => ID_EX_out.pc,
            pc_plus4 => ID_EX_out.pc_plus4,
            is_imm => ID_EX_out.isImm,
            isBranch => ID_EX_out.isBranch,
            alu_s => ID_EX_out.alu_s,
            alu_result => alu_result,
            isBranchTaken => isBranchTaken,
            pc_branch => pc_branch
        );

    EX_MEM_inst: entity work.EX_MEM
        port map(
            clk => clk,
            reset => reset,
            EX_MEM_in => EX_MEM_in,
            EX_MEM_out => EX_MEM_out
        );

    MEM_inst: entity work.MEM
        port map(
            clk => clk, 
            address => EX_MEM_out.alu_result,
            we => EX_MEM_out.isSt,
            wd => EX_MEM_out.op2,
            rd => data_mem_out
        );

    MEM_WB_inst: entity work.MEM_WB
        port map(
            clk => clk,
            reset => reset,
            MEM_WB_in => MEM_WB_in,
            MEM_WB_out => MEM_WB_out
        );

    WB_inst: entity work.WB
        port map(
            alu_result => MEM_WB_out.alu_result,
            mem_data   => MEM_WB_out.mem_data,
            isLd       => MEM_WB_out.isLd,
            isWb_in    => MEM_WB_out.isWb,
            rd_in      => MEM_WB_out.rd,

            wb_data    => wb_data,
            isWb_out   => open,
            rd_out     => open
        );

end rtl;