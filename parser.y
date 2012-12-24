%{
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <stdint.h>

void save_literal(int lit);
void queue_label(const char *lbl);
void save_labelref(const char *lbl);
int yyerror(const char *s);
int yylex(void);

/* internal state */
uint16_t memory[0x10000];
int addr;
int num_literals;
struct sym {
	char *name;
	int addr;
} sym_tab[0x10000];
int num_syms;
char *sym_ref_tab[0x10000];

/* extra information from the scanner */
int opcode;
int gpr_no;
int literal;
char str[1024];
char lbl[1024];
char *sptr;
%}
%token OP
%token SPC_OP
%token DAT
%token RES
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
	| list inst { memory[addr++] = (uint16_t)$2; addr += num_literals; num_literals = 0; }
	| list data
	| list res
	| list anchor
	;

inst:	OP lval ',' rval { $$ = (opcode) | ($2 << 5) | ($4 << 10); }
	| SPC_OP rval { $$ = (opcode << 5) | ($2 << 10); }
	;

data:	DAT lit { memory[addr++] = (uint16_t)$2; }
	| DAT STR { sptr = &str[0]; while(*sptr) memory[addr++] = (uint16_t)*sptr++; }
	| data ',' lit { memory[addr++] = (uint16_t)$3; }
	| data ',' STR { sptr = &str[0]; while(*sptr) memory[addr++] = (uint16_t)*sptr++; }
	;

res:	RES lit { addr += $2; }
	;

anchor:	':' LABEL { queue_label(lbl); }
	;

lit:	INT { $$ = literal; }
	| CHAR { $$ = literal; }
	;

lblref:	LABEL { save_literal(0x900f); save_labelref(lbl); }
	;

num:	lit { save_literal($1); }
	| lblref
	;

lval:	val { $$ = $1; }
	| PUSH { $$ = 0x18; }
	| '[' '-' '-' SP ']' { $$ = 0x18; }
	| num { $$ = 0x1f; /* 0x1F as lvalue has meaning, but I'm not sure how to represent it in assembly. This doesn't seem right. */ }
	;

rval:	val { $$ = $1; }
	| POP { $$ = 0x18; }
	| '[' SP '+' '+' ']' { $$ = 0x18; }
	| lblref { $$ = 0x1f;}
	| lit { if ((literal >= -1) && (literal <= 30)) $$ = literal + 0x21; else {$$ = 0x1f; save_literal(literal); } }
	;

val:	GPR { $$ = gpr_no; }
	| '[' GPR ']' { $$ = gpr_no + 0x08; }
	| '[' GPR '+' num ']' { $$ = gpr_no + 0x10; }
	| '[' GPR '-' num ']' { $$ = gpr_no + 0x10; }
	| '[' num '+' GPR ']' { $$ = gpr_no + 0x10; }
	| PEEK { $$ = 0x19; }
	| '[' SP ']' { $$ = 0x19; }
	| PICK '[' num ']' { $$ = 0x1a; }
	| '[' SP '+' num ']' { $$ = 0x1a; }
	| '[' SP '-' num ']' { $$ = 0x1a; }
	| '[' num '+' SP ']' { $$ = 0x1a; }
	| SP { $$ = 0x1b; }
	| PC { $$ = 0x1c; }
	| EX { $$ = 0x1d; }
	| '[' num ']' { $$ = 0x1e; }
	;

%%

void save_literal(int lit)
{
	sym_ref_tab[addr + 2] = sym_ref_tab[addr + 1];
	sym_ref_tab[addr + 1] = NULL;
	memory[addr + 2] = memory[addr+1];
	memory[addr + 1] = (uint16_t)lit;
	num_literals++;
}

void queue_label(const char *lbl)
{
	sym_tab[num_syms].name = (char *)malloc(strlen(lbl) + 1);
	strcpy(sym_tab[num_syms].name, lbl);
	sym_tab[num_syms].addr = addr;
	num_syms++;
}

void save_labelref(const char *lbl)
{
	sym_ref_tab[addr + 1] = (char *)malloc(strlen(lbl) + 1);
	strcpy(sym_ref_tab[addr + 1], lbl);
}

int yyerror(const char *s)
{
	fprintf(stderr, "%s\n", s);
	return 0;
}

int resolve_sym_ref(int i)
{
	int j;

	for (j = 0; j < num_syms; j++) {
		if (strcmp(sym_ref_tab[i], sym_tab[j].name) == 0) {
			memory[i] = sym_tab[j].addr;
			break;
		}
	}
	if (j == num_syms) {
		fprintf(stderr, "unresolved reference %s at address 0x%.4X\n",
				sym_ref_tab[i], i);
		return -1;
	}

	return 0;
}

int main(int argc, char *argv[])
{
	int i;
	const char defaultoutfilename[] = "out.bin";
	const char *outfilename = defaultoutfilename;
	FILE *f;

	for (i = 1; i < argc; i++) {
		if ((strcmp(argv[i], "--debug") == 0) || (strcmp(argv[i], "-d") == 0))
			yydebug = 1;
		else if (strcmp(argv[i], "-o") == 0)
			if ((i + 1) < argc) {
				outfilename = argv[++i];
			} else {
				fprintf(stderr, "-o requires an argument\n");
				exit(1);
			}
		else
			outfilename = argv[i];
	}

	memset(memory, 0, sizeof(memory));
	addr = 0;
	num_literals = 0;
	memset(sym_tab, 0, sizeof(sym_tab));
	num_syms = 0;
	memset(sym_ref_tab, 0, sizeof(sym_ref_tab));

	yyparse();

	for (i = 0; i < addr; i++)
		if (sym_ref_tab[i])
			resolve_sym_ref(i);

	f = fopen(outfilename, "wb");
	if (0x10000 != fwrite(memory, 2, 0x10000, f))
		perror("fwrite");
	fclose(f);

	return 0;
}
