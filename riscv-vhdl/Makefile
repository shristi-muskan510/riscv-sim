# Makefile for RISC-V VHDL project
STD = --std=08
SRC = src/pc.vhdl src/instr_mem.vhdl src/data_mem.vhdl src/regfile.vhdl src/alu.vhdl src/decoder.vhdl src/control.vhdl src/core.vhdl
TB  = tb/core_tb.vhdl
TOP = tb/core_tb

all: run

analyze:
	ghdl -a $(STD) $(SRC) $(TB)

elaborate:
	ghdl -e $(STD) $(TOP)

run: analyze elaborate
	ghdl -r $(STD) $(TOP) --wave=wave.ghw

clean:
	rm -f *.o *.cf $(TOP) wave.vcd wave.ghw