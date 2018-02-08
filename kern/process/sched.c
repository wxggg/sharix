#include <sched.h>
#include <sync.h>
#include <slab.h>
#include <stdio.h>
#include <thread.h>
#include <sync.h>

/*************** static value ***************/

static list_entry_t timer_list;
static struct run_queue *rq = NULL;

void switch_to(reg_context_t *from, reg_context_t *to);

/************** static function ***********/

static inline void enqueue(struct proc_struct *proc)
{
	list_add_before(&(rq->run_list), &(proc->run_link));
	if (proc->time_slice == 0 || proc->time_slice > rq->max_time_slice)
	{
		proc->time_slice = rq->max_time_slice;
	}
	rq->proc_num++;
}

static inline void dequeue(struct proc_struct *proc)
{
	list_del_init(&(proc->run_link));
	rq->proc_num--;
}

static inline struct proc_struct *pick_next(void)
{
	list_entry_t *le = list_next(&(rq->run_list));
	if (le != &(rq->run_list))
	{
		return to_struct(le, struct proc_struct, run_link);
	}
	return NULL;
}

static void proc_tick(struct proc_struct *proc)
{
	if (proc != idleproc)
	{
		if (proc->time_slice > 0)
		{
			proc->time_slice--;
		}
		if (proc->time_slice == 0)
		{
			proc->need_resched = 1;
		}
	}
	else
	{
		proc->need_resched = 1;
	}
}

/**************** schedule api **************/

void sched_init(void)
{
	list_init(&timer_list);

	rq = (struct run_queue *)kmalloc(sizeof(struct run_queue));
	list_init(&(rq->rq_link));
	list_init(&(rq->run_list));
	rq->max_time_slice = 8;
	rq->proc_num = 0;
	cprintf("sched_init over\n");
}

void wakeup_proc(struct proc_struct *proc)
{
	bool intr_flag;
	local_intr_save(intr_flag);
	{
		if (proc->state != PROC_RUNNABLE)
		{
			proc->state = PROC_RUNNABLE;
			if (proc != current)
			{
				enqueue(proc);
			}
		}
	}
	local_intr_restore(intr_flag);
}

void schedule(void)
{
	cprintf("sched.c:schedule\n");
	print_proc(current);
	bool intr_flag;
	local_intr_save(intr_flag);
	{
		// current->need_resched = 0;
		// if (current->state == PROC_RUNNABLE) {
		//   enqueue(current);
		// }
		// if ((next = pick_next()) != NULL) {
		//   dequeue(next);
		// }
		// if (next == NULL) {
		//   next = idleproc;
		// }
		// if (next != current) {
		//   proc_run(next);
		// }

		list_entry_t *run = NULL;
		list_entry_t *le = &current->thread_list;
		while ((le = list_next(le)) != &current->thread_list)
		{
			if (run == NULL)
			{
				run = le;
			}
			else
			{
				if (rand() % 2 == 1)
				{
					run = le;
				}
			}
		}
		if (run != NULL)
		{
			thread_t *t = to_struct(run, thread_t, thread_link);
			cprintf("schedule ready to run\n");
			cprintf("name:%s\n", t->name);
			if (t->tid == 0)
			{
				current->need_resched = 0;
			}
			currentthread = t;
			thread_run(t);
			cprintf("schedule thread run end\n");
		}
		else
		{
			current->need_resched = 0;
		}

		// list_entry_t *le = list_next(&(current->thread_list));
		// while (le != &(current->thread_list)) {
		//   thread_t * t = to_struct(le, thread_t, thread_link);
		//   currentthread = t;
		//   thread_run(t);
		//   cprintf("schedule thread run end\n");
		// }
		// struct context context;
		// print_proc(current);
		// switch_to(&context, &(current->context));
	}
	local_intr_restore(intr_flag);
	cprintf("schedule end----------------------------------\n");
}
