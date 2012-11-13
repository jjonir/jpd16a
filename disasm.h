#ifndef _DISASM_H
#define _DISASM_H

#include <stdint.h>

int decode_inst(uint16_t *inst, char *buf);

#endif
