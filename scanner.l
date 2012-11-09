%{
#include <stdlib.h>
#include <stdio.h>
%}

op (set)|(add)|(sub)|(mul)|(mli)|(div)|(dvi)|(mod)|(mdi)|(and)|(bor)|(xor)|(shr)|(asr)|(shl)|(ifb)|(ifc)|(ife)|(ifn)|(ifg)|(ifa)|(ifl)|(ifu)|(adx)|(sbx)|(sti)|(std)
spc_op (jsr)|(int)|(iag)|(ias)|(rfi)|(iaq)|(hwn)|(hwq)|(hwi)
dat (dat)
reg (a)|(b)|(c)|(x)|(y)|(z)|(i)|(j)|(pc)|(sp)|(ex)|(ia)
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
}

{spc_op} {
	printf("special op: %s\n", yytext);
}

{dat} {
	printf("dat\n");
}

{reg} {
	printf("register: %s\n", yytext);
}

{push} {
	printf("push\n");
}

{pop} {
	printf("pop\n");
}

{peek} {
	printf("peek\n");
}

{pick} {
	printf("pick\n");
}

{int} {
	printf("int: %li\n", strtol(yytext, NULL, 10));
}

{octal_int} {
	printf("octal int: %lo\n", strtoul(yytext, NULL, 010));
}

{hex_int} {
	printf("hex int: %lx\n", strtoul(yytext, NULL, 0x10));
}

{char} {
	printf("character constant: %c\n", yytext[1]);
}

{str} {
	printf("string constant: %s\n", yytext);
}

{label} {
	printf("label reference %s\n", yytext);
}

, {
	printf("comma\n");
}

"[" {
	printf("open bracket\n");
}

"]" {
	printf("close bracket\n");
}

"+"|"-" {
	printf("plusorminus %s\n", yytext);
}

:{label} {
	printf("label: %s\n", yytext+1);
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

	yylex();

	return 0;
}
#endif
