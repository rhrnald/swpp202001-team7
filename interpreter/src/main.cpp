#include <iostream>
#include <fstream>
#include <iomanip>

#include "parser.h"
#include "state.h"
#include "error.h"

using namespace std;


int main(int argc, char** argv) {
  if (argc != 2) {
    cout << "USAGE: sf-interpreter <input assembly file>" << endl;
    return 1;
  }

  string filename = argv[1];
  error_filename = filename;

  Program* program = parse(filename);
  if (program == nullptr) {
    cout << "Error: cannot find " << filename << endl;
    return 1;
  }

  State state;
  state.set_program(program);

  Function* main = program->get_function("main");
  if (main == nullptr)
    invoke_runtime_error("missing main function");

  uint64_t ret = state.exec_function(main);

  ofstream log("sf-interpreter.log");
  log << fixed << setprecision(4);
  log << "Returned: " << ret << endl;
  log << "Cost: " << state.get_cost() << endl;
  log.close();

  return 0;
}
