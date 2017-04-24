#include <pmm.h>
#include <memlayout.h>
#include <mmu.h>
#include <buddy_pmm.h>


size_t npage = 0;

struct Page *pages; //the begin address of pages

const struct pmm_manager *pmm_manager;

static void init_pmm_manager(void)
{
	cprintf("init_pmm_manager\n");
	pmm_manager = &buddy_pmm_manager;
	cprintf("memory management: %s\n", pmm_manager->name);
	pmm_manager->init();
}

static void init_memmap(struct Page *base, size_t n)
{
	pmm_manager->init_memmap(base, n);
}


static void page_init(void)
{
	struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);

	uint64_t maxpa = 0, begin, free_end;

	for (int i = 0; i < memmap->nr_map; ++i)
	{
		begin = memmap->map[i].addr;
		free_end = begin + memmap->map[i].size;
		cprintf("map[%d]: begin:%08llx free_end:%08llx size:%08llx type:%d\n", 
			i, begin, free_end-1, memmap->map[i].size, memmap->map[i].type);
		if(memmap->map[i].type == E820_ARM) {
			if(maxpa < free_end && begin < KMEMSIZE)
				maxpa = free_end;
		}
	}
	if(maxpa > KMEMSIZE) maxpa = KMEMSIZE;

	extern char end[];
	cprintf("end:%x", end);
	npage = maxpa / PGSIZE;
	pages = (struct Page *)ROUND_UP((void*)end, PGSIZE);

//	for(int i=0; i<npage; ++i)
//		SetPageReserved(pages+i);

	uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page)*npage);
	cprintf("freemem:%x", freemem);
	for (int i=0; i<memmap->nr_map; ++i) {
		begin = memmap->map[i].addr;
		free_end = begin + memmap->map[i].size;
		if(memmap->map[i].type == E820_ARM) 
		{
			if(begin < freemem) begin = freemem;
			if(free_end > KMEMSIZE) free_end = KMEMSIZE;
			if(begin < free_end) 
			{
				begin = ROUND_UP(begin, PGSIZE);
				free_end = ROUND_DOWN(free_end, PGSIZE);
				if(begin < free_end) {
					cprintf("------- begin:%8llx free_end:%8llx\n", begin, free_end);
					init_memmap(VADDR(begin), (free_end-begin)/PGSIZE);
				}
			}
		}
	}
	cprintf("free_end:%x \n", free_end);

	cprintf("maxpa:%x \n", maxpa);
	cprintf("npage:%d  pages:%x", npage, pages);
}

static void check_alloc_page()
{
	pmm_manager->check();
}
static void gdt_init(void)
{
	// set boot kernel stack and default SS0
//	ts.ts_esp0 = (uintptr_t)bootstacktop;

}
void pmm_init(void) 
{
	init_pmm_manager();
	page_init();

	check_alloc_page();

//	while(1){}
//	gdt_init();
}

struct Page *alloc_pages(size_t n)
{
	cprintf("alloc_pages n=%d  ", n);
	struct Page *page = pmm_manager->alloc_pages(n);
	cprintf("page:%x\n", page);
	return page;
}
void free_pages(struct Page *base, size_t n)
{
	pmm_manager->free_pages(base, n);
}
void pageinfo()
{
	pmm_manager->pageinfo();
}