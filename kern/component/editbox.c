#include <editbox.h>
#include <font.h>
#include <kdebug.h>
#include <stringbuffer.h>

keybuf_t kb;

void getcontent(editbox_t *peb) 
{
    keybuf_init(&kb);
	while(1) {
		edit_readline(peb);
        edit_runcmd(peb);
	} 
}

void edit_putchar(char ch, editbox_t *peb) 
{
    if(ch == '\n' || ch == '\t') {
        peb->cur_y ++;
        peb->cur_x = 0;
        if(peb->cur_y >= peb->ch_y)
            peb->cur_y = 0;
        return;
    } 
	int x = peb->point.x + peb->cur_x*ASC16_WIDTH;
	int y = peb->point.y + peb->cur_y*ASC16_HEIGHT;
	
	draw_asc16(ch, (point_t){x, y}, peb->text_c);
	peb->cur_x ++;
	if(peb->cur_x >= peb->ch_x) {
		peb->cur_x = 0;
		peb->cur_y ++;
	}
	if(peb->cur_y >= peb->ch_y) 
		peb->cur_y = 0;
}
void edit_putstr(char *str, editbox_t *peb)
{
    int length = strlen(str);
    for(int i=0; i<length; i++) {
        edit_putchar(*(str+i), peb);
    }
}

void edit_readline(editbox_t *peb) 
{
    int i = 0 , c;
    memset(peb->ch,'\0',peb->ch_size);
    while (1) {
        while((c=keybuf_pop(&kb)) == 0);
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < 800 - 1) {
            peb->ch[i ++] = c;
            edit_putchar(c, peb);
        }
        else if (c == '\b' && i > 0) {
            i --;
        }
        else if (c == '\n' || c == '\r') {
            peb->ch[i] = '\0';  
            peb->cur_x = 0;
			peb->cur_y ++;
			if(peb->cur_y >= peb->ch_y-1) peb->ch_y = 0;
            return;
        }
    }
}

void edit_runcmd(editbox_t *peb)
{   
    if(strcmp(peb->ch, "hello") == 0)
        edit_putstr("great\n", peb);
    else if(strcmp(peb->ch, "system") == 0)
        draw_bmp_test();
    else if(strcmp(peb->ch, "who are you") == 0)
        edit_putstr("I am joker\n", peb);
    else if(strcmp(peb->ch, "kerninfo") == 0)
        print_kerninfo();
    else;
}