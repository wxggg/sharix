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
#include <kerninfo.h>
#include <slab.h>
#include <math.h>

/*********** global value ************/
graphic_t *g = NULL;



/********* graphic library *******************/
static inline BOOL is_pixel_valid(int32_t x, int32_t y)
{
	if(x<0 || y<0 || (uint32_t)x >= binfo->scrnx || (uint32_t)y >= binfo->scrny)
		return FALSE;
	return TRUE;
}

static void set_pixel(int x, int y, rgb_t c)
{
	if(!is_pixel_valid(x,y))
		return;
	int nBppixel = binfo->bitspixel>>3;
	uint8_t * pvram = (uint8_t*)(binfo->vram + nBppixel*binfo->scrnx*y + nBppixel*x);
	*pvram = c.b;
	*(pvram+1) = c.g;
	*(pvram+2) = c.r;
}

static rgb_t get_pixel(int32_t x, int32_t y)
{
	if(!is_pixel_valid(x,y))
		return (rgb_t){0,0,0};
	uint8_t * pvram = binfo->vram + y*binfo->scrnx + x;
	return (rgb_t){*pvram,*(pvram+1),*(pvram+2)};
}

static void draw_line(point_t p1, point_t p2, rgb_t c)
{
	if(p2.x<p1.x || p2.y<p1.y) {
		draw_line(p2, p1, c);
		return;
	}

	BOOL type = (p2.x-p1.x) > (p2.y-p1.y);
	if(type) {
		float yt1 = p1.y, dy = (float)(p2.y-p1.y)/(p2.x-p1.x);
		int xt1=p1.x;
		for(;yt1<=p2.y && xt1<=p2.x; yt1+=dy, xt1++)
			set_pixel(xt1,yt1,c);
	} else{
		float xt2 = p1.x, dx = (float)(p2.x-p1.x)/(p2.y-p1.y);
		int yt2 = p1.y;
		for(;xt2<=p2.x && yt2<=p2.y; xt2+=dx, yt2++)
			set_pixel(xt2, yt2,c);
	}
}

static void draw_rect(rect_t rect, rgb_t c)
{
	point_t p1 = rect.p;
	point_t p2 = (point_t){p1.x, p1.y+rect.height-1};
	point_t p3 = (point_t){p1.x+rect.width-1, p1.y};
	point_t p4 = (point_t){p1.x+rect.width-1, p1.y+rect.height-1};
	draw_line(p1, p2, c);
	draw_line(p2, p4, c);
	draw_line(p4, p3, c);
	draw_line(p3, p1, c);
}

static void fill_rect(rect_t rect, rgb_t c)
{
	int nBppixel = binfo->bitspixel>>3;
	int scrnx = binfo->scrnx;
	int scrny = binfo->scrny;
	int left = rect.p.x, right = rect.p.x+rect.width-1;
	int top = rect.p.y, bottom = rect.p.y+rect.height-1;

	if(left>right || top>bottom || left>scrnx-1 || top>scrny-1) return;
	if(left < 0) left = 0;
	if(top < 0) top = 0;
	if(right > scrnx-1) right = scrnx-1;
	if(bottom > scrny-1) bottom = scrny-1;

	uint8_t * vram = (uint8_t*)binfo->vram;
	uint8_t *pvram = vram;

	for (size_t i = top; i <= bottom; i++) {
		for (size_t j = left; j <= right; j++) {
			pvram = (uint8_t*)(vram + nBppixel*(scrnx*i+j));
			*pvram = c.b;
			*(pvram+1) = c.g;
			*(pvram+2) = c.r;
		}
	}
}

static void draw_bitmap(rect_t rect, bitmap_t * pbmp)
{
	uint8_t * pbmp_addr = (uint8_t*)pbmp+pbmp->file_head.bf_offset_bits;
	uint32_t nbit = pbmp->info_head.bi_bit_count;
	if(nbit != 24) return;
	uint32_t width = abs(pbmp->info_head.bi_width);
	uint32_t height = abs(pbmp->info_head.bi_height);

	size_t nBpline = ((width*nbit + 31) >> 5) << 2;

	size_t x0 = rect.p.x, y0 = rect.p.y;
	if(width > rect.width) width = rect.width;
	if(height > rect.height) height = rect.height;

	int nBppixel = binfo->bitspixel>>3;
	int scrnx = binfo->scrnx;
	int scrny = binfo->scrny;

	if(x0+width > scrnx) width = scrnx-x0-1;
	if(y0+height > scrny) height = scrny-y0-1;

	uint8_t * vram = (uint8_t*)binfo->vram;
	uint8_t *pvram = vram;
	uint8_t *pdata = pbmp_addr;
	for (size_t i = 0; i < width; i++) {
		for (size_t j = 0; j < height; j++) {
			pvram = (uint8_t*)(vram + nBppixel*(scrnx*(y0+j)+x0+i));
			pdata = (uint8_t*)(pbmp_addr + nBpline*j + i*3);
			*pvram = *pdata;
			*(pvram+1) = *(pdata+1);
			*(pvram+2) = *(pdata+2);
		}
	}
}

static void fill_bitmap(rect_t rect, bitmap_t * pbmp)
{
	uint32_t width = abs(pbmp->info_head.bi_width);
	uint32_t height = abs(pbmp->info_head.bi_height);

	size_t x = rect.p.x, y = rect.p.y;
	while (x<rect.p.x+rect.width) {
		y = rect.p.y;
		while (y<rect.p.y+rect.height) {
			draw_bitmap(RECT(x,y,width,height), pbmp);
			y += height;
		}
		x += width;
	}
}



/************* get ***************/
graphic_t * get_graphic()
{
	if(!g) {
		g = (graphic_t*) kmalloc(sizeof(graphic_t));
		g->set_pixel = set_pixel;
		g->get_pixel = get_pixel;
		g->draw_line = draw_line;
		g->draw_rect = draw_rect;
		g->fill_rect = fill_rect;
		g->draw_bitmap = draw_bitmap;
		g->fill_bitmap = fill_bitmap;
	}
	return g;
}

rect_t get_scrn_rect()
{
	rect_t rect = RECT(0, 0, binfo->scrnx, binfo->scrny);
	return rect;
}
