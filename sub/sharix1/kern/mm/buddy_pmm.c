#include <pmm.h>
#include <buddy_pmm.h>

// from 2^0 to 2^10
static free_area_t free_area[MAX_ORDER+1];

#define free_list(x) (free_area[x].free_list)
#define nr_free(x) (free_area[x].nr_free)

static void buddy_init(void)
{
	while(1) {
	    cprintf("buddy-");
	}
	for (int i = 0; i < MAX_ORDER; ++i)
	{
		cprintf("bi-");
//		list_init(&free_list(i));
//		nr_free(i) = 0;
	}
	while(1){}
}

static void buddy_init_memmap(struct Page *base, size_t n)
{
	struct Page *p = base;
	for (; p != base + n; p++) {
//		if(!PageReserved(p))
//			cprintf("ERROR: buddy_init_memmap #1\n");
		p->flags = p->order = 0;
	}
	p = base;
	size_t order = MAX_ORDER, order_size = (1<<order);
	while (n != 0) {
		while(n >= order_size) {
			p->order = 1;
			cprintf("wtf:%d p:%8x", p->order, p);
			SetPageReserved(p);
			cprintf("order:%d flags:%x >  ", order, p->flags);
			list_add(&free_list(order), &(p->page_link));
			p += order_size;
			n -= order_size;
			nr_free(order)++;

			cprintf("list order=%d ++\n", order);
		}
		--order; 
		order_size >>= 1;
	}
}

static struct Page * buddy_alloc_pages(size_t n)
{

	return NULL;
}

static void buddy_free_pages(struct Page *base, size_t n)
{

}

static void buddy_check(void)
{
	int count=0, total=0;
	for (int i = 0; i < MAX_ORDER; ++i)
	{
		list_entry_t *list = &free_list(i), *le = list;
		while((le = list_next(le)) != list) {
			struct Page *p = tostruct(le, struct Page, page_link);
//			cprintf("flags:%x order:%d\n", p->flags, p->order);
			if(!(PageProperty(p) && p->order == i))
//				cprintf("ERROR: buddy_check #1\n");
			count++, total += (1<<i);
		}
	}
}

const struct pmm_manager buddy_pmm_manager = {
	.name = "buddy_pmm_manager",
	.init = buddy_init,
	.init_memmap = buddy_init_memmap,
	.alloc_pages = buddy_alloc_pages,
	.free_pages = buddy_free_pages,	
	.check = buddy_check,
};