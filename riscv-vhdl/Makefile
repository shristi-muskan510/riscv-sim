# =============================================================================
#  Makefile — RISC-V 5-Stage Pipeline (GHDL / VHDL-2008)
# =============================================================================
STD = --std=08

# Source files — compile order: pkg first, leaves, then top
SRC = src/pipeline_pkg.vhdl \
      src/instr_mem.vhdl    \
      src/stageIF.vhdl      \
      src/IF_ID.vhdl        \
      src/ID.vhdl           \
      src/ID_EX.vhdl        \
      src/control.vhdl      \
      src/regfile.vhdl      \
      src/EX.vhdl           \
      src/EX_MEM.vhdl       \
      src/MEM.vhdl          \
      src/MEM_WB.vhdl       \
      src/WB.vhdl           \
      src/core.vhdl

# ── Default: run both testbenches ─────────────────────────────────────────────
all: run_imem run_core

# ── 1. Standalone instr_mem ROM unit test ─────────────────────────────────────
analyze_imem:
	ghdl -a $(STD) src/instr_mem.vhdl tb/instr_mem_tb.vhdl

elaborate_imem: analyze_imem
	ghdl -e $(STD) instr_mem_tb

run_imem: elaborate_imem
	@echo ""
	@echo ">>> Running instr_mem ROM unit test..."
	ghdl -r $(STD) instr_mem_tb

# ── 2. Full pipeline testbench (all sections A-G) ─────────────────────────────
analyze_core:
	ghdl -a $(STD) $(SRC) tb/core_tb.vhdl

elaborate_core: analyze_core
	ghdl -e $(STD) core_tb

run_core: elaborate_core
	@echo ""
	@echo ">>> Running full pipeline simulation (sections A-G)..."
	ghdl -r $(STD) core_tb --wave=core_tb.ghw

# ── Convenience ───────────────────────────────────────────────────────────────
sim: run_core

clean:
	rm -f *.o *.cf core_tb instr_mem_tb *.ghw *.vcd e~*.o work-obj08.cf