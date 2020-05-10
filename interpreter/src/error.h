#ifndef SWPP_ASM_INTERPRETER_ERROR_H
#define SWPP_ASM_INTERPRETER_ERROR_H

#include <string>

#include "regfile.h"

using namespace std;


extern string error_filename;
extern int error_line_num;

void invoke_syntax_error(const string& msg);
void invoke_runtime_error(const string& msg);
void invoke_assertion_failed(const RegFile& regfile);

#endif //SWPP_ASM_INTERPRETER_ERROR_H
