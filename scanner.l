%{
#include <stdlib.h>
#include <stdio.h>
#include "parser.tab.h"

#ifndef SCANNER_ONLY
	#define printf(...)
#else
	#define printf(...) printf(__VA_ARGS__)
#endif
%}

op (set)|(add)|(sub)|(mul)|(mli)|(div)|(dvi)|(mod)|(mdi)|(and)|(bor)|(xor)|(shr)|(asr)|(shl)|(ifb)|(ifc)|(ife)|(ifn)|(ifg)|(ifa)|(ifl)|(ifu)|(adx)|(sbx)|(sti)|(std)
spc_op (jsr)|(int)|(iag)|(ias)|(rfi)|(iaq)|(hwn)|(hwq)|(hwi)
dat (dat)
gpr (a)|(b)|(c)|(x)|(y)|(z)|(i)|(j)
pc (pc)
sp (sp)
ex (ex)
push (push)
pop (pop)
peek (peek)
pick (pick)
label [_a-z][_a-z0-9]*
int 0|([1-9][0-9]*)
octal_int 0[0-7]+
hex_int 0x[0-9a-f]+
char \'.\'
str \".*\"

%%

{op} {
	printf("op: %s\n", yytext);
	return OP;
}

{spc_op} {
	printf("special op: %s\n", yytext);
	return SPC_OP;
}

{dat} {
	printf("dat\n");
	return DAT;
}

{gpr} {
	printf("gpr: %s\n", yytext);
	return GPR;
}

{pc} {
	printf("pc\n");
	return PC;
}

{sp} {
	printf("sp\n");
	return SP;
}

{ex} {
	printf("ex\n");
	return EX;
}

{push} {
	printf("push\n");
	return PUSH;
}

{pop} {
	printf("pop\n");
	return POP;
}

{peek} {
	printf("peek\n");
	return PEEK;
}

{pick} {
	printf("pick\n");
	return PICK;
}

{int} {
	printf("int: %li\n", strtol(yytext, NULL, 10));
	return INT;
}

{octal_int} {
	printf("octal int: %lo\n", strtoul(yytext, NULL, 010));
	return INT;
}

{hex_int} {
	printf("hex int: %lx\n", strtoul(yytext, NULL, 0x10));
	return INT;
}

{char} {
	printf("character constant: %c\n", yytext[1]);
	return CHAR;
}

{str} {
	printf("string constant: %s\n", yytext);
	return STR;
}

{label} {
	printf("label reference %s\n", yytext);
	return LABEL;
}

","|"["|"]"|"+"|"-"|":" {
	printf("pass-through character: %c\n", yytext[0]);
	return yytext[0];
}

[ \t\n]+ /* Eat whitespace */
;.*\n    /* Eat comments */

%%

#ifdef SCANNER_ONLY
int main(int argc, char *argv[])
{
	++argv, --argc;
	if (argc > 0)
		yyin = fopen(argv[0], "r");
	else
		yyin = stdin;

	while(yylex());

	return 0;
}
#else
int yywrap(void)
{
	return 1;
}
#endif
