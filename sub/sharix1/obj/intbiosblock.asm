
obj/intbiosblock.o:     file format elf32-i386


Disassembly of section .text:

00007e00 <asmstart>:
.set SMAP,                  0x534d4150
.code16
.section ".text"
.global asmstart
asmstart:
	jmp main
    7e00:	eb 5f                	jmp    7e61 <main>

00007e02 <check_vbe>:

#---------------FUNCTION set video_mode800x600--------
set_video_mode:
check_vbe:
	mov $0x4f00, %ax #VBE
    7e02:	b8 00 4f cd 10       	mov    $0x10cd4f00,%eax
	int $0x10 
	cmp $0x004f, %ax #if VBE exist, ax==0x004f
    7e07:	83 f8 4f             	cmp    $0x4f,%eax
	jne set_mode_vga13
    7e0a:	75 4f                	jne    7e5b <set_mode_vga13>
	movw 0x04(%di), %ax
    7e0c:	8b 45 04             	mov    0x4(%ebp),%eax
	cmp $0x0200, %ax	#version should > 2.0
    7e0f:	3d 00 02 72 47       	cmp    $0x47720200,%eax

00007e14 <check_vbe_mode>:
	jb set_mode_vga13
check_vbe_mode:
	movw $0x118, %cx
    7e14:	b9 18 01 b8 01       	mov    $0x1b80118,%ecx
	mov $0x4f01, %ax 
    7e19:	4f                   	dec    %edi
	int $0x10 
    7e1a:	cd 10                	int    $0x10
	cmp $0x004f, %ax
    7e1c:	83 f8 4f             	cmp    $0x4f,%eax
	jne set_mode_vga13
    7e1f:	75 3a                	jne    7e5b <set_mode_vga13>
	movw (%di), %ax
    7e21:	8b 05 25 80 00 74    	mov    0x74008025,%eax
	andw $0x0080, %ax
	jz set_mode_vga13
    7e27:	33                   	.byte 0x33

00007e28 <save_video_mode_info>:
save_video_mode_info:
    movw $0x118, 0x2 #vmode
    7e28:	c7 06 02 00 18 01    	movl   $0x1180002,(%esi)
    movw 0x12(%di), %ax
    7e2e:	8b 45 12             	mov    0x12(%ebp),%eax
    movw %ax, 0x4  #scrnx
    7e31:	a3 04 00 8b 45       	mov    %eax,0x458b0004
    movw 0x14(%di), %ax
    7e36:	14 a3                	adc    $0xa3,%al
    movw %ax, 0x6  #scrny
    7e38:	06                   	push   %es
    7e39:	00 8a 45 19 a2 08    	add    %cl,0x8a21945(%edx)
    movb 0x19(%di), %al
    movb %al, 0x8  #bitspixel
    7e3f:	00 8a 45 1b a2 09    	add    %cl,0x9a21b45(%edx)
    movb 0x1b(%di), %al 
    movb %al, 0x9 #mem_model
    7e45:	00 66 8b             	add    %ah,-0x75(%esi)
    movl 0x28(%di), %eax
    7e48:	45                   	inc    %ebp
    7e49:	28 66 a3             	sub    %ah,-0x5d(%esi)
    movl %eax, 0xc  #vram 
    7e4c:	0c 00                	or     $0x0,%al

00007e4e <set_mode_vbe>:
set_mode_vbe:
	movw $0x118, %bx
    7e4e:	bb 18 01 81 c3       	mov    $0xc3810118,%ebx
	addw $0x4000, %bx
    7e53:	00 40 b8             	add    %al,-0x48(%eax)
	mov $0x4f02, %ax
    7e56:	02 4f cd             	add    -0x33(%edi),%cl
	int $0x10 
    7e59:	10 c3                	adc    %al,%bl

00007e5b <set_mode_vga13>:
	ret
#-------FUNCTION set video320x200
set_mode_vga13:
	mov $0x0013, %ax
    7e5b:	b8 13 00 cd 10       	mov    $0x10cd0013,%eax
	int $0x10
	ret
    7e60:	c3                   	ret    

00007e61 <main>:


main:
	call set_video_mode 
    7e61:	e8                   	.byte 0xe8
    7e62:	9e                   	sahf   
    7e63:	ff                   	.byte 0xff

00007e64 <seta20.1>:
	# Enable A20:
    #  For backwards compatibility with the earliest PCs, physical
    #  address line 20 is tied low, so that addresses higher than
    #  1MB wrap around to zero by default. This code undoes this.
seta20.1:
    inb $0x64, %al                                  # Wait for not busy
    7e64:	e4 64                	in     $0x64,%al
    testb $0x2, %al
    7e66:	a8 02                	test   $0x2,%al

    movb $0xd1, %al                                 # 0xd1 -> port 0x64
    7e68:	b0 d1                	mov    $0xd1,%al
    outb %al, $0x64
    7e6a:	e6 64                	out    %al,$0x64

00007e6c <seta20.2>:

seta20.2:
    inb $0x64, %al                                  # Wait for not busy
    7e6c:	e4 64                	in     $0x64,%al
    testb $0x2, %al
    7e6e:	a8 02                	test   $0x2,%al
    jnz seta20.2
    7e70:	75 fa                	jne    7e6c <seta20.2>

    movb $0xdf, %al                                 # 0xdf -> port 0x60
    7e72:	b0 df                	mov    $0xdf,%al
    outb %al, $0x60
    7e74:	e6 60                	out    %al,$0x60

00007e76 <probe_memory>:

probe_memory:
    movl $0, 0x8000
    7e76:	66 c7 06 00 80       	movw   $0x8000,(%esi)
    7e7b:	00 00                	add    %al,(%eax)
    7e7d:	00 00                	add    %al,(%eax)
    xorl %ebx, %ebx
    7e7f:	66 31 db             	xor    %bx,%bx
    movw $0x8004, %di
    7e82:	bf                   	.byte 0xbf
    7e83:	04 80                	add    $0x80,%al

00007e85 <start_probe>:
start_probe:
    movl $0xE820, %eax
    7e85:	66 b8 20 e8          	mov    $0xe820,%ax
    7e89:	00 00                	add    %al,(%eax)
    movl $20, %ecx 
    7e8b:	66 b9 14 00          	mov    $0x14,%cx
    7e8f:	00 00                	add    %al,(%eax)
    movl $SMAP, %edx
    7e91:	66 ba 50 41          	mov    $0x4150,%dx
    7e95:	4d                   	dec    %ebp
    7e96:	53                   	push   %ebx
    int $0x15
    7e97:	cd 15                	int    $0x15
    jnc cont 
    7e99:	73 08                	jae    7ea3 <cont>
    movw $12345, 0x8000
    7e9b:	c7 06 00 80 39 30    	movl   $0x30398000,(%esi)
    jmp finish_probe
    7ea1:	eb 0e                	jmp    7eb1 <finish_probe>

00007ea3 <cont>:
cont:
    addw $20, %di 
    7ea3:	83 c7 14             	add    $0x14,%edi
    incl 0x8000
    7ea6:	66 ff 06             	incw   (%esi)
    7ea9:	00 80 66 83 fb 00    	add    %al,0xfb8366(%eax)
    cmpl $0, %ebx 
    jnz start_probe
    7eaf:	75 d4                	jne    7e85 <start_probe>

00007eb1 <finish_probe>:

    # Switch from real to protected mode, using a bootstrap GDT
    # and segment translation that makes virtual addresses
    # identical to physical addresses, so that the
    # effective memory map does not change during the switch.
    cli
    7eb1:	fa                   	cli    
    lgdt gdtdesc
    7eb2:	0f 01 16             	lgdtl  (%esi)
    7eb5:	98                   	cwtl   
    7eb6:	80 0f 20             	orb    $0x20,(%edi)
    movl %cr0, %eax
    7eb9:	c0 66 83 c8          	shlb   $0xc8,-0x7d(%esi)
    orl $CR0_PE_ON, %eax
    7ebd:	01 0f                	add    %ecx,(%edi)
    movl %eax, %cr0
    7ebf:	22 c0                	and    %al,%al


    # Jump to next instruction, but in 32-bit code segment.
    # Switches processor into 32-bit mode.
    ljmp $PROT_MODE_CSEG, $protcseg
    7ec1:	ea                   	.byte 0xea
    7ec2:	c6                   	(bad)  
    7ec3:	7e 08                	jle    7ecd <protcseg+0x7>
	...

00007ec6 <protcseg>:

.code32                                             # Assemble for 32-bit mode
protcseg:
    # Set up the protected-mode data segment registers
    movw $PROT_MODE_DSEG, %ax                       # Our data segment selector
    7ec6:	66 b8 10 00          	mov    $0x10,%ax
    movw %ax, %ds                                   # -> DS: Data Segment
    7eca:	8e d8                	mov    %eax,%ds
    movw %ax, %es                                   # -> ES: Extra Segment
    7ecc:	8e c0                	mov    %eax,%es
    movw %ax, %fs                                   # -> FS
    7ece:	8e e0                	mov    %eax,%fs
    movw %ax, %gs                                   # -> GS
    7ed0:	8e e8                	mov    %eax,%gs
    movw %ax, %ss                                   # -> SS: Stack Segment
    7ed2:	8e d0                	mov    %eax,%ss

    # Set up the stack pointer and call into C. The stack region is from 0--start(0x7c00)
    movl $0x0, %ebp
    7ed4:	bd 00 00 00 00       	mov    $0x0,%ebp
    movl $0x7c00, %esp
    7ed9:	bc 00 7c 00 00       	mov    $0x7c00,%esp
    
    call bootmain
    7ede:	e8 9b 00 00 00       	call   7f7e <bootmain>

00007ee3 <readseg>:
/* *
 * readseg - read @count bytes at @offset from kernel into virtual address @va,
 * might copy more than asked.
 * */
static void
readseg(uintptr_t va, uint32_t count, uint32_t offset) {
    7ee3:	55                   	push   %ebp
    7ee4:	89 e5                	mov    %esp,%ebp
    7ee6:	57                   	push   %edi
    uintptr_t end_va = va + count;
    7ee7:	8d 3c 10             	lea    (%eax,%edx,1),%edi

    // round down to sector boundary
    va -= offset % SECTSIZE;
    7eea:	89 ca                	mov    %ecx,%edx

    // translate from bytes to sectors; kernel starts at sector 1
    uint32_t secno = (offset / SECTSIZE) + 1;
    7eec:	c1 e9 09             	shr    $0x9,%ecx
/* *
 * readseg - read @count bytes at @offset from kernel into virtual address @va,
 * might copy more than asked.
 * */
static void
readseg(uintptr_t va, uint32_t count, uint32_t offset) {
    7eef:	56                   	push   %esi
    uintptr_t end_va = va + count;

    // round down to sector boundary
    va -= offset % SECTSIZE;
    7ef0:	81 e2 ff 01 00 00    	and    $0x1ff,%edx

    // translate from bytes to sectors; kernel starts at sector 1
    uint32_t secno = (offset / SECTSIZE) + 1;
    7ef6:	8d 71 01             	lea    0x1(%ecx),%esi
/* *
 * readseg - read @count bytes at @offset from kernel into virtual address @va,
 * might copy more than asked.
 * */
static void
readseg(uintptr_t va, uint32_t count, uint32_t offset) {
    7ef9:	53                   	push   %ebx
    uintptr_t end_va = va + count;

    // round down to sector boundary
    va -= offset % SECTSIZE;
    7efa:	29 d0                	sub    %edx,%eax
/* *
 * readseg - read @count bytes at @offset from kernel into virtual address @va,
 * might copy more than asked.
 * */
static void
readseg(uintptr_t va, uint32_t count, uint32_t offset) {
    7efc:	53                   	push   %ebx
    uintptr_t end_va = va + count;
    7efd:	89 7d f0             	mov    %edi,-0x10(%ebp)

    // round down to sector boundary
    va -= offset % SECTSIZE;
    7f00:	89 c3                	mov    %eax,%ebx
    uint32_t secno = (offset / SECTSIZE) + 1;

    // If this is too slow, we could read lots of sectors at a time.
    // We'd write more to memory than asked, but it doesn't matter --
    // we load in increasing order.
    for (; va < end_va; va += SECTSIZE, secno ++) {
    7f02:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
    7f05:	73 71                	jae    7f78 <readseg+0x95>
static inline void write_eflags(uint32_t eflags) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
    7f07:	ba f7 01 00 00       	mov    $0x1f7,%edx
    7f0c:	ec                   	in     (%dx),%al
#define RES_SIZE        4096

/* waitdisk - wait for disk ready */
static void
waitdisk(void) {
    while ((inb(0x1F7) & 0xC0) != 0x40)
    7f0d:	83 e0 c0             	and    $0xffffffc0,%eax
    7f10:	3c 40                	cmp    $0x40,%al
    7f12:	75 f3                	jne    7f07 <readseg+0x24>
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
    7f14:	ba f2 01 00 00       	mov    $0x1f2,%edx
    7f19:	b0 01                	mov    $0x1,%al
    7f1b:	ee                   	out    %al,(%dx)
    7f1c:	ba f3 01 00 00       	mov    $0x1f3,%edx
    7f21:	89 f0                	mov    %esi,%eax
    7f23:	ee                   	out    %al,(%dx)
    7f24:	89 f0                	mov    %esi,%eax
    7f26:	ba f4 01 00 00       	mov    $0x1f4,%edx
    7f2b:	c1 e8 08             	shr    $0x8,%eax
    7f2e:	ee                   	out    %al,(%dx)
    7f2f:	89 f0                	mov    %esi,%eax
    7f31:	ba f5 01 00 00       	mov    $0x1f5,%edx
    7f36:	c1 e8 10             	shr    $0x10,%eax
    7f39:	ee                   	out    %al,(%dx)
    7f3a:	89 f0                	mov    %esi,%eax
    7f3c:	ba f6 01 00 00       	mov    $0x1f6,%edx
    7f41:	c1 e8 18             	shr    $0x18,%eax
    7f44:	83 e0 0f             	and    $0xf,%eax
    7f47:	83 c8 e0             	or     $0xffffffe0,%eax
    7f4a:	ee                   	out    %al,(%dx)
    7f4b:	b0 20                	mov    $0x20,%al
    7f4d:	ba f7 01 00 00       	mov    $0x1f7,%edx
    7f52:	ee                   	out    %al,(%dx)
static inline void write_eflags(uint32_t eflags) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
    7f53:	ba f7 01 00 00       	mov    $0x1f7,%edx
    7f58:	ec                   	in     (%dx),%al
    7f59:	83 e0 c0             	and    $0xffffffc0,%eax
    7f5c:	3c 40                	cmp    $0x40,%al
    7f5e:	75 f3                	jne    7f53 <readseg+0x70>
    return data;
}

static inline void
insl(uint32_t port, void *addr, int cnt) {
    asm volatile (
    7f60:	89 df                	mov    %ebx,%edi
    7f62:	b9 80 00 00 00       	mov    $0x80,%ecx
    7f67:	ba f0 01 00 00       	mov    $0x1f0,%edx
    7f6c:	fc                   	cld    
    7f6d:	f2 6d                	repnz insl (%dx),%es:(%edi)
    uint32_t secno = (offset / SECTSIZE) + 1;

    // If this is too slow, we could read lots of sectors at a time.
    // We'd write more to memory than asked, but it doesn't matter --
    // we load in increasing order.
    for (; va < end_va; va += SECTSIZE, secno ++) {
    7f6f:	81 c3 00 02 00 00    	add    $0x200,%ebx
    7f75:	46                   	inc    %esi
    7f76:	eb 8a                	jmp    7f02 <readseg+0x1f>
        readsect((void *)va, secno);
    }
}
    7f78:	58                   	pop    %eax
    7f79:	5b                   	pop    %ebx
    7f7a:	5e                   	pop    %esi
    7f7b:	5f                   	pop    %edi
    7f7c:	5d                   	pop    %ebp
    7f7d:	c3                   	ret    

00007f7e <bootmain>:

/* bootmain - the entry of bootloader */
void
bootmain(void) {
    7f7e:	55                   	push   %ebp
    // read the 1st page off disk
    readseg((uintptr_t)ELFHDR, SECTSIZE * 8, SECTSIZE * 2);
    7f7f:	b9 00 04 00 00       	mov    $0x400,%ecx
    7f84:	ba 00 10 00 00       	mov    $0x1000,%edx
    7f89:	b8 00 00 01 00       	mov    $0x10000,%eax
    }
}

/* bootmain - the entry of bootloader */
void
bootmain(void) {
    7f8e:	89 e5                	mov    %esp,%ebp
    7f90:	56                   	push   %esi
    7f91:	53                   	push   %ebx
    // read the 1st page off disk
    readseg((uintptr_t)ELFHDR, SECTSIZE * 8, SECTSIZE * 2);
    7f92:	e8 4c ff ff ff       	call   7ee3 <readseg>

    // is this a valid ELF?
    if (ELFHDR->e_magic != ELF_MAGIC) {
    7f97:	81 3d 00 00 01 00 7f 	cmpl   $0x464c457f,0x10000
    7f9e:	45 4c 46 
    7fa1:	75 59                	jne    7ffc <bootmain+0x7e>
    }

    struct proghdr *ph, *eph;

    // load each program segment (ignores ph flags)
    ph = (struct proghdr *)((uintptr_t)ELFHDR + ELFHDR->e_phoff);
    7fa3:	a1 1c 00 01 00       	mov    0x1001c,%eax
    eph = ph + ELFHDR->e_phnum;
    7fa8:	0f b7 35 2c 00 01 00 	movzwl 0x1002c,%esi
    }

    struct proghdr *ph, *eph;

    // load each program segment (ignores ph flags)
    ph = (struct proghdr *)((uintptr_t)ELFHDR + ELFHDR->e_phoff);
    7faf:	8d 98 00 00 01 00    	lea    0x10000(%eax),%ebx
    eph = ph + ELFHDR->e_phnum;
    7fb5:	c1 e6 05             	shl    $0x5,%esi
    7fb8:	01 de                	add    %ebx,%esi
    for (; ph < eph; ph ++) {
    7fba:	39 f3                	cmp    %esi,%ebx
    7fbc:	73 1e                	jae    7fdc <bootmain+0x5e>
        readseg(ph->p_va & 0xFFFFFF, ph->p_memsz, SECTSIZE*2+ph->p_offset);
    7fbe:	8b 43 04             	mov    0x4(%ebx),%eax
    7fc1:	8b 53 14             	mov    0x14(%ebx),%edx
    struct proghdr *ph, *eph;

    // load each program segment (ignores ph flags)
    ph = (struct proghdr *)((uintptr_t)ELFHDR + ELFHDR->e_phoff);
    eph = ph + ELFHDR->e_phnum;
    for (; ph < eph; ph ++) {
    7fc4:	83 c3 20             	add    $0x20,%ebx
        readseg(ph->p_va & 0xFFFFFF, ph->p_memsz, SECTSIZE*2+ph->p_offset);
    7fc7:	8d 88 00 04 00 00    	lea    0x400(%eax),%ecx
    7fcd:	8b 43 e8             	mov    -0x18(%ebx),%eax
    7fd0:	25 ff ff ff 00       	and    $0xffffff,%eax
    7fd5:	e8 09 ff ff ff       	call   7ee3 <readseg>
    7fda:	eb de                	jmp    7fba <bootmain+0x3c>
    }

    readseg((uintptr_t)RES_ADDR, SECTSIZE * (8+116), SECTSIZE * 8000);
    7fdc:	b8 00 10 01 00       	mov    $0x11000,%eax
    7fe1:	b9 00 80 3e 00       	mov    $0x3e8000,%ecx
    7fe6:	ba 00 f8 00 00       	mov    $0xf800,%edx
    7feb:	e8 f3 fe ff ff       	call   7ee3 <readseg>

    // call the entry point from the ELF header
    // note: does not return
    ((void (*)(void))(ELFHDR->e_entry & 0xFFFFFF))();
    7ff0:	a1 18 00 01 00       	mov    0x10018,%eax
    7ff5:	25 ff ff ff 00       	and    $0xffffff,%eax
    7ffa:	ff d0                	call   *%eax
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
}

static inline void
outw(uint16_t port, uint16_t data) {
    asm volatile ("outw %0, %1" :: "a" (data), "d" (port) : "memory");
    7ffc:	ba 00 8a ff ff       	mov    $0xffff8a00,%edx
    8001:	89 d0                	mov    %edx,%eax
    8003:	66 ef                	out    %ax,(%dx)
    8005:	b8 00 8e ff ff       	mov    $0xffff8e00,%eax
    800a:	66 ef                	out    %ax,(%dx)
    outw(0x8A00, 0x8A00);
    outw(0x8A00, 0x8E00);

    /* do nothing */
//    while (1);
}
    800c:	5b                   	pop    %ebx
    800d:	5e                   	pop    %esi
    800e:	5d                   	pop    %ebp
    800f:	c3                   	ret    
