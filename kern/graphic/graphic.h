#include <types.h>

struct BOOTINFO
{
	char cyls, leds, vmode, reserve;
	uint16_t scrnx, scrny;
	uint8_t *vram;
};
#define ADR_BOOTINFO 0x00000000

/*  0:黑*//*  1:亮红*//*  2:亮绿*//*  3:亮黄*//*  4:亮蓝*//*  5:亮紫*//*  6:浅亮蓝*//*  7:白*/
/*  8:亮灰 *//*  9:暗红 *//* 10:暗绿 *//* 11:暗黄 *//* 12:暗青 *//* 13:暗紫 *//* 14:浅暗蓝 *//* 15:暗灰 */
#define	COL8_000000		0
#define	COL8_FF0000		1 
#define	COL8_00FF00		2
#define	COL8_FFFF00		3
#define	COL8_0000FF		4
#define	COL8_FF00FF		5
#define	COL8_00FFFF		6
#define	COL8_FFFFFF		7
#define	COL8_C6C6C6		8
#define	COL8_840000		9
#define	COL8_008400		10
#define	COL8_848400		11
#define	COL8_000084		12
#define	COL8_840084		13
#define	COL8_008484		14
#define COL8_848484		15

typedef enum Color
{
	black = 0, light_red, light_green, light_yellow, light_blue,
	light_purple, ll_blue, white, light_grey, dark_red, dark_green, dark_yellow,
	dark_blue, dark_purple, ld_blue, dark_grey  
}Color;

void graphic_init() ;
void set_palette(int start, int end, unsigned char *rgb);
void init_palette(void);
void init_mouse_cursor8(char *mouse);

BOOL _gSetPixel(int32_t x, int32_t y, Color c);
Color _gGetPixel(int32_t x, int32_t y);
static BOOL is_pixel_valid(int32_t x, int32_t y);
rect_t _gGetScrnRect();
void init_screen8();
void draw_mouse(char *mouse);

void _gdrawline(Color c, point_t p1, point_t p2);
void _gdrawrect(Color c, rect_t	rect);
void _gfillrect(char *buf, rect_t rect);
void _gfillrect2(Color c, rect_t rect);
static BOOL is_pixel_valid(int32_t x, int32_t y);
