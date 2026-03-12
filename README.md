# RISC-V CPU

## 📌 Overview
This project is an educational implementation of a 32-bit RISC-V processor built in multiple phases. Each phase explores a different aspect of CPU design and implementation — starting from a high-level C++ simulation to a VHDL-based hardware implementation.

The project follows the RV32I instruction set architecture (ISA) and gradually evolves from instruction simulation to a fully working CPU core.

## 📂 Project Structure

---

## 🔹 Phase 1: C++ Simulation  
### ✨ Features  
- Full **RV32I instruction set simulation** in C++.
- Implements the instruction cycle: **Fetch → Decode → Execute → Memory → Writeback**.
- Debug-friendly: register and memory states printed after execution.
- Useful as a reference model to validate later hardware implementations.

### ▶️ How to Run
1. Go to the riscv-sim folder
2. make
3. Run a test file (You can use the sample provided in test.s)

---
## 🔹 Phase 2: VHDL (Non-Pipelined CPU)

### ✨ Features  
- Implements a non-pipelined CPU in VHDL.
- Supports arithmetic, logical, branch, load/store, and jump instructions.
- Fully modular design with ALU, PC, Register File, Control Unit, Data Memory, Instruction Memory, and a core.
- Verified using custom testbenches.

### ▶️ How to Run
1. Install GHDL
2. Go to the riscv-vhdl folder
3. Write some sample instructions (You can use the samples provided in instr.hex)
4. make

---

## 🔹 Phase 3: Pipelined CPU

### ✨ Features
- Transition from single-cycle to a **5-stage pipeline**:
  1. **IF** (Instruction Fetch)
  2. **ID** (Instruction Decode)
  3. **EX** (Execute)
  4. **MEM** (Memory Access)
  5. **WB** (Write Back)
- Addition of **pipeline registers** between stages to increase clock frequency.
- Initial support for instruction throughput of one instruction per cycle (under ideal conditions).

### ▶️ How to Run
1. Go to the `riscv-vhdl` folder.
2. Follow the same GHDL compilation steps as Phase 2.

---
## 🔮 Roadmap  

- **Phase 4:** Hazard detection and data forwarding to handle data/control dependencies.

## Final Note
This project was built as part of my exploration of **computer architecture** and **system design**. 
