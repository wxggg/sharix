#ifndef _KERN_EDITBOX_H
#define _KERN_EDITBOX_H 

#include <types.h>

typedef struct editbox_s
{
	point_t point;
	int ch_x; //num of width
	int ch_y; // num of height
	rgb_t bg_c;
	rgb_t text_c; 
	int cur_x, cur_y;
	char * ch;
	int ch_size;
} editbox_t;

void getcontent(editbox_t * peb);

#endif