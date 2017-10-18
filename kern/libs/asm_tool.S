.global io_load_eflags
.global io_store_eflags
.global io_in8
.global io_out8
.global io_cli
.global io_sti
.global set_pixel

io_cli:	# void io_cli(void);
	cli
	ret

io_sti: # void io_sti(void);
	sti
	ret

io_load_eflags: # int io_load_eflags(void)
    pushfl
    pop %eax
    ret

io_store_eflags: # void io_store_eflags(int eflags);
	movl 4(%esp), %eax
	push %eax
	popfl
	ret

io_in8: # int io_in8(int port)
	movl 4(%esp), %edx
	xorl %eax, %eax
	in %dx, %al
	ret

io_out8: # void io_out8(int port, int data)
	movl 4(%esp), %edx
	movb 8(%esp), %al
	outb %al, %dx
	ret
