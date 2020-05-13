#include <iostream>
#include <cstdlib>

#include "error.h"


string error_filename;
int error_line_num = 0;

void invoke_syntax_error(const string& msg) {
  cout << "Syntax error at " << error_filename << ":" << error_line_num << ": " << msg << endl;
  exit(EXIT_FAILURE);
}

void invoke_runtime_error(const string& msg) {
  cout << "Runtime error at " << error_filename << ":" << error_line_num << ": " << msg << endl;
  exit(EXIT_FAILURE);
}

void invoke_assertion_failed(const RegFile& regfile) {
  cout << "Assertion failed at " << error_filename << ":" << error_line_num << endl;
  cout << "Registers: " << regfile.to_string() << endl;
  exit(EXIT_FAILURE);
}
