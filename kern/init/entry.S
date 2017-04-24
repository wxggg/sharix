#include <entryasm.h>

.text
.global kern_entry
kern_entry:
	lgdt REALLOC(__gdtesc)
	movl $KERNEL_DS, %eax
	movw %ax, %ds 
	movw %ax, %es 
	movw %ax, %ss 
	ljmp $KERNEL_CS, $relocated

relocated:
	#set up ebp, esp
	movl $0x0, %ebp 
	# kernel stack ------   bootstack --->  bootstacktop
	# kernel stack size KSTACKSIZE(8KB)
	movl $bootstacktop, %esp
	call kern_init

spin:
	jmp spin

.data
.align PGSIZE
	.globl bootstack 
bootstack:
	.space KSTACKSIZE
bootstacktop:


.align 4
__gdt:
	SEG_NULLASM
	SEG_ASM(STA_X | STA_R, - KERNBASE, 0xFFFFFFFF)
	SEG_ASM(STA_W, - KERNBASE, 0xFFFFFFFF)
__gdtesc:
	.word 0x17  			# sizeof(gdt) - 1
	.long REALLOC(__gdt)	# address gdt