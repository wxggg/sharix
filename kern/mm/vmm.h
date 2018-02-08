#pragma once

#include <types.h>
#include <rb_tree.h>
#include <list.h>
#include <mmu.h>

/* the struct of vma is linked to the linear address
*/

struct mm_struct;

// virtual memory area
struct vma_struct {
  struct mm_struct *vm_mm;
  uintptr_t vm_start;           // start address of vma
  uintptr_t vm_end;             // end address
  uint32_t vm_flags;            // flags of vma
  list_entry_t list_link;       // list link between sorted vm
};


#define VM_READ           0x00000001
#define VM_WRITE          0x00000002
#define VM_EXEC           0x00000004

// control struct for a set of vma using the same PDT
struct mm_struct {
  list_entry_t mmap_list;       // list link of sorted vm
  struct vma_struct *mmap_cache;    // link cache
  uintptr_t *pgdir;                 // PDT
  int map_count;                // count of vma
};

struct vma_struct *find_vma(struct mm_struct *mm, uintptr_t addr);

struct vma_struct *vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags);
void insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma);

struct mm_struct *mm_create(void);
void mm_destroy(struct mm_struct *mm);

void check_vmm(void);
int do_pgfault(struct mm_struct *mm, uint32_t error_code, uintptr_t addr);
