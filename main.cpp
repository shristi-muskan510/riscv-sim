#include "cpu.h"
#include <iostream>
using namespace std;

int main() {
    cpu myCPU(1024); // 1 KB memory

    //load instructions

    uint32_t instr = myCPU.fetch();
    decode_instr(myCPU, instr);

    return 0;
}