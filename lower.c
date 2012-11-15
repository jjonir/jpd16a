#include <stdio.h>

int main()
{
	int c;
	while(!feof(stdin)) {
		c = fgetc(stdin);
		if (c == EOF) {
		} else if ((c >= 'A') && (c <= 'Z'))
			fputc(c - 'A' + 'a', stdout);
		else
			fputc(c, stdout);
	}
}
