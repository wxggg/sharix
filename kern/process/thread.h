#pragma once

#include <proc.h>

typedef struct context
{
    uint32_t eip;
    uint32_t esp;
    uint32_t ebx;
    uint32_t ecx;
    uint32_t edx;
    uint32_t esi;
    uint32_t edi;
    uint32_t ebp;
} reg_context_t;

typedef struct thread_s {
  char name[16];
  int tid;
  struct proc_struct *parent;

  reg_context_t context;
  uintptr_t kstack;
  struct trapframe *tf;

  list_entry_t thread_link;
} thread_t;

extern thread_t * currentthread;

thread_t * thread_create(int (*fn)(void *), void *arg);
void thread_join(thread_t * t);
void thread_run(thread_t *thread);
void thread_exit();
