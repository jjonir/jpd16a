%{
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "parser.tab.h"

extern int opcode;
extern int gpr_no;
extern int literal;
extern char str[1024];
extern char lbl[1024];

const char *opcode_table[0x20] = {
	"",
	"set",
	"add", "sub", "mul", "mli", "div", "dvi", "mod", "mdi",
	"and", "bor", "xor", "shr", "asr", "shl",
	"ifb", "ifc", "ife", "ifn", "ifg", "ifa", "ifl", "ifu",
	"", "",
	"adx", "sbx",
	"", "",
	"sti", "std"
};

const char *spc_opcode_table[0x20] = {
	"",
	"jsr",
	"", "", "", "", "", "",
	"int", "iag", "ias", "rfi", "iaq",
	"", "", "",
	"hwn", "hwq", "hwi",
	"", "", "", "", "", "", "", "", "", "", "", "", ""
};

const char *gpr_table[0x08] = {
	"a", "b", "c", "x", "y", "z", "i", "j"
};

#ifndef SCANNER_ONLY
	#define printf(...)
#else
	#define printf(...) printf(__VA_ARGS__)
#endif
%}

op (set)|(add)|(sub)|(mul)|(mli)|(div)|(dvi)|(mod)|(mdi)|(and)|(bor)|(xor)|(shr)|(asr)|(shl)|(ifb)|(ifc)|(ife)|(ifn)|(ifg)|(ifa)|(ifl)|(ifu)|(adx)|(sbx)|(sti)|(std)
spc_op (jsr)|(int)|(iag)|(ias)|(rfi)|(iaq)|(hwn)|(hwq)|(hwi)
dat (dat)
res (res)
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
#ifndef SCANNER_ONLY
	for (opcode = 0; opcode < 0x20; opcode++)
		if(0 == strcmp(yytext, opcode_table[opcode]))
			break;
#endif
	return OP;
}

{spc_op} {
	printf("special op: %s\n", yytext);
#ifndef SCANNER_ONLY
	for (opcode = 0; opcode < 0x20; opcode++)
		if(0 == strcmp(yytext, spc_opcode_table[opcode]))
			break;
#endif
	return SPC_OP;
}

{dat} {
	printf("dat\n");
	return DAT;
}

{res} {
	printf("res\n");
	return RES;
}

{gpr} {
	printf("gpr: %s\n", yytext);
#ifndef SCANNER_ONLY
	for (gpr_no = 0; gpr_no < 0x20; gpr_no++)
		if(0 == strcmp(yytext, gpr_table[gpr_no]))
			break;
#endif
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
#ifndef SCANNER_ONLY
	literal = strtoul(yytext, NULL, 10);
#endif
	return INT;
}

{octal_int} {
	printf("octal int: %lo\n", strtoul(yytext, NULL, 010));
#ifndef SCANNER_ONLY
	literal = strtoul(yytext, NULL, 010);
#endif
	return INT;
}

{hex_int} {
	printf("hex int: %lx\n", strtoul(yytext, NULL, 0x10));
#ifndef SCANNER_ONLY
	literal = strtoul(yytext, NULL, 0x10);
#endif
	return INT;
}

{char} {
	printf("character constant: %c\n", yytext[1]);
#ifndef SCANNER_ONLY
	literal = yytext[1];
#endif
	return CHAR;
}

{str} {
	printf("string constant: %s\n", yytext);
#ifndef SCANNER_ONLY
	strncpy(str, yytext + 1, 1024);
	str[strlen(str) - 1] = 0;
#endif
	return STR;
}

{label} {
	printf("label %s\n", yytext);
#ifndef SCANNER_ONLY
	strncpy(lbl, yytext, 1024);
#endif
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
