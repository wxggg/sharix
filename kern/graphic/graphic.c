#include <graphic.h>
#include <asm_tool.h>
#include <font.h>
#include <bitmap.h>
#include <color.h>
#include <editbox.h>
#include <monitor.h>
#include <memlayout.h>
#include <stdio.h>
#include <string.h>

struct BOOTINFO *binfo = (struct BOOTINFO *)(ADR_BOOTINFO);

void draw_editbox(editbox_t eb);

struct BOOTINFO* get_bootinfo() {
	return binfo;
}

inline BOOL is_pixel_valid(int32_t x, int32_t y)
{
	if(x<0 || y<0 || (uint32_t)x >= binfo->scrnx || (uint32_t)y >= binfo->scrny)
		return FALSE;
	return TRUE;
}

inline BOOL setpixel(int32_t x, int32_t y, rgb_t c)
{
	// cprintf("vram:%x scrnx:%d scrny:%d\n", binfo->vram, binfo->scrnx, binfo->scrny);
//	if(!is_pixel_valid(x, y))
//		return FALSE;

	int nBppixel = binfo->bitspixel>>3;
	uint8_t * pvram = (uint8_t*)(binfo->vram + nBppixel*binfo->scrnx*y + nBppixel*x);
	// cprintf("setpixel: pvram:%x\n", *pvram);
	// *pvram = c;

	// cprintf("wtf:%x ---------------------------\n", *pvram);

	*pvram = c.r;
	*(pvram+1) = c.g;
	*(pvram+2) = c.b;
	return TRUE;
}

rgb_t _gGetPixel(int32_t x, int32_t y)
{
	if(!is_pixel_valid(x,y))
		return (rgb_t){0,0,0};
	//uint8_t * pvram = binfo->vram + y*binfo->scrnx + x;
	//return *pvram;
	return (rgb_t){0,0,0};
}

rect_t _gGetScrnRect()
{
	rect_t rect;
	rect.left = 0;
	rect.top = 0;
	rect.width = binfo->scrnx;
	rect.height = binfo->scrny;
	return rect;
}


void graphic_init()
{
	binfo->vram += KERNBASE;
	cprintf("graphic_init\n");
	init_screen8();

	draw_asc16('>', (point_t){22, 2}, MediumBlue);
	draw_str16("Chill out!", (point_t){30, 2}, (rgb_t){32,33,22});

  rgb_t buff[16*16];
  init_mouse_cursor8(buff);
  draw_mouse(buff);

	char buf[100];
	memset(buf,'\0',100);

	editbox_t eb;
	eb.point = (point_t){100,100};
	eb.ch_x = 60;
	eb.ch_y = 30;
	eb.bg_c = Pink;
	eb.text_c = Black;
	eb.ch = buf;
	eb.ch_size = 100;
	eb.cur_x = eb.cur_y = 0;

	draw_editbox(eb);
 	getcontent(&eb);

}

void init_screen8()
{
	cprintf("wtf binfo:%x\n", binfo);
	cprintf("scrnx:%d binfo:%x", binfo->scrnx, binfo);
	setpixel(20,30,(rgb_t){0,0xff,0});
	_gfillrect2((rgb_t){20,40,100}, (rect_t){0,0,binfo->scrnx,binfo->scrny});
	cprintf("wtf");
	_gdrawrect((rgb_t){100,100,100}, (rect_t){0, 0, 64, 700});

	for(int i=0; i<10; i++)
	{
		_gfillrect2((rgb_t){200,220,10}, (rect_t){2, 2+70*i, 60, 60});
		_gdrawrect((rgb_t){32,33,44}, (rect_t){2, 2+70*i, 60, 60});
	}

	_gdrawline((rgb_t){211,22,32}, (point_t){100, 70}, (point_t){800, 70});
	draw_str16("Rolling in the deep", (point_t){120,20}, Black);

	return;
}

void draw_editbox(editbox_t eb) {
	_gfillrect2(eb.bg_c, (rect_t){eb.point.x, eb.point.y, eb.ch_x*ASC16_WIDTH, eb.ch_y*ASC16_HEIGHT});
}

void draw_mouse(rgb_t *mouse)
{
	rect_t rect = {30,40,16,16};
	_gfillrect(mouse, rect);
}

void _gdrawline(rgb_t c, point_t p1, point_t p2)
{
	BOOL type = (p2.x-p1.x) > (p2.y-p1.y);
	if(type) {
		float yt1 = p1.y, dy = (float)(p2.y-p1.y)/(p2.x-p1.x);
		int xt1=p1.x;
		for(;yt1<=p2.y && xt1<=p2.x; yt1+=dy, xt1++)
			setpixel(xt1,yt1,c);
	} else{
		float xt2 = p1.x, dx = (float)(p2.x-p1.x)/(p2.y-p1.y);
		int yt2 = p1.y;
		for(;xt2<=p2.x && yt2<=p2.y; xt2+=dx, yt2++)
			setpixel(xt2, yt2,c);
	}


}

void _gdrawrect(rgb_t c, rect_t	rect)
{
	int x1 = rect.left, x2 = rect.left+rect.width-1;
	int y1 = rect.top, y2 = rect.top+rect.height-1;
	_gdrawline(c, (point_t){x1, y1}, (point_t){x2, y1});
	_gdrawline(c, (point_t){x1, y1}, (point_t){x1, y2});
	_gdrawline(c, (point_t){x2, y1}, (point_t){x2, y2});
	_gdrawline(c, (point_t){x1, y2}, (point_t){x2, y2});
}

void _gfillrect(rgb_t *buf, rect_t rect)
{
	for(int x=rect.left; x<rect.left+rect.width; x++)
		for(int y=rect.top; y<rect.top+rect.height; y++)
			setpixel(x, y, buf[(x-rect.left) + rect.width*(y-rect.top)]);
}

void _gfillrect2(rgb_t c, rect_t rect)
{
	for(int x=rect.left; x<rect.left+rect.width; x++)
		for(int y=rect.top; y<rect.top+rect.height; y++) {
			// cprintf(".");
			setpixel(x, y, c);

		}

}

void init_mouse_cursor8(rgb_t *mouse)
{
	static char cursor[16][16] = {
		"**************..",
		"*OOOOOOOOOOO*...",
		"*OOOOOOOOOO*....",
		"*OOOOOOOOO*.....",
		"*OOOOOOOO*......",
		"*OOOOOOO*.......",
		"*OOOOOOO*.......",
		"*OOOOOOOO*......",
		"*OOOO**OOO*.....",
		"*OOO*..*OOO*....",
		"*OO*....*OOO*...",
		"*O*......*OOO*..",
		"**........*OOO*.",
		"*..........*OOO*",
		"............*OO*",
		".............***"
	};
	int x, y;

	for (y = 0; y < 16; y++) {
		for (x = 0; x < 16; x++) {
			if (cursor[y][x] == '*') {
				mouse[y * 16 + x] = LightPink;
			}
			if (cursor[y][x] == 'O') {
				mouse[y * 16 + x] = Navy;
			}
			if (cursor[y][x] == '.') {
				mouse[y * 16 + x] = BlueViolet;
			}
		}
	}
	return;
}
