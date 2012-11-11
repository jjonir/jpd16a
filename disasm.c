#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>
#include <string.h>

char lval[16], rval[16];
FILE *f;
int i;

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

void read_word(uint16_t *word)
{
	fread(word, 2, 1, f);
	i++;
}

void decode_lval(uint16_t val)
{
	uint16_t word;

	if (val < 0x08) {
		sprintf(lval, "%s", gpr_table[val]);
	} else if (val < 0x10) {
		sprintf(lval, "[%s]", gpr_table[val - 0x08]);
	} else if (val < 0x18) {
		read_word(&word);
		sprintf(lval, "[%x+%s]", word, gpr_table[val - 0x10]);
	} else {
		switch (val) {
		case 0x18:
			sprintf(lval, "push");
			break;
		case 0x19:
			sprintf(lval, "peek");
			break;
		case 0x1a:
			read_word(&word);
			sprintf(lval, "[sp+%x]", word);
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
			read_word(&word);
			sprintf(lval, "[%x]", word);
			break;
		case 0x1f:
			read_word(&word);
			sprintf(lval, "%x", word);
			break;
		default:
			break;
		}
	}
}

void decode_rval(uint16_t val)
{
	char temp[16];
	if (val >= 0x20) {
		sprintf(rval, "%x", (int16_t)val - 0x21);
	} else if (val == 0x18) {
		sprintf(rval, "pop");
	} else {
		strncpy(temp, lval, 16);
		decode_lval(val);
		strncpy(rval, lval, 16);
		strncpy(lval, temp, 16);
	}
}

int main(int argc, char *argv[])
{
	const char *fname;
	int bytes;
	uint16_t word;

	if (argc > 1)
		fname = argv[1];

	f = fopen(fname, "rb");

	if (argc > 2) {
		bytes = atoi(argv[2]);
	} else {
		bytes = 1;
		i = 0;
		while ((i < 0x10000) & !feof(f)) {
			read_word(&word);
			if (word)
				bytes = i + 2;
		}
		rewind(f);
	}

	i = 0;
	while ((i < bytes) && !feof(f)) {
		printf("0x%.4X: ", i);
		read_word(&word);
		if (word & 0x1F) {
			decode_rval((word >> 10) & 0x3F);
			decode_lval((word >> 5) & 0x1F);
			printf("%s %s, %s\n", opcode_table[word & 0x1F],
						lval, rval);
		} else if ((word >> 5) & 0x1F) {
			decode_rval((word >> 10) & 0x3F);
			printf("%s %s\n", spc_opcode_table[(word >> 5) & 0x1F],
						rval);
		} else {
			printf("dat %x\n", word);
		}
	}

	fclose(f);
	return 0;
}
