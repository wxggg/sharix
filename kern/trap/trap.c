#include <trap.h>
#include <mmu.h>
#include <memlayout.h>
#include <bitmap.h>
#include <x86.h>
#include <picirq.h>
#include <editbox.h>
#include <clock.h>
#include <entryasm.h>
#include <stdio.h>
#include <console.h>
#include <vmm.h>
#include <proc.h>
#include <sched.h>
#include <assert.h>

#define TICK_NUM 100

static struct gatedesc idt[256] = {{0}};

static struct pseudodesc idt_pd = {
	sizeof(idt) - 1, (uintptr_t)idt};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void idt_init(void)
{
	extern uintptr_t __vectors[];
	for (int i = 0; i < sizeof(idt) / sizeof(struct gatedesc); i++)
		SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);

	// load the IDT
	lidt(&idt_pd);
	cprintf("idt_init finished\n");
}
void print_regs(struct pushregs *regs)
{
	cprintf("  edi  0x%08x\n", regs->reg_edi);
	cprintf("  esi  0x%08x\n", regs->reg_esi);
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
	cprintf("  edx  0x%08x\n", regs->reg_edx);
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
	cprintf("  eax  0x%08x\n", regs->reg_eax);
}
void print_trapframe(struct trapframe *tf)
{
	cprintf("trapframe at %p\n", tf);
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x \n", tf->tf_trapno);
	cprintf("  err  0x%08x\n", tf->tf_err);
	cprintf("  eip  0x%08x\n", tf->tf_eip);
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
	cprintf("  flag 0x%08x ", tf->tf_eflags);
}

static int pgfault_handler(struct trapframe *tf)
{
	extern struct mm_struct *check_mm_struct;
	return do_pgfault(check_mm_struct, tf->tf_err, rcr2());
}

static void trap_dispatch(struct trapframe *tf)
{
	char c;
	switch (tf->tf_trapno)
	{
	case T_PGFLT:
		if (pgfault_handler(tf))
		{
			// schedule();
			cprintf("page fault at tf:\n");
			print_trapframe(tf);
			panic("pgfault handler error");
		}
		break;
	case IRQ_OFFSET + IRQ_TIMER:
		ticks++;
		if (ticks % TICK_NUM == 0)
		{
			cprintf("tick\n");
			current->need_resched = 1;
		}
		break;
	case IRQ_OFFSET + IRQ_KBD:
		c = cons_getc();
		cprintf("%s [%03d] %c\n", (tf->tf_trapno != IRQ_OFFSET + IRQ_KBD) ? "serial" : "kbd", c, c);
		keybuf_push(&kb, c);
		break;
	default:;
		// cprintf("UNKNOW INT\n");
		// panic("unhandled INT");
	}
}

void trap(struct trapframe *tf)
{
	cprintf("trap--- ");
	trap_dispatch(tf);
}
