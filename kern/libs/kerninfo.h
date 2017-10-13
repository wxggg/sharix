#ifndef _KERNINFO_H
#define _KERNINFO_H

#include <types.h>
#include <pmm.h>

#define FONT_ASC16_ADDR 0x11000
#define FONT_ASC16_SIZE (4096)

#define BMP_ICON_ADDR FONT_ASC16_ADDR+FONT_ASC16_SIZE
#define BMP_ICON_SIZE (58*1024)

struct BOOTINFO
{
	uint8_t cyls, leds, vmode, reserve;
	uint16_t scrnx, scrny;
	uint8_t bitspixel, mem_model;
	uint16_t reserve2;
	uint8_t *vram;
};


#define ADR_BOOTINFO 0x00000000
#define BOOTINFO_SIZE (sizeof(BOOTINFO))
extern struct BOOTINFO* binfo;

struct CMD
{
	uint8_t word_width;
	uint8_t word_height;
//	uint8_t


};


#endif
