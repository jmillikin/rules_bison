%{
#include <stdio.h>
#include "tests/hello_c.h"
#include "tests/hello_common.h"

static int next_token = HELLO;
int yylex() {
    int token = next_token;
    if (token == HELLO) {
        next_token = WORLD;
    } else {
        next_token = 0;
    }
    return token;
}

void yyerror(const char *s) {
  fprintf(stderr, "%s\n",s);
}

%}

%start greeting
%token HELLO WORLD

%%

greeting: HELLO WORLD {
    hello_common();
    printf("Hello, world!\n");
}

%%
