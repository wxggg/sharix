#pragma once

#define SEG_KTEXT 1
#define SEG_KDATA 2
#define SEG_UTEXT 3
#define SEG_UDATA 4
#define SEG_TSS   5

/* global descriptor numbers */

/* global descrptor numbers */
#define GD_KTEXT    ((SEG_KTEXT) << 3)      // kernel text
#define GD_KDATA    ((SEG_KDATA) << 3)      // kernel data
#define GD_UTEXT    ((SEG_UTEXT) << 3)      // user text
#define GD_UDATA    ((SEG_UDATA) << 3)      // user data
#define GD_TSS      ((SEG_TSS) << 3)        // task segment selector

#define DPL_KERNEL 	(0)
#define DPL_USER 	(3)

#define KERNEL_CS   ((GD_KTEXT) | DPL_KERNEL)
#define KERNEL_DS   ((GD_KDATA) | DPL_KERNEL)
#define USER_CS     ((GD_UTEXT) | DPL_USER)
#define USER_DS     ((GD_UDATA) | DPL_USER)

#define KERNBASE 	0xC0000000
#define KMEMSIZE 	0x38000000
#define KERNTOP 	(KERNBASE + KMEMSIZE)

#define KSTACKPAGE 	2
#define KSTACKSIZE 	(KSTACKPAGE * PGSIZE)

#ifndef __ASSEMBLER__

#include <types.h>

#include <list.h>
#include <atomic.h>

#define E820MAX 	20 
#define E820_ARM 	1	// memory
#define E820_ARR 	2 	// reserved

struct e820map
{
	int nr_map;
	struct 
	{
		uint64_t addr;
		uint64_t size;
		uint32_t type;
	}map[E820MAX];
};

struct Page
{
	uint32_t flags;
	unsigned int order;
	list_entry_t page_link;
};

#define PG_reserved 	0
#define PG_property		1 // if =1 means is valid

#define SetPageReserved(page) 	set_bit(PG_reserved, &((page)->flags))
#define ClearPageReserved(page) clear_bit(PG_reserved, &((page)->flags))
#define PageReserved(page) 		test_bit(PG_reserved, &((page)->flags))

#define SetPageProperty(page) 	set_bit(PG_reserved, &((page)->flags))
#define ClearPageProperty(page) clear_bit(PG_property, &((page)->flags))
#define PageProperty(page) 		test_bit(PG_property, &((page)->flags))

typedef struct 
{
	list_entry_t free_list;
	unsigned int nr_free;	// # of free pages 
} free_area_t;

#endif
