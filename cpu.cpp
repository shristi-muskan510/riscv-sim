#include "cpu.h"

// CPU constructor
cpu::cpu(size_t mem_size) : memory(mem_size, 0) {}

// Fetch 32-bit instruction
uint32_t cpu::fetch() {
    uint32_t instr = 0;
    for(int i=0; i<4; i++){
        instr = instr | (memory[pc+i] << (8*i));  // little endian
    }
    return instr;
}
