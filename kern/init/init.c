#include <types.h>
#include <stdio.h>
#include <string.h>
#include <console.h>
#include <monitor.h>
#include <graphic.h>
#include <picirq.h>
#include <trap.h>
#include <intr.h>
#include <clock.h>
#include <pmm.h>
#include <kdebug.h>
#include <asm_tool.h>
#include <window.h>
#include <slab.h>
#include <color.h>
#include <font.h>
#include <vmm.h>
#include <proc.h>
#include <sched.h>
#include <assert.h>

struct BOOTINFO *binfo = (struct BOOTINFO *)(ADR_BOOTINFO + KERNBASE);

int kern_init(void) __attribute__((noreturn));

int kern_init(void)
{
    extern char edata[], end[];
    memset(edata, 0, end - edata);

    cons_init();
    // print_kerninfo();

    pmm_init();

    pic_init();
    idt_init();
    clock_init();

    intr_enable();

    check_vmm();

    sched_init();

    proc_init();

    cpu_idle();

    //should not come here
    panic("error system out");
    while (1)
    {

    }
}
