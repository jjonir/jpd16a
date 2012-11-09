LEX = flex
CC = gcc
CFLAGS = -Wall -Wextra

.PHONY: all clean

all: scanner

scanner: scanner_only.o
	$(CC) -o $@ $< -lfl

scanner.o: scanner.c
	$(CC) $(CFLAGS) -Wno-sign-compare -Wno-unused-function -c -o $@ $<
scanner_only.o: scanner_only.c
	$(CC) $(CFLAGS) -Wno-sign-compare -Wno-unused-function -c -o $@ $<

scanner_only.c: scanner.l
	$(LEX) -DSCANNER_ONLY $<
	mv lex.yy.c scanner_only.c

scanner.c: scanner.l
	$(LEX) $<
	mv lex.yy.c scanner.c

clean:
	$(RM) scanner.c scanner_only.c scanner.o scanner_only.o scanner
