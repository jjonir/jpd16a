%{
#include <stdio.h>
int yyerror(const char *s);
int yylex(void);
%}
%token OP
%token SPC_OP
%token DAT
%token LABEL
%token STR
%token INT
%token CHAR
%token GPR
%token PC
%token SP
%token EX
%token PUSH
%token POP
%token PEEK
%token PICK

%%

list:	/* Empty. */
	| list inst
	| list data
	| list anchor
	;

inst:	OP lval ',' rval
	| SPC_OP rval
	;

data:	DAT num
	| DAT STR
	| data ',' num
	| data ',' STR
	;

anchor:	':' LABEL
	;

num:	INT
	| CHAR
	| LABEL
	;

lval:	GPR
	| '[' GPR ']'
	| '[' GPR '+' num ']'
	| '[' GPR '-' num ']'
	| '[' num '+' GPR ']'
	| PUSH
	| '[' '-' '-' SP ']'
	| PEEK
	| '[' SP ']'
	| PICK '[' num ']'
	| '[' SP '+' num ']'
	| '[' SP '-' num ']'
	| '[' num '+' SP ']'
	| SP
	| PC
	| EX
	| '[' num ']'
	| num /* 0x1F as lvalue has meaning, but I'm not sure how to represent it in assembly. This doesn't seem right. */
	;

rval:	GPR
	| '[' GPR ']'
	| '[' GPR '+' num ']'
	| '[' GPR '-' num ']'
	| '[' num '+' GPR ']'
	| POP
	| '[' SP '+' '+' ']'
	| PEEK
	| '[' SP ']'
	| PICK '[' num ']'
	| '[' SP '+' num ']'
	| '[' SP '-' num ']'
	| '[' num '+' SP ']'
	| SP
	| PC
	| EX
	| '[' num ']'
	| num /* accept full 16bit numbers for rval. */
	;

%%

int yyerror(const char *s)
{
	fprintf(stderr, "%s\n", s);
	return 0;
}

int main(int argc, char *argv[])
{
	if (argc > 1)
		if (argv[1][0] == 'd')
			yydebug = 1;
	yyparse();
	return 0;
}
