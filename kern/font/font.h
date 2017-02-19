#ifndef _KERN_FONT_H_
#define _KERN_FONT_H_ 

#include <types.h>
#include <graphic.h>

#define ASC16_SIZE 16
#define ASC16_WIDTH 8
#define ASC16_HEIGHT 16



BOOL draw_asc16(char ch, point_t point, rgb_t c);
BOOL draw_str16(char* ch, point_t point, rgb_t c);


#endif


