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
	void (*pageinfo)(void);
};

extern const struct pmm_manager *pmm_manager;
extern struct Page pages;

void pmm_init(void);

struct Page *alloc_pages(size_t n);
void free_pages(struct Page *base, size_t n);

#define PADDR(kva) ({uintptr_t __m_kva = (uintptr_t)(kva); \
					__m_kva - KERNBASE;})

#define VADDR(kpa) ({uintptr_t __m_kpa = (uintptr_t)(kpa); \
					__m_kpa + KERNBASE;})

static inline uintptr_t get_page_addr(struct Page *page)
{
	int number = page-pages;
}