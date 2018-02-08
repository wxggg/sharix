#pragma once

#include <types.h>

/* Trap Numbers */

/* Processor-defined: */
#define T_PGFLT 								14

#define IRQ_TIMER               0
#define IRQ_KBD                 1
#define IRQ_COM1                4


/* registers as pushed by pushal */
struct pushregs
{
	uint32_t reg_edi;
	uint32_t reg_esi;
	uint32_t reg_ebp;
	uint32_t reg_oesp;	/* useless */
	uint32_t reg_ebx;
	uint32_t reg_edx;
	uint32_t reg_ecx;
	uint32_t reg_eax;
};

struct trapframe
{
	struct pushregs tf_regs;
	uint16_t tf_es;
	uint16_t tf_padding1;
	uint16_t tf_ds;
	uint16_t tf_padding2;
	/* trapno are pushed in vectors.S to identify the trap*/
	uint32_t tf_trapno;
	/* below here defined by x86 hardware */
	uint32_t tf_err;
	uintptr_t tf_eip;
	uint16_t tf_cs;
	uint16_t tf_padding3;
	uint32_t tf_eflags;
	/* below here only when crossing rings, such as from user to kernel */
	uintptr_t tf_esp;
	uint16_t tf_ss;
	uint16_t tf_padding4;
} __attribute__((packed));

void idt_init(void);
void print_trapframe(struct trapframe *tf);
