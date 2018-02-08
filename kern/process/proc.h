#pragma once

#include <types.h>
#include <list.h>
#include <trap.h>
#include <memlayout.h>
#include <mmu.h>
#include <thread.h>

// process's state in his life cycle
enum proc_state
{
    PROC_UNINIT = 0, // uninitialized
    PROC_SLEEPING,   // sleeping
    PROC_RUNNABLE,   // runnable(maybe running)
    PROC_ZOMBIE,     // almost dead, and wait parent proc to reclaim his resource
};



struct proc_struct
{
    enum proc_state state;
    int pid;
    int need_resched;
    char name[16];

    uintptr_t kstack; // kernel stack  
    struct mm_struct *mm;
    // struct context context;
    struct trapframe *tf;
    uintptr_t cr3; // address of PDT
    
    list_entry_t list_link;
    list_entry_t run_link;
    int time_slice;

    struct proc_struct *parent;
    struct proc_struct *child;

    list_entry_t thread_list;
    // thread_t * main;
    struct thread_s *main;
};

extern struct proc_struct *idleproc;
extern struct proc_struct *current;

void proc_run(struct proc_struct *proc);
void print_proc(struct proc_struct *proc);

void proc_init();
void cpu_idle();
