#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <unistd.h>

int main(int argc, char *argv[])
{
	int fds[2];
	int i, j;
	char **parser_argv;
	char *infilename = NULL;

	pipe(fds);

	parser_argv = (char **)malloc((argc + 1) * sizeof(char *));
	parser_argv[0] = "parser";
	for (i = 1, j = 1; i < argc; i++) {
		if (strcmp(argv[i], "-o") == 0) {
			parser_argv[j++] = argv[i++];
			parser_argv[j++] = argv[i];
		} else if (strcmp(argv[i], "-d") == 0) {
			parser_argv[j++] = argv[i];
		} else {
			infilename = argv[i];
		}
	}
	parser_argv[i] = NULL;

	if (fork() == 0) {
		if (infilename != NULL) {
			close(0);
			dup(fileno(fopen(infilename, "r"))); // TODO error check
		}

		close(1);
		dup(fds[1]);
		close(fds[0]);
		execlp("tr", "tr", "A-Z", "a-z", NULL);
		perror("parent: execlp");
	} else {
		close(0);
		dup(fds[0]);
		close(fds[1]);
		execvp("./parser", parser_argv);
		perror("child: execlp");
	}

	return 0;
}
