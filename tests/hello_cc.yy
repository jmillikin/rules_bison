%define api.value.type variant
%define api.token.constructor

%{
#include <cstdio>
#include "tests/hello_cc.h"
#include "tests/hello_common.h"

static int count = 0;
yy::parser::symbol_type next_token = yy::parser::token::HELLO;
yy::parser::symbol_type yylex() {
    switch (count++) {
    case 0:
        return yy::parser::make_HELLO();
    case 1:
        return yy::parser::make_WORLD();
    default:
        return yy::parser::make_END_OF_FILE();
    }
}

void yy::parser::error(const std::string &s) {
  fprintf(stderr, "%s\n", s.c_str());
}

%}

%start greeting
%token HELLO WORLD
%token END_OF_FILE 0

%%

greeting: HELLO WORLD {
    hello_common();
    printf("Hello, world!\n");
}

%%
