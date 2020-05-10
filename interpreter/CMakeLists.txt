cmake_minimum_required(VERSION 3.10)
project(swpp_asm_interpreter)

set(CMAKE_CXX_STANDARD 17)

add_executable(sf-interpreter src/main.cpp src/value.h src/opcode.h src/stmt.h src/value.cpp src/size.h src/stmt.cpp src/reg.h src/regfile.h src/regfile.cpp src/error.h src/memory.h src/error.cpp src/memory.cpp src/size.cpp src/function.h src/function.cpp src/program.h src/program.cpp src/state.h src/state.cpp src/parser.h src/parser.cpp)
