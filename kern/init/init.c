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

int kern_init(void) __attribute__((noreturn));


int
kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);

    struct BOOTINFO *binfo = (struct BOOTINFO *) ADR_BOOTINFO;
   
    const char *message = "Sharix os is loading ...";
    cprintf("%s\n\n", message);

    cons_init();

    pic_init();
    idt_init();

    intr_enable(); 

    graphic_init();

    rgb_t buff[16*16];
    init_mouse_cursor8(buff);
    draw_mouse(buff);

    while (1) {
//        monitor(NULL);
    }
}
