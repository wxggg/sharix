#pragma once

#include <types.h>
#include <kerninfo.h>
#include <bitmap.h>

typedef struct point_s
{
	int32_t x;
	int32_t y;
} point_t;

#define POINT(x,y) (point_t){x,y}

typedef struct rect_s
{
	point_t p;
	uint32_t width;
	uint32_t height;
} rect_t;

#define RECTP(p,w,h) ((rect_t){p,w,h})
#define RECT(x,y,w,h) RECTP(POINT(x,y),w,h)

typedef struct rgb_s
{
	uint8_t r;
	uint8_t g;
	uint8_t b;
} rgb_t;

typedef struct painter_s
{
  rgb_t color;
} painter_t;

typedef struct graphic_s
{
  void (*init)(void);
  void (*set_pixel)(int x, int y, rgb_t c);
 	rgb_t (*get_pixel)(int x, int y);

  void (*draw_line)(point_t p1, point_t p2, rgb_t c);
  void (*draw_circle)(point_t p, uint32_t r);
  void (*draw_rect)(rect_t rect, rgb_t c);

  void (*fill_rect)(rect_t rect, rgb_t c);
  void (*fill_circle)(point_t p, uint32_t r);

	void (*draw_bitmap)(rect_t rect, bitmap_t * pbmp);
	void (*fill_bitmap)(rect_t rect, bitmap_t * pbmp);
} graphic_t;

graphic_t * get_graphic();
rect_t get_scrn_rect();
BOOL setpixel(int32_t x, int32_t y, rgb_t c);

void init_screen8();
