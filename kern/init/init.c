#include <types.h>
#include <stdio.h>
#include <string.h>
#include <console.h>
#include <monitor.h>
#include <assert.h>
#include <graphic.h>

int kern_init(void) __attribute__((noreturn));


int
kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);

    struct BOOTINFO *binfo = (struct BOOTINFO *) ADR_BOOTINFO;
    binfo->vmode = 8;
    binfo->scrnx = 320;
    binfo->scrny = 200;
    binfo->vram = (uint8_t *)0x000a0000;

//    cons_init();                // init the console 
//    const char *message = "(THU.CST) os is loading ...";
//    cprintf("%s\n\n", message);


    graphic_init();

    char buff[16*16];
    init_mouse_cursor8(buff);
    draw_mouse(buff);

    while (1) {
        monitor(NULL);
    }
}
