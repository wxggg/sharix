#ifndef __KERN_DRIVER_CLOCK_H__
#define __KERN_DRIVER_CLOCK_H__ 

#include <types.h>

void clock_init(void);

extern volatile size_t ticks;

#endif