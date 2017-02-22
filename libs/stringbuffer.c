#include <stringbuffer.h>
#include <string.h>


void buffer_init(StringBuffer *sb, char *buf, int size)
{
	sb->base = buf;
	sb->top = sb->base;
	sb->stacksize = size;
}

char buffer_gettop(StringBuffer sb)
{
	if(sb.top == sb.base) return 0;
	return *(sb.top-1);
}

void buffer_push(StringBuffer *sb, char ch)
{
	if(sb->top-sb->base >= sb->stacksize) return;
	*(sb->top++) = ch;
}

char buffer_pop(StringBuffer *sb) 
{
	if(sb->top == sb->base) return 0;
	return *(--sb->top);
}

void keybuf_init(keybuf_t *pkb)
{
	memset(pkb->data, 0, 32);
	pkb->front = 0;
	pkb->rear = 0;
}

bool keybuf_push(keybuf_t *pkb, char ch)
{
	if(pkb->front-pkb->rear == 1)
		return 0;
	if((pkb->front==0 && pkb->rear==31))
		return 0;
	pkb->data[pkb->rear] = ch;
	if(++pkb->rear == 32)
		pkb->rear = 0;
	return 1;
}

char keybuf_pop(keybuf_t *pkb)
{
	if(pkb->front == pkb->rear)
		return 0;
	char c = pkb->data[pkb->front];
	if(++pkb->front == 32)
		pkb->front = 0;

	return c;
}