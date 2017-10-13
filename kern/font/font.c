#include <kerninfo.h>
#include <graphic.h>
#include <font.h>

static uint8_t* p_font_asc16_b = (uint8_t*)(FONT_ASC16_ADDR+KERNBASE);

BOOL draw_asc16(char ch, point_t point, rgb_t c)
{
	uint8_t * p_asc = p_font_asc16_b + (uint8_t)ch * 16;

	for(int y=0; y<ASC16_HEIGHT; y++){
		uint8_t testbit = 1 << 7;
		for(int x=0; x<ASC16_WIDTH; x++)
		{
			if(*p_asc & testbit)
				setpixel(point.x+x, point.y+y, c);
			testbit >>= 1;
		}
		p_asc ++;
	}
	return TRUE;
}

BOOL draw_str16(char* ch, point_t point, rgb_t c)
{
	unsigned char * p = (unsigned char *)ch;
	int x=point.x, y=point.y;
	while(*p != '\0') {
		draw_asc16(*p, (point_t){x, y}, c);
		x += 8;
		p++;
	}
	return TRUE;
}
