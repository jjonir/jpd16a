#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>
#include <string.h>

char lval[16], rval[16];

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

#ifdef STANDALONE
static int decode_inst(uint16_t *inst, char *buf);
#endif
static int decode_lval(uint16_t val, uint16_t next);
static int decode_rval(uint16_t val, uint16_t next);

int decode_lval(uint16_t val, uint16_t next)
{
	int rv = 0;

	if (val < 0x08) {
		sprintf(lval, "%s", gpr_table[val]);
	} else if (val < 0x10) {
		sprintf(lval, "[%s]", gpr_table[val - 0x08]);
	} else if (val < 0x18) {
		rv = 1;
		sprintf(lval, "[0x%.4x+%s]", next, gpr_table[val - 0x10]);
	} else {
		switch (val) {
		case 0x18:
			sprintf(lval, "push");
			break;
		case 0x19:
			sprintf(lval, "peek");
			break;
		case 0x1a:
			rv = 1;
			sprintf(lval, "[sp+0x%.4x]", next);
			break;
		case 0x1b:
			sprintf(lval, "sp");
			break;
		case 0x1c:
			sprintf(lval, "pc");
			break;
		case 0x1d:
			sprintf(lval, "ex");
			break;
		case 0x1e:
			rv = 1;
			sprintf(lval, "[0x%.4x]", next);
			break;
		case 0x1f:
			rv = 1;
			sprintf(lval, "0x%.4x", next);
			break;
		default:
			break;
		}
	}

	return rv;
}

int decode_rval(uint16_t val, uint16_t next)
{
	int rv = 0;
	char temp[16];

	if (val >= 0x20) {
		sprintf(rval, "0x%.4x", (int16_t)val - 0x21);
	} else if (val == 0x18) {
		sprintf(rval, "pop");
	} else {
		strncpy(temp, lval, 16);
		rv = decode_lval(val, next);
		strncpy(rval, lval, 16);
		strncpy(lval, temp, 16);
	}

	return rv;
}

int decode_inst(uint16_t *inst, char *buf)
{
	int words = 1;
	uint16_t word;

	word = inst[0];
	if (word & 0x1F) {
		words += decode_rval((word >> 10) & 0x3F, inst[words]);
		words += decode_lval((word >> 5) & 0x1F, inst[words]);
		sprintf(buf, "%s %s, %s", opcode_table[word & 0x1F], lval, rval);
	} else if ((word >> 5) & 0x1F) {
		words += decode_rval((word >> 10) & 0x3F, inst[words]);
		sprintf(buf, "%s %s", spc_opcode_table[(word >> 5) & 0x1F], rval);
	} else {
		sprintf(buf, "dat 0x%.4x", word);
	}

	return words;
}

#ifdef STANDALONE
int main(int argc, char *argv[])
{
	FILE *f;
	const char *fname = NULL;
	int i, len, inst_len;
	uint16_t memory[0x10000];
	uint16_t start = 0, end = 0xFFFF, last;
	char buf[32];

	for (i = 1; i < argc; i++) {
		if (strncmp(argv[i], "--start=", 8) == 0)
			start = atoi(argv[i] + 8);
		else if (strncmp(argv[i], "--end=", 6) == 0)
			end = atoi(argv[i] + 6);
		else
			fname = argv[i];
	}

	if (fname == NULL) {
		fprintf(stderr, "usage: disasm <fname> [--start=<start>] [--end=<end>]\n");
		exit(1);
	}

	f = fopen(fname, "rb");
	len = fread(memory, 2, 0x10000, f);
	fclose(f);

	last = 0;
	for (i = 0; i < len; i++) {
		if (memory[i])
			last = i;
	}

	if ((last + 1) < end)
		end = last + 1;

	for (i = start; i <= end; i += inst_len) {
		inst_len = decode_inst(&memory[i], buf);
		printf("0x%.4X: %s\n", i, buf);
	}

	return 0;
}
#endif
