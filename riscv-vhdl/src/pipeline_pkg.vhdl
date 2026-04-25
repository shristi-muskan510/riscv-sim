library ieee;
use ieee.std_logic_1164.all;

package pipeline_pkg is

    type IF_ID_type is record
        pc       : std_logic_vector(31 downto 0);
        pc_plus4 : std_logic_vector(31 downto 0);
        instr    : std_logic_vector(31 downto 0);
    end record;

    type ID_EX_type is record
        op1      : std_logic_vector(31 downto 0);
        op2      : std_logic_vector(31 downto 0);
        rs1      : std_logic_vector(4 downto 0);
        rs2      : std_logic_vector(4 downto 0);
        imm      : std_logic_vector(31 downto 0);
        rd       : std_logic_vector(4 downto 0);
        pc       : std_logic_vector(31 downto 0);
        pc_plus4 : std_logic_vector(31 downto 0);
        isWb     : std_logic;
        isLd     : std_logic;
        isSt     : std_logic;
        isImm    : std_logic;
        ra       : std_logic;
        alu_s    : std_logic_vector(3 downto 0);
        isBranch : std_logic;
        instr    : std_logic_vector(31 downto 0);
    end record;

    type EX_MEM_type is record 
        alu_result : std_logic_vector(31 downto 0);
        rd         : std_logic_vector(4 downto 0);
        op2        : std_logic_vector(31 downto 0);
        pc         : std_logic_vector(31 downto 0);
        pc_plus4   : std_logic_vector(31 downto 0);
        isWb       : std_logic;
        isLd       : std_logic;
        isSt       : std_logic;
        ra         : std_logic;
        isBranch   : std_logic;
        instr    : std_logic_vector(31 downto 0);
    end record;

    type MEM_WB_type is record 
        alu_result : std_logic_vector(31 downto 0);
        rd         : std_logic_vector(4 downto 0);
        mem_data   : std_logic_vector(31 downto 0);
        pc         : std_logic_vector(31 downto 0);
        pc_plus4   : std_logic_vector(31 downto 0);
        isWb       : std_logic;
        isLd       : std_logic;
        ra         : std_logic;
        instr    : std_logic_vector(31 downto 0);
    end record;

end package;