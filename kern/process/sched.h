#pragma once
#include <types.h>
#include <list.h>
#include <proc.h>

typedef struct {
    unsigned int expires;			// when it is time
    struct proc_struct *proc;
    list_entry_t timer_link;
} timer_t;

struct run_queue {
	list_entry_t run_list;
	unsigned int proc_num;
	int max_time_slice;
	list_entry_t rq_link;
};

void sched_init();
void wakeup_proc();

void schedule();
