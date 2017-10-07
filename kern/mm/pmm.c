#include <pmm.h>
#include <memlayout.h>
#include <mmu.h>
#include <buddy_pmm.h>
#include <x86.h>
#include <stdio.h>
#include <string.h>
#include <kdebug.h>

static struct taskstate ts = {0};

uintptr_t *boot_pgdir = NULL;
uintptr_t boot_cr3;

size_t npage = 0;

struct Page *pages; //the begin address of pages

const struct pmm_manager *pmm_manager;

uintptr_t * const vpt = (uintptr_t *)VPT;
uintptr_t * const vpd = (uintptr_t *)PGADDR(PDX(VPT), PDX(VPT), 0);


static struct segdesc gdt[] = {
	SEG_NULL,
    [SEG_KTEXT] = SEG(STA_X | STA_R, 0x0, 0xFFFFFFFF, DPL_KERNEL),
    [SEG_KDATA] = SEG(STA_W, 0x0, 0xFFFFFFFF, DPL_KERNEL),
    [SEG_UTEXT] = SEG(STA_X | STA_R, 0x0, 0xFFFFFFFF, DPL_USER),
    [SEG_UDATA] = SEG(STA_W, 0x0, 0xFFFFFFFF, DPL_USER),
    [SEG_TSS]   = SEG_NULL,
};

static struct pseudodesc gdt_pd = {
	sizeof(gdt) -1, (uintptr_t)gdt
};

static void check_pgdir(void);
void check_boot_pgdir();
uintptr_t * get_pte(uintptr_t *pgdir, uintptr_t la);
static int get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store);

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
					init_memmap(pa2page(begin), (free_end-begin)/PGSIZE);
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

static inline void
lgdt(struct pseudodesc *pd) {
    asm volatile ("lgdt (%0)" :: "r" (pd));
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
}

/* *
 * load_esp0 - change the ESP0 in default task state segment,
 * so that we can use different kernel stack when we trap frame
 * user to kernel.
 * */
void
load_esp0(uintptr_t esp0) {
    ts.ts_esp0 = esp0;
}

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
    // set boot kernel stack and default SS0
    load_esp0((uintptr_t)bootstacktop);
    ts.ts_ss0 = KERNEL_DS;

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEGTSS(STS_T32A, (uintptr_t)&ts, sizeof(ts), DPL_KERNEL);

    // reload all segment registers
    lgdt(&gdt_pd);

    // load the TSS
    ltr(GD_TSS);
}

static void boot_map_segment(uintptr_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm)
{
	size_t n = ROUND_UP(size + PG_OFF(la), PGSIZE) /PGSIZE;
	la = ROUND_DOWN(la, PGSIZE);
	pa = ROUND_DOWN(pa, PGSIZE);
	for(; n>0; n--,la+=PGSIZE,pa+=PGSIZE)
	{
		uintptr_t *pte_p = get_pte(pgdir, la);
//        cprintf("ptep:%x *ptep:%x n:%x pa:%x la:%x\n", pte_p, *pte_p, pa, la);

		*pte_p = pa | PTE_P | perm;
	}
}
void enable_paging(void)
{
	lcr3(boot_cr3);
	// turn on paging
    uint32_t cr0 = rcr0();
    cr0 |= CR0_PE | CR0_PG | CR0_AM | CR0_WP | CR0_NE | CR0_TS | CR0_EM | CR0_MP;
    cr0 &= ~(CR0_TS | CR0_EM);
    lcr0(cr0);
//    cprintf("cr0:%x =============\n", cr0);
}

void pmm_init(void)
{
	init_pmm_manager();
	page_init();

	check_alloc_page();

	struct Page *p = alloc_page();
	boot_pgdir = (uintptr_t*)page2va(p);
	memset(boot_pgdir, 0, PGSIZE);
	boot_cr3 = PADDR(boot_pgdir);

	cprintf("boot_pgdir:%x  cr3:%x \n", boot_pgdir, boot_cr3);

	check_pgdir();

	cprintf("boot_pgdir 0:%x 1:%x 2:%x\n", boot_pgdir[0], boot_pgdir[1], boot_pgdir[2]);

	// recursively insert boot_pgdir in itself
	// to form a virtual page table at virtual address VPT
	boot_pgdir[PDX(VPT)] = PADDR(boot_pgdir) | PTE_P | PTE_W;

	boot_map_segment(boot_pgdir, KERNBASE, KMEMSIZE, 0, PTE_W);

	//temporary map:
    //virtual_addr 3G~3G+4M = linear_addr 0~4M = linear_addr 3G~3G+4M = phy_addr 0~4M
	boot_pgdir[0] = boot_pgdir[PDX(KERNBASE)];

	enable_paging();
	gdt_init();

	boot_pgdir[0] = 0;

	check_boot_pgdir();

//	for(int i=0;i<1024;i++) {
//		cprintf("pgdir[%d]:%x\n", i, boot_pgdir[i]);
//	}

	print_pgdir();
	print_stackframe();

}

struct Page *alloc_pages(size_t n)
{
	struct Page *page = pmm_manager->alloc_pages(n);
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

/**************************** page dir *****************************/
/**
pte: page table entry
pde: page directory entry
**/
uintptr_t * get_pte(uintptr_t *pgdir, uintptr_t la)
{
	uintptr_t *pde_p = &pgdir[PDX(la)];
	if(!(*pde_p & PTE_P)) {
		cprintf("alloc-");
		struct Page *page = alloc_page();
		uintptr_t pa = page2pa(page);
		memset((void*)VADDR(pa), 0, PGSIZE);
		*pde_p = pa | PTE_U | PTE_W | PTE_P;
	}
	return &((uintptr_t*)VADDR(PDE_ADDR(*pde_p)))[PTX(la)];
}
struct Page * get_page(uintptr_t *pgdir, uintptr_t la)
{
	uintptr_t *pte_p = get_pte(pgdir, la);
	if(pte_p != NULL && *pte_p & PTE_P)
		return pa2page(*pte_p);
	return NULL;
}

static inline void page_remove_pte(uintptr_t *pgdir, uintptr_t la, uintptr_t * pte_p)
{
	cprintf("page_remove_pte   la:%x pte_p:%x *pte_p:%x\n", la, pte_p, *pte_p);
	if(*pte_p & PTE_P) {
		*pte_p = 0;
		tlb_invalidate(pgdir, la);
	}
}
static inline void page_remove(uintptr_t *pgdir, uintptr_t la)
{
	uintptr_t *pte_p = get_pte(pgdir, la);
	if(pte_p != NULL)
		page_remove_pte(pgdir, la, pte_p);
}
int page_insert(uintptr_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm)
{
	uintptr_t *pte_p = get_pte(pgdir, la);
	if(*pte_p != 0) {
		if(pte2page(*pte_p) != page)
			page_remove_pte(pgdir, la, pte_p);
	}
	*pte_p = page2pa(page) | PTE_P | perm;
	tlb_invalidate(pgdir, la);
	return 0;
}
void tlb_invalidate(uintptr_t *pgdir, uintptr_t la)
{
	if(rcr3() == PADDR(pgdir)) {
		invlpg((void*)la);
	}
}
static void check_pgdir(void)
{
	struct Page* p = get_page(boot_pgdir, 0x0);
	cprintf("p:%x\n", p);

	struct Page *p1 = alloc_page();
	page_insert(boot_pgdir, p1, 0x0, PTE_W);

	uintptr_t *pte_p = get_pte(boot_pgdir, 0x0);
	cprintf("*pte_p:%x pa2page(*pte_p):%x p1:%x  \n", *pte_p, pa2page(*pte_p), p1);
	cprintf("wtf\n");
	cprintf("pte_p:%x  newpte_p:%x\n", pte_p, get_pte(boot_pgdir, 0));

	struct Page *p2 = alloc_page();
	page_insert(boot_pgdir, p2, PGSIZE, PTE_W);
	pte_p = get_pte(boot_pgdir, PGSIZE);
	cprintf("*pte_p:%x pa2page(*pte_p):%x p2:%x  \n", *pte_p, pa2page(*pte_p), p2);

//	page_insert(boot_pgdir, p1, PGSIZE);
//	pte_p = get_pte(boot_pgdir, PGSIZE);
//	cprintf("pa2page(*pte_p):%x", pa2page(*pte_p));

	page_remove(boot_pgdir, 0x0);
	page_remove(boot_pgdir, PGSIZE);
	free_page(pa2page(boot_pgdir[0]));
	boot_pgdir[0]= 0;

	cprintf("check_pgdir succeeded\n");
}

void check_boot_pgdir()
{
	uintptr_t *pte_p;
	int i;
	for(i=0; i<npage; i+=PGSIZE)
	{
		pte_p = get_pte(boot_pgdir, (uintptr_t)VADDR(i));
		cprintf("pte_p:%x   i:%x", pte_p, i);
		if(PTE_ADDR(*pte_p) == i)
			cprintf("   *pte_p:%x \n", *pte_p);
	}

	cprintf("%x  %x\n", PDE_ADDR(boot_pgdir[PDX(VPT)]), PADDR(boot_pgdir));
	cprintf("%x\n", boot_pgdir[0]);

	struct Page *p;
	p = alloc_page();
	page_insert(boot_pgdir, p, 0x100+PGSIZE, PTE_W);
	page_insert(boot_pgdir, p, 0x100, PTE_W);
	page_insert(boot_pgdir, p, 0x100+18, PTE_W);

	const char *str = "hello world!";
	char *c = (char*)0x100;
//	char ch = *c; // test for read
	*c = 'c'; //test for write
	strcpy((void*)0x100, str);
	int ret = strcmp((void*)0x100, (void*)(0x100));
	cprintf("ret:%d str:%s str2:%s\n", ret, str, (char*)(0x100+3));
	cprintf("pa of p: %x\n", page2pa(p));
//	*(char*)(page2va(p) + 0x100) = '\0';
	ret = strlen((const char*)0x100);
	cprintf("ret:%x", ret);

	free_page(p);
	free_page(pa2page(PDE_ADDR(boot_pgdir[0])));
	boot_pgdir[0] = 0;

	cprintf("check_boot_pgdir() succeeded!\n");
}


//perm2str - use string 'u,r,w,-' to present the permission
static const char *
perm2str(int perm) {
    static char str[4];
    str[0] = (perm & PTE_U) ? 'u' : '-';
    str[1] = 'r';
    str[2] = (perm & PTE_W) ? 'w' : '-';
    str[3] = '\0';
    return str;
}

//get_pgtable_items - In [left, right] range of PDT or PT, find a continuous linear addr space
//                  - (left_store*X_SIZE~right_store*X_SIZE) for PDT or PT
//                  - X_SIZE=PTSIZE=4M, if PDT; X_SIZE=PGSIZE=4K, if PT
// paramemters:
//  left:        no use ???
//  right:       the high side of table's range
//  start:       the low side of table's range
//  table:       the beginning addr of table
//  left_store:  the pointer of the high side of table's next range
//  right_store: the pointer of the low side of table's next range
// return value: 0 - not a invalid item range, perm - a valid item range with perm permission
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
    if (start >= right) {
        return 0;
    }
    while (start < right && !(table[start] & PTE_P)) {
        start ++;
    }
    if (start < right) {
        if (left_store != NULL) {
            *left_store = start;
        }
        int perm = (table[start ++] & PTE_USER);
        while (start < right && (table[start] & PTE_USER) == perm) {
            start ++;
        }
        if (right_store != NULL) {
            *right_store = start;
        }
        return perm;
    }
    return 0;
}

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
    cprintf("-------------------- BEGIN --------------------\n");
// 	for(int i=0;i<1024;i++) {
// 		cprintf("%x  ", vpd[i]);
// 	}
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, 1024, right, vpd, &left, &right)) != 0) {
//    	cprintf("perm:%x   ", perm);
    	cprintf("left:%d right:%d \n", left, right);
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
                left * PGSIZE*1024, right * PGSIZE*1024, (right - left) * PGSIZE*1024, perm2str(perm));
        size_t l, r = left * 1024;
        while ((perm = get_pgtable_items(left * 1024, right * 1024, r, vpt, &l, &r)) != 0) {
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
        }
    }
    cprintf("--------------------- END ---------------------\n");
}
