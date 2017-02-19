#ifndef _KERN_BITMAP_H_
#define _KERN_BITMAP_H_ 

#include <types.h>

#pragma pack(1)
typedef struct bitmap_file_header_t {
	uint16_t bf_type;//文件标示
	uint32_t bf_size;// 用字节表示的整个文件的大小
	uint32_t bf_reserved;//保留必须为０
	uint32_t bf_offset_bits;//从文件开始到位图数据开始之间的偏移量
} bitmap_file_header_t;

typedef struct bitmap_info_header_t
{
	uint32_t bi_size;//bitmap_info_header_size
	int32_t bi_width;//位图宽度像素单位
	int32_t bi_height;
	uint16_t bi_planes;//位图位面数=1
	uint16_t bi_bit_count;//每个像素位数
	uint32_t bi_compression;//压缩方式
	uint32_t bi_size_image;//位图数据大小，４的倍数
	int32_t bi_xpels_per_meter;//水平分辨率
	int32_t bi_ypels_per_meter;
	uint32_t bi_clr_used;//颜色数
	uint32_t bi_clr_important;//重要的颜色数
} bitmap_info_header_t;
#pragma pack()

typedef struct bitmap24_t
{
	bitmap_file_header_t file_head;
	bitmap_info_header_t info_head;
} bitmap_t;

void draw_bmp_test();

#endif