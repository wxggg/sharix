#pragma once

#include <types.h>
#include <memlayout.h>
#include <mmu.h>

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
extern struct Page *pages;
extern char bootstack[], bootstacktop[];

void pmm_init(void);

struct Page *alloc_pages(size_t n);
#define alloc_page() alloc_pages(1)
void pageinfo();

void free_pages(struct Page *base, size_t n);
#define free_page(page) free_pages(page, 1)

void tlb_invalidate(uintptr_t *pgdir, uintptr_t la);
void print_pgdir(void);

#define PADDR(kva) ({uintptr_t __m_kva = (uintptr_t)(kva); \
					__m_kva - KERNBASE;})

#define VADDR(kpa) ({uintptr_t __m_kpa = (uintptr_t)(kpa); \
					__m_kpa + KERNBASE;})

/* *
 * KADDR - takes a physical address and returns the corresponding kernel virtual address. It panics if you pass an invalid physical address.
 * */
#define KADDR(pa) ({                                                    \
			uintptr_t __m_pa = (pa);                                    \
			(void *) (__m_pa + KERNBASE);                               \
})

static inline struct Page* n2page(int n)
{
	return &pages[n];
}
static inline int page2n(struct Page* page)
{
	return page - pages;
}

static inline uintptr_t page2pa(struct Page *page)
{
	return page2n(page) << 12;
}
static inline struct Page* pa2page(uintptr_t p)
{
	return &pages[PAGE_NUM(p)];
}

static inline uintptr_t page2va(struct Page *page)
{
	return VADDR(page2pa(page));
}
static inline struct Page* va2page(uintptr_t p)
{
	return pa2page(PADDR(p));
}

static inline struct Page * pte2page(uintptr_t pte)
{
	return pa2page(PTE_ADDR(pte));
}
static inline struct Page * pde2page(uintptr_t pde)
{
	return pa2page(PDE_ADDR(pde));
}

static inline void *
page2kva(struct Page *page) {
    return KADDR(page2pa(page));
}

static inline struct Page *
kva2page(void *kva) {
    return pa2page(PADDR(kva));
}
