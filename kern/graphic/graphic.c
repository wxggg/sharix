#include <graphic.h>
#include <asm_tool.h>
#include <font.h>

const struct BOOTINFO *binfo = (struct BOOTINFO *) ADR_BOOTINFO;
static Color bgcolor = 0;

static BOOL is_pixel_valid(int32_t x, int32_t y)
{
	if(x<0 || y<0 || (uint32_t)x >= binfo->scrnx || (uint32_t)y >= binfo->scrny)
		return FALSE;
	return TRUE;
}

BOOL _gSetPixel(int32_t x, int32_t y, Color c)
{
	if(!is_pixel_valid(x, y))
		return FALSE;
	uint8_t * pvram = binfo->vram + y*binfo->scrnx + x;
	*pvram = c;
	return TRUE;
}

Color _gGetPixel(int32_t x, int32_t y)
{
	if(!is_pixel_valid(x,y))
		return 0;
	uint8_t * pvram = binfo->vram + y*binfo->scrnx + x;
	return *pvram;
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
	init_palette();
	init_screen8(binfo->vram, 320, 200);

	draw_asc16(':', (point_t){22, 2}, black);
	draw_str16("I am Joker", (point_t){30, 2}, light_red);
}

void init_palette(void)
{
	static uint8_t table_rgb[16 * 3] = {
		0x00, 0x00, 0x00,	/*  0:黑*/
		0xff, 0x00, 0x00,	/*  1:亮红*/
		0x00, 0xff, 0x00,	/*  2:亮绿*/
		0xff, 0xff, 0x00,	/*  3:亮黄*/
		0x00, 0x00, 0xff,	/*  4:亮蓝*/
		0xff, 0x00, 0xff,	/*  5:亮紫*/
		0x00, 0xff, 0xff,	/*  6:浅亮蓝*/
		0xff, 0xff, 0xff,	/*  7:白*/
		0xc6, 0xc6, 0xc6,	/*  8:亮灰 */
		0x84, 0x00, 0x00,	/*  9:暗红 */
		0x00, 0x84, 0x00,	/* 10:暗绿 */
		0x84, 0x84, 0x00,	/* 11:暗黄 */
		0x00, 0x00, 0x84,	/* 12:暗青 */
		0x84, 0x00, 0x84,	/* 13:暗紫 */
		0x00, 0x84, 0x84,	/* 14:浅暗蓝 */
		0x84, 0x84, 0x84	/* 15:暗灰 */
	};
	set_palette(0, 15, table_rgb);
	return;

}

void set_palette(int start, int end, uint8_t *rgb)
{
	int i, eflags;
	eflags = io_load_eflags();	/*记录中断许可标志的值  */
	io_cli(); 					/* 将中断许可标志置为0，禁止中断 */
	io_out8(0x03c8, start);
	for (i = start; i <= end; i++) {
		io_out8(0x03c9, rgb[0] / 4);
		io_out8(0x03c9, rgb[1] / 4);
		io_out8(0x03c9, rgb[2] / 4);
		rgb += 3;
	}
	io_store_eflags(eflags);	/*复原中断许可标志*/
	return;
}

void init_screen8()
{
	bgcolor = ld_blue;

	_gfillrect2(ld_blue, (rect_t){0,0,320,200});
	_gfillrect2(ll_blue, (rect_t){0,0,20,200});
	_gfillrect2(white, (rect_t){0,180, 20,200});
//	_gfillrect2(light_yellow, (rect_t){0,100,50,180}); 

	_gdrawrect(dark_purple, (rect_t){0, 0, 20, 200});

	for(int i=0; i<10; i++)
	{
		_gfillrect2(light_green, (rect_t){2, 2+20*i, 16, 16});
		_gdrawrect(dark_grey, (rect_t){2, 2+20*i, 16, 16});
	}

	_gdrawline(4, (point_t){20, 20}, (point_t){300, 20});


	return;
}

void draw_mouse(char *mouse) 
{
	rect_t rect = {30,40,16,16};
	_gfillrect(mouse, rect);
}

void _gdrawline(Color c, point_t p1, point_t p2)
{
	BOOL type = (p2.x-p1.x) > (p2.y-p1.y);
	if(type) {
		float yt1 = p1.y, dy = (float)(p2.y-p1.y)/(p2.x-p1.x);
		int xt1=p1.x;
		for(;yt1<=p2.y && xt1<=p2.x; yt1+=dy, xt1++)
			_gSetPixel(xt1, (int)yt1, c);
	} else{
		float xt2 = p1.x, dx = (float)(p2.x-p1.x)/(p2.y-p1.y);
		int yt2 = p1.y;
		for(;xt2<=p2.x && yt2<=p2.y; xt2+=dx, yt2++)
			_gSetPixel((int)xt2, yt2, c);
	}


}

void _gdrawrect(Color c, rect_t	rect)
{
	int x1 = rect.left, x2 = rect.left+rect.width-1;
	int y1 = rect.top, y2 = rect.top+rect.height-1;
	_gdrawline(c, (point_t){x1, y1}, (point_t){x2, y1});
	_gdrawline(c, (point_t){x1, y1}, (point_t){x1, y2});
	_gdrawline(c, (point_t){x2, y1}, (point_t){x2, y2});
	_gdrawline(c, (point_t){x1, y2}, (point_t){x2, y2});
}

void _gfillrect(char *buf, rect_t rect)
{	
	for(int i=0; i<rect.height; i++) {
		for(int j=0; j<rect.width; j++) {
			binfo->vram[(rect.top+i)*binfo->scrnx+rect.left+j] = buf[i*rect.width+j];
		}
	}
}

void _gfillrect2(Color c, rect_t rect)
{
	for(int i=0; i<rect.height; i++) {
		for(int j=0; j<rect.width; j++) {
			binfo->vram[(rect.top+i)*binfo->scrnx+rect.left+j] = c;
		}
	}
}

void init_mouse_cursor8(char *mouse)
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
				mouse[y * 16 + x] = COL8_00FF00;
			}
			if (cursor[y][x] == 'O') {
				mouse[y * 16 + x] = COL8_FFFFFF;
			}
			if (cursor[y][x] == '.') {
				mouse[y * 16 + x] = bgcolor;
			}
		}
	}
	return;
}
