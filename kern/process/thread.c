#include <thread.h>
#include <slab.h>
#include <sync.h>
#include <sched.h>
#include <stdio.h>
#include <assert.h>

void thread_entry(void);
void switch_to(reg_context_t *from, reg_context_t *to);

thread_t *currentthread = NULL;

/******************* static ******************************/
void run_entrys(struct trapframe *tf);
static void run_entry(void)
{
	run_entrys(currentthread->tf);
}

/******************** thread api ************************/

thread_t *thread_create(int (*fn)(void *), void *arg)
{
	thread_t *thread = (thread_t *)kmalloc(sizeof(thread_t));
	thread->parent = current;
	thread->kstack = (uintptr_t)kmalloc(KSTACKSIZE);

	struct trapframe *tf = thread->tf = (struct trapframe *)(thread->kstack + KSTACKSIZE) - 1;
	tf->tf_cs = KERNEL_CS;
	tf->tf_ds = tf->tf_es = tf->tf_ss = KERNEL_DS;
	tf->tf_regs.reg_ebx = (uint32_t)fn;
	tf->tf_regs.reg_edx = (uint32_t)arg;
	tf->tf_eip = (uint32_t)thread_entry;

	thread->context.esp = (uintptr_t)tf;
	thread->context.eip = (uintptr_t)run_entry;

	return thread;
}

void thread_join(thread_t *thread)
{
	list_add(&current->thread_list, &(thread->thread_link));
}

void thread_run(thread_t *thread)
{
	bool intr_flag;
	struct proc_struct *prev = current;
	local_intr_save(intr_flag);
	{
		// current = thread->parent;
		switch_to(&(prev->main->context), &(thread->context));
		// panic("thread.c thread run end");
	}
	local_intr_restore(intr_flag);
}

void thread_exit()
{
	cprintf("thread thread_exit begin\n");
	if (currentthread->tid != 0)
	{
		list_del(&(currentthread->thread_link));
	}
	schedule();
}
