#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>

int main(int argc, char *argv[])
{
	FILE *f;
	const char *fname;
	uint16_t word;
	int bytes;
	int i;

	if (argc > 1)
		fname = argv[1];

	f = fopen(fname, "rb");

	if (argc > 2) {
		bytes = atoi(argv[2]);
	} else {
		bytes = 1;
		for (i = 0; (i < 0x10000) & !feof(f); i++) {
			fread(&word, 2, 1, f);
			if (word)
				bytes = i + 2;
		}
		rewind(f);
	}

	for (i = 0; (i < bytes) && !feof(f); i++) {
		fread(&word, 2, 1, f);
		printf("addr: 0x%.4X  o: 0x%.2X  b: 0x%.2X  a: 0x%.2X  word: 0x%.4X\n",
			i,
			word & 0x1F,
			(word >> 5) & 0x1F,
			(word >> 10) & 0x3F,
			word);
	}
	fclose(f);
	return 0;
}
