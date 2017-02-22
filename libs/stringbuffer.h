#ifndef __LIB_STRINGBUFFER_H__
#define __LIB_STRINGBUFFER_H__ 

#include <types.h>

typedef struct
{
	char *base;
	char *top;
	int stacksize;
} StringBuffer;

typedef struct keybuf_s
{
	unsigned char data[32];
	int front, rear;
} keybuf_t;

void keybuf_init(keybuf_t *pkb);
bool keybuf_push(keybuf_t *pkb, char ch);
char keybuf_pop(keybuf_t *pkb);


#endif