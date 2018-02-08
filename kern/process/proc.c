#include <proc.h>
#include <pmm.h>
#include <sync.h>
#include <slab.h>
#include <string.h>
#include <sched.h>
#include <stdio.h>
#include <thread.h>

void kernel_thread_entry(void);

list_entry_t proc_list;

struct proc_struct *idleproc = NULL;
struct proc_struct *current = NULL;

void switch_to(reg_context_t *from, reg_context_t *to);

/******************* static ******************************/
void run_entrys(struct trapframe *tf);
static void run_entry(void)
{
	run_entrys(current->tf);
}

/********************* process api ************************/

struct proc_struct *alloc_proc()
{
	struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
	if (proc)
	{
		proc->state = PROC_UNINIT;
		proc->pid = -1;
		// proc->kstack = 0;
		proc->parent = NULL;
		proc->mm = NULL;
		// memset(&(proc->context), 0, sizeof(reg_context_t));
		proc->tf = NULL;
		proc->cr3 = boot_cr3;
		proc->time_slice = 0;
		list_init(&(proc->run_link));
		list_init(&(proc->thread_list));
		proc->main = NULL;
	}
	return proc;
}

int kernel_thread(int (*fn)(void *), void *arg)
{
	struct trapframe tf;
	memset(&tf, 0, sizeof(struct trapframe));
	tf.tf_cs = KERNEL_CS;
	tf.tf_ds = tf.tf_es = tf.tf_ss = KERNEL_DS;
	tf.tf_regs.reg_ebx = (uint32_t)fn;
	tf.tf_regs.reg_edx = (uint32_t)arg;
	tf.tf_eip = (uint32_t)kernel_thread_entry;

	struct proc_struct *proc = alloc_proc();
	if (!proc)
		return -1;

	proc->parent = current;
	proc->kstack = (uintptr_t)kmalloc(PGSIZE);
	proc->pid = 1;
	list_add(&proc_list, &(proc->list_link));
	proc->time_slice = 0;

	proc->tf = (struct trapframe *)(proc->kstack + PGSIZE) - 1;
	*(proc->tf) = *(&tf); // tf value copied
	proc->tf->tf_regs.reg_eax = 0;
	proc->tf->tf_esp = 0;
	proc->tf->tf_eflags |= FL_IF;

	// proc->context.eip = (uintptr_t)run_entry;
	// proc->context.esp = (uintptr_t)(proc->tf);

	// wakeup_proc(proc);
	return 1;
}

int do_exit_thread(int error_code)
{
	struct proc_struct *proc, *parent;
	proc = parent = current->parent;
	kfree(current->kstack);
	list_del(&(proc->list_link));
	kfree(current);
	current = proc;
	schedule();
	return 0;
}

int do_exit(int error_code)
{
	bool intr_flag;
	local_intr_save(intr_flag);
	{
		//TODO: killl the child thread
	}
	local_intr_restore(intr_flag);
	return do_exit_thread(error_code);
}

void proc_run(struct proc_struct *proc)
{
	if (proc != current)
	{
		bool intr_flag;
		struct proc_struct *prev = current;
		local_intr_save(intr_flag);
		{
			current = proc;
			print_proc(current);
			// load_esp0(proc->kstack + PGSIZE);
			// lcr3(proc->cr3);
			// switch_to(&(prev->context), &(proc->context));
		}
		local_intr_restore(intr_flag);
	}
	else
	{
		bool intr_flag2;
		reg_context_t context;
		local_intr_save(intr_flag2);
		{
			// switch_to(&context, &(current->context));
		}
		local_intr_restore(intr_flag2);
	}
}

struct proc_struct *find_proc(int pid)
{
	struct proc_struct *proc;
	list_entry_t *le = list_next(&proc_list);
	while (le != &proc_list)
	{
		proc = to_struct(le, struct proc_struct, list_link);
		if (proc->pid == pid)
			return proc;
	}
	return NULL;
}

/********************************* other part *********************************/

static void print_context(reg_context_t *p)
{
	cprintf("------------- contex ---------------\n");
	cprintf("eip: %x\n", p->eip);
	cprintf("esp: %x\n", p->esp);
	cprintf("ebx: %x\n", p->ebx);
	cprintf("ecx: %x\n", p->ecx);
	cprintf("edx: %x\n", p->edx);
	cprintf("esi: %x\n", p->esi);
	cprintf("edi: %x\n", p->edi);
	cprintf("ebp: %x\n", p->ebp);
}

void print_proc(struct proc_struct *proc)
{
	cprintf("\n------------------- [info process] ---------------\n\t");
	if (!proc)
	{
		cprintf("\tprint proc null\n");
		return;
	}
	switch (proc->state)
	{
	case PROC_UNINIT:
		cprintf("state: uninitialized\n");
		break;
	case PROC_SLEEPING:
		cprintf("state: sleeping\n");
		break;
	case PROC_RUNNABLE:
		cprintf("state: runnable\n");
		break;
	case PROC_ZOMBIE:
		cprintf("state: zombie\n");
	default:
		cprintf("state: ?=%d\n", proc->state);
		break;
	}
	cprintf("\tname:\t %s\n", proc->name);
	cprintf("\tpid:\t %d\n", proc->pid);
	cprintf("\tkstack:\t %x\n", proc->kstack);
	if (proc->parent)
	{
		cprintf("\tparent pid:\t %d\n", proc->parent->pid);
	}
	if (proc->mm)
	{
		cprintf("\tmm:\t %x\n", proc->mm);
	}
	// print_context(&proc->context);
	if (proc->tf)
	{
		print_trapframe(proc->tf);
	}
	cprintf("\tcr3:\t %x\n", proc->cr3);
	cprintf("\tneed_resched:\t %d\n", proc->need_resched);
	cprintf("\ttime_slice:\t %d\n", proc->time_slice);
	cprintf("--------- [thread list] ---------\n");
	list_entry_t *le = &proc->thread_list;
	while ((le = list_next(le)) != &proc->thread_list)
	{
		thread_t *p = to_struct(le, thread_t, thread_link);
		cprintf("%s->", p->name);
	}
	cprintf("\n");
	cprintf("--------------------------------------------------\n\n");
}

static int thread1(void *arg)
{
	cprintf("thread 1 is running !");
	for (size_t i = 0; i < 10; i++)
	{
		cprintf("thread1 i=%d\n", i);
	}
	// while(1) {

	// }
	cprintf("threa1 is over\n");
	return 0;
}

static int thread2(void *arg)
{
	for (size_t i = 0; i < 10; i++)
	{
		cprintf("thread2 j=%d\n", i);
	}
	// while(1) {

	// }
	cprintf("threa2 is over\n");
	return 0;
}

void proc_init()
{
	list_init(&proc_list);
	idleproc = alloc_proc();

	idleproc->pid = 0;
	idleproc->need_resched = 1;

	memcpy(idleproc->name, "idleproc", 16);
	idleproc->state = PROC_RUNNABLE;
	idleproc->kstack = (uintptr_t)bootstack;

	thread_t *main = thread_create(cpu_idle, NULL);
	main->tid = 0;
	memcpy(main->name, "main", 16);
	list_add_after(&(idleproc->thread_list), &(main->thread_link));
	idleproc->main = main;

	thread_t *pthr1 = thread_create(thread1, NULL);
	pthr1->tid = 1;
	memcpy(pthr1->name, "pthr1", 16);
	list_add_after(&(idleproc->thread_list), &(pthr1->thread_link));

	thread_t *pthr2 = thread_create(thread2, NULL);
	pthr2->tid = 2;
	memcpy(pthr2->name, "pthr2", 16);
	// list_add_after(&(idleproc->thread_list), &(pthr2->thread_link));

	current = idleproc;

	print_proc(current);
}

void cpu_idle()
{
	// window_t *win = get_parent_window();
	// m(win)->show();
	//
	// window_t * terminal = create_window(500,600);
	// m(terminal)->show();
	//
	// window_t * terminal2 = create_window(400,400);
	// m(terminal2)->show();
	//
	// draw_mouse(400,400);
	//
	// draw_str16("Author: Xingang Wang", (point_t){800,40}, White);
	// draw_str16("Visit: www.sharix.site", (point_t){800,60}, White);

	while (1)
	{
		if (current->need_resched)
		{
			schedule();
		}
	}
}
