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

#define TICK_NUM 100

static struct gatedesc idt[256] = {{0}};

static struct pseudodesc idt_pd = {
	sizeof(idt) -1, (uintptr_t)idt
};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void idt_init(void) {
	extern uintptr_t __vectors[];
	for(int i=0; i<sizeof(idt)/sizeof(struct gatedesc);i++)
		SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);

	// load the IDT
	lidt(&idt_pd);
	cprintf("idt_init finished\n");
}

static void trap_dispatch(struct trapframe *tf) {
	char c;
	switch(tf->tf_trapno) {
		case T_PGFLT:
			// cprintf("pgfault\n");
			break;
		case IRQ_OFFSET + IRQ_TIMER:
			ticks ++;
			if (ticks % TICK_NUM == 0) {
//				cprintf("%d ticks\n", TICK_NUM);
			}
			break;
		case IRQ_OFFSET + IRQ_KBD:
			c = cons_getc();
			cprintf("%s [%03d] %c\n", (tf->tf_trapno != IRQ_OFFSET + IRQ_KBD) ? "serial":"kbd", c, c);
			keybuf_push(&kb, c);
			break;
		default:;
			cprintf("UNKNOW INT\n");
	}
}

void trap(struct trapframe *tf) {
	// cprintf("trap");
	trap_dispatch(tf);
}
