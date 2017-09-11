#include <types.h>
#include <x86.h>
#include <picirq.h>
#include <stdio.h>

#define IO_PIC1		0x20 //Master
#define IO_PIC2 	0xA0 //Slave

#define IRQ_SLAVE 	2		// IRQ at which slave connects to master

static bool did_init = 0;
static uint16_t irq_mask = 0xFFFF & ~(1 << IRQ_SLAVE);

static void pic_setmask(uint16_t mask) {
	irq_mask = mask;
	if(did_init) {
		outb(IO_PIC1+1, mask);
		outb(IO_PIC2+1, mask>>8);
	}
}

void pic_init(void) {
	did_init = 1;
	//mask all int
	outb(IO_PIC1+1, 0xFF);
	outb(IO_PIC2+1, 0xFF);

	/**master (8259A-1)**/

    // ICW1:  0001g0hi
    //    g:  0 = edge triggering, 1 = level triggering
    //    h:  0 = cascaded PICs, 1 = master only
    //    i:  0 = no ICW4, 1 = ICW4 required
    outb(IO_PIC1, 0x11);

	//ICW2:给 ICW2 写入 0x20,设置中断向量偏移值为 0x20,
	//即把主 8259A 的 IRQ0-7 映射到向量 0x20-0x27
    outb(IO_PIC1+1, IRQ_OFFSET);

    //ICW3:ICW3 是 8259A 的级联命令字,给 ICW3 写入 0x4,
    //0x4 表示此主中断控制器的第 2 个 IR 线(从 0 开始计数)连接从中断控制器。
    outb(IO_PIC1+1, 1<<IRQ_SLAVE);

    //ICW4:给ICW4写入0x3,0x3表示采用自动EOI方式,即在中断响应时,
    //在8259A送出中断矢量后,自动将ISR相应位复位;并且采用一般嵌套方式,
    //即当某个中断正在服务时,本级中断及更低级的中断都被屏蔽,只有更高的中断才能响应。
    outb(IO_PIC1+1, 0x3);

    /**slave (8259A-2) **/
    outb(IO_PIC2, 0x11);	//ICW1
    outb(IO_PIC2+1, IRQ_OFFSET+8); //ICW2
    outb(IO_PIC2+1, IRQ_SLAVE);	//ICW3
    outb(IO_PIC2+1, 0x3); //ICW4

    /****************set OCW3 of master&&slave ******************/
    // OCW3:  0ef01prs
    //   ef:  0x = NOP, 10 = clear specific mask, 11 = set specific mask
    //    p:  0 = no polling, 1 = polling mode
    //   rs:  0x = NOP, 10 = read IRR, 11 = read ISR
    outb(IO_PIC1, 0x68); //clear specific mask
    outb(IO_PIC1, 0x0a); //read IRR by default

    outb(IO_PIC2, 0x68);
    outb(IO_PIC2, 0x0a);

    //初始化完毕,使能主从8259A的所有中断
    if(irq_mask != 0xFFFF) {
    	pic_setmask(irq_mask);
    }
    cprintf("pic_init finished\n");

}
void pic_enable(unsigned int irq) {
	pic_setmask(irq_mask & ~(1<<irq));
}
