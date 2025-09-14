#pragma once
#include <cstdint>
#include <vector>
using namespace std;
extern bool halt;

enum Format { R, I, S, SB, U, UJ };

struct cpu {
    uint32_t pc = 0;         // program counter
    uint32_t reg[32] = {0};  // 32 registers
    vector<uint8_t> memory;  // byte-addressable memory

    cpu(size_t mem_size);
    uint32_t fetch();
};

// Functions declared
void decode_instr(cpu &c, uint32_t instr);
void execute_instr(cpu &c, uint32_t opcode, uint32_t func3, uint32_t func7, uint32_t rd, uint32_t op1, uint32_t op2, int32_t imm, int format, bool halt);