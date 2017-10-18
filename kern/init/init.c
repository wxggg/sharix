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
#include <asm_tool.h>
#include <window.h>
#include <slab.h>
#include <color.h>
#include <font.h>

struct BOOTINFO *binfo = (struct BOOTINFO *) (ADR_BOOTINFO+KERNBASE);

int kern_init(void) __attribute__((noreturn));

int kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);

    cons_init();
    print_kerninfo();

    pmm_init();

    pic_init();
    idt_init();
    clock_init();
    intr_enable();

    window_t *win = get_parent_window();
    m(win)->show();

    window_t * terminal = create_window(500,600);
    m(terminal)->show();

    window_t * terminal2 = create_window(400,400);
    m(terminal2)->show();

    draw_mouse(400,400);

    draw_str16("Author: Xingang Wang", (point_t){800,40}, White);
    draw_str16("Visit: www.sharix.site", (point_t){800,60}, White);

    while (1) {
//        monitor(NULL);
    }
}
