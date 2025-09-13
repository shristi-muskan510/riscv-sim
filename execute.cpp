#include "cpu.h"
#include <iostream>

void execute_instr(cpu &c, uint32_t opcode, uint32_t func3, uint32_t func7, uint32_t rd, uint32_t op1, uint32_t op2, int32_t imm, int format, bool halt){
    uint8_t val8;
    uint16_t val16;
    uint32_t ema = 0;

    switch(format){

        case R:
            switch(func3){
                case 0x0: //ADD , SUB
                    if(func7 == 0x00) c.reg[rd] = op1 + op2;
                    else c.reg[rd] = op1 - op2;
                break;
                case 0x1: // SLL
                    c.reg[rd] = op1 << (op2 & 0x1F);
                break;
                case 0x2: // SLT
                    if((int32_t)op1 < (int32_t)op2) c.reg[rd] = 1;
                    else c.reg[rd] = 0;
                break;
                case 0x3: // SLTU
                    if(op1 < op2) c.reg[rd] = 1;
                    else c.reg[rd] = 0;
                break;
                case 0x4: // XOR
                    c.reg[rd] = op1 ^ op2;
                break;
                case 0x5: // SRL, SRA
                    if(func7 == 0x00) c.reg[rd] = op1 >> (op2 & 0x1F);
                    else c.reg[rd] = (int32_t)op1 >> (op2 & 0x1F);
                break;
                case 0x6: // OR
                    c.reg[rd] = op1 | op2;
                break;
                case 0x7: // AND
                    c.reg[rd] = op1 & op2;
                break;
            }
        break;

        case I:
            switch(opcode){
                case 0x13:
                    switch(func3){
                        case 0x0: //ADDI
                            c.reg[rd] = op1 + imm;
                        break;
                        case 0x1: // SLLI
                            c.reg[rd] = op1 << (imm & 0x1F);
                        break;
                        case 0x2: // SLTI
                            if((int32_t)op1 < imm) c.reg[rd] = 1;
                            else c.reg[rd] = 0;
                        break;
                        case 0x3: // SLTIU
                            if(op1 < imm) c.reg[rd] = 1;
                            else c.reg[rd] = 0;
                        break;
                        case 0x4: // XORI
                            c.reg[rd] = op1 ^ imm;
                        break;
                        case 0x5: // SRLI, SRAI
                            if(imm & 0x400) c.reg[rd] = (int32_t)op1 >> (imm & 0x1F); // Or should i use func7 instead???
                            else c.reg[rd] = op1 >> (imm & 0x1F);
                        break;
                        case 0x6: // ORI
                            c.reg[rd] = op1 | imm;
                        break;
                        case 0x7: // ANDI
                            c.reg[rd] = op1 & imm;
                        break;
                    }
                break;
                case 0x03:
                    switch(func3){
                        case 0x0: // LB
                            val8 = c.memory[op1];
                            c.reg[rd] = (int32_t)val8;
                        break;
                        case 0x4: // LBU
                            val8 = c.memory[op1];
                            c.reg[rd] = (uint32_t)val8;
                        break;
                        case 0x1: //LH
                            val16 = 0;
                            for(int i=0; i<2; i++){
                                val16 |= c.memory[op1+i] << (8*i);
                            }
                            c.reg[rd] = (int32_t)val16;
                        break;
                        case 0x5: //LHU
                            val16 = 0;
                            for(int i=0; i<2; i++){
                                val16 |= (c.memory[op1+i] << (8*i));
                            }
                            c.reg[rd] = (uint32_t)val16;
                        break;
                        case 0x2: //LW
                            uint32_t val32 = 0;
                            for(int i=0; i<4; i++){
                                val32 |= (c.memory[op1+i] << (8*i));
                            }
                            c.reg[rd] = val32;
                        break;
                    }

                case 0x67:
                // JALR instruction. will define later on
                break;
            }
        break;

        case S:
            switch(func3){
                case 0x0: // SB
                ema = op2 + imm;
                c.memory[ema] = op1 & 0xFF;
                break;
                case 0x1: // SH
                    ema = op2 + imm;
                    for(int i=0; i<2; i++){
                       c.memory[ema+i] = (op1 >> (8*i)) & 0xFF;
                    }
                break;
                case 0x2: // SW
                    ema = op2 + imm;
                    for(int i=0; i<4; i++){
                       c.memory[ema+i] = (op1 >> (8*i)) & 0xFF;
                    }
                break;
            }
        break;

        case U:
        switch(opcode){
            case 0x37: // LUI
                c.reg[rd] = imm;
            break;
            case 0x17: // AUIPC
                c.reg[rd] = c.pc + imm;
            break;
        }
        break;

        case SB:
            switch(func3){
                case 0x0: //BEQ
                    if(op1 == op2) c.pc = c.pc + imm;
                    else c.pc = c.pc + 4;
                break;
                case 0x1: //BNE
                    if(op1 != op2) c.pc = c.pc + imm;
                    else c.pc = c.pc + 4;
                break;
                case 0x4: //BGE
                    if((int32_t)op1 >= (int32_t)op2) c.pc = c.pc + imm;
                    else c.pc = c.pc + 4;
                break;
                case 0x5: //BLT
                    if((int32_t)op1 < (int32_t)op2) c.pc = c.pc + imm;
                    else c.pc = c.pc + 4;
                break;
                case 0x6: //BLTU
                    if(op1 < op2) c.pc = c.pc + imm;
                    else c.pc = c.pc + 4;
                break;
                case 0x7: //BGEU
                    if(op1 >= op2) c.pc = c.pc + imm;
                    else c.pc = c.pc + 4;
                break;
            }
        break;

        case UJ:
            // JAL
            c.reg[rd] = c.pc + 4;
            c.pc = c.pc + imm;
        break;

        default: // SYSTEM instructions
            if (imm == 1) {
                cout << "EBREAK: halting.\n";
                halt = true;
            }
    break;
    }

    c.reg[0] = 0;
}