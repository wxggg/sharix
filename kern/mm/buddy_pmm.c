#include <pmm.h>
#include <buddy_pmm.h>
#include <stdio.h>

// from 2^0 to 2^10
static free_area_t free_area[MAX_ORDER+1];

#define free_list(x) (free_area[x].free_list)
#define nr_free(x) (free_area[x].nr_free)

static void buddy_init(void)
{
	for (int i = 0; i < MAX_ORDER; ++i)
	{
		list_init(&free_list(i));
		nr_free(i) = 0;
	}
}

static void buddy_init_memmap(struct Page *base, size_t n)
{
	struct Page *p = base;
	for (; p != base + n; p++) {
		p->flags = p->order = 0;
	}
	p = base;
	size_t order = MAX_ORDER, order_size = (1<<order);
	while (n != 0) {
		while(n >= order_size) {
			p->order = order;
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
static inline struct Page* buddy_alloc_pages_sub(size_t order)
{
	if(order>MAX_ORDER)
		cprintf("buddy_alloc_page_sub order ERROR\n");
	for(size_t i=order; i<=MAX_ORDER; i++) {
		if(!list_empty(&free_list(i))) {
			list_entry_t *le = list_next(&free_list(i));
			struct Page *page = to_struct(le, struct Page, page_link);
			nr_free(i) --;
			list_del(le);
			size_t size = 1 << i;
			while(i > order) {
				i--;
				size >>= 1;
				struct Page * buddy = page+size;
				buddy->order = i;
				nr_free(i) ++;
				list_add(&free_list(i), &(buddy->page_link));
			}
			return page;
		}
	}
	return NULL;

}
static inline size_t getorder(size_t n) {
	size_t order, order_size;
	for(order = 0, order_size=1; order<=MAX_ORDER;order++, order_size<<=1) {
		if(n<=order_size) return order;
	}
	return -1;
}


static void buddy_free_pages_sub(struct Page *base, size_t order)
{
	struct Page * p=base;
	p->order = order;
	size_t i=order, flag=0;

	while(i<MAX_ORDER) {
		list_entry_t * le = list_next(&free_list(i));
		while(1) {
			if(le == &free_list(i)) {
				flag = 1;
				break;
			}
			struct Page * buddy = to_struct(le, struct Page, page_link);
			le = list_next(le);
			size_t p_size = 1<<p->order, buddy_size = 1<<buddy->order;
			if(p == buddy+buddy_size) {
				list_del(&(buddy->page_link));
				nr_free(i) --;
				p = buddy;
				p->order ++;
				cprintf("left match\n");
				break;
			}
			else if(p+p_size == buddy) {
				list_del(&(buddy->page_link));
				nr_free(i) --;
				p->order ++;
				cprintf("right match\n");
				break;
			}
			else {
				flag = 1;
				break;
			}
		}
		if(flag == 1) break;
		i++;
	}
	list_add(&free_list(i), &(p->page_link));
	nr_free(i)++;
}
static struct Page * buddy_alloc_pages(size_t n)
{
	if(n == 0)return NULL;
	size_t order = getorder(n), order_size = (1<<order);
	struct Page *page = buddy_alloc_pages_sub(order);
	if(page != NULL && n!=order_size) {
		free_pages(page+n, order_size-n);
	}
	return page;
}

static void buddy_free_pages(struct Page *base, size_t n)
{
	cprintf("buddy_free_pages base:%x n:%d  ", base, n);
	if (n==1) {
		buddy_free_pages_sub(base, 0);
	}
	else {
		size_t i=0, size = 1;
		while(n>=size) {
			i++;
			size <<=1;
		}
		while(n!=0) {
			while(n<size) {
				i--;
				size>>=1;
			}
			base->order = i;
			buddy_free_pages_sub(base, i);
			base += size;
			n -= size;
		}
	}
}

static void buddy_check(void)
{
	struct Page *p = alloc_pages(3);
	pageinfo();
	free_pages(p, 3);
	pageinfo();
}

static void buddy_pageinfo(void)
{
	for (int i = 0; i <= MAX_ORDER; ++i)
	{
		cprintf("order:%d nr_free:%d\n", i, nr_free(i));
	}
}

const struct pmm_manager buddy_pmm_manager = {
	.name = "buddy_pmm_manager",
	.init = buddy_init,
	.init_memmap = buddy_init_memmap,
	.alloc_pages = buddy_alloc_pages,
	.free_pages = buddy_free_pages,
	.check = buddy_check,
	.pageinfo = buddy_pageinfo,
};
