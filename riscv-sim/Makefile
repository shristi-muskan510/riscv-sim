# Makefile for RISC-V C++ Simulator
CXX = g++
CXXFLAGS = -Wall -O2 -std=c++17 -Iinclude

SRC = $(wildcard src/*.cpp)
OBJ = $(SRC:.cpp=.o)

TARGET = riscv-sim

all: $(TARGET)

$(TARGET): $(OBJ)
	$(CXX) $(CXXFLAGS) -o $@ $(OBJ)

%.o: %.cpp
	$(CXX) $(CXXFLAGS) -c $< -o $@

run: $(TARGET)
	./$(TARGET) test.s

clean:
	rm -f $(OBJ) $(TARGET)