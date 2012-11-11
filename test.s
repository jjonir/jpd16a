:top
set a, b
:arithmetic
add c, x
sub y, z
mul i, j
mli [a], [b]
div [c], [x]
dvi [y], [z]
mod [i], [j]
mdi [a+0], [1+a]
:binary
and [b+2], [3+b]
bor [c+4], [5+c]
xor [x+6], [7+x]
shr [y+8], [9+y]
asr [z+10], [11+z]
shl [i+12], [13+i]
:conditional
ifb [j+14], [15+j]
ifc push, pop
ife [--sp], [sp++]
ifn peek, [sp]
ifg pick[16], [sp+17]
ifa [17+sp], sp
ifl pc, ex
ifu [18], 19
:multiword
adx [a+top], [arithmetic+b]
sbx [c+binary], [conditional+x]
:increment
sti [y+multiword], [increment+z]
std [i+special], [interrupts+j]
:special
jsr pick[hardware]
:interrupts
int data
iag [data2]
ias 'e'
rfi 0x010c
iaq 012345
:hardware
hwn [data]
hwq 0xffff
hwi 1337
:data
dat 0xbeef, 077777, 65535, 'a', "foo bar"
:data2
dat "a string", 0
