#pragma once

#include <types.h>
#include <memlayout.h>

struct pmm_manager
{
	const char *name;
	void (*init)(void);
	void (*init_memmap)(struct Page *base, size_t n);
	struct Page *(*alloc_pages)(size_t n);
	void (*free_pages)(struct Page *base, size_t n);
	void (*check)(void);
};

extern const struct pmm_manager *pmm_manager;

void pmm_init(void);

#define PADDR(kva) ({uintptr_t __m_kva = (uintptr_t)(kva); \
					__m_kva - KERNBASE;})

