#include "cpu.h"

void decode_instr(cpu &c, uint32_t instr){
    // 1. Split the instructions in all possible parts.
    uint32_t opcode = instr & 0x7F;
    uint32_t rd = (instr >> 7) & 0x1F;
    uint32_t func3 = (instr >> 12) & 0x7;
    uint32_t rs1 = (instr >> 15) & 0x1F;
    uint32_t rs2 = (instr >> 20) & 0x1F;
    uint32_t func7 = (instr >> 25) & 0x7F;
    int32_t imm_i = (int32_t)instr >> 20; // Imm I format
    int32_t imm_s = (((instr >> 25) << 5) | ((instr >> 7) & 0x1F)); // Imm S Format
    if (imm_s & 0x800)
        imm_s |= 0xFFFFF000;
    int32_t imm_u = ((int32_t)instr & 0xFFFFF000); // Imm U Format
    int32_t imm_sb = ((instr >> 31) << 12) // Imm SB Format
                | ((instr >> 25 & 0x3F) << 5)
                | ((instr >> 8 & 0xF) << 1)
                | ((instr >> 7 & 0x1) << 11);
    if (imm_sb & 0x1000)
        imm_sb |= 0xFFFFE000;
    int32_t imm_uj = ((instr >> 31) << 20) // Imm UJ Format
                | ((instr >> 21 & 0x3FF) << 1)
                | ((instr >> 20 & 0x1) << 11)
                | ((instr >> 12 & 0xFF) << 12);
    if (imm_uj & 0x00100000)
        imm_uj |= 0xFFF00000;

    // 2. Choose the correct Immediate
    int format = -1;

    switch(opcode){
        case 0x33: format = R; break;
        case 0x13: case 0x03: case 0x67: format = I; break;
        case 0x23: format = S; break;
        case 0x63: format = SB; break;
        case 0x37: case 0x17: format = U; break;
        case 0x6F: format = UJ; break;
        default: break;
    }

    int32_t imm = 0;

    switch(format){
        case I: imm = imm_i; break;
        case S: imm = imm_s; break;
        case U: imm = imm_u; break;
        case SB: imm = imm_sb; break;
        case UJ: imm = imm_uj; break;
        default: break;
    }
    
    // 3. Read the registers
    uint32_t op1 = 0, op2 = 0;

    if(format == R || format == I || format == S || format == SB){
        op1 = c.reg[rs1];
    }

    if(format == R || format == S || format == SB){
        op2 = c.reg[rs2];
    }

    execute_instr(c, opcode, func3, func7, rd, op1, op2, imm, format, halt);
}