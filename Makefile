CC = gcc
CFLAGS = -Wall -Wextra
LEX = flex
LFLAGS =
YACC = bison
YFLAGS = -d -t

.PHONY: all clean

all: jpd16a scanner parser memdump disasm

jpd16a: parser assembler.c
	$(CC) -o $@ assembler.c

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

disasm: disasm.c
	$(CC) $(CFLAGS) -DSTANDALONE -o $@ $<

clean:
	$(RM) jpd16a parser.tab.c parser.tab.h parser.o scanner.c scanner.o parser scanner_only.c scanner_only.o scanner memdump disasm
