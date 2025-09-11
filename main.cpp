#include "cpu.h"
#include <iostream>
using namespace std;

int main() {
    cpu myCPU(1024); // 1 KB memory

    // Load a test instruction
    myCPU.memory[0] = 0x93;
    myCPU.memory[1] = 0x00;
    myCPU.memory[2] = 0x50;
    myCPU.memory[3] = 0x00;

    uint32_t instr = myCPU.fetch();
    decode_instr(myCPU, instr);

    return 0;
}