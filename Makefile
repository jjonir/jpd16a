CC = gcc
CFLAGS = -Wall -Wextra
LEX = flex
LFLAGS = 
YACC = bison
YFLAGS = -d -t

.PHONY: all clean

all: scanner parser memdump

parser: parser.o scanner.o
	$(CC) -o $@ parser.o scanner.o

parser.o: parser.tab.c
	$(CC) $(CFLAGS) -c -o $@ $<

parser.tab.c: parser.y
	$(YACC) $(YFLAGS) $<

scanner.o: scanner.c parser.tab.c
	$(CC) $(CFLAGS) -Wno-sign-compare -Wno-unused-function -c -o $@ $<

scanner.c: scanner.l
	$(LEX) $<
	mv lex.yy.c scanner.c

# Build just the scanner: scans its input or provided file and prints tokens
scanner: scanner_only.o
	$(CC) -o $@ $< -lfl

scanner_only.o: scanner_only.c parser.tab.c
	$(CC) $(CFLAGS) -Wno-sign-compare -Wno-unused-function -c -o $@ $<

scanner_only.c: scanner.l
	$(LEX) -DSCANNER_ONLY $<
	mv lex.yy.c scanner_only.c

memdump: memdump.c
	$(CC) $(CFLAGS) -o $@ $<

clean:
	$(RM) parser.tab.c parser.tab.h parser.o scanner.c scanner.o parser scanner_only.c scanner_only.o scanner memdump
