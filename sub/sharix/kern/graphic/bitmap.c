#include <bitmap.h>
#include <types.h>
#include <graphic.h>
#include <kerninfo.h> 
#include <math.h>

static bitmap_t* p_bmp_icon = (bitmap_t*)(BMP_ICON_ADDR);

BOOL draw_bitmap(bitmap_t* p_bmp, int x0, int y0)
{
	uint8_t* p_bmp_data_addr = (uint8_t*)p_bmp + p_bmp->file_head.bf_offset_bits;
	uint8_t* p_data;

	/* 不是24位位图 */
	if (p_bmp->info_head.bi_bit_count != 24)
		return FALSE;

	/* 图像的宽、髙 */
	int bmp_cx = abs(p_bmp->info_head.bi_width);
	int bmp_cy = abs(p_bmp->info_head.bi_height);
 
	int nBpline = (((bmp_cx*p_bmp->info_head.bi_bit_count + 31) >> 5) << 2);

	for(int j=0; j<bmp_cy; j++) {
		for(int i=0; i<bmp_cx; i++) {
			p_data = p_bmp_data_addr + nBpline*j + 3*i;
			setpixel(x0+i, y0+j, (rgb_t){p_data[2], p_data[1], p_data[0]});
		}
	}

	return TRUE;
}


void draw_bmp_test()
{
	draw_bitmap(p_bmp_icon, 820, 20);
}