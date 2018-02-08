#include <vmm.h>
#include <slab.h>
#include <pmm.h>
#include <stdio.h>
#include <error.h>

/*************** vmm_struct ********************/

// vma_create - alloc a vma_struct & initialize it. (addr range: vm_start~vm_end)
struct vma_struct *
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags)
{
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
    if (vma != NULL)
    {
        vma->vm_start = vm_start;
        vma->vm_end = vm_end;
        vma->vm_flags = vm_flags;
    }
    return vma;
}

// vma_destroy - free vma_struct
static void
vma_destroy(struct vma_struct *vma)
{
    kfree(vma);
}

// find_vma - find a vma  (vma->vm_start <= addr <= vma_vm_end)
struct vma_struct *
find_vma(struct mm_struct *mm, uintptr_t addr)
{
    struct vma_struct *vma = NULL;
    if (mm != NULL)
    {
        vma = mm->mmap_cache;
        if (!(vma != NULL && vma->vm_start <= addr && addr < vma->vm_end))
        {
            // cache do not satisfy, need to find
            bool found = 0;
            list_entry_t *list = &(mm->mmap_list), *le = list;
            while ((le = list_next(le)) != list)
            {
                vma = to_struct(le, struct vma_struct, list_link);
                if (addr < vma->vm_end)
                {
                    found = 1;
                    break;
                }
            }
            if (!found)
            {
                vma = NULL;
            }
        }
        if (vma != NULL)
        {
            mm->mmap_cache = vma;
        }
    }
    return vma;
}

// insert_vma_struct -insert vma in mm's rb tree link & list link
void insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma)
{
    list_entry_t *list = &(mm->mmap_list);
    list_entry_t *le_prev = list;

    list_entry_t *le = list;
    while ((le = list_next(le)) != list)
    {
        struct vma_struct *mmap_prev = to_struct(le, struct vma_struct, list_link);
        if (mmap_prev->vm_start > vma->vm_start)
        {
            break;
        }
        le_prev = le;
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count++;
}

/************************* mm_struct ***********************/
// mm_create -  alloc a mm_struct & initialize it.
struct mm_struct *mm_create(void)
{
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
    if (mm != NULL)
    {
        list_init(&(mm->mmap_list));
        mm->mmap_cache = NULL;
        mm->pgdir = NULL;
        mm->map_count = 0;
    }
    return mm;
}

// mm_destroy - free mm and mm internal fields
void mm_destroy(struct mm_struct *mm)
{
    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list)
    {
        list_del(le);
        vma_destroy(to_struct(le, struct vma_struct, list_link));
    }
    kfree(mm);
}

/*************************************************************/

static void check_vma_struct(void)
{
    struct mm_struct *mm = mm_create();
    struct vma_struct *vma = vma_create(0x00, 0xff, 0);
    insert_vma_struct(mm, vma);

    list_entry_t *le = list_next(&(mm->mmap_list));
    struct vma_struct *mmap = to_struct(le, struct vma_struct, list_link);
    if (mmap->vm_start != 0x00 || mmap->vm_end != 0xff)
    {
        cprintf("error check_vma_struct\n");
        return;
    }

    mm_destroy(mm);
    cprintf("check_vma_struct over\n");
}

struct mm_struct *check_mm_struct;
static void check_pgfault(void)
{
    check_mm_struct = mm_create();
    struct mm_struct *mm = check_mm_struct;

    mm->pgdir = boot_pgdir;

    struct vma_struct *vma = vma_create(0, PGSIZE * 1024, VM_WRITE);
    insert_vma_struct(mm, vma);

    uintptr_t addr = 0x100;
    if (find_vma(mm, addr) != vma)
        cprintf("error check_pgfault find_vma\n");

    int sum = 0;
    for (size_t i = 0; i < 10; i++)
    {
        *(char *)(addr + i) = i;
        sum += i;
    }
    for (size_t i = 0; i < 10; i++)
    {
        sum -= *(char *)(addr + i);
    }
    if (sum != 0)
    {
        cprintf("check_pgfault error\n");
    }
    page_remove(mm->pgdir, ROUNDDOWN(addr, PGSIZE));
    free_page(pa2page(mm->pgdir[0]));
    mm->pgdir[0] = 0;
    mm->pgdir = NULL;
    cprintf("check_pgfault over\n");
}

void check_vmm(void)
{
    check_vma_struct();
    check_pgfault();
}

/********************* do_pgfault ************************/
int do_pgfault(struct mm_struct *mm, uint32_t error_code, uintptr_t addr)
{
    int ret = -1;
    struct vma_struct *vma = find_vma(mm, addr);
    if (vma == NULL || vma->vm_start > addr)
    {
        goto failed;
    }

    switch (error_code & 0x3)
    {
    default:
        /* default is 3: write, present */
    case 2: /* write, not present */
        if (!(vma->vm_flags & VM_WRITE))
        {
            goto failed;
        }
        break;
    case 1: /* read, present */
        goto failed;
    case 0: /* read, not present */
        if (!(vma->vm_flags & (VM_READ | VM_EXEC)))
        {
            goto failed;
        }
    }

    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE)
    {
        perm |= PTE_W;
    }
    addr = ROUNDDOWN(addr, PGSIZE);

    ret = E_INVAL;
    uintptr_t *ptep;

    if ((ptep = get_pte(mm->pgdir, addr)) == NULL)
    {
        goto failed;
    }

    struct Page *page;
    if (*ptep & PTE_P)
    { // *ptep exst a page
        page = pte2page(*ptep);
    }
    else
    { // need to alloc_page
        page = alloc_page();
    }
    page_insert(mm->pgdir, page, addr, perm);

    ret = 0;
failed:
    return ret;
}
