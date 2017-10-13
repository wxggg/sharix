#ifndef _KERN_GRAPHIC_H
#define _KERN_GRAPHIC_H


#include <types.h>
#include <kerninfo.h>



void graphic_init() ;
void init_mouse_cursor8(rgb_t *mouse);

BOOL setpixel(int32_t x, int32_t y, rgb_t c);
rgb_t _gGetPixel(int32_t x, int32_t y);
rect_t _gGetScrnRect();
void init_screen8();
void draw_mouse(rgb_t *mouse);

void _gdrawline(rgb_t c, point_t p1, point_t p2);
void _gdrawrect(rgb_t c, rect_t	rect);
void _gfillrect(rgb_t *buf, rect_t rect);
void _gfillrect2(rgb_t c, rect_t rect);
BOOL is_pixel_valid(int32_t x, int32_t y);

struct BOOTINFO* get_bootinfo();

#endif
