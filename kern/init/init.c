#include <types.h>
#include <stdio.h>
#include <string.h>
#include <console.h>
#include <monitor.h>
#include <assert.h>
#include <graphic.h>
#include <picirq.h>
#include <trap.h>
#include <intr.h>
#include <clock.h>
#include <pmm.h>
#include <kdebug.h>

int kern_init(void) __attribute__((noreturn));
 
int
kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
//    struct BOOTINFO *binfo = (struct BOOTINFO *) ADR_BOOTINFO;
    cons_init();

    const char *message = "Sharix is loading ...";
    cprintf("%s\n\n", message);

    print_kerninfo();

    pmm_init();


    pic_init();
    cprintf("wtfwtf-------------------------\n");

    idt_init();
    clock_init();

    intr_enable();

    graphic_init();

    while (1) {
//        monitor(NULL);
    }
}
