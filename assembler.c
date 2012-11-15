#include <stdio.h>
#include <errno.h>
#include <unistd.h>

int main(int argc, char *argv[])
{
	int fds[2];
	pipe(fds);

	if (fork() == 0) {
		close(1);
		dup(fds[1]);
		close(fds[0]);
		execlp("./lower", "lower", NULL);
		perror("parent: execlp");
	} else {
		close(0);
		dup(fds[0]);
		close(fds[1]);
		execlp("./parser", "parser", NULL);
		perror("child: execlp");
	}

	return 0;
}
