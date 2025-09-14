#include "cpu.h"
#include <iostream>
#include <fstream>
#include <vector>
using namespace std;

int main() {
    cpu myCPU(1024); // 1 KB memory

    // load instructions
    ifstream file("test.bin", ios::binary);
    if (!file) {
        cerr << "Error opening program file\n";
        return 1;
    }
    file.read(reinterpret_cast<char*>(myCPU.memory.data()), myCPU.memory.size());

    // Loop for running the processor
    while(!halt){
        uint32_t instr = myCPU.fetch();
        decode_instr(myCPU, instr);

        if (instr == 0x00100073) {
            cout << "Program halted by EBREAK.\n";
            halt = true;
        }

        myCPU.pc += 4;
    }

    cout << "\n=== Register Dump ===\n";
    for (int i = 0; i < 32; i++) {
        cout << "x" << i << " = " << myCPU.reg[i] << "\n";
    }

    return 0;
}