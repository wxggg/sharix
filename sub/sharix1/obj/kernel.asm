
bin/kernel:     file format elf32-i386


Disassembly of section .text:

c0100000 <kern_entry>:
#include <entryasm.h>

.text
.global kern_entry
kern_entry:
	lgdt REALLOC(__gdtesc)
c0100000:	0f 01 15 18 30 11 00 	lgdtl  0x113018
	movl $KERNEL_DS, %eax
c0100007:	b8 10 00 00 00       	mov    $0x10,%eax
	movw %ax, %ds 
c010000c:	8e d8                	mov    %eax,%ds
	movw %ax, %es 
c010000e:	8e c0                	mov    %eax,%es
	movw %ax, %ss 
c0100010:	8e d0                	mov    %eax,%ss
	ljmp $KERNEL_CS, $relocated
c0100012:	ea 19 00 10 c0 08 00 	ljmp   $0x8,$0xc0100019

c0100019 <relocated>:

relocated:
	#set up ebp, esp
	movl $0x0, %ebp 
c0100019:	bd 00 00 00 00       	mov    $0x0,%ebp
	# kernel stack ------   bootstack --->  bootstacktop
	# kernel stack size KSTACKSIZE(8KB)
	movl $bootstacktop, %esp
c010001e:	bc 00 30 11 c0       	mov    $0xc0113000,%esp
	call kern_init
c0100023:	e8 02 00 00 00       	call   c010002a <kern_init>

c0100028 <spin>:

spin:
	jmp spin
c0100028:	eb fe                	jmp    c0100028 <spin>

c010002a <kern_init>:

int kern_init(void) __attribute__((noreturn));


int
kern_init(void) {
c010002a:	55                   	push   %ebp
c010002b:	89 e5                	mov    %esp,%ebp
c010002d:	83 ec 18             	sub    $0x18,%esp
    extern char edata[], end[];
    memset(edata, 0, end - edata);
c0100030:	ba d0 49 11 c0       	mov    $0xc01149d0,%edx
c0100035:	b8 88 3a 11 c0       	mov    $0xc0113a88,%eax
c010003a:	29 c2                	sub    %eax,%edx
c010003c:	89 d0                	mov    %edx,%eax
c010003e:	83 ec 04             	sub    $0x4,%esp
c0100041:	50                   	push   %eax
c0100042:	6a 00                	push   $0x0
c0100044:	68 88 3a 11 c0       	push   $0xc0113a88
c0100049:	e8 22 39 00 00       	call   c0103970 <memset>
c010004e:	83 c4 10             	add    $0x10,%esp
    struct BOOTINFO *binfo = (struct BOOTINFO *) ADR_BOOTINFO;
c0100051:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    cons_init();
c0100058:	e8 b3 10 00 00       	call   c0101110 <cons_init>

    const char *message = "Sharix is loading ...";
c010005d:	c7 45 f0 c0 42 10 c0 	movl   $0xc01042c0,-0x10(%ebp)
    cprintf("%s\n\n", message);
c0100064:	83 ec 08             	sub    $0x8,%esp
c0100067:	ff 75 f0             	pushl  -0x10(%ebp)
c010006a:	68 d6 42 10 c0       	push   $0xc01042d6
c010006f:	e8 70 00 00 00       	call   c01000e4 <cprintf>
c0100074:	83 c4 10             	add    $0x10,%esp

    print_kerninfo();
c0100077:	e8 6b 07 00 00       	call   c01007e7 <print_kerninfo>

    pmm_init();
c010007c:	e8 68 33 00 00       	call   c01033e9 <pmm_init>



    pic_init();
c0100081:	e8 59 11 00 00       	call   c01011df <pic_init>
    idt_init();
c0100086:	e8 cc 12 00 00       	call   c0101357 <idt_init>
 //   clock_init();

    intr_enable(); 
c010008b:	e8 b9 12 00 00       	call   c0101349 <intr_enable>

    graphic_init();
c0100090:	e8 78 20 00 00       	call   c010210d <graphic_init>

    while (1) {
//        monitor(NULL);
    }
c0100095:	eb fe                	jmp    c0100095 <kern_init+0x6b>

c0100097 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
c0100097:	55                   	push   %ebp
c0100098:	89 e5                	mov    %esp,%ebp
c010009a:	83 ec 08             	sub    $0x8,%esp
    cons_putc(c);
c010009d:	83 ec 0c             	sub    $0xc,%esp
c01000a0:	ff 75 08             	pushl  0x8(%ebp)
c01000a3:	e8 76 10 00 00       	call   c010111e <cons_putc>
c01000a8:	83 c4 10             	add    $0x10,%esp
    (*cnt) ++;
c01000ab:	8b 45 0c             	mov    0xc(%ebp),%eax
c01000ae:	8b 00                	mov    (%eax),%eax
c01000b0:	8d 50 01             	lea    0x1(%eax),%edx
c01000b3:	8b 45 0c             	mov    0xc(%ebp),%eax
c01000b6:	89 10                	mov    %edx,(%eax)
}
c01000b8:	90                   	nop
c01000b9:	c9                   	leave  
c01000ba:	c3                   	ret    

c01000bb <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
c01000bb:	55                   	push   %ebp
c01000bc:	89 e5                	mov    %esp,%ebp
c01000be:	83 ec 18             	sub    $0x18,%esp
    int cnt = 0;
c01000c1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
c01000c8:	ff 75 0c             	pushl  0xc(%ebp)
c01000cb:	ff 75 08             	pushl  0x8(%ebp)
c01000ce:	8d 45 f4             	lea    -0xc(%ebp),%eax
c01000d1:	50                   	push   %eax
c01000d2:	68 97 00 10 c0       	push   $0xc0100097
c01000d7:	e8 ca 3b 00 00       	call   c0103ca6 <vprintfmt>
c01000dc:	83 c4 10             	add    $0x10,%esp
    return cnt;
c01000df:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01000e2:	c9                   	leave  
c01000e3:	c3                   	ret    

c01000e4 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
c01000e4:	55                   	push   %ebp
c01000e5:	89 e5                	mov    %esp,%ebp
c01000e7:	83 ec 18             	sub    $0x18,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c01000ea:	8d 45 0c             	lea    0xc(%ebp),%eax
c01000ed:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vcprintf(fmt, ap);
c01000f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01000f3:	83 ec 08             	sub    $0x8,%esp
c01000f6:	50                   	push   %eax
c01000f7:	ff 75 08             	pushl  0x8(%ebp)
c01000fa:	e8 bc ff ff ff       	call   c01000bb <vcprintf>
c01000ff:	83 c4 10             	add    $0x10,%esp
c0100102:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c0100105:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100108:	c9                   	leave  
c0100109:	c3                   	ret    

c010010a <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
c010010a:	55                   	push   %ebp
c010010b:	89 e5                	mov    %esp,%ebp
c010010d:	83 ec 08             	sub    $0x8,%esp
    cons_putc(c);
c0100110:	83 ec 0c             	sub    $0xc,%esp
c0100113:	ff 75 08             	pushl  0x8(%ebp)
c0100116:	e8 03 10 00 00       	call   c010111e <cons_putc>
c010011b:	83 c4 10             	add    $0x10,%esp
}
c010011e:	90                   	nop
c010011f:	c9                   	leave  
c0100120:	c3                   	ret    

c0100121 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
c0100121:	55                   	push   %ebp
c0100122:	89 e5                	mov    %esp,%ebp
c0100124:	83 ec 18             	sub    $0x18,%esp
    int cnt = 0;
c0100127:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    char c;
    while ((c = *str ++) != '\0') {
c010012e:	eb 14                	jmp    c0100144 <cputs+0x23>
        cputch(c, &cnt);
c0100130:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c0100134:	83 ec 08             	sub    $0x8,%esp
c0100137:	8d 55 f0             	lea    -0x10(%ebp),%edx
c010013a:	52                   	push   %edx
c010013b:	50                   	push   %eax
c010013c:	e8 56 ff ff ff       	call   c0100097 <cputch>
c0100141:	83 c4 10             	add    $0x10,%esp
 * */
int
cputs(const char *str) {
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
c0100144:	8b 45 08             	mov    0x8(%ebp),%eax
c0100147:	8d 50 01             	lea    0x1(%eax),%edx
c010014a:	89 55 08             	mov    %edx,0x8(%ebp)
c010014d:	0f b6 00             	movzbl (%eax),%eax
c0100150:	88 45 f7             	mov    %al,-0x9(%ebp)
c0100153:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
c0100157:	75 d7                	jne    c0100130 <cputs+0xf>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
c0100159:	83 ec 08             	sub    $0x8,%esp
c010015c:	8d 45 f0             	lea    -0x10(%ebp),%eax
c010015f:	50                   	push   %eax
c0100160:	6a 0a                	push   $0xa
c0100162:	e8 30 ff ff ff       	call   c0100097 <cputch>
c0100167:	83 c4 10             	add    $0x10,%esp
    return cnt;
c010016a:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c010016d:	c9                   	leave  
c010016e:	c3                   	ret    

c010016f <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
c010016f:	55                   	push   %ebp
c0100170:	89 e5                	mov    %esp,%ebp
c0100172:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = cons_getc()) == 0)
c0100175:	e8 b5 0f 00 00       	call   c010112f <cons_getc>
c010017a:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010017d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100181:	74 f2                	je     c0100175 <getchar+0x6>
        /* do nothing */;
    return c;
c0100183:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100186:	c9                   	leave  
c0100187:	c3                   	ret    

c0100188 <io_cli>:
.global io_out8
.global io_cli
.global io_sti

io_cli:	# void io_cli(void);
	cli 
c0100188:	fa                   	cli    
	ret
c0100189:	c3                   	ret    

c010018a <io_sti>:

io_sti: # void io_sti(void);
	sti 
c010018a:	fb                   	sti    
	ret 
c010018b:	c3                   	ret    

c010018c <io_load_eflags>:

io_load_eflags: # int io_load_eflags(void)
    pushfl
c010018c:	9c                   	pushf  
    pop %eax
c010018d:	58                   	pop    %eax
    ret
c010018e:	c3                   	ret    

c010018f <io_store_eflags>:

io_store_eflags: # void io_store_eflags(int eflags);
	movl 4(%esp), %eax
c010018f:	8b 44 24 04          	mov    0x4(%esp),%eax
	push %eax 
c0100193:	50                   	push   %eax
	popfl
c0100194:	9d                   	popf   
	ret
c0100195:	c3                   	ret    

c0100196 <io_in8>:

io_in8: # int io_in8(int port)
	movl 4(%esp), %edx
c0100196:	8b 54 24 04          	mov    0x4(%esp),%edx
	xorl %eax, %eax
c010019a:	31 c0                	xor    %eax,%eax
	in %dx, %al 
c010019c:	ec                   	in     (%dx),%al
	ret
c010019d:	c3                   	ret    

c010019e <io_out8>:

io_out8: # void io_out8(int port, int data)
	movl 4(%esp), %edx
c010019e:	8b 54 24 04          	mov    0x4(%esp),%edx
	movb 8(%esp), %al 
c01001a2:	8a 44 24 08          	mov    0x8(%esp),%al
	outb %al, %dx 
c01001a6:	ee                   	out    %al,(%dx)
c01001a7:	c3                   	ret    

c01001a8 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
c01001a8:	55                   	push   %ebp
c01001a9:	89 e5                	mov    %esp,%ebp
c01001ab:	83 ec 28             	sub    $0x28,%esp
    if (prompt != NULL) {
c01001ae:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01001b2:	74 13                	je     c01001c7 <readline+0x1f>
        cprintf("%s", prompt);
c01001b4:	83 ec 08             	sub    $0x8,%esp
c01001b7:	ff 75 08             	pushl  0x8(%ebp)
c01001ba:	68 db 42 10 c0       	push   $0xc01042db
c01001bf:	e8 20 ff ff ff       	call   c01000e4 <cprintf>
c01001c4:	83 c4 10             	add    $0x10,%esp
    }
    int i = 0 , c;
c01001c7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        c = getchar();
c01001ce:	e8 9c ff ff ff       	call   c010016f <getchar>
c01001d3:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (c < 0) {
c01001d6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01001da:	79 0a                	jns    c01001e6 <readline+0x3e>
            return NULL;
c01001dc:	b8 00 00 00 00       	mov    $0x0,%eax
c01001e1:	e9 e1 00 00 00       	jmp    c01002c7 <readline+0x11f>
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
c01001e6:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
c01001ea:	7e 79                	jle    c0100265 <readline+0xbd>
c01001ec:	81 7d f4 fe 03 00 00 	cmpl   $0x3fe,-0xc(%ebp)
c01001f3:	7f 70                	jg     c0100265 <readline+0xbd>
            cputchar(c);
c01001f5:	83 ec 0c             	sub    $0xc,%esp
c01001f8:	ff 75 f0             	pushl  -0x10(%ebp)
c01001fb:	e8 0a ff ff ff       	call   c010010a <cputchar>
c0100200:	83 c4 10             	add    $0x10,%esp
            buf[i ++] = c;
c0100203:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100206:	8d 50 01             	lea    0x1(%eax),%edx
c0100209:	89 55 f4             	mov    %edx,-0xc(%ebp)
c010020c:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010020f:	88 90 a0 3a 11 c0    	mov    %dl,-0x3feec560(%eax)
            draw_asc16(c, (point_t){20+8*i, 20+16*j}, (rgb_t){32,32,32});
c0100215:	c6 45 e5 20          	movb   $0x20,-0x1b(%ebp)
c0100219:	c6 45 e6 20          	movb   $0x20,-0x1a(%ebp)
c010021d:	c6 45 e7 20          	movb   $0x20,-0x19(%ebp)
c0100221:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100224:	c1 e0 03             	shl    $0x3,%eax
c0100227:	83 c0 14             	add    $0x14,%eax
c010022a:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010022d:	a1 a0 3e 11 c0       	mov    0xc0113ea0,%eax
c0100232:	c1 e0 04             	shl    $0x4,%eax
c0100235:	83 c0 14             	add    $0x14,%eax
c0100238:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010023b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010023e:	0f be d0             	movsbl %al,%edx
c0100241:	83 ec 04             	sub    $0x4,%esp
c0100244:	89 e0                	mov    %esp,%eax
c0100246:	0f b7 4d e5          	movzwl -0x1b(%ebp),%ecx
c010024a:	66 89 08             	mov    %cx,(%eax)
c010024d:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
c0100251:	88 48 02             	mov    %cl,0x2(%eax)
c0100254:	ff 75 ec             	pushl  -0x14(%ebp)
c0100257:	ff 75 e8             	pushl  -0x18(%ebp)
c010025a:	52                   	push   %edx
c010025b:	e8 03 29 00 00       	call   c0102b63 <draw_asc16>
c0100260:	83 c4 10             	add    $0x10,%esp
c0100263:	eb 5d                	jmp    c01002c2 <readline+0x11a>
        }
        else if (c == '\b' && i > 0) {
c0100265:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
c0100269:	75 1a                	jne    c0100285 <readline+0xdd>
c010026b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010026f:	7e 14                	jle    c0100285 <readline+0xdd>
            cputchar(c);
c0100271:	83 ec 0c             	sub    $0xc,%esp
c0100274:	ff 75 f0             	pushl  -0x10(%ebp)
c0100277:	e8 8e fe ff ff       	call   c010010a <cputchar>
c010027c:	83 c4 10             	add    $0x10,%esp
            i --;
c010027f:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c0100283:	eb 3d                	jmp    c01002c2 <readline+0x11a>
        }
        else if (c == '\n' || c == '\r') {
c0100285:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
c0100289:	74 0a                	je     c0100295 <readline+0xed>
c010028b:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
c010028f:	0f 85 39 ff ff ff    	jne    c01001ce <readline+0x26>
            cputchar(c);
c0100295:	83 ec 0c             	sub    $0xc,%esp
c0100298:	ff 75 f0             	pushl  -0x10(%ebp)
c010029b:	e8 6a fe ff ff       	call   c010010a <cputchar>
c01002a0:	83 c4 10             	add    $0x10,%esp
            buf[i] = '\0';
c01002a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01002a6:	05 a0 3a 11 c0       	add    $0xc0113aa0,%eax
c01002ab:	c6 00 00             	movb   $0x0,(%eax)
            j++;
c01002ae:	a1 a0 3e 11 c0       	mov    0xc0113ea0,%eax
c01002b3:	83 c0 01             	add    $0x1,%eax
c01002b6:	a3 a0 3e 11 c0       	mov    %eax,0xc0113ea0
            return buf;
c01002bb:	b8 a0 3a 11 c0       	mov    $0xc0113aa0,%eax
c01002c0:	eb 05                	jmp    c01002c7 <readline+0x11f>
        }
    }
c01002c2:	e9 07 ff ff ff       	jmp    c01001ce <readline+0x26>
}
c01002c7:	c9                   	leave  
c01002c8:	c3                   	ret    

c01002c9 <__panic>:
/* *
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
c01002c9:	55                   	push   %ebp
c01002ca:	89 e5                	mov    %esp,%ebp
c01002cc:	83 ec 18             	sub    $0x18,%esp
    if (is_panic) {
c01002cf:	a1 a4 3e 11 c0       	mov    0xc0113ea4,%eax
c01002d4:	85 c0                	test   %eax,%eax
c01002d6:	74 02                	je     c01002da <__panic+0x11>
        goto panic_dead;
c01002d8:	eb 48                	jmp    c0100322 <__panic+0x59>
    }
    is_panic = 1;
c01002da:	c7 05 a4 3e 11 c0 01 	movl   $0x1,0xc0113ea4
c01002e1:	00 00 00 

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
c01002e4:	8d 45 14             	lea    0x14(%ebp),%eax
c01002e7:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
c01002ea:	83 ec 04             	sub    $0x4,%esp
c01002ed:	ff 75 0c             	pushl  0xc(%ebp)
c01002f0:	ff 75 08             	pushl  0x8(%ebp)
c01002f3:	68 de 42 10 c0       	push   $0xc01042de
c01002f8:	e8 e7 fd ff ff       	call   c01000e4 <cprintf>
c01002fd:	83 c4 10             	add    $0x10,%esp
    vcprintf(fmt, ap);
c0100300:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100303:	83 ec 08             	sub    $0x8,%esp
c0100306:	50                   	push   %eax
c0100307:	ff 75 10             	pushl  0x10(%ebp)
c010030a:	e8 ac fd ff ff       	call   c01000bb <vcprintf>
c010030f:	83 c4 10             	add    $0x10,%esp
    cprintf("\n");
c0100312:	83 ec 0c             	sub    $0xc,%esp
c0100315:	68 fa 42 10 c0       	push   $0xc01042fa
c010031a:	e8 c5 fd ff ff       	call   c01000e4 <cprintf>
c010031f:	83 c4 10             	add    $0x10,%esp
    va_end(ap);

panic_dead:
    while (1) {
        monitor(NULL);
c0100322:	83 ec 0c             	sub    $0xc,%esp
c0100325:	6a 00                	push   $0x0
c0100327:	e8 36 08 00 00       	call   c0100b62 <monitor>
c010032c:	83 c4 10             	add    $0x10,%esp
    }
c010032f:	eb f1                	jmp    c0100322 <__panic+0x59>

c0100331 <__warn>:
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
c0100331:	55                   	push   %ebp
c0100332:	89 e5                	mov    %esp,%ebp
c0100334:	83 ec 18             	sub    $0x18,%esp
    va_list ap;
    va_start(ap, fmt);
c0100337:	8d 45 14             	lea    0x14(%ebp),%eax
c010033a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
c010033d:	83 ec 04             	sub    $0x4,%esp
c0100340:	ff 75 0c             	pushl  0xc(%ebp)
c0100343:	ff 75 08             	pushl  0x8(%ebp)
c0100346:	68 fc 42 10 c0       	push   $0xc01042fc
c010034b:	e8 94 fd ff ff       	call   c01000e4 <cprintf>
c0100350:	83 c4 10             	add    $0x10,%esp
    vcprintf(fmt, ap);
c0100353:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100356:	83 ec 08             	sub    $0x8,%esp
c0100359:	50                   	push   %eax
c010035a:	ff 75 10             	pushl  0x10(%ebp)
c010035d:	e8 59 fd ff ff       	call   c01000bb <vcprintf>
c0100362:	83 c4 10             	add    $0x10,%esp
    cprintf("\n");
c0100365:	83 ec 0c             	sub    $0xc,%esp
c0100368:	68 fa 42 10 c0       	push   $0xc01042fa
c010036d:	e8 72 fd ff ff       	call   c01000e4 <cprintf>
c0100372:	83 c4 10             	add    $0x10,%esp
    va_end(ap);
}
c0100375:	90                   	nop
c0100376:	c9                   	leave  
c0100377:	c3                   	ret    

c0100378 <is_kernel_panic>:

bool
is_kernel_panic(void) {
c0100378:	55                   	push   %ebp
c0100379:	89 e5                	mov    %esp,%ebp
    return is_panic;
c010037b:	a1 a4 3e 11 c0       	mov    0xc0113ea4,%eax
}
c0100380:	5d                   	pop    %ebp
c0100381:	c3                   	ret    

c0100382 <stab_binsearch>:
 *      stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
 * will exit setting left = 118, right = 554.
 * */
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
c0100382:	55                   	push   %ebp
c0100383:	89 e5                	mov    %esp,%ebp
c0100385:	83 ec 20             	sub    $0x20,%esp
    int l = *region_left, r = *region_right, any_matches = 0;
c0100388:	8b 45 0c             	mov    0xc(%ebp),%eax
c010038b:	8b 00                	mov    (%eax),%eax
c010038d:	89 45 fc             	mov    %eax,-0x4(%ebp)
c0100390:	8b 45 10             	mov    0x10(%ebp),%eax
c0100393:	8b 00                	mov    (%eax),%eax
c0100395:	89 45 f8             	mov    %eax,-0x8(%ebp)
c0100398:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

    while (l <= r) {
c010039f:	e9 d2 00 00 00       	jmp    c0100476 <stab_binsearch+0xf4>
        int true_m = (l + r) / 2, m = true_m;
c01003a4:	8b 55 fc             	mov    -0x4(%ebp),%edx
c01003a7:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01003aa:	01 d0                	add    %edx,%eax
c01003ac:	89 c2                	mov    %eax,%edx
c01003ae:	c1 ea 1f             	shr    $0x1f,%edx
c01003b1:	01 d0                	add    %edx,%eax
c01003b3:	d1 f8                	sar    %eax
c01003b5:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01003b8:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01003bb:	89 45 f0             	mov    %eax,-0x10(%ebp)

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
c01003be:	eb 04                	jmp    c01003c4 <stab_binsearch+0x42>
            m --;
c01003c0:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)

    while (l <= r) {
        int true_m = (l + r) / 2, m = true_m;

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
c01003c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01003c7:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c01003ca:	7c 1f                	jl     c01003eb <stab_binsearch+0x69>
c01003cc:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01003cf:	89 d0                	mov    %edx,%eax
c01003d1:	01 c0                	add    %eax,%eax
c01003d3:	01 d0                	add    %edx,%eax
c01003d5:	c1 e0 02             	shl    $0x2,%eax
c01003d8:	89 c2                	mov    %eax,%edx
c01003da:	8b 45 08             	mov    0x8(%ebp),%eax
c01003dd:	01 d0                	add    %edx,%eax
c01003df:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c01003e3:	0f b6 c0             	movzbl %al,%eax
c01003e6:	3b 45 14             	cmp    0x14(%ebp),%eax
c01003e9:	75 d5                	jne    c01003c0 <stab_binsearch+0x3e>
            m --;
        }
        if (m < l) {    // no match in [l, m]
c01003eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01003ee:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c01003f1:	7d 0b                	jge    c01003fe <stab_binsearch+0x7c>
            l = true_m + 1;
c01003f3:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01003f6:	83 c0 01             	add    $0x1,%eax
c01003f9:	89 45 fc             	mov    %eax,-0x4(%ebp)
            continue;
c01003fc:	eb 78                	jmp    c0100476 <stab_binsearch+0xf4>
        }

        // actual binary search
        any_matches = 1;
c01003fe:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
        if (stabs[m].n_value < addr) {
c0100405:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100408:	89 d0                	mov    %edx,%eax
c010040a:	01 c0                	add    %eax,%eax
c010040c:	01 d0                	add    %edx,%eax
c010040e:	c1 e0 02             	shl    $0x2,%eax
c0100411:	89 c2                	mov    %eax,%edx
c0100413:	8b 45 08             	mov    0x8(%ebp),%eax
c0100416:	01 d0                	add    %edx,%eax
c0100418:	8b 40 08             	mov    0x8(%eax),%eax
c010041b:	3b 45 18             	cmp    0x18(%ebp),%eax
c010041e:	73 13                	jae    c0100433 <stab_binsearch+0xb1>
            *region_left = m;
c0100420:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100423:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100426:	89 10                	mov    %edx,(%eax)
            l = true_m + 1;
c0100428:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010042b:	83 c0 01             	add    $0x1,%eax
c010042e:	89 45 fc             	mov    %eax,-0x4(%ebp)
c0100431:	eb 43                	jmp    c0100476 <stab_binsearch+0xf4>
        } else if (stabs[m].n_value > addr) {
c0100433:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100436:	89 d0                	mov    %edx,%eax
c0100438:	01 c0                	add    %eax,%eax
c010043a:	01 d0                	add    %edx,%eax
c010043c:	c1 e0 02             	shl    $0x2,%eax
c010043f:	89 c2                	mov    %eax,%edx
c0100441:	8b 45 08             	mov    0x8(%ebp),%eax
c0100444:	01 d0                	add    %edx,%eax
c0100446:	8b 40 08             	mov    0x8(%eax),%eax
c0100449:	3b 45 18             	cmp    0x18(%ebp),%eax
c010044c:	76 16                	jbe    c0100464 <stab_binsearch+0xe2>
            *region_right = m - 1;
c010044e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100451:	8d 50 ff             	lea    -0x1(%eax),%edx
c0100454:	8b 45 10             	mov    0x10(%ebp),%eax
c0100457:	89 10                	mov    %edx,(%eax)
            r = m - 1;
c0100459:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010045c:	83 e8 01             	sub    $0x1,%eax
c010045f:	89 45 f8             	mov    %eax,-0x8(%ebp)
c0100462:	eb 12                	jmp    c0100476 <stab_binsearch+0xf4>
        } else {
            // exact match for 'addr', but continue loop to find
            // *region_right
            *region_left = m;
c0100464:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100467:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010046a:	89 10                	mov    %edx,(%eax)
            l = m;
c010046c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010046f:	89 45 fc             	mov    %eax,-0x4(%ebp)
            addr ++;
c0100472:	83 45 18 01          	addl   $0x1,0x18(%ebp)
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
    int l = *region_left, r = *region_right, any_matches = 0;

    while (l <= r) {
c0100476:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100479:	3b 45 f8             	cmp    -0x8(%ebp),%eax
c010047c:	0f 8e 22 ff ff ff    	jle    c01003a4 <stab_binsearch+0x22>
            l = m;
            addr ++;
        }
    }

    if (!any_matches) {
c0100482:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100486:	75 0f                	jne    c0100497 <stab_binsearch+0x115>
        *region_right = *region_left - 1;
c0100488:	8b 45 0c             	mov    0xc(%ebp),%eax
c010048b:	8b 00                	mov    (%eax),%eax
c010048d:	8d 50 ff             	lea    -0x1(%eax),%edx
c0100490:	8b 45 10             	mov    0x10(%ebp),%eax
c0100493:	89 10                	mov    %edx,(%eax)
        l = *region_right;
        for (; l > *region_left && stabs[l].n_type != type; l --)
            /* do nothing */;
        *region_left = l;
    }
}
c0100495:	eb 3f                	jmp    c01004d6 <stab_binsearch+0x154>
    if (!any_matches) {
        *region_right = *region_left - 1;
    }
    else {
        // find rightmost region containing 'addr'
        l = *region_right;
c0100497:	8b 45 10             	mov    0x10(%ebp),%eax
c010049a:	8b 00                	mov    (%eax),%eax
c010049c:	89 45 fc             	mov    %eax,-0x4(%ebp)
        for (; l > *region_left && stabs[l].n_type != type; l --)
c010049f:	eb 04                	jmp    c01004a5 <stab_binsearch+0x123>
c01004a1:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
c01004a5:	8b 45 0c             	mov    0xc(%ebp),%eax
c01004a8:	8b 00                	mov    (%eax),%eax
c01004aa:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c01004ad:	7d 1f                	jge    c01004ce <stab_binsearch+0x14c>
c01004af:	8b 55 fc             	mov    -0x4(%ebp),%edx
c01004b2:	89 d0                	mov    %edx,%eax
c01004b4:	01 c0                	add    %eax,%eax
c01004b6:	01 d0                	add    %edx,%eax
c01004b8:	c1 e0 02             	shl    $0x2,%eax
c01004bb:	89 c2                	mov    %eax,%edx
c01004bd:	8b 45 08             	mov    0x8(%ebp),%eax
c01004c0:	01 d0                	add    %edx,%eax
c01004c2:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c01004c6:	0f b6 c0             	movzbl %al,%eax
c01004c9:	3b 45 14             	cmp    0x14(%ebp),%eax
c01004cc:	75 d3                	jne    c01004a1 <stab_binsearch+0x11f>
            /* do nothing */;
        *region_left = l;
c01004ce:	8b 45 0c             	mov    0xc(%ebp),%eax
c01004d1:	8b 55 fc             	mov    -0x4(%ebp),%edx
c01004d4:	89 10                	mov    %edx,(%eax)
    }
}
c01004d6:	90                   	nop
c01004d7:	c9                   	leave  
c01004d8:	c3                   	ret    

c01004d9 <debuginfo_eip>:
 * the specified instruction address, @addr.  Returns 0 if information
 * was found, and negative if not.  But even if it returns negative it
 * has stored some information into '*info'.
 * */
int
debuginfo_eip(uintptr_t addr, struct eipdebuginfo *info) {
c01004d9:	55                   	push   %ebp
c01004da:	89 e5                	mov    %esp,%ebp
c01004dc:	83 ec 38             	sub    $0x38,%esp
    const struct stab *stabs, *stab_end;
    const char *stabstr, *stabstr_end;

    info->eip_file = "<unknown>";
c01004df:	8b 45 0c             	mov    0xc(%ebp),%eax
c01004e2:	c7 00 1c 43 10 c0    	movl   $0xc010431c,(%eax)
    info->eip_line = 0;
c01004e8:	8b 45 0c             	mov    0xc(%ebp),%eax
c01004eb:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
c01004f2:	8b 45 0c             	mov    0xc(%ebp),%eax
c01004f5:	c7 40 08 1c 43 10 c0 	movl   $0xc010431c,0x8(%eax)
    info->eip_fn_namelen = 9;
c01004fc:	8b 45 0c             	mov    0xc(%ebp),%eax
c01004ff:	c7 40 0c 09 00 00 00 	movl   $0x9,0xc(%eax)
    info->eip_fn_addr = addr;
c0100506:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100509:	8b 55 08             	mov    0x8(%ebp),%edx
c010050c:	89 50 10             	mov    %edx,0x10(%eax)
    info->eip_fn_narg = 0;
c010050f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100512:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)

    stabs = __STAB_BEGIN__;
c0100519:	c7 45 f4 c0 49 10 c0 	movl   $0xc01049c0,-0xc(%ebp)
    stab_end = __STAB_END__;
c0100520:	c7 45 f0 34 e1 10 c0 	movl   $0xc010e134,-0x10(%ebp)
    stabstr = __STABSTR_BEGIN__;
c0100527:	c7 45 ec 35 e1 10 c0 	movl   $0xc010e135,-0x14(%ebp)
    stabstr_end = __STABSTR_END__;
c010052e:	c7 45 e8 0c 0d 11 c0 	movl   $0xc0110d0c,-0x18(%ebp)

    // String table validity checks
    if (stabstr_end <= stabstr || stabstr_end[-1] != 0) {
c0100535:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100538:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c010053b:	76 0d                	jbe    c010054a <debuginfo_eip+0x71>
c010053d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100540:	83 e8 01             	sub    $0x1,%eax
c0100543:	0f b6 00             	movzbl (%eax),%eax
c0100546:	84 c0                	test   %al,%al
c0100548:	74 0a                	je     c0100554 <debuginfo_eip+0x7b>
        return -1;
c010054a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c010054f:	e9 91 02 00 00       	jmp    c01007e5 <debuginfo_eip+0x30c>
    // 'eip'.  First, we find the basic source file containing 'eip'.
    // Then, we look in that source file for the function.  Then we look
    // for the line number.

    // Search the entire set of stabs for the source file (type N_SO).
    int lfile = 0, rfile = (stab_end - stabs) - 1;
c0100554:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
c010055b:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010055e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100561:	29 c2                	sub    %eax,%edx
c0100563:	89 d0                	mov    %edx,%eax
c0100565:	c1 f8 02             	sar    $0x2,%eax
c0100568:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
c010056e:	83 e8 01             	sub    $0x1,%eax
c0100571:	89 45 e0             	mov    %eax,-0x20(%ebp)
    stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
c0100574:	ff 75 08             	pushl  0x8(%ebp)
c0100577:	6a 64                	push   $0x64
c0100579:	8d 45 e0             	lea    -0x20(%ebp),%eax
c010057c:	50                   	push   %eax
c010057d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
c0100580:	50                   	push   %eax
c0100581:	ff 75 f4             	pushl  -0xc(%ebp)
c0100584:	e8 f9 fd ff ff       	call   c0100382 <stab_binsearch>
c0100589:	83 c4 14             	add    $0x14,%esp
    if (lfile == 0)
c010058c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010058f:	85 c0                	test   %eax,%eax
c0100591:	75 0a                	jne    c010059d <debuginfo_eip+0xc4>
        return -1;
c0100593:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0100598:	e9 48 02 00 00       	jmp    c01007e5 <debuginfo_eip+0x30c>

    // Search within that file's stabs for the function definition
    // (N_FUN).
    int lfun = lfile, rfun = rfile;
c010059d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01005a0:	89 45 dc             	mov    %eax,-0x24(%ebp)
c01005a3:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01005a6:	89 45 d8             	mov    %eax,-0x28(%ebp)
    int lline, rline;
    stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
c01005a9:	ff 75 08             	pushl  0x8(%ebp)
c01005ac:	6a 24                	push   $0x24
c01005ae:	8d 45 d8             	lea    -0x28(%ebp),%eax
c01005b1:	50                   	push   %eax
c01005b2:	8d 45 dc             	lea    -0x24(%ebp),%eax
c01005b5:	50                   	push   %eax
c01005b6:	ff 75 f4             	pushl  -0xc(%ebp)
c01005b9:	e8 c4 fd ff ff       	call   c0100382 <stab_binsearch>
c01005be:	83 c4 14             	add    $0x14,%esp

    if (lfun <= rfun) {
c01005c1:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01005c4:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01005c7:	39 c2                	cmp    %eax,%edx
c01005c9:	7f 7c                	jg     c0100647 <debuginfo_eip+0x16e>
        // stabs[lfun] points to the function name
        // in the string table, but check bounds just in case.
        if (stabs[lfun].n_strx < stabstr_end - stabstr) {
c01005cb:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01005ce:	89 c2                	mov    %eax,%edx
c01005d0:	89 d0                	mov    %edx,%eax
c01005d2:	01 c0                	add    %eax,%eax
c01005d4:	01 d0                	add    %edx,%eax
c01005d6:	c1 e0 02             	shl    $0x2,%eax
c01005d9:	89 c2                	mov    %eax,%edx
c01005db:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01005de:	01 d0                	add    %edx,%eax
c01005e0:	8b 00                	mov    (%eax),%eax
c01005e2:	8b 4d e8             	mov    -0x18(%ebp),%ecx
c01005e5:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01005e8:	29 d1                	sub    %edx,%ecx
c01005ea:	89 ca                	mov    %ecx,%edx
c01005ec:	39 d0                	cmp    %edx,%eax
c01005ee:	73 22                	jae    c0100612 <debuginfo_eip+0x139>
            info->eip_fn_name = stabstr + stabs[lfun].n_strx;
c01005f0:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01005f3:	89 c2                	mov    %eax,%edx
c01005f5:	89 d0                	mov    %edx,%eax
c01005f7:	01 c0                	add    %eax,%eax
c01005f9:	01 d0                	add    %edx,%eax
c01005fb:	c1 e0 02             	shl    $0x2,%eax
c01005fe:	89 c2                	mov    %eax,%edx
c0100600:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100603:	01 d0                	add    %edx,%eax
c0100605:	8b 10                	mov    (%eax),%edx
c0100607:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010060a:	01 c2                	add    %eax,%edx
c010060c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010060f:	89 50 08             	mov    %edx,0x8(%eax)
        }
        info->eip_fn_addr = stabs[lfun].n_value;
c0100612:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100615:	89 c2                	mov    %eax,%edx
c0100617:	89 d0                	mov    %edx,%eax
c0100619:	01 c0                	add    %eax,%eax
c010061b:	01 d0                	add    %edx,%eax
c010061d:	c1 e0 02             	shl    $0x2,%eax
c0100620:	89 c2                	mov    %eax,%edx
c0100622:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100625:	01 d0                	add    %edx,%eax
c0100627:	8b 50 08             	mov    0x8(%eax),%edx
c010062a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010062d:	89 50 10             	mov    %edx,0x10(%eax)
        addr -= info->eip_fn_addr;
c0100630:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100633:	8b 40 10             	mov    0x10(%eax),%eax
c0100636:	29 45 08             	sub    %eax,0x8(%ebp)
        // Search within the function definition for the line number.
        lline = lfun;
c0100639:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010063c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfun;
c010063f:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0100642:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0100645:	eb 15                	jmp    c010065c <debuginfo_eip+0x183>
    } else {
        // Couldn't find function stab!  Maybe we're in an assembly
        // file.  Search the whole file for the line number.
        info->eip_fn_addr = addr;
c0100647:	8b 45 0c             	mov    0xc(%ebp),%eax
c010064a:	8b 55 08             	mov    0x8(%ebp),%edx
c010064d:	89 50 10             	mov    %edx,0x10(%eax)
        lline = lfile;
c0100650:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100653:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfile;
c0100656:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0100659:	89 45 d0             	mov    %eax,-0x30(%ebp)
    }
    info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
c010065c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010065f:	8b 40 08             	mov    0x8(%eax),%eax
c0100662:	83 ec 08             	sub    $0x8,%esp
c0100665:	6a 3a                	push   $0x3a
c0100667:	50                   	push   %eax
c0100668:	e8 77 31 00 00       	call   c01037e4 <strfind>
c010066d:	83 c4 10             	add    $0x10,%esp
c0100670:	89 c2                	mov    %eax,%edx
c0100672:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100675:	8b 40 08             	mov    0x8(%eax),%eax
c0100678:	29 c2                	sub    %eax,%edx
c010067a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010067d:	89 50 0c             	mov    %edx,0xc(%eax)

    // Search within [lline, rline] for the line number stab.
    // If found, set info->eip_line to the right line number.
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
c0100680:	83 ec 0c             	sub    $0xc,%esp
c0100683:	ff 75 08             	pushl  0x8(%ebp)
c0100686:	6a 44                	push   $0x44
c0100688:	8d 45 d0             	lea    -0x30(%ebp),%eax
c010068b:	50                   	push   %eax
c010068c:	8d 45 d4             	lea    -0x2c(%ebp),%eax
c010068f:	50                   	push   %eax
c0100690:	ff 75 f4             	pushl  -0xc(%ebp)
c0100693:	e8 ea fc ff ff       	call   c0100382 <stab_binsearch>
c0100698:	83 c4 20             	add    $0x20,%esp
    if (lline <= rline) {
c010069b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010069e:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01006a1:	39 c2                	cmp    %eax,%edx
c01006a3:	7f 24                	jg     c01006c9 <debuginfo_eip+0x1f0>
        info->eip_line = stabs[rline].n_desc;
c01006a5:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01006a8:	89 c2                	mov    %eax,%edx
c01006aa:	89 d0                	mov    %edx,%eax
c01006ac:	01 c0                	add    %eax,%eax
c01006ae:	01 d0                	add    %edx,%eax
c01006b0:	c1 e0 02             	shl    $0x2,%eax
c01006b3:	89 c2                	mov    %eax,%edx
c01006b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01006b8:	01 d0                	add    %edx,%eax
c01006ba:	0f b7 40 06          	movzwl 0x6(%eax),%eax
c01006be:	0f b7 d0             	movzwl %ax,%edx
c01006c1:	8b 45 0c             	mov    0xc(%ebp),%eax
c01006c4:	89 50 04             	mov    %edx,0x4(%eax)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
c01006c7:	eb 13                	jmp    c01006dc <debuginfo_eip+0x203>
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
    if (lline <= rline) {
        info->eip_line = stabs[rline].n_desc;
    } else {
        return -1;
c01006c9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01006ce:	e9 12 01 00 00       	jmp    c01007e5 <debuginfo_eip+0x30c>
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
           && stabs[lline].n_type != N_SOL
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
        lline --;
c01006d3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01006d6:	83 e8 01             	sub    $0x1,%eax
c01006d9:	89 45 d4             	mov    %eax,-0x2c(%ebp)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
c01006dc:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01006df:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01006e2:	39 c2                	cmp    %eax,%edx
c01006e4:	7c 56                	jl     c010073c <debuginfo_eip+0x263>
           && stabs[lline].n_type != N_SOL
c01006e6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01006e9:	89 c2                	mov    %eax,%edx
c01006eb:	89 d0                	mov    %edx,%eax
c01006ed:	01 c0                	add    %eax,%eax
c01006ef:	01 d0                	add    %edx,%eax
c01006f1:	c1 e0 02             	shl    $0x2,%eax
c01006f4:	89 c2                	mov    %eax,%edx
c01006f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01006f9:	01 d0                	add    %edx,%eax
c01006fb:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c01006ff:	3c 84                	cmp    $0x84,%al
c0100701:	74 39                	je     c010073c <debuginfo_eip+0x263>
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
c0100703:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100706:	89 c2                	mov    %eax,%edx
c0100708:	89 d0                	mov    %edx,%eax
c010070a:	01 c0                	add    %eax,%eax
c010070c:	01 d0                	add    %edx,%eax
c010070e:	c1 e0 02             	shl    $0x2,%eax
c0100711:	89 c2                	mov    %eax,%edx
c0100713:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100716:	01 d0                	add    %edx,%eax
c0100718:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c010071c:	3c 64                	cmp    $0x64,%al
c010071e:	75 b3                	jne    c01006d3 <debuginfo_eip+0x1fa>
c0100720:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100723:	89 c2                	mov    %eax,%edx
c0100725:	89 d0                	mov    %edx,%eax
c0100727:	01 c0                	add    %eax,%eax
c0100729:	01 d0                	add    %edx,%eax
c010072b:	c1 e0 02             	shl    $0x2,%eax
c010072e:	89 c2                	mov    %eax,%edx
c0100730:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100733:	01 d0                	add    %edx,%eax
c0100735:	8b 40 08             	mov    0x8(%eax),%eax
c0100738:	85 c0                	test   %eax,%eax
c010073a:	74 97                	je     c01006d3 <debuginfo_eip+0x1fa>
        lline --;
    }
    if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr) {
c010073c:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010073f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100742:	39 c2                	cmp    %eax,%edx
c0100744:	7c 46                	jl     c010078c <debuginfo_eip+0x2b3>
c0100746:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100749:	89 c2                	mov    %eax,%edx
c010074b:	89 d0                	mov    %edx,%eax
c010074d:	01 c0                	add    %eax,%eax
c010074f:	01 d0                	add    %edx,%eax
c0100751:	c1 e0 02             	shl    $0x2,%eax
c0100754:	89 c2                	mov    %eax,%edx
c0100756:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100759:	01 d0                	add    %edx,%eax
c010075b:	8b 00                	mov    (%eax),%eax
c010075d:	8b 4d e8             	mov    -0x18(%ebp),%ecx
c0100760:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0100763:	29 d1                	sub    %edx,%ecx
c0100765:	89 ca                	mov    %ecx,%edx
c0100767:	39 d0                	cmp    %edx,%eax
c0100769:	73 21                	jae    c010078c <debuginfo_eip+0x2b3>
        info->eip_file = stabstr + stabs[lline].n_strx;
c010076b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010076e:	89 c2                	mov    %eax,%edx
c0100770:	89 d0                	mov    %edx,%eax
c0100772:	01 c0                	add    %eax,%eax
c0100774:	01 d0                	add    %edx,%eax
c0100776:	c1 e0 02             	shl    $0x2,%eax
c0100779:	89 c2                	mov    %eax,%edx
c010077b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010077e:	01 d0                	add    %edx,%eax
c0100780:	8b 10                	mov    (%eax),%edx
c0100782:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100785:	01 c2                	add    %eax,%edx
c0100787:	8b 45 0c             	mov    0xc(%ebp),%eax
c010078a:	89 10                	mov    %edx,(%eax)
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
c010078c:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010078f:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0100792:	39 c2                	cmp    %eax,%edx
c0100794:	7d 4a                	jge    c01007e0 <debuginfo_eip+0x307>
        for (lline = lfun + 1;
c0100796:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100799:	83 c0 01             	add    $0x1,%eax
c010079c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c010079f:	eb 18                	jmp    c01007b9 <debuginfo_eip+0x2e0>
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
            info->eip_fn_narg ++;
c01007a1:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007a4:	8b 40 14             	mov    0x14(%eax),%eax
c01007a7:	8d 50 01             	lea    0x1(%eax),%edx
c01007aa:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007ad:	89 50 14             	mov    %edx,0x14(%eax)
    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
c01007b0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01007b3:	83 c0 01             	add    $0x1,%eax
c01007b6:	89 45 d4             	mov    %eax,-0x2c(%ebp)

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
             lline < rfun && stabs[lline].n_type == N_PSYM;
c01007b9:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01007bc:	8b 45 d8             	mov    -0x28(%ebp),%eax
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
c01007bf:	39 c2                	cmp    %eax,%edx
c01007c1:	7d 1d                	jge    c01007e0 <debuginfo_eip+0x307>
             lline < rfun && stabs[lline].n_type == N_PSYM;
c01007c3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01007c6:	89 c2                	mov    %eax,%edx
c01007c8:	89 d0                	mov    %edx,%eax
c01007ca:	01 c0                	add    %eax,%eax
c01007cc:	01 d0                	add    %edx,%eax
c01007ce:	c1 e0 02             	shl    $0x2,%eax
c01007d1:	89 c2                	mov    %eax,%edx
c01007d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007d6:	01 d0                	add    %edx,%eax
c01007d8:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c01007dc:	3c a0                	cmp    $0xa0,%al
c01007de:	74 c1                	je     c01007a1 <debuginfo_eip+0x2c8>
             lline ++) {
            info->eip_fn_narg ++;
        }
    }
    return 0;
c01007e0:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01007e5:	c9                   	leave  
c01007e6:	c3                   	ret    

c01007e7 <print_kerninfo>:
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void
print_kerninfo(void) {
c01007e7:	55                   	push   %ebp
c01007e8:	89 e5                	mov    %esp,%ebp
c01007ea:	83 ec 08             	sub    $0x8,%esp
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
c01007ed:	83 ec 0c             	sub    $0xc,%esp
c01007f0:	68 26 43 10 c0       	push   $0xc0104326
c01007f5:	e8 ea f8 ff ff       	call   c01000e4 <cprintf>
c01007fa:	83 c4 10             	add    $0x10,%esp
    cprintf("  entry  0x%08x (phys)\n", kern_init);
c01007fd:	83 ec 08             	sub    $0x8,%esp
c0100800:	68 2a 00 10 c0       	push   $0xc010002a
c0100805:	68 3f 43 10 c0       	push   $0xc010433f
c010080a:	e8 d5 f8 ff ff       	call   c01000e4 <cprintf>
c010080f:	83 c4 10             	add    $0x10,%esp
    cprintf("  etext  0x%08x (phys)\n", etext);
c0100812:	83 ec 08             	sub    $0x8,%esp
c0100815:	68 be 42 10 c0       	push   $0xc01042be
c010081a:	68 57 43 10 c0       	push   $0xc0104357
c010081f:	e8 c0 f8 ff ff       	call   c01000e4 <cprintf>
c0100824:	83 c4 10             	add    $0x10,%esp
    cprintf("  edata  0x%08x (phys)\n", edata);
c0100827:	83 ec 08             	sub    $0x8,%esp
c010082a:	68 88 3a 11 c0       	push   $0xc0113a88
c010082f:	68 6f 43 10 c0       	push   $0xc010436f
c0100834:	e8 ab f8 ff ff       	call   c01000e4 <cprintf>
c0100839:	83 c4 10             	add    $0x10,%esp
    cprintf("  end    0x%08x (phys)\n", end);
c010083c:	83 ec 08             	sub    $0x8,%esp
c010083f:	68 d0 49 11 c0       	push   $0xc01149d0
c0100844:	68 87 43 10 c0       	push   $0xc0104387
c0100849:	e8 96 f8 ff ff       	call   c01000e4 <cprintf>
c010084e:	83 c4 10             	add    $0x10,%esp
    cprintf("Kernel executable memory footprint: %dKB\n", (end - kern_init + 1023)/1024);
c0100851:	b8 d0 49 11 c0       	mov    $0xc01149d0,%eax
c0100856:	05 ff 03 00 00       	add    $0x3ff,%eax
c010085b:	ba 2a 00 10 c0       	mov    $0xc010002a,%edx
c0100860:	29 d0                	sub    %edx,%eax
c0100862:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
c0100868:	85 c0                	test   %eax,%eax
c010086a:	0f 48 c2             	cmovs  %edx,%eax
c010086d:	c1 f8 0a             	sar    $0xa,%eax
c0100870:	83 ec 08             	sub    $0x8,%esp
c0100873:	50                   	push   %eax
c0100874:	68 a0 43 10 c0       	push   $0xc01043a0
c0100879:	e8 66 f8 ff ff       	call   c01000e4 <cprintf>
c010087e:	83 c4 10             	add    $0x10,%esp
}
c0100881:	90                   	nop
c0100882:	c9                   	leave  
c0100883:	c3                   	ret    

c0100884 <print_debuginfo>:
/* *
 * print_debuginfo - read and print the stat information for the address @eip,
 * and info.eip_fn_addr should be the first address of the related function.
 * */
void
print_debuginfo(uintptr_t eip) {
c0100884:	55                   	push   %ebp
c0100885:	89 e5                	mov    %esp,%ebp
c0100887:	81 ec 28 01 00 00    	sub    $0x128,%esp
    struct eipdebuginfo info;
    if (debuginfo_eip(eip, &info) != 0) {
c010088d:	83 ec 08             	sub    $0x8,%esp
c0100890:	8d 45 dc             	lea    -0x24(%ebp),%eax
c0100893:	50                   	push   %eax
c0100894:	ff 75 08             	pushl  0x8(%ebp)
c0100897:	e8 3d fc ff ff       	call   c01004d9 <debuginfo_eip>
c010089c:	83 c4 10             	add    $0x10,%esp
c010089f:	85 c0                	test   %eax,%eax
c01008a1:	74 15                	je     c01008b8 <print_debuginfo+0x34>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
c01008a3:	83 ec 08             	sub    $0x8,%esp
c01008a6:	ff 75 08             	pushl  0x8(%ebp)
c01008a9:	68 ca 43 10 c0       	push   $0xc01043ca
c01008ae:	e8 31 f8 ff ff       	call   c01000e4 <cprintf>
c01008b3:	83 c4 10             	add    $0x10,%esp
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
    }
}
c01008b6:	eb 65                	jmp    c010091d <print_debuginfo+0x99>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
    }
    else {
        char fnname[256];
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c01008b8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01008bf:	eb 1c                	jmp    c01008dd <print_debuginfo+0x59>
            fnname[j] = info.eip_fn_name[j];
c01008c1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01008c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01008c7:	01 d0                	add    %edx,%eax
c01008c9:	0f b6 00             	movzbl (%eax),%eax
c01008cc:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c01008d2:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01008d5:	01 ca                	add    %ecx,%edx
c01008d7:	88 02                	mov    %al,(%edx)
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
    }
    else {
        char fnname[256];
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c01008d9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c01008dd:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01008e0:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01008e3:	7f dc                	jg     c01008c1 <print_debuginfo+0x3d>
            fnname[j] = info.eip_fn_name[j];
        }
        fnname[j] = '\0';
c01008e5:	8d 95 dc fe ff ff    	lea    -0x124(%ebp),%edx
c01008eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01008ee:	01 d0                	add    %edx,%eax
c01008f0:	c6 00 00             	movb   $0x0,(%eax)
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
c01008f3:	8b 45 ec             	mov    -0x14(%ebp),%eax
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
            fnname[j] = info.eip_fn_name[j];
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
c01008f6:	8b 55 08             	mov    0x8(%ebp),%edx
c01008f9:	89 d1                	mov    %edx,%ecx
c01008fb:	29 c1                	sub    %eax,%ecx
c01008fd:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0100900:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100903:	83 ec 0c             	sub    $0xc,%esp
c0100906:	51                   	push   %ecx
c0100907:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c010090d:	51                   	push   %ecx
c010090e:	52                   	push   %edx
c010090f:	50                   	push   %eax
c0100910:	68 e6 43 10 c0       	push   $0xc01043e6
c0100915:	e8 ca f7 ff ff       	call   c01000e4 <cprintf>
c010091a:	83 c4 20             	add    $0x20,%esp
                fnname, eip - info.eip_fn_addr);
    }
}
c010091d:	90                   	nop
c010091e:	c9                   	leave  
c010091f:	c3                   	ret    

c0100920 <read_eip>:

static uint32_t read_eip(void) __attribute__((noinline));

static uint32_t
read_eip(void) {
c0100920:	55                   	push   %ebp
c0100921:	89 e5                	mov    %esp,%ebp
c0100923:	83 ec 10             	sub    $0x10,%esp
    uint32_t eip;
    asm volatile("movl 4(%%ebp), %0" : "=r" (eip));
c0100926:	8b 45 04             	mov    0x4(%ebp),%eax
c0100929:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return eip;
c010092c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c010092f:	c9                   	leave  
c0100930:	c3                   	ret    

c0100931 <print_stackframe>:
 *
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the boundary.
 * */
void
print_stackframe(void) {
c0100931:	55                   	push   %ebp
c0100932:	89 e5                	mov    %esp,%ebp
c0100934:	83 ec 28             	sub    $0x28,%esp
}

static inline uint32_t
read_ebp(void) {
    uint32_t ebp;
    asm volatile ("movl %%ebp, %0" : "=r" (ebp));
c0100937:	89 e8                	mov    %ebp,%eax
c0100939:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return ebp;
c010093c:	8b 45 e0             	mov    -0x20(%ebp),%eax
    uint32_t ebp = read_ebp(), eip = read_eip();
c010093f:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100942:	e8 d9 ff ff ff       	call   c0100920 <read_eip>
c0100947:	89 45 f0             	mov    %eax,-0x10(%ebp)

    int i, j;
    for (i = 0; ebp != 0 && i < STACKFRAME_DEPTH; i ++) {
c010094a:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0100951:	e9 8d 00 00 00       	jmp    c01009e3 <print_stackframe+0xb2>
        cprintf("ebp:0x%08x eip:0x%08x args:", ebp, eip);
c0100956:	83 ec 04             	sub    $0x4,%esp
c0100959:	ff 75 f0             	pushl  -0x10(%ebp)
c010095c:	ff 75 f4             	pushl  -0xc(%ebp)
c010095f:	68 f8 43 10 c0       	push   $0xc01043f8
c0100964:	e8 7b f7 ff ff       	call   c01000e4 <cprintf>
c0100969:	83 c4 10             	add    $0x10,%esp
        uint32_t *args = (uint32_t *)ebp + 2;
c010096c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010096f:	83 c0 08             	add    $0x8,%eax
c0100972:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        for (j = 0; j < 4; j ++) {
c0100975:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
c010097c:	eb 26                	jmp    c01009a4 <print_stackframe+0x73>
            cprintf("0x%08x ", args[j]);
c010097e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100981:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0100988:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010098b:	01 d0                	add    %edx,%eax
c010098d:	8b 00                	mov    (%eax),%eax
c010098f:	83 ec 08             	sub    $0x8,%esp
c0100992:	50                   	push   %eax
c0100993:	68 14 44 10 c0       	push   $0xc0104414
c0100998:	e8 47 f7 ff ff       	call   c01000e4 <cprintf>
c010099d:	83 c4 10             	add    $0x10,%esp

    int i, j;
    for (i = 0; ebp != 0 && i < STACKFRAME_DEPTH; i ++) {
        cprintf("ebp:0x%08x eip:0x%08x args:", ebp, eip);
        uint32_t *args = (uint32_t *)ebp + 2;
        for (j = 0; j < 4; j ++) {
c01009a0:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
c01009a4:	83 7d e8 03          	cmpl   $0x3,-0x18(%ebp)
c01009a8:	7e d4                	jle    c010097e <print_stackframe+0x4d>
            cprintf("0x%08x ", args[j]);
        }
        cprintf("\n");
c01009aa:	83 ec 0c             	sub    $0xc,%esp
c01009ad:	68 1c 44 10 c0       	push   $0xc010441c
c01009b2:	e8 2d f7 ff ff       	call   c01000e4 <cprintf>
c01009b7:	83 c4 10             	add    $0x10,%esp
        print_debuginfo(eip - 1);
c01009ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01009bd:	83 e8 01             	sub    $0x1,%eax
c01009c0:	83 ec 0c             	sub    $0xc,%esp
c01009c3:	50                   	push   %eax
c01009c4:	e8 bb fe ff ff       	call   c0100884 <print_debuginfo>
c01009c9:	83 c4 10             	add    $0x10,%esp
        eip = ((uint32_t *)ebp)[1];
c01009cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01009cf:	83 c0 04             	add    $0x4,%eax
c01009d2:	8b 00                	mov    (%eax),%eax
c01009d4:	89 45 f0             	mov    %eax,-0x10(%ebp)
        ebp = ((uint32_t *)ebp)[0];
c01009d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01009da:	8b 00                	mov    (%eax),%eax
c01009dc:	89 45 f4             	mov    %eax,-0xc(%ebp)
void
print_stackframe(void) {
    uint32_t ebp = read_ebp(), eip = read_eip();

    int i, j;
    for (i = 0; ebp != 0 && i < STACKFRAME_DEPTH; i ++) {
c01009df:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
c01009e3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01009e7:	74 0a                	je     c01009f3 <print_stackframe+0xc2>
c01009e9:	83 7d ec 13          	cmpl   $0x13,-0x14(%ebp)
c01009ed:	0f 8e 63 ff ff ff    	jle    c0100956 <print_stackframe+0x25>
        cprintf("\n");
        print_debuginfo(eip - 1);
        eip = ((uint32_t *)ebp)[1];
        ebp = ((uint32_t *)ebp)[0];
    }
}
c01009f3:	90                   	nop
c01009f4:	c9                   	leave  
c01009f5:	c3                   	ret    

c01009f6 <parse>:
#define MAXARGS         16
#define WHITESPACE      " \t\n\r"

/* parse - parse the command buffer into whitespace-separated arguments */
static int
parse(char *buf, char **argv) {
c01009f6:	55                   	push   %ebp
c01009f7:	89 e5                	mov    %esp,%ebp
c01009f9:	83 ec 18             	sub    $0x18,%esp
    int argc = 0;
c01009fc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100a03:	eb 0c                	jmp    c0100a11 <parse+0x1b>
            *buf ++ = '\0';
c0100a05:	8b 45 08             	mov    0x8(%ebp),%eax
c0100a08:	8d 50 01             	lea    0x1(%eax),%edx
c0100a0b:	89 55 08             	mov    %edx,0x8(%ebp)
c0100a0e:	c6 00 00             	movb   $0x0,(%eax)
static int
parse(char *buf, char **argv) {
    int argc = 0;
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100a11:	8b 45 08             	mov    0x8(%ebp),%eax
c0100a14:	0f b6 00             	movzbl (%eax),%eax
c0100a17:	84 c0                	test   %al,%al
c0100a19:	74 1e                	je     c0100a39 <parse+0x43>
c0100a1b:	8b 45 08             	mov    0x8(%ebp),%eax
c0100a1e:	0f b6 00             	movzbl (%eax),%eax
c0100a21:	0f be c0             	movsbl %al,%eax
c0100a24:	83 ec 08             	sub    $0x8,%esp
c0100a27:	50                   	push   %eax
c0100a28:	68 b7 44 10 c0       	push   $0xc01044b7
c0100a2d:	e8 7f 2d 00 00       	call   c01037b1 <strchr>
c0100a32:	83 c4 10             	add    $0x10,%esp
c0100a35:	85 c0                	test   %eax,%eax
c0100a37:	75 cc                	jne    c0100a05 <parse+0xf>
            *buf ++ = '\0';
        }
        if (*buf == '\0') {
c0100a39:	8b 45 08             	mov    0x8(%ebp),%eax
c0100a3c:	0f b6 00             	movzbl (%eax),%eax
c0100a3f:	84 c0                	test   %al,%al
c0100a41:	74 69                	je     c0100aac <parse+0xb6>
            break;
        }

        // save and scan past next arg
        if (argc == MAXARGS - 1) {
c0100a43:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
c0100a47:	75 12                	jne    c0100a5b <parse+0x65>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
c0100a49:	83 ec 08             	sub    $0x8,%esp
c0100a4c:	6a 10                	push   $0x10
c0100a4e:	68 bc 44 10 c0       	push   $0xc01044bc
c0100a53:	e8 8c f6 ff ff       	call   c01000e4 <cprintf>
c0100a58:	83 c4 10             	add    $0x10,%esp
        }
        argv[argc ++] = buf;
c0100a5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a5e:	8d 50 01             	lea    0x1(%eax),%edx
c0100a61:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0100a64:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0100a6b:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100a6e:	01 c2                	add    %eax,%edx
c0100a70:	8b 45 08             	mov    0x8(%ebp),%eax
c0100a73:	89 02                	mov    %eax,(%edx)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100a75:	eb 04                	jmp    c0100a7b <parse+0x85>
            buf ++;
c0100a77:	83 45 08 01          	addl   $0x1,0x8(%ebp)
        // save and scan past next arg
        if (argc == MAXARGS - 1) {
            cprintf("Too many arguments (max %d).\n", MAXARGS);
        }
        argv[argc ++] = buf;
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100a7b:	8b 45 08             	mov    0x8(%ebp),%eax
c0100a7e:	0f b6 00             	movzbl (%eax),%eax
c0100a81:	84 c0                	test   %al,%al
c0100a83:	0f 84 7a ff ff ff    	je     c0100a03 <parse+0xd>
c0100a89:	8b 45 08             	mov    0x8(%ebp),%eax
c0100a8c:	0f b6 00             	movzbl (%eax),%eax
c0100a8f:	0f be c0             	movsbl %al,%eax
c0100a92:	83 ec 08             	sub    $0x8,%esp
c0100a95:	50                   	push   %eax
c0100a96:	68 b7 44 10 c0       	push   $0xc01044b7
c0100a9b:	e8 11 2d 00 00       	call   c01037b1 <strchr>
c0100aa0:	83 c4 10             	add    $0x10,%esp
c0100aa3:	85 c0                	test   %eax,%eax
c0100aa5:	74 d0                	je     c0100a77 <parse+0x81>
            buf ++;
        }
    }
c0100aa7:	e9 57 ff ff ff       	jmp    c0100a03 <parse+0xd>
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
            *buf ++ = '\0';
        }
        if (*buf == '\0') {
            break;
c0100aac:	90                   	nop
        argv[argc ++] = buf;
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
            buf ++;
        }
    }
    return argc;
c0100aad:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100ab0:	c9                   	leave  
c0100ab1:	c3                   	ret    

c0100ab2 <runcmd>:
/* *
 * runcmd - parse the input string, split it into separated arguments
 * and then lookup and invoke some related commands/
 * */
int
runcmd(char *buf, struct trapframe *tf) {
c0100ab2:	55                   	push   %ebp
c0100ab3:	89 e5                	mov    %esp,%ebp
c0100ab5:	83 ec 58             	sub    $0x58,%esp
    char *argv[MAXARGS];
    int argc = parse(buf, argv);
c0100ab8:	83 ec 08             	sub    $0x8,%esp
c0100abb:	8d 45 b0             	lea    -0x50(%ebp),%eax
c0100abe:	50                   	push   %eax
c0100abf:	ff 75 08             	pushl  0x8(%ebp)
c0100ac2:	e8 2f ff ff ff       	call   c01009f6 <parse>
c0100ac7:	83 c4 10             	add    $0x10,%esp
c0100aca:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (argc == 0) {
c0100acd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0100ad1:	75 0a                	jne    c0100add <runcmd+0x2b>
        return 0;
c0100ad3:	b8 00 00 00 00       	mov    $0x0,%eax
c0100ad8:	e9 83 00 00 00       	jmp    c0100b60 <runcmd+0xae>
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100add:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100ae4:	eb 59                	jmp    c0100b3f <runcmd+0x8d>
        if (strcmp(commands[i].name, argv[0]) == 0) {
c0100ae6:	8b 4d b0             	mov    -0x50(%ebp),%ecx
c0100ae9:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100aec:	89 d0                	mov    %edx,%eax
c0100aee:	01 c0                	add    %eax,%eax
c0100af0:	01 d0                	add    %edx,%eax
c0100af2:	c1 e0 02             	shl    $0x2,%eax
c0100af5:	05 20 30 11 c0       	add    $0xc0113020,%eax
c0100afa:	8b 00                	mov    (%eax),%eax
c0100afc:	83 ec 08             	sub    $0x8,%esp
c0100aff:	51                   	push   %ecx
c0100b00:	50                   	push   %eax
c0100b01:	e8 0b 2c 00 00       	call   c0103711 <strcmp>
c0100b06:	83 c4 10             	add    $0x10,%esp
c0100b09:	85 c0                	test   %eax,%eax
c0100b0b:	75 2e                	jne    c0100b3b <runcmd+0x89>
            return commands[i].func(argc - 1, argv + 1, tf);
c0100b0d:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100b10:	89 d0                	mov    %edx,%eax
c0100b12:	01 c0                	add    %eax,%eax
c0100b14:	01 d0                	add    %edx,%eax
c0100b16:	c1 e0 02             	shl    $0x2,%eax
c0100b19:	05 28 30 11 c0       	add    $0xc0113028,%eax
c0100b1e:	8b 10                	mov    (%eax),%edx
c0100b20:	8d 45 b0             	lea    -0x50(%ebp),%eax
c0100b23:	83 c0 04             	add    $0x4,%eax
c0100b26:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c0100b29:	83 e9 01             	sub    $0x1,%ecx
c0100b2c:	83 ec 04             	sub    $0x4,%esp
c0100b2f:	ff 75 0c             	pushl  0xc(%ebp)
c0100b32:	50                   	push   %eax
c0100b33:	51                   	push   %ecx
c0100b34:	ff d2                	call   *%edx
c0100b36:	83 c4 10             	add    $0x10,%esp
c0100b39:	eb 25                	jmp    c0100b60 <runcmd+0xae>
    int argc = parse(buf, argv);
    if (argc == 0) {
        return 0;
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100b3b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0100b3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b42:	83 f8 03             	cmp    $0x3,%eax
c0100b45:	76 9f                	jbe    c0100ae6 <runcmd+0x34>
        if (strcmp(commands[i].name, argv[0]) == 0) {
            return commands[i].func(argc - 1, argv + 1, tf);
        }
    }
    cprintf("Unknown command '%s'\n", argv[0]);
c0100b47:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0100b4a:	83 ec 08             	sub    $0x8,%esp
c0100b4d:	50                   	push   %eax
c0100b4e:	68 da 44 10 c0       	push   $0xc01044da
c0100b53:	e8 8c f5 ff ff       	call   c01000e4 <cprintf>
c0100b58:	83 c4 10             	add    $0x10,%esp
    return 0;
c0100b5b:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100b60:	c9                   	leave  
c0100b61:	c3                   	ret    

c0100b62 <monitor>:

/***** Implementations of basic kernel monitor commands *****/

void
monitor(struct trapframe *tf) {
c0100b62:	55                   	push   %ebp
c0100b63:	89 e5                	mov    %esp,%ebp
c0100b65:	83 ec 18             	sub    $0x18,%esp
    cputchar('&');
c0100b68:	83 ec 0c             	sub    $0xc,%esp
c0100b6b:	6a 26                	push   $0x26
c0100b6d:	e8 98 f5 ff ff       	call   c010010a <cputchar>
c0100b72:	83 c4 10             	add    $0x10,%esp
    cprintf("Welcome to the kernel debug monitor!!\n");
c0100b75:	83 ec 0c             	sub    $0xc,%esp
c0100b78:	68 f0 44 10 c0       	push   $0xc01044f0
c0100b7d:	e8 62 f5 ff ff       	call   c01000e4 <cprintf>
c0100b82:	83 c4 10             	add    $0x10,%esp
    cprintf("Type 'help' for a list of commands.\n");
c0100b85:	83 ec 0c             	sub    $0xc,%esp
c0100b88:	68 18 45 10 c0       	push   $0xc0104518
c0100b8d:	e8 52 f5 ff ff       	call   c01000e4 <cprintf>
c0100b92:	83 c4 10             	add    $0x10,%esp
    toc = 0;
c0100b95:	c7 05 84 49 11 c0 00 	movl   $0x0,0xc0114984
c0100b9c:	00 00 00 
    char *buf;
    while (1) {
        if(toc == 0) {
c0100b9f:	a1 84 49 11 c0       	mov    0xc0114984,%eax
c0100ba4:	85 c0                	test   %eax,%eax
c0100ba6:	75 f7                	jne    c0100b9f <monitor+0x3d>
           if ((buf = readline("K> ")) != NULL) {
c0100ba8:	83 ec 0c             	sub    $0xc,%esp
c0100bab:	68 3d 45 10 c0       	push   $0xc010453d
c0100bb0:	e8 f3 f5 ff ff       	call   c01001a8 <readline>
c0100bb5:	83 c4 10             	add    $0x10,%esp
c0100bb8:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100bbb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100bbf:	74 de                	je     c0100b9f <monitor+0x3d>
                if (runcmd(buf, tf) < 0) {
c0100bc1:	83 ec 08             	sub    $0x8,%esp
c0100bc4:	ff 75 08             	pushl  0x8(%ebp)
c0100bc7:	ff 75 f4             	pushl  -0xc(%ebp)
c0100bca:	e8 e3 fe ff ff       	call   c0100ab2 <runcmd>
c0100bcf:	83 c4 10             	add    $0x10,%esp
c0100bd2:	85 c0                	test   %eax,%eax
c0100bd4:	78 02                	js     c0100bd8 <monitor+0x76>
                    break;
                }
            } 
        }
        
    }
c0100bd6:	eb c7                	jmp    c0100b9f <monitor+0x3d>
    char *buf;
    while (1) {
        if(toc == 0) {
           if ((buf = readline("K> ")) != NULL) {
                if (runcmd(buf, tf) < 0) {
                    break;
c0100bd8:	90                   	nop
                }
            } 
        }
        
    }
}
c0100bd9:	90                   	nop
c0100bda:	c9                   	leave  
c0100bdb:	c3                   	ret    

c0100bdc <mon_help>:

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
c0100bdc:	55                   	push   %ebp
c0100bdd:	89 e5                	mov    %esp,%ebp
c0100bdf:	83 ec 38             	sub    $0x38,%esp
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100be2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100be9:	e9 90 00 00 00       	jmp    c0100c7e <mon_help+0xa2>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
c0100bee:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100bf1:	89 d0                	mov    %edx,%eax
c0100bf3:	01 c0                	add    %eax,%eax
c0100bf5:	01 d0                	add    %edx,%eax
c0100bf7:	c1 e0 02             	shl    $0x2,%eax
c0100bfa:	05 24 30 11 c0       	add    $0xc0113024,%eax
c0100bff:	8b 08                	mov    (%eax),%ecx
c0100c01:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100c04:	89 d0                	mov    %edx,%eax
c0100c06:	01 c0                	add    %eax,%eax
c0100c08:	01 d0                	add    %edx,%eax
c0100c0a:	c1 e0 02             	shl    $0x2,%eax
c0100c0d:	05 20 30 11 c0       	add    $0xc0113020,%eax
c0100c12:	8b 00                	mov    (%eax),%eax
c0100c14:	83 ec 04             	sub    $0x4,%esp
c0100c17:	51                   	push   %ecx
c0100c18:	50                   	push   %eax
c0100c19:	68 41 45 10 c0       	push   $0xc0104541
c0100c1e:	e8 c1 f4 ff ff       	call   c01000e4 <cprintf>
c0100c23:	83 c4 10             	add    $0x10,%esp
        draw_str16(commands[i].name, (point_t){20, 40+i*16}, (rgb_t){43,43,43});
c0100c26:	c6 45 d5 2b          	movb   $0x2b,-0x2b(%ebp)
c0100c2a:	c6 45 d6 2b          	movb   $0x2b,-0x2a(%ebp)
c0100c2e:	c6 45 d7 2b          	movb   $0x2b,-0x29(%ebp)
c0100c32:	c7 45 d8 14 00 00 00 	movl   $0x14,-0x28(%ebp)
c0100c39:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100c3c:	c1 e0 04             	shl    $0x4,%eax
c0100c3f:	83 c0 28             	add    $0x28,%eax
c0100c42:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0100c45:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100c48:	89 d0                	mov    %edx,%eax
c0100c4a:	01 c0                	add    %eax,%eax
c0100c4c:	01 d0                	add    %edx,%eax
c0100c4e:	c1 e0 02             	shl    $0x2,%eax
c0100c51:	05 20 30 11 c0       	add    $0xc0113020,%eax
c0100c56:	8b 10                	mov    (%eax),%edx
c0100c58:	83 ec 04             	sub    $0x4,%esp
c0100c5b:	89 e0                	mov    %esp,%eax
c0100c5d:	0f b7 4d d5          	movzwl -0x2b(%ebp),%ecx
c0100c61:	66 89 08             	mov    %cx,(%eax)
c0100c64:	0f b6 4d d7          	movzbl -0x29(%ebp),%ecx
c0100c68:	88 48 02             	mov    %cl,0x2(%eax)
c0100c6b:	ff 75 dc             	pushl  -0x24(%ebp)
c0100c6e:	ff 75 d8             	pushl  -0x28(%ebp)
c0100c71:	52                   	push   %edx
c0100c72:	e8 87 1f 00 00       	call   c0102bfe <draw_str16>
c0100c77:	83 c4 10             	add    $0x10,%esp

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100c7a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0100c7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100c81:	83 f8 03             	cmp    $0x3,%eax
c0100c84:	0f 86 64 ff ff ff    	jbe    c0100bee <mon_help+0x12>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
        draw_str16(commands[i].name, (point_t){20, 40+i*16}, (rgb_t){43,43,43});
    }
    cputchar('*');
c0100c8a:	83 ec 0c             	sub    $0xc,%esp
c0100c8d:	6a 2a                	push   $0x2a
c0100c8f:	e8 76 f4 ff ff       	call   c010010a <cputchar>
c0100c94:	83 c4 10             	add    $0x10,%esp
    _gfillrect2(MediumBlue, (rect_t){200,200,500,500});
c0100c97:	c7 45 e0 c8 00 00 00 	movl   $0xc8,-0x20(%ebp)
c0100c9e:	c7 45 e4 c8 00 00 00 	movl   $0xc8,-0x1c(%ebp)
c0100ca5:	c7 45 e8 f4 01 00 00 	movl   $0x1f4,-0x18(%ebp)
c0100cac:	c7 45 ec f4 01 00 00 	movl   $0x1f4,-0x14(%ebp)
c0100cb3:	c6 45 f1 00          	movb   $0x0,-0xf(%ebp)
c0100cb7:	c6 45 f2 00          	movb   $0x0,-0xe(%ebp)
c0100cbb:	c6 45 f3 cd          	movb   $0xcd,-0xd(%ebp)
c0100cbf:	83 ec 0c             	sub    $0xc,%esp
c0100cc2:	ff 75 ec             	pushl  -0x14(%ebp)
c0100cc5:	ff 75 e8             	pushl  -0x18(%ebp)
c0100cc8:	ff 75 e4             	pushl  -0x1c(%ebp)
c0100ccb:	ff 75 e0             	pushl  -0x20(%ebp)
c0100cce:	83 ec 04             	sub    $0x4,%esp
c0100cd1:	89 e0                	mov    %esp,%eax
c0100cd3:	0f b7 55 f1          	movzwl -0xf(%ebp),%edx
c0100cd7:	66 89 10             	mov    %dx,(%eax)
c0100cda:	0f b6 55 f3          	movzbl -0xd(%ebp),%edx
c0100cde:	88 50 02             	mov    %dl,0x2(%eax)
c0100ce1:	e8 ee 1b 00 00       	call   c01028d4 <_gfillrect2>
c0100ce6:	83 c4 20             	add    $0x20,%esp
    return 0;
c0100ce9:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100cee:	c9                   	leave  
c0100cef:	c3                   	ret    

c0100cf0 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
c0100cf0:	55                   	push   %ebp
c0100cf1:	89 e5                	mov    %esp,%ebp
c0100cf3:	83 ec 08             	sub    $0x8,%esp
    print_kerninfo();
c0100cf6:	e8 ec fa ff ff       	call   c01007e7 <print_kerninfo>
    return 0;
c0100cfb:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100d00:	c9                   	leave  
c0100d01:	c3                   	ret    

c0100d02 <mon_bootinfo>:
/* *
 * mon_bootinfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_bootinfo(int argc, char **argv, struct trapframe *tf) {
c0100d02:	55                   	push   %ebp
c0100d03:	89 e5                	mov    %esp,%ebp
c0100d05:	83 ec 18             	sub    $0x18,%esp
    struct BOOTINFO* pboot = get_bootinfo();
c0100d08:	e8 ae 12 00 00       	call   c0101fbb <get_bootinfo>
c0100d0d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("uint8_t: cyls=%d leds=%x  ", pboot->cyls, pboot->leds); 
c0100d10:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100d13:	0f b6 40 01          	movzbl 0x1(%eax),%eax
c0100d17:	0f b6 d0             	movzbl %al,%edx
c0100d1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100d1d:	0f b6 00             	movzbl (%eax),%eax
c0100d20:	0f b6 c0             	movzbl %al,%eax
c0100d23:	83 ec 04             	sub    $0x4,%esp
c0100d26:	52                   	push   %edx
c0100d27:	50                   	push   %eax
c0100d28:	68 4a 45 10 c0       	push   $0xc010454a
c0100d2d:	e8 b2 f3 ff ff       	call   c01000e4 <cprintf>
c0100d32:	83 c4 10             	add    $0x10,%esp
    cprintf("vmode=%x reserve=%x\n", pboot->vmode, pboot->reserve);
c0100d35:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100d38:	0f b6 40 03          	movzbl 0x3(%eax),%eax
c0100d3c:	0f b6 d0             	movzbl %al,%edx
c0100d3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100d42:	0f b6 40 02          	movzbl 0x2(%eax),%eax
c0100d46:	0f b6 c0             	movzbl %al,%eax
c0100d49:	83 ec 04             	sub    $0x4,%esp
c0100d4c:	52                   	push   %edx
c0100d4d:	50                   	push   %eax
c0100d4e:	68 65 45 10 c0       	push   $0xc0104565
c0100d53:	e8 8c f3 ff ff       	call   c01000e4 <cprintf>
c0100d58:	83 c4 10             	add    $0x10,%esp
    cprintf("uint16_t: scrnx=%d scrny=%d\n", pboot->scrnx, pboot->scrny);
c0100d5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100d5e:	0f b7 40 06          	movzwl 0x6(%eax),%eax
c0100d62:	0f b7 d0             	movzwl %ax,%edx
c0100d65:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100d68:	0f b7 40 04          	movzwl 0x4(%eax),%eax
c0100d6c:	0f b7 c0             	movzwl %ax,%eax
c0100d6f:	83 ec 04             	sub    $0x4,%esp
c0100d72:	52                   	push   %edx
c0100d73:	50                   	push   %eax
c0100d74:	68 7a 45 10 c0       	push   $0xc010457a
c0100d79:	e8 66 f3 ff ff       	call   c01000e4 <cprintf>
c0100d7e:	83 c4 10             	add    $0x10,%esp
    cprintf("uint8_t: bitspixel=%d mem_model=%d\n", pboot->bitspixel, pboot->mem_model);
c0100d81:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100d84:	0f b6 40 09          	movzbl 0x9(%eax),%eax
c0100d88:	0f b6 d0             	movzbl %al,%edx
c0100d8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100d8e:	0f b6 40 08          	movzbl 0x8(%eax),%eax
c0100d92:	0f b6 c0             	movzbl %al,%eax
c0100d95:	83 ec 04             	sub    $0x4,%esp
c0100d98:	52                   	push   %edx
c0100d99:	50                   	push   %eax
c0100d9a:	68 98 45 10 c0       	push   $0xc0104598
c0100d9f:	e8 40 f3 ff ff       	call   c01000e4 <cprintf>
c0100da4:	83 c4 10             	add    $0x10,%esp
    cprintf("uint8_t: vram=%x\n", pboot->vram);    
c0100da7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100daa:	8b 40 0c             	mov    0xc(%eax),%eax
c0100dad:	83 ec 08             	sub    $0x8,%esp
c0100db0:	50                   	push   %eax
c0100db1:	68 bc 45 10 c0       	push   $0xc01045bc
c0100db6:	e8 29 f3 ff ff       	call   c01000e4 <cprintf>
c0100dbb:	83 c4 10             	add    $0x10,%esp
    return 0;
c0100dbe:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100dc3:	c9                   	leave  
c0100dc4:	c3                   	ret    

c0100dc5 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
c0100dc5:	55                   	push   %ebp
c0100dc6:	89 e5                	mov    %esp,%ebp
c0100dc8:	83 ec 08             	sub    $0x8,%esp
    print_stackframe();
c0100dcb:	e8 61 fb ff ff       	call   c0100931 <print_stackframe>
    return 0;
c0100dd0:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100dd5:	c9                   	leave  
c0100dd6:	c3                   	ret    

c0100dd7 <clock_init>:
/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void
clock_init(void) {
c0100dd7:	55                   	push   %ebp
c0100dd8:	89 e5                	mov    %esp,%ebp
c0100dda:	83 ec 18             	sub    $0x18,%esp
c0100ddd:	66 c7 45 f6 43 00    	movw   $0x43,-0xa(%ebp)
c0100de3:	c6 45 ef 34          	movb   $0x34,-0x11(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100de7:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
c0100deb:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0100def:	ee                   	out    %al,(%dx)
c0100df0:	66 c7 45 f4 40 00    	movw   $0x40,-0xc(%ebp)
c0100df6:	c6 45 f0 9c          	movb   $0x9c,-0x10(%ebp)
c0100dfa:	0f b6 45 f0          	movzbl -0x10(%ebp),%eax
c0100dfe:	0f b7 55 f4          	movzwl -0xc(%ebp),%edx
c0100e02:	ee                   	out    %al,(%dx)
c0100e03:	66 c7 45 f2 40 00    	movw   $0x40,-0xe(%ebp)
c0100e09:	c6 45 f1 2e          	movb   $0x2e,-0xf(%ebp)
c0100e0d:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0100e11:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0100e15:	ee                   	out    %al,(%dx)
    outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
    outb(IO_TIMER1, TIMER_DIV(100) % 256);
    outb(IO_TIMER1, TIMER_DIV(100) / 256);

    // initialize time counter 'ticks' to zero
    ticks = 0;
c0100e16:	c7 05 88 49 11 c0 00 	movl   $0x0,0xc0114988
c0100e1d:	00 00 00 

    cprintf("++ setup timer interrupts\n");
c0100e20:	83 ec 0c             	sub    $0xc,%esp
c0100e23:	68 ce 45 10 c0       	push   $0xc01045ce
c0100e28:	e8 b7 f2 ff ff       	call   c01000e4 <cprintf>
c0100e2d:	83 c4 10             	add    $0x10,%esp
    pic_enable(IRQ_TIMER);
c0100e30:	83 ec 0c             	sub    $0xc,%esp
c0100e33:	6a 00                	push   $0x0
c0100e35:	e8 e2 04 00 00       	call   c010131c <pic_enable>
c0100e3a:	83 c4 10             	add    $0x10,%esp
}
c0100e3d:	90                   	nop
c0100e3e:	c9                   	leave  
c0100e3f:	c3                   	ret    

c0100e40 <delay>:
#include <kbdreg.h>
#include <trap.h>

/* stupid I/O delay routine necessitated by historical PC design flaws */
static void
delay(void) {
c0100e40:	55                   	push   %ebp
c0100e41:	89 e5                	mov    %esp,%ebp
c0100e43:	83 ec 10             	sub    $0x10,%esp
c0100e46:	66 c7 45 fe 84 00    	movw   $0x84,-0x2(%ebp)
static inline void write_eflags(uint32_t eflags) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100e4c:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c0100e50:	89 c2                	mov    %eax,%edx
c0100e52:	ec                   	in     (%dx),%al
c0100e53:	88 45 f4             	mov    %al,-0xc(%ebp)
c0100e56:	66 c7 45 fc 84 00    	movw   $0x84,-0x4(%ebp)
c0100e5c:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
c0100e60:	89 c2                	mov    %eax,%edx
c0100e62:	ec                   	in     (%dx),%al
c0100e63:	88 45 f5             	mov    %al,-0xb(%ebp)
c0100e66:	66 c7 45 fa 84 00    	movw   $0x84,-0x6(%ebp)
c0100e6c:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0100e70:	89 c2                	mov    %eax,%edx
c0100e72:	ec                   	in     (%dx),%al
c0100e73:	88 45 f6             	mov    %al,-0xa(%ebp)
c0100e76:	66 c7 45 f8 84 00    	movw   $0x84,-0x8(%ebp)
c0100e7c:	0f b7 45 f8          	movzwl -0x8(%ebp),%eax
c0100e80:	89 c2                	mov    %eax,%edx
c0100e82:	ec                   	in     (%dx),%al
c0100e83:	88 45 f7             	mov    %al,-0x9(%ebp)
    inb(0x84);
    inb(0x84);
    inb(0x84);
    inb(0x84);
}
c0100e86:	90                   	nop
c0100e87:	c9                   	leave  
c0100e88:	c3                   	ret    

c0100e89 <lpt_putc>:
#define LPTPORT         0x378
  

/* lpt_putc - copy console output to parallel port */
static void
lpt_putc(int c) {
c0100e89:	55                   	push   %ebp
c0100e8a:	89 e5                	mov    %esp,%ebp
c0100e8c:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c0100e8f:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c0100e96:	eb 09                	jmp    c0100ea1 <lpt_putc+0x18>
        delay();
c0100e98:	e8 a3 ff ff ff       	call   c0100e40 <delay>

/* lpt_putc - copy console output to parallel port */
static void
lpt_putc(int c) {
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c0100e9d:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c0100ea1:	66 c7 45 f4 79 03    	movw   $0x379,-0xc(%ebp)
c0100ea7:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
c0100eab:	89 c2                	mov    %eax,%edx
c0100ead:	ec                   	in     (%dx),%al
c0100eae:	88 45 f3             	mov    %al,-0xd(%ebp)
    return data;
c0100eb1:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0100eb5:	84 c0                	test   %al,%al
c0100eb7:	78 09                	js     c0100ec2 <lpt_putc+0x39>
c0100eb9:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c0100ec0:	7e d6                	jle    c0100e98 <lpt_putc+0xf>
        delay();
    }
    outb(LPTPORT + 0, c);
c0100ec2:	8b 45 08             	mov    0x8(%ebp),%eax
c0100ec5:	0f b6 c0             	movzbl %al,%eax
c0100ec8:	66 c7 45 f8 78 03    	movw   $0x378,-0x8(%ebp)
c0100ece:	88 45 f0             	mov    %al,-0x10(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100ed1:	0f b6 45 f0          	movzbl -0x10(%ebp),%eax
c0100ed5:	0f b7 55 f8          	movzwl -0x8(%ebp),%edx
c0100ed9:	ee                   	out    %al,(%dx)
c0100eda:	66 c7 45 f6 7a 03    	movw   $0x37a,-0xa(%ebp)
c0100ee0:	c6 45 f1 0d          	movb   $0xd,-0xf(%ebp)
c0100ee4:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0100ee8:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0100eec:	ee                   	out    %al,(%dx)
c0100eed:	66 c7 45 fa 7a 03    	movw   $0x37a,-0x6(%ebp)
c0100ef3:	c6 45 f2 08          	movb   $0x8,-0xe(%ebp)
c0100ef7:	0f b6 45 f2          	movzbl -0xe(%ebp),%eax
c0100efb:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0100eff:	ee                   	out    %al,(%dx)
    outb(LPTPORT + 2, 0x08 | 0x04 | 0x01);
    outb(LPTPORT + 2, 0x08);
}
c0100f00:	90                   	nop
c0100f01:	c9                   	leave  
c0100f02:	c3                   	ret    

c0100f03 <cons_intr>:
/* *
 * cons_intr - called by device interrupt routines to feed input
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
c0100f03:	55                   	push   %ebp
c0100f04:	89 e5                	mov    %esp,%ebp
c0100f06:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = (*proc)()) != -1) {
c0100f09:	eb 33                	jmp    c0100f3e <cons_intr+0x3b>
        if (c != 0) {
c0100f0b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100f0f:	74 2d                	je     c0100f3e <cons_intr+0x3b>
            cons.buf[cons.wpos ++] = c;
c0100f11:	a1 c4 40 11 c0       	mov    0xc01140c4,%eax
c0100f16:	8d 50 01             	lea    0x1(%eax),%edx
c0100f19:	89 15 c4 40 11 c0    	mov    %edx,0xc01140c4
c0100f1f:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100f22:	88 90 c0 3e 11 c0    	mov    %dl,-0x3feec140(%eax)
            if (cons.wpos == CONSBUFSIZE) {
c0100f28:	a1 c4 40 11 c0       	mov    0xc01140c4,%eax
c0100f2d:	3d 00 02 00 00       	cmp    $0x200,%eax
c0100f32:	75 0a                	jne    c0100f3e <cons_intr+0x3b>
                cons.wpos = 0;
c0100f34:	c7 05 c4 40 11 c0 00 	movl   $0x0,0xc01140c4
c0100f3b:	00 00 00 
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
    int c;
    while ((c = (*proc)()) != -1) {
c0100f3e:	8b 45 08             	mov    0x8(%ebp),%eax
c0100f41:	ff d0                	call   *%eax
c0100f43:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100f46:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
c0100f4a:	75 bf                	jne    c0100f0b <cons_intr+0x8>
            if (cons.wpos == CONSBUFSIZE) {
                cons.wpos = 0;
            }
        }
    }
}
c0100f4c:	90                   	nop
c0100f4d:	c9                   	leave  
c0100f4e:	c3                   	ret    

c0100f4f <kbd_proc_data>:
 *
 * The kbd_proc_data() function gets data from the keyboard.
 * If we finish a character, return it, else 0. And return -1 if no data.
 * */
static int
kbd_proc_data(void) {
c0100f4f:	55                   	push   %ebp
c0100f50:	89 e5                	mov    %esp,%ebp
c0100f52:	83 ec 18             	sub    $0x18,%esp
c0100f55:	66 c7 45 ec 64 00    	movw   $0x64,-0x14(%ebp)
static inline void write_eflags(uint32_t eflags) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100f5b:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c0100f5f:	89 c2                	mov    %eax,%edx
c0100f61:	ec                   	in     (%dx),%al
c0100f62:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
c0100f65:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
    int c;
    uint8_t data;
    static uint32_t shift;

    if ((inb(KBSTATP) & KBS_DIB) == 0) {
c0100f69:	0f b6 c0             	movzbl %al,%eax
c0100f6c:	83 e0 01             	and    $0x1,%eax
c0100f6f:	85 c0                	test   %eax,%eax
c0100f71:	75 0a                	jne    c0100f7d <kbd_proc_data+0x2e>
        return -1;
c0100f73:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0100f78:	e9 5d 01 00 00       	jmp    c01010da <kbd_proc_data+0x18b>
c0100f7d:	66 c7 45 f0 60 00    	movw   $0x60,-0x10(%ebp)
static inline void write_eflags(uint32_t eflags) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100f83:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c0100f87:	89 c2                	mov    %eax,%edx
c0100f89:	ec                   	in     (%dx),%al
c0100f8a:	88 45 ea             	mov    %al,-0x16(%ebp)
    return data;
c0100f8d:	0f b6 45 ea          	movzbl -0x16(%ebp),%eax
    }

    data = inb(KBDATAP);
c0100f91:	88 45 f3             	mov    %al,-0xd(%ebp)

    if (data == 0xE0) {
c0100f94:	80 7d f3 e0          	cmpb   $0xe0,-0xd(%ebp)
c0100f98:	75 17                	jne    c0100fb1 <kbd_proc_data+0x62>
        // E0 escape character
        shift |= E0ESC;
c0100f9a:	a1 c8 40 11 c0       	mov    0xc01140c8,%eax
c0100f9f:	83 c8 40             	or     $0x40,%eax
c0100fa2:	a3 c8 40 11 c0       	mov    %eax,0xc01140c8
        return 0;
c0100fa7:	b8 00 00 00 00       	mov    $0x0,%eax
c0100fac:	e9 29 01 00 00       	jmp    c01010da <kbd_proc_data+0x18b>
    } else if (data & 0x80) {
c0100fb1:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0100fb5:	84 c0                	test   %al,%al
c0100fb7:	79 47                	jns    c0101000 <kbd_proc_data+0xb1>
        // Key released
        data = (shift & E0ESC ? data : data & 0x7F);
c0100fb9:	a1 c8 40 11 c0       	mov    0xc01140c8,%eax
c0100fbe:	83 e0 40             	and    $0x40,%eax
c0100fc1:	85 c0                	test   %eax,%eax
c0100fc3:	75 09                	jne    c0100fce <kbd_proc_data+0x7f>
c0100fc5:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0100fc9:	83 e0 7f             	and    $0x7f,%eax
c0100fcc:	eb 04                	jmp    c0100fd2 <kbd_proc_data+0x83>
c0100fce:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0100fd2:	88 45 f3             	mov    %al,-0xd(%ebp)
        shift &= ~(shiftcode[data] | E0ESC);
c0100fd5:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0100fd9:	0f b6 80 60 30 11 c0 	movzbl -0x3feecfa0(%eax),%eax
c0100fe0:	83 c8 40             	or     $0x40,%eax
c0100fe3:	0f b6 c0             	movzbl %al,%eax
c0100fe6:	f7 d0                	not    %eax
c0100fe8:	89 c2                	mov    %eax,%edx
c0100fea:	a1 c8 40 11 c0       	mov    0xc01140c8,%eax
c0100fef:	21 d0                	and    %edx,%eax
c0100ff1:	a3 c8 40 11 c0       	mov    %eax,0xc01140c8
        return 0;
c0100ff6:	b8 00 00 00 00       	mov    $0x0,%eax
c0100ffb:	e9 da 00 00 00       	jmp    c01010da <kbd_proc_data+0x18b>
    } else if (shift & E0ESC) {
c0101000:	a1 c8 40 11 c0       	mov    0xc01140c8,%eax
c0101005:	83 e0 40             	and    $0x40,%eax
c0101008:	85 c0                	test   %eax,%eax
c010100a:	74 11                	je     c010101d <kbd_proc_data+0xce>
        // Last character was an E0 escape; or with 0x80
        data |= 0x80;
c010100c:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
        shift &= ~E0ESC;
c0101010:	a1 c8 40 11 c0       	mov    0xc01140c8,%eax
c0101015:	83 e0 bf             	and    $0xffffffbf,%eax
c0101018:	a3 c8 40 11 c0       	mov    %eax,0xc01140c8
    }

    shift |= shiftcode[data];
c010101d:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101021:	0f b6 80 60 30 11 c0 	movzbl -0x3feecfa0(%eax),%eax
c0101028:	0f b6 d0             	movzbl %al,%edx
c010102b:	a1 c8 40 11 c0       	mov    0xc01140c8,%eax
c0101030:	09 d0                	or     %edx,%eax
c0101032:	a3 c8 40 11 c0       	mov    %eax,0xc01140c8
    shift ^= togglecode[data];
c0101037:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c010103b:	0f b6 80 60 31 11 c0 	movzbl -0x3feecea0(%eax),%eax
c0101042:	0f b6 d0             	movzbl %al,%edx
c0101045:	a1 c8 40 11 c0       	mov    0xc01140c8,%eax
c010104a:	31 d0                	xor    %edx,%eax
c010104c:	a3 c8 40 11 c0       	mov    %eax,0xc01140c8

    c = charcode[shift & (CTL | SHIFT)][data];
c0101051:	a1 c8 40 11 c0       	mov    0xc01140c8,%eax
c0101056:	83 e0 03             	and    $0x3,%eax
c0101059:	8b 14 85 60 35 11 c0 	mov    -0x3feecaa0(,%eax,4),%edx
c0101060:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101064:	01 d0                	add    %edx,%eax
c0101066:	0f b6 00             	movzbl (%eax),%eax
c0101069:	0f b6 c0             	movzbl %al,%eax
c010106c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (shift & CAPSLOCK) {
c010106f:	a1 c8 40 11 c0       	mov    0xc01140c8,%eax
c0101074:	83 e0 08             	and    $0x8,%eax
c0101077:	85 c0                	test   %eax,%eax
c0101079:	74 22                	je     c010109d <kbd_proc_data+0x14e>
        if ('a' <= c && c <= 'z')
c010107b:	83 7d f4 60          	cmpl   $0x60,-0xc(%ebp)
c010107f:	7e 0c                	jle    c010108d <kbd_proc_data+0x13e>
c0101081:	83 7d f4 7a          	cmpl   $0x7a,-0xc(%ebp)
c0101085:	7f 06                	jg     c010108d <kbd_proc_data+0x13e>
            c += 'A' - 'a';
c0101087:	83 6d f4 20          	subl   $0x20,-0xc(%ebp)
c010108b:	eb 10                	jmp    c010109d <kbd_proc_data+0x14e>
        else if ('A' <= c && c <= 'Z')
c010108d:	83 7d f4 40          	cmpl   $0x40,-0xc(%ebp)
c0101091:	7e 0a                	jle    c010109d <kbd_proc_data+0x14e>
c0101093:	83 7d f4 5a          	cmpl   $0x5a,-0xc(%ebp)
c0101097:	7f 04                	jg     c010109d <kbd_proc_data+0x14e>
            c += 'a' - 'A';
c0101099:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
    }

    // Process special keys
    // Ctrl-Alt-Del: reboot
    if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
c010109d:	a1 c8 40 11 c0       	mov    0xc01140c8,%eax
c01010a2:	f7 d0                	not    %eax
c01010a4:	83 e0 06             	and    $0x6,%eax
c01010a7:	85 c0                	test   %eax,%eax
c01010a9:	75 2c                	jne    c01010d7 <kbd_proc_data+0x188>
c01010ab:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
c01010b2:	75 23                	jne    c01010d7 <kbd_proc_data+0x188>
        cprintf("Rebooting!\n");
c01010b4:	83 ec 0c             	sub    $0xc,%esp
c01010b7:	68 e9 45 10 c0       	push   $0xc01045e9
c01010bc:	e8 23 f0 ff ff       	call   c01000e4 <cprintf>
c01010c1:	83 c4 10             	add    $0x10,%esp
c01010c4:	66 c7 45 ee 92 00    	movw   $0x92,-0x12(%ebp)
c01010ca:	c6 45 e9 03          	movb   $0x3,-0x17(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01010ce:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c01010d2:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c01010d6:	ee                   	out    %al,(%dx)
        outb(0x92, 0x3); // courtesy of Chris Frost
    }
    return c;
c01010d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01010da:	c9                   	leave  
c01010db:	c3                   	ret    

c01010dc <kbd_intr>:

/* kbd_intr - try to feed input characters from keyboard */
static void
kbd_intr(void) {
c01010dc:	55                   	push   %ebp
c01010dd:	89 e5                	mov    %esp,%ebp
c01010df:	83 ec 08             	sub    $0x8,%esp
    cons_intr(kbd_proc_data);
c01010e2:	83 ec 0c             	sub    $0xc,%esp
c01010e5:	68 4f 0f 10 c0       	push   $0xc0100f4f
c01010ea:	e8 14 fe ff ff       	call   c0100f03 <cons_intr>
c01010ef:	83 c4 10             	add    $0x10,%esp
}
c01010f2:	90                   	nop
c01010f3:	c9                   	leave  
c01010f4:	c3                   	ret    

c01010f5 <kbd_init>:

static void
kbd_init(void) {
c01010f5:	55                   	push   %ebp
c01010f6:	89 e5                	mov    %esp,%ebp
c01010f8:	83 ec 08             	sub    $0x8,%esp
    // drain the kbd buffer
    kbd_intr();
c01010fb:	e8 dc ff ff ff       	call   c01010dc <kbd_intr>
    pic_enable(IRQ_KBD);
c0101100:	83 ec 0c             	sub    $0xc,%esp
c0101103:	6a 01                	push   $0x1
c0101105:	e8 12 02 00 00       	call   c010131c <pic_enable>
c010110a:	83 c4 10             	add    $0x10,%esp
}
c010110d:	90                   	nop
c010110e:	c9                   	leave  
c010110f:	c3                   	ret    

c0101110 <cons_init>:

/* cons_init - initializes the console devices */
void
cons_init(void) { 
c0101110:	55                   	push   %ebp
c0101111:	89 e5                	mov    %esp,%ebp
c0101113:	83 ec 08             	sub    $0x8,%esp
    kbd_init();
c0101116:	e8 da ff ff ff       	call   c01010f5 <kbd_init>
}
c010111b:	90                   	nop
c010111c:	c9                   	leave  
c010111d:	c3                   	ret    

c010111e <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void
cons_putc(int c) {
c010111e:	55                   	push   %ebp
c010111f:	89 e5                	mov    %esp,%ebp
    lpt_putc(c); 
c0101121:	ff 75 08             	pushl  0x8(%ebp)
c0101124:	e8 60 fd ff ff       	call   c0100e89 <lpt_putc>
c0101129:	83 c4 04             	add    $0x4,%esp
}
c010112c:	90                   	nop
c010112d:	c9                   	leave  
c010112e:	c3                   	ret    

c010112f <cons_getc>:
/* *
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int
cons_getc(void) {
c010112f:	55                   	push   %ebp
c0101130:	89 e5                	mov    %esp,%ebp
c0101132:	83 ec 18             	sub    $0x18,%esp
    int c;

    // poll for any pending input characters,
    // so that this function works even when interrupts are disabled
    // (e.g., when called from the kernel monitor).
    kbd_intr();
c0101135:	e8 a2 ff ff ff       	call   c01010dc <kbd_intr>

    // grab the next character from the input buffer.
    if (cons.rpos != cons.wpos) {
c010113a:	8b 15 c0 40 11 c0    	mov    0xc01140c0,%edx
c0101140:	a1 c4 40 11 c0       	mov    0xc01140c4,%eax
c0101145:	39 c2                	cmp    %eax,%edx
c0101147:	74 36                	je     c010117f <cons_getc+0x50>
        c = cons.buf[cons.rpos ++];
c0101149:	a1 c0 40 11 c0       	mov    0xc01140c0,%eax
c010114e:	8d 50 01             	lea    0x1(%eax),%edx
c0101151:	89 15 c0 40 11 c0    	mov    %edx,0xc01140c0
c0101157:	0f b6 80 c0 3e 11 c0 	movzbl -0x3feec140(%eax),%eax
c010115e:	0f b6 c0             	movzbl %al,%eax
c0101161:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (cons.rpos == CONSBUFSIZE) {
c0101164:	a1 c0 40 11 c0       	mov    0xc01140c0,%eax
c0101169:	3d 00 02 00 00       	cmp    $0x200,%eax
c010116e:	75 0a                	jne    c010117a <cons_getc+0x4b>
            cons.rpos = 0;
c0101170:	c7 05 c0 40 11 c0 00 	movl   $0x0,0xc01140c0
c0101177:	00 00 00 
        }
        return c;
c010117a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010117d:	eb 05                	jmp    c0101184 <cons_getc+0x55>
    }
    return 0;
c010117f:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0101184:	c9                   	leave  
c0101185:	c3                   	ret    

c0101186 <pic_setmask>:
#define IRQ_SLAVE 	2		// IRQ at which slave connects to master

static bool did_init = 0;
static uint16_t irq_mask = 0xFFFF & ~(1 << IRQ_SLAVE);

static void pic_setmask(uint16_t mask) {
c0101186:	55                   	push   %ebp
c0101187:	89 e5                	mov    %esp,%ebp
c0101189:	83 ec 14             	sub    $0x14,%esp
c010118c:	8b 45 08             	mov    0x8(%ebp),%eax
c010118f:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
	irq_mask = mask;
c0101193:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c0101197:	66 a3 70 35 11 c0    	mov    %ax,0xc0113570
	if(did_init) {
c010119d:	a1 cc 40 11 c0       	mov    0xc01140cc,%eax
c01011a2:	85 c0                	test   %eax,%eax
c01011a4:	74 36                	je     c01011dc <pic_setmask+0x56>
		outb(IO_PIC1+1, mask);
c01011a6:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c01011aa:	0f b6 c0             	movzbl %al,%eax
c01011ad:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
c01011b3:	88 45 fa             	mov    %al,-0x6(%ebp)
c01011b6:	0f b6 45 fa          	movzbl -0x6(%ebp),%eax
c01011ba:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c01011be:	ee                   	out    %al,(%dx)
		outb(IO_PIC2+1, mask>>8);
c01011bf:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c01011c3:	66 c1 e8 08          	shr    $0x8,%ax
c01011c7:	0f b6 c0             	movzbl %al,%eax
c01011ca:	66 c7 45 fc a1 00    	movw   $0xa1,-0x4(%ebp)
c01011d0:	88 45 fb             	mov    %al,-0x5(%ebp)
c01011d3:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
c01011d7:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
c01011db:	ee                   	out    %al,(%dx)
	}
}
c01011dc:	90                   	nop
c01011dd:	c9                   	leave  
c01011de:	c3                   	ret    

c01011df <pic_init>:

void pic_init(void) {
c01011df:	55                   	push   %ebp
c01011e0:	89 e5                	mov    %esp,%ebp
c01011e2:	83 ec 30             	sub    $0x30,%esp
	did_init = 1;
c01011e5:	c7 05 cc 40 11 c0 01 	movl   $0x1,0xc01140cc
c01011ec:	00 00 00 
c01011ef:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
c01011f5:	c6 45 d6 ff          	movb   $0xff,-0x2a(%ebp)
c01011f9:	0f b6 45 d6          	movzbl -0x2a(%ebp),%eax
c01011fd:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c0101201:	ee                   	out    %al,(%dx)
c0101202:	66 c7 45 fc a1 00    	movw   $0xa1,-0x4(%ebp)
c0101208:	c6 45 d7 ff          	movb   $0xff,-0x29(%ebp)
c010120c:	0f b6 45 d7          	movzbl -0x29(%ebp),%eax
c0101210:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
c0101214:	ee                   	out    %al,(%dx)
c0101215:	66 c7 45 fa 20 00    	movw   $0x20,-0x6(%ebp)
c010121b:	c6 45 d8 11          	movb   $0x11,-0x28(%ebp)
c010121f:	0f b6 45 d8          	movzbl -0x28(%ebp),%eax
c0101223:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0101227:	ee                   	out    %al,(%dx)
c0101228:	66 c7 45 f8 21 00    	movw   $0x21,-0x8(%ebp)
c010122e:	c6 45 d9 20          	movb   $0x20,-0x27(%ebp)
c0101232:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c0101236:	0f b7 55 f8          	movzwl -0x8(%ebp),%edx
c010123a:	ee                   	out    %al,(%dx)
c010123b:	66 c7 45 f6 21 00    	movw   $0x21,-0xa(%ebp)
c0101241:	c6 45 da 04          	movb   $0x4,-0x26(%ebp)
c0101245:	0f b6 45 da          	movzbl -0x26(%ebp),%eax
c0101249:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c010124d:	ee                   	out    %al,(%dx)
c010124e:	66 c7 45 f4 21 00    	movw   $0x21,-0xc(%ebp)
c0101254:	c6 45 db 03          	movb   $0x3,-0x25(%ebp)
c0101258:	0f b6 45 db          	movzbl -0x25(%ebp),%eax
c010125c:	0f b7 55 f4          	movzwl -0xc(%ebp),%edx
c0101260:	ee                   	out    %al,(%dx)
c0101261:	66 c7 45 f2 a0 00    	movw   $0xa0,-0xe(%ebp)
c0101267:	c6 45 dc 11          	movb   $0x11,-0x24(%ebp)
c010126b:	0f b6 45 dc          	movzbl -0x24(%ebp),%eax
c010126f:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101273:	ee                   	out    %al,(%dx)
c0101274:	66 c7 45 f0 a1 00    	movw   $0xa1,-0x10(%ebp)
c010127a:	c6 45 dd 28          	movb   $0x28,-0x23(%ebp)
c010127e:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0101282:	0f b7 55 f0          	movzwl -0x10(%ebp),%edx
c0101286:	ee                   	out    %al,(%dx)
c0101287:	66 c7 45 ee a1 00    	movw   $0xa1,-0x12(%ebp)
c010128d:	c6 45 de 02          	movb   $0x2,-0x22(%ebp)
c0101291:	0f b6 45 de          	movzbl -0x22(%ebp),%eax
c0101295:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0101299:	ee                   	out    %al,(%dx)
c010129a:	66 c7 45 ec a1 00    	movw   $0xa1,-0x14(%ebp)
c01012a0:	c6 45 df 03          	movb   $0x3,-0x21(%ebp)
c01012a4:	0f b6 45 df          	movzbl -0x21(%ebp),%eax
c01012a8:	0f b7 55 ec          	movzwl -0x14(%ebp),%edx
c01012ac:	ee                   	out    %al,(%dx)
c01012ad:	66 c7 45 ea 20 00    	movw   $0x20,-0x16(%ebp)
c01012b3:	c6 45 e0 68          	movb   $0x68,-0x20(%ebp)
c01012b7:	0f b6 45 e0          	movzbl -0x20(%ebp),%eax
c01012bb:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c01012bf:	ee                   	out    %al,(%dx)
c01012c0:	66 c7 45 e8 20 00    	movw   $0x20,-0x18(%ebp)
c01012c6:	c6 45 e1 0a          	movb   $0xa,-0x1f(%ebp)
c01012ca:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c01012ce:	0f b7 55 e8          	movzwl -0x18(%ebp),%edx
c01012d2:	ee                   	out    %al,(%dx)
c01012d3:	66 c7 45 e6 a0 00    	movw   $0xa0,-0x1a(%ebp)
c01012d9:	c6 45 e2 68          	movb   $0x68,-0x1e(%ebp)
c01012dd:	0f b6 45 e2          	movzbl -0x1e(%ebp),%eax
c01012e1:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c01012e5:	ee                   	out    %al,(%dx)
c01012e6:	66 c7 45 e4 a0 00    	movw   $0xa0,-0x1c(%ebp)
c01012ec:	c6 45 e3 0a          	movb   $0xa,-0x1d(%ebp)
c01012f0:	0f b6 45 e3          	movzbl -0x1d(%ebp),%eax
c01012f4:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
c01012f8:	ee                   	out    %al,(%dx)

    outb(IO_PIC2, 0x68);
    outb(IO_PIC2, 0x0a);

    //初始化完毕,使能主从8259A的所有中断
    if(irq_mask != 0xFFFF) {
c01012f9:	0f b7 05 70 35 11 c0 	movzwl 0xc0113570,%eax
c0101300:	66 83 f8 ff          	cmp    $0xffff,%ax
c0101304:	74 13                	je     c0101319 <pic_init+0x13a>
    	pic_setmask(irq_mask);
c0101306:	0f b7 05 70 35 11 c0 	movzwl 0xc0113570,%eax
c010130d:	0f b7 c0             	movzwl %ax,%eax
c0101310:	50                   	push   %eax
c0101311:	e8 70 fe ff ff       	call   c0101186 <pic_setmask>
c0101316:	83 c4 04             	add    $0x4,%esp
    }

}
c0101319:	90                   	nop
c010131a:	c9                   	leave  
c010131b:	c3                   	ret    

c010131c <pic_enable>:
void pic_enable(unsigned int irq) {
c010131c:	55                   	push   %ebp
c010131d:	89 e5                	mov    %esp,%ebp
	pic_setmask(irq_mask & ~(1<<irq));
c010131f:	8b 45 08             	mov    0x8(%ebp),%eax
c0101322:	ba 01 00 00 00       	mov    $0x1,%edx
c0101327:	89 c1                	mov    %eax,%ecx
c0101329:	d3 e2                	shl    %cl,%edx
c010132b:	89 d0                	mov    %edx,%eax
c010132d:	f7 d0                	not    %eax
c010132f:	89 c2                	mov    %eax,%edx
c0101331:	0f b7 05 70 35 11 c0 	movzwl 0xc0113570,%eax
c0101338:	21 d0                	and    %edx,%eax
c010133a:	0f b7 c0             	movzwl %ax,%eax
c010133d:	50                   	push   %eax
c010133e:	e8 43 fe ff ff       	call   c0101186 <pic_setmask>
c0101343:	83 c4 04             	add    $0x4,%esp
}
c0101346:	90                   	nop
c0101347:	c9                   	leave  
c0101348:	c3                   	ret    

c0101349 <intr_enable>:
#include <x86.h>
#include <intr.h>

void intr_enable(void) {
c0101349:	55                   	push   %ebp
c010134a:	89 e5                	mov    %esp,%ebp
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
}

static inline void
sti(void) {
    asm volatile ("sti");
c010134c:	fb                   	sti    
	sti();
}
c010134d:	90                   	nop
c010134e:	5d                   	pop    %ebp
c010134f:	c3                   	ret    

c0101350 <intr_disable>:

void intr_disable(void) {
c0101350:	55                   	push   %ebp
c0101351:	89 e5                	mov    %esp,%ebp
}

static inline void
cli(void) {
    asm volatile ("cli" ::: "memory");
c0101353:	fa                   	cli    
	cli();
c0101354:	90                   	nop
c0101355:	5d                   	pop    %ebp
c0101356:	c3                   	ret    

c0101357 <idt_init>:
static struct pseudodesc idt_pd = {
	sizeof(idt) -1, (uintptr_t)idt
};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void idt_init(void) { 
c0101357:	55                   	push   %ebp
c0101358:	89 e5                	mov    %esp,%ebp
c010135a:	83 ec 10             	sub    $0x10,%esp
	extern uintptr_t __vectors[];
	for(int i=0; i<sizeof(idt)/sizeof(struct gatedesc);i++)
c010135d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c0101364:	e9 c3 00 00 00       	jmp    c010142c <idt_init+0xd5>
		SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
c0101369:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010136c:	8b 04 85 7a 35 11 c0 	mov    -0x3feeca86(,%eax,4),%eax
c0101373:	89 c2                	mov    %eax,%edx
c0101375:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101378:	66 89 14 c5 e0 40 11 	mov    %dx,-0x3feebf20(,%eax,8)
c010137f:	c0 
c0101380:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101383:	66 c7 04 c5 e2 40 11 	movw   $0x8,-0x3feebf1e(,%eax,8)
c010138a:	c0 08 00 
c010138d:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101390:	0f b6 14 c5 e4 40 11 	movzbl -0x3feebf1c(,%eax,8),%edx
c0101397:	c0 
c0101398:	83 e2 e0             	and    $0xffffffe0,%edx
c010139b:	88 14 c5 e4 40 11 c0 	mov    %dl,-0x3feebf1c(,%eax,8)
c01013a2:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01013a5:	0f b6 14 c5 e4 40 11 	movzbl -0x3feebf1c(,%eax,8),%edx
c01013ac:	c0 
c01013ad:	83 e2 1f             	and    $0x1f,%edx
c01013b0:	88 14 c5 e4 40 11 c0 	mov    %dl,-0x3feebf1c(,%eax,8)
c01013b7:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01013ba:	0f b6 14 c5 e5 40 11 	movzbl -0x3feebf1b(,%eax,8),%edx
c01013c1:	c0 
c01013c2:	83 e2 f0             	and    $0xfffffff0,%edx
c01013c5:	83 ca 0e             	or     $0xe,%edx
c01013c8:	88 14 c5 e5 40 11 c0 	mov    %dl,-0x3feebf1b(,%eax,8)
c01013cf:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01013d2:	0f b6 14 c5 e5 40 11 	movzbl -0x3feebf1b(,%eax,8),%edx
c01013d9:	c0 
c01013da:	83 e2 ef             	and    $0xffffffef,%edx
c01013dd:	88 14 c5 e5 40 11 c0 	mov    %dl,-0x3feebf1b(,%eax,8)
c01013e4:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01013e7:	0f b6 14 c5 e5 40 11 	movzbl -0x3feebf1b(,%eax,8),%edx
c01013ee:	c0 
c01013ef:	83 e2 9f             	and    $0xffffff9f,%edx
c01013f2:	88 14 c5 e5 40 11 c0 	mov    %dl,-0x3feebf1b(,%eax,8)
c01013f9:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01013fc:	0f b6 14 c5 e5 40 11 	movzbl -0x3feebf1b(,%eax,8),%edx
c0101403:	c0 
c0101404:	83 ca 80             	or     $0xffffff80,%edx
c0101407:	88 14 c5 e5 40 11 c0 	mov    %dl,-0x3feebf1b(,%eax,8)
c010140e:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101411:	8b 04 85 7a 35 11 c0 	mov    -0x3feeca86(,%eax,4),%eax
c0101418:	c1 e8 10             	shr    $0x10,%eax
c010141b:	89 c2                	mov    %eax,%edx
c010141d:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101420:	66 89 14 c5 e6 40 11 	mov    %dx,-0x3feebf1a(,%eax,8)
c0101427:	c0 
};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void idt_init(void) { 
	extern uintptr_t __vectors[];
	for(int i=0; i<sizeof(idt)/sizeof(struct gatedesc);i++)
c0101428:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c010142c:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010142f:	3d ff 00 00 00       	cmp    $0xff,%eax
c0101434:	0f 86 2f ff ff ff    	jbe    c0101369 <idt_init+0x12>
		SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);

	// load the IDT
	lidt(REALLOC(&idt_pd));
c010143a:	b8 74 35 11 40       	mov    $0x40113574,%eax
c010143f:	89 45 f8             	mov    %eax,-0x8(%ebp)
    }
}

static inline void
lidt(struct pseudodesc *pd) {
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
c0101442:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0101445:	0f 01 18             	lidtl  (%eax)
}
c0101448:	90                   	nop
c0101449:	c9                   	leave  
c010144a:	c3                   	ret    

c010144b <trap_dispatch>:

static void trap_dispatch(struct trapframe *tf) {
c010144b:	55                   	push   %ebp
c010144c:	89 e5                	mov    %esp,%ebp
c010144e:	83 ec 18             	sub    $0x18,%esp
	char c;
	switch(tf->tf_trapno) {
c0101451:	8b 45 08             	mov    0x8(%ebp),%eax
c0101454:	8b 40 28             	mov    0x28(%eax),%eax
c0101457:	83 f8 20             	cmp    $0x20,%eax
c010145a:	74 0a                	je     c0101466 <trap_dispatch+0x1b>
c010145c:	83 f8 21             	cmp    $0x21,%eax
c010145f:	74 45                	je     c01014a6 <trap_dispatch+0x5b>
c0101461:	e9 8e 00 00 00       	jmp    c01014f4 <trap_dispatch+0xa9>
		case IRQ_OFFSET + IRQ_TIMER:
			ticks ++;
c0101466:	a1 88 49 11 c0       	mov    0xc0114988,%eax
c010146b:	83 c0 01             	add    $0x1,%eax
c010146e:	a3 88 49 11 c0       	mov    %eax,0xc0114988
			if (ticks % TICK_NUM == 0) {
c0101473:	8b 0d 88 49 11 c0    	mov    0xc0114988,%ecx
c0101479:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
c010147e:	89 c8                	mov    %ecx,%eax
c0101480:	f7 e2                	mul    %edx
c0101482:	89 d0                	mov    %edx,%eax
c0101484:	c1 e8 05             	shr    $0x5,%eax
c0101487:	6b c0 64             	imul   $0x64,%eax,%eax
c010148a:	29 c1                	sub    %eax,%ecx
c010148c:	89 c8                	mov    %ecx,%eax
c010148e:	85 c0                	test   %eax,%eax
c0101490:	75 74                	jne    c0101506 <trap_dispatch+0xbb>
				cprintf("%d ticks\n", TICK_NUM);
c0101492:	83 ec 08             	sub    $0x8,%esp
c0101495:	6a 64                	push   $0x64
c0101497:	68 f5 45 10 c0       	push   $0xc01045f5
c010149c:	e8 43 ec ff ff       	call   c01000e4 <cprintf>
c01014a1:	83 c4 10             	add    $0x10,%esp
			}
			break;
c01014a4:	eb 60                	jmp    c0101506 <trap_dispatch+0xbb>
		case IRQ_OFFSET + IRQ_KBD:
			c = cons_getc();
c01014a6:	e8 84 fc ff ff       	call   c010112f <cons_getc>
c01014ab:	88 45 f7             	mov    %al,-0x9(%ebp)
			cprintf("%s [%03d] %c\n", (tf->tf_trapno != IRQ_OFFSET + IRQ_KBD) ? "serial":"kbd", c, c);
c01014ae:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
c01014b2:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c01014b6:	8b 4d 08             	mov    0x8(%ebp),%ecx
c01014b9:	8b 49 28             	mov    0x28(%ecx),%ecx
c01014bc:	83 f9 21             	cmp    $0x21,%ecx
c01014bf:	74 07                	je     c01014c8 <trap_dispatch+0x7d>
c01014c1:	b9 ff 45 10 c0       	mov    $0xc01045ff,%ecx
c01014c6:	eb 05                	jmp    c01014cd <trap_dispatch+0x82>
c01014c8:	b9 06 46 10 c0       	mov    $0xc0104606,%ecx
c01014cd:	52                   	push   %edx
c01014ce:	50                   	push   %eax
c01014cf:	51                   	push   %ecx
c01014d0:	68 0a 46 10 c0       	push   $0xc010460a
c01014d5:	e8 0a ec ff ff       	call   c01000e4 <cprintf>
c01014da:	83 c4 10             	add    $0x10,%esp
			keybuf_push(&kb, c);
c01014dd:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c01014e1:	83 ec 08             	sub    $0x8,%esp
c01014e4:	50                   	push   %eax
c01014e5:	68 a0 49 11 c0       	push   $0xc01149a0
c01014ea:	e8 f9 2c 00 00       	call   c01041e8 <keybuf_push>
c01014ef:	83 c4 10             	add    $0x10,%esp
			break;
c01014f2:	eb 13                	jmp    c0101507 <trap_dispatch+0xbc>
		default:
			cprintf("UNKNOW INT\n");
c01014f4:	83 ec 0c             	sub    $0xc,%esp
c01014f7:	68 18 46 10 c0       	push   $0xc0104618
c01014fc:	e8 e3 eb ff ff       	call   c01000e4 <cprintf>
c0101501:	83 c4 10             	add    $0x10,%esp
	}
}
c0101504:	eb 01                	jmp    c0101507 <trap_dispatch+0xbc>
		case IRQ_OFFSET + IRQ_TIMER:
			ticks ++;
			if (ticks % TICK_NUM == 0) {
				cprintf("%d ticks\n", TICK_NUM);
			}
			break;
c0101506:	90                   	nop
			keybuf_push(&kb, c);
			break;
		default:
			cprintf("UNKNOW INT\n");
	}
}
c0101507:	90                   	nop
c0101508:	c9                   	leave  
c0101509:	c3                   	ret    

c010150a <trap>:

void trap(struct trapframe *tf) {
c010150a:	55                   	push   %ebp
c010150b:	89 e5                	mov    %esp,%ebp
c010150d:	83 ec 08             	sub    $0x8,%esp
	cprintf("trap");
c0101510:	83 ec 0c             	sub    $0xc,%esp
c0101513:	68 24 46 10 c0       	push   $0xc0104624
c0101518:	e8 c7 eb ff ff       	call   c01000e4 <cprintf>
c010151d:	83 c4 10             	add    $0x10,%esp
	trap_dispatch(tf);
c0101520:	83 ec 0c             	sub    $0xc,%esp
c0101523:	ff 75 08             	pushl  0x8(%ebp)
c0101526:	e8 20 ff ff ff       	call   c010144b <trap_dispatch>
c010152b:	83 c4 10             	add    $0x10,%esp
c010152e:	90                   	nop
c010152f:	c9                   	leave  
c0101530:	c3                   	ret    

c0101531 <vector0>:
# handler
.text
.global __alltraps
.global vector0
vector0:
  pushl $0
c0101531:	6a 00                	push   $0x0
  pushl $0
c0101533:	6a 00                	push   $0x0
  jmp __alltraps
c0101535:	e9 67 0a 00 00       	jmp    c0101fa1 <__alltraps>

c010153a <vector1>:
.global vector1
vector1:
  pushl $0
c010153a:	6a 00                	push   $0x0
  pushl $1
c010153c:	6a 01                	push   $0x1
  jmp __alltraps
c010153e:	e9 5e 0a 00 00       	jmp    c0101fa1 <__alltraps>

c0101543 <vector2>:
.global vector2
vector2:
  pushl $0
c0101543:	6a 00                	push   $0x0
  pushl $2
c0101545:	6a 02                	push   $0x2
  jmp __alltraps
c0101547:	e9 55 0a 00 00       	jmp    c0101fa1 <__alltraps>

c010154c <vector3>:
.global vector3
vector3:
  pushl $0
c010154c:	6a 00                	push   $0x0
  pushl $3
c010154e:	6a 03                	push   $0x3
  jmp __alltraps
c0101550:	e9 4c 0a 00 00       	jmp    c0101fa1 <__alltraps>

c0101555 <vector4>:
.global vector4
vector4:
  pushl $0
c0101555:	6a 00                	push   $0x0
  pushl $4
c0101557:	6a 04                	push   $0x4
  jmp __alltraps
c0101559:	e9 43 0a 00 00       	jmp    c0101fa1 <__alltraps>

c010155e <vector5>:
.global vector5
vector5:
  pushl $0
c010155e:	6a 00                	push   $0x0
  pushl $5
c0101560:	6a 05                	push   $0x5
  jmp __alltraps
c0101562:	e9 3a 0a 00 00       	jmp    c0101fa1 <__alltraps>

c0101567 <vector6>:
.global vector6
vector6:
  pushl $0
c0101567:	6a 00                	push   $0x0
  pushl $6
c0101569:	6a 06                	push   $0x6
  jmp __alltraps
c010156b:	e9 31 0a 00 00       	jmp    c0101fa1 <__alltraps>

c0101570 <vector7>:
.global vector7
vector7:
  pushl $0
c0101570:	6a 00                	push   $0x0
  pushl $7
c0101572:	6a 07                	push   $0x7
  jmp __alltraps
c0101574:	e9 28 0a 00 00       	jmp    c0101fa1 <__alltraps>

c0101579 <vector8>:
.global vector8
vector8:
  pushl $8
c0101579:	6a 08                	push   $0x8
  jmp __alltraps
c010157b:	e9 21 0a 00 00       	jmp    c0101fa1 <__alltraps>

c0101580 <vector9>:
.global vector9
vector9:
  pushl $9
c0101580:	6a 09                	push   $0x9
  jmp __alltraps
c0101582:	e9 1a 0a 00 00       	jmp    c0101fa1 <__alltraps>

c0101587 <vector10>:
.global vector10
vector10:
  pushl $10
c0101587:	6a 0a                	push   $0xa
  jmp __alltraps
c0101589:	e9 13 0a 00 00       	jmp    c0101fa1 <__alltraps>

c010158e <vector11>:
.global vector11
vector11:
  pushl $11
c010158e:	6a 0b                	push   $0xb
  jmp __alltraps
c0101590:	e9 0c 0a 00 00       	jmp    c0101fa1 <__alltraps>

c0101595 <vector12>:
.global vector12
vector12:
  pushl $12
c0101595:	6a 0c                	push   $0xc
  jmp __alltraps
c0101597:	e9 05 0a 00 00       	jmp    c0101fa1 <__alltraps>

c010159c <vector13>:
.global vector13
vector13:
  pushl $13
c010159c:	6a 0d                	push   $0xd
  jmp __alltraps
c010159e:	e9 fe 09 00 00       	jmp    c0101fa1 <__alltraps>

c01015a3 <vector14>:
.global vector14
vector14:
  pushl $14
c01015a3:	6a 0e                	push   $0xe
  jmp __alltraps
c01015a5:	e9 f7 09 00 00       	jmp    c0101fa1 <__alltraps>

c01015aa <vector15>:
.global vector15
vector15:
  pushl $0
c01015aa:	6a 00                	push   $0x0
  pushl $15
c01015ac:	6a 0f                	push   $0xf
  jmp __alltraps
c01015ae:	e9 ee 09 00 00       	jmp    c0101fa1 <__alltraps>

c01015b3 <vector16>:
.global vector16
vector16:
  pushl $0
c01015b3:	6a 00                	push   $0x0
  pushl $16
c01015b5:	6a 10                	push   $0x10
  jmp __alltraps
c01015b7:	e9 e5 09 00 00       	jmp    c0101fa1 <__alltraps>

c01015bc <vector17>:
.global vector17
vector17:
  pushl $17
c01015bc:	6a 11                	push   $0x11
  jmp __alltraps
c01015be:	e9 de 09 00 00       	jmp    c0101fa1 <__alltraps>

c01015c3 <vector18>:
.global vector18
vector18:
  pushl $0
c01015c3:	6a 00                	push   $0x0
  pushl $18
c01015c5:	6a 12                	push   $0x12
  jmp __alltraps
c01015c7:	e9 d5 09 00 00       	jmp    c0101fa1 <__alltraps>

c01015cc <vector19>:
.global vector19
vector19:
  pushl $0
c01015cc:	6a 00                	push   $0x0
  pushl $19
c01015ce:	6a 13                	push   $0x13
  jmp __alltraps
c01015d0:	e9 cc 09 00 00       	jmp    c0101fa1 <__alltraps>

c01015d5 <vector20>:
.global vector20
vector20:
  pushl $0
c01015d5:	6a 00                	push   $0x0
  pushl $20
c01015d7:	6a 14                	push   $0x14
  jmp __alltraps
c01015d9:	e9 c3 09 00 00       	jmp    c0101fa1 <__alltraps>

c01015de <vector21>:
.global vector21
vector21:
  pushl $0
c01015de:	6a 00                	push   $0x0
  pushl $21
c01015e0:	6a 15                	push   $0x15
  jmp __alltraps
c01015e2:	e9 ba 09 00 00       	jmp    c0101fa1 <__alltraps>

c01015e7 <vector22>:
.global vector22
vector22:
  pushl $0
c01015e7:	6a 00                	push   $0x0
  pushl $22
c01015e9:	6a 16                	push   $0x16
  jmp __alltraps
c01015eb:	e9 b1 09 00 00       	jmp    c0101fa1 <__alltraps>

c01015f0 <vector23>:
.global vector23
vector23:
  pushl $0
c01015f0:	6a 00                	push   $0x0
  pushl $23
c01015f2:	6a 17                	push   $0x17
  jmp __alltraps
c01015f4:	e9 a8 09 00 00       	jmp    c0101fa1 <__alltraps>

c01015f9 <vector24>:
.global vector24
vector24:
  pushl $0
c01015f9:	6a 00                	push   $0x0
  pushl $24
c01015fb:	6a 18                	push   $0x18
  jmp __alltraps
c01015fd:	e9 9f 09 00 00       	jmp    c0101fa1 <__alltraps>

c0101602 <vector25>:
.global vector25
vector25:
  pushl $0
c0101602:	6a 00                	push   $0x0
  pushl $25
c0101604:	6a 19                	push   $0x19
  jmp __alltraps
c0101606:	e9 96 09 00 00       	jmp    c0101fa1 <__alltraps>

c010160b <vector26>:
.global vector26
vector26:
  pushl $0
c010160b:	6a 00                	push   $0x0
  pushl $26
c010160d:	6a 1a                	push   $0x1a
  jmp __alltraps
c010160f:	e9 8d 09 00 00       	jmp    c0101fa1 <__alltraps>

c0101614 <vector27>:
.global vector27
vector27:
  pushl $0
c0101614:	6a 00                	push   $0x0
  pushl $27
c0101616:	6a 1b                	push   $0x1b
  jmp __alltraps
c0101618:	e9 84 09 00 00       	jmp    c0101fa1 <__alltraps>

c010161d <vector28>:
.global vector28
vector28:
  pushl $0
c010161d:	6a 00                	push   $0x0
  pushl $28
c010161f:	6a 1c                	push   $0x1c
  jmp __alltraps
c0101621:	e9 7b 09 00 00       	jmp    c0101fa1 <__alltraps>

c0101626 <vector29>:
.global vector29
vector29:
  pushl $0
c0101626:	6a 00                	push   $0x0
  pushl $29
c0101628:	6a 1d                	push   $0x1d
  jmp __alltraps
c010162a:	e9 72 09 00 00       	jmp    c0101fa1 <__alltraps>

c010162f <vector30>:
.global vector30
vector30:
  pushl $0
c010162f:	6a 00                	push   $0x0
  pushl $30
c0101631:	6a 1e                	push   $0x1e
  jmp __alltraps
c0101633:	e9 69 09 00 00       	jmp    c0101fa1 <__alltraps>

c0101638 <vector31>:
.global vector31
vector31:
  pushl $0
c0101638:	6a 00                	push   $0x0
  pushl $31
c010163a:	6a 1f                	push   $0x1f
  jmp __alltraps
c010163c:	e9 60 09 00 00       	jmp    c0101fa1 <__alltraps>

c0101641 <vector32>:
.global vector32
vector32:
  pushl $0
c0101641:	6a 00                	push   $0x0
  pushl $32
c0101643:	6a 20                	push   $0x20
  jmp __alltraps
c0101645:	e9 57 09 00 00       	jmp    c0101fa1 <__alltraps>

c010164a <vector33>:
.global vector33
vector33:
  pushl $0
c010164a:	6a 00                	push   $0x0
  pushl $33
c010164c:	6a 21                	push   $0x21
  jmp __alltraps
c010164e:	e9 4e 09 00 00       	jmp    c0101fa1 <__alltraps>

c0101653 <vector34>:
.global vector34
vector34:
  pushl $0
c0101653:	6a 00                	push   $0x0
  pushl $34
c0101655:	6a 22                	push   $0x22
  jmp __alltraps
c0101657:	e9 45 09 00 00       	jmp    c0101fa1 <__alltraps>

c010165c <vector35>:
.global vector35
vector35:
  pushl $0
c010165c:	6a 00                	push   $0x0
  pushl $35
c010165e:	6a 23                	push   $0x23
  jmp __alltraps
c0101660:	e9 3c 09 00 00       	jmp    c0101fa1 <__alltraps>

c0101665 <vector36>:
.global vector36
vector36:
  pushl $0
c0101665:	6a 00                	push   $0x0
  pushl $36
c0101667:	6a 24                	push   $0x24
  jmp __alltraps
c0101669:	e9 33 09 00 00       	jmp    c0101fa1 <__alltraps>

c010166e <vector37>:
.global vector37
vector37:
  pushl $0
c010166e:	6a 00                	push   $0x0
  pushl $37
c0101670:	6a 25                	push   $0x25
  jmp __alltraps
c0101672:	e9 2a 09 00 00       	jmp    c0101fa1 <__alltraps>

c0101677 <vector38>:
.global vector38
vector38:
  pushl $0
c0101677:	6a 00                	push   $0x0
  pushl $38
c0101679:	6a 26                	push   $0x26
  jmp __alltraps
c010167b:	e9 21 09 00 00       	jmp    c0101fa1 <__alltraps>

c0101680 <vector39>:
.global vector39
vector39:
  pushl $0
c0101680:	6a 00                	push   $0x0
  pushl $39
c0101682:	6a 27                	push   $0x27
  jmp __alltraps
c0101684:	e9 18 09 00 00       	jmp    c0101fa1 <__alltraps>

c0101689 <vector40>:
.global vector40
vector40:
  pushl $0
c0101689:	6a 00                	push   $0x0
  pushl $40
c010168b:	6a 28                	push   $0x28
  jmp __alltraps
c010168d:	e9 0f 09 00 00       	jmp    c0101fa1 <__alltraps>

c0101692 <vector41>:
.global vector41
vector41:
  pushl $0
c0101692:	6a 00                	push   $0x0
  pushl $41
c0101694:	6a 29                	push   $0x29
  jmp __alltraps
c0101696:	e9 06 09 00 00       	jmp    c0101fa1 <__alltraps>

c010169b <vector42>:
.global vector42
vector42:
  pushl $0
c010169b:	6a 00                	push   $0x0
  pushl $42
c010169d:	6a 2a                	push   $0x2a
  jmp __alltraps
c010169f:	e9 fd 08 00 00       	jmp    c0101fa1 <__alltraps>

c01016a4 <vector43>:
.global vector43
vector43:
  pushl $0
c01016a4:	6a 00                	push   $0x0
  pushl $43
c01016a6:	6a 2b                	push   $0x2b
  jmp __alltraps
c01016a8:	e9 f4 08 00 00       	jmp    c0101fa1 <__alltraps>

c01016ad <vector44>:
.global vector44
vector44:
  pushl $0
c01016ad:	6a 00                	push   $0x0
  pushl $44
c01016af:	6a 2c                	push   $0x2c
  jmp __alltraps
c01016b1:	e9 eb 08 00 00       	jmp    c0101fa1 <__alltraps>

c01016b6 <vector45>:
.global vector45
vector45:
  pushl $0
c01016b6:	6a 00                	push   $0x0
  pushl $45
c01016b8:	6a 2d                	push   $0x2d
  jmp __alltraps
c01016ba:	e9 e2 08 00 00       	jmp    c0101fa1 <__alltraps>

c01016bf <vector46>:
.global vector46
vector46:
  pushl $0
c01016bf:	6a 00                	push   $0x0
  pushl $46
c01016c1:	6a 2e                	push   $0x2e
  jmp __alltraps
c01016c3:	e9 d9 08 00 00       	jmp    c0101fa1 <__alltraps>

c01016c8 <vector47>:
.global vector47
vector47:
  pushl $0
c01016c8:	6a 00                	push   $0x0
  pushl $47
c01016ca:	6a 2f                	push   $0x2f
  jmp __alltraps
c01016cc:	e9 d0 08 00 00       	jmp    c0101fa1 <__alltraps>

c01016d1 <vector48>:
.global vector48
vector48:
  pushl $0
c01016d1:	6a 00                	push   $0x0
  pushl $48
c01016d3:	6a 30                	push   $0x30
  jmp __alltraps
c01016d5:	e9 c7 08 00 00       	jmp    c0101fa1 <__alltraps>

c01016da <vector49>:
.global vector49
vector49:
  pushl $0
c01016da:	6a 00                	push   $0x0
  pushl $49
c01016dc:	6a 31                	push   $0x31
  jmp __alltraps
c01016de:	e9 be 08 00 00       	jmp    c0101fa1 <__alltraps>

c01016e3 <vector50>:
.global vector50
vector50:
  pushl $0
c01016e3:	6a 00                	push   $0x0
  pushl $50
c01016e5:	6a 32                	push   $0x32
  jmp __alltraps
c01016e7:	e9 b5 08 00 00       	jmp    c0101fa1 <__alltraps>

c01016ec <vector51>:
.global vector51
vector51:
  pushl $0
c01016ec:	6a 00                	push   $0x0
  pushl $51
c01016ee:	6a 33                	push   $0x33
  jmp __alltraps
c01016f0:	e9 ac 08 00 00       	jmp    c0101fa1 <__alltraps>

c01016f5 <vector52>:
.global vector52
vector52:
  pushl $0
c01016f5:	6a 00                	push   $0x0
  pushl $52
c01016f7:	6a 34                	push   $0x34
  jmp __alltraps
c01016f9:	e9 a3 08 00 00       	jmp    c0101fa1 <__alltraps>

c01016fe <vector53>:
.global vector53
vector53:
  pushl $0
c01016fe:	6a 00                	push   $0x0
  pushl $53
c0101700:	6a 35                	push   $0x35
  jmp __alltraps
c0101702:	e9 9a 08 00 00       	jmp    c0101fa1 <__alltraps>

c0101707 <vector54>:
.global vector54
vector54:
  pushl $0
c0101707:	6a 00                	push   $0x0
  pushl $54
c0101709:	6a 36                	push   $0x36
  jmp __alltraps
c010170b:	e9 91 08 00 00       	jmp    c0101fa1 <__alltraps>

c0101710 <vector55>:
.global vector55
vector55:
  pushl $0
c0101710:	6a 00                	push   $0x0
  pushl $55
c0101712:	6a 37                	push   $0x37
  jmp __alltraps
c0101714:	e9 88 08 00 00       	jmp    c0101fa1 <__alltraps>

c0101719 <vector56>:
.global vector56
vector56:
  pushl $0
c0101719:	6a 00                	push   $0x0
  pushl $56
c010171b:	6a 38                	push   $0x38
  jmp __alltraps
c010171d:	e9 7f 08 00 00       	jmp    c0101fa1 <__alltraps>

c0101722 <vector57>:
.global vector57
vector57:
  pushl $0
c0101722:	6a 00                	push   $0x0
  pushl $57
c0101724:	6a 39                	push   $0x39
  jmp __alltraps
c0101726:	e9 76 08 00 00       	jmp    c0101fa1 <__alltraps>

c010172b <vector58>:
.global vector58
vector58:
  pushl $0
c010172b:	6a 00                	push   $0x0
  pushl $58
c010172d:	6a 3a                	push   $0x3a
  jmp __alltraps
c010172f:	e9 6d 08 00 00       	jmp    c0101fa1 <__alltraps>

c0101734 <vector59>:
.global vector59
vector59:
  pushl $0
c0101734:	6a 00                	push   $0x0
  pushl $59
c0101736:	6a 3b                	push   $0x3b
  jmp __alltraps
c0101738:	e9 64 08 00 00       	jmp    c0101fa1 <__alltraps>

c010173d <vector60>:
.global vector60
vector60:
  pushl $0
c010173d:	6a 00                	push   $0x0
  pushl $60
c010173f:	6a 3c                	push   $0x3c
  jmp __alltraps
c0101741:	e9 5b 08 00 00       	jmp    c0101fa1 <__alltraps>

c0101746 <vector61>:
.global vector61
vector61:
  pushl $0
c0101746:	6a 00                	push   $0x0
  pushl $61
c0101748:	6a 3d                	push   $0x3d
  jmp __alltraps
c010174a:	e9 52 08 00 00       	jmp    c0101fa1 <__alltraps>

c010174f <vector62>:
.global vector62
vector62:
  pushl $0
c010174f:	6a 00                	push   $0x0
  pushl $62
c0101751:	6a 3e                	push   $0x3e
  jmp __alltraps
c0101753:	e9 49 08 00 00       	jmp    c0101fa1 <__alltraps>

c0101758 <vector63>:
.global vector63
vector63:
  pushl $0
c0101758:	6a 00                	push   $0x0
  pushl $63
c010175a:	6a 3f                	push   $0x3f
  jmp __alltraps
c010175c:	e9 40 08 00 00       	jmp    c0101fa1 <__alltraps>

c0101761 <vector64>:
.global vector64
vector64:
  pushl $0
c0101761:	6a 00                	push   $0x0
  pushl $64
c0101763:	6a 40                	push   $0x40
  jmp __alltraps
c0101765:	e9 37 08 00 00       	jmp    c0101fa1 <__alltraps>

c010176a <vector65>:
.global vector65
vector65:
  pushl $0
c010176a:	6a 00                	push   $0x0
  pushl $65
c010176c:	6a 41                	push   $0x41
  jmp __alltraps
c010176e:	e9 2e 08 00 00       	jmp    c0101fa1 <__alltraps>

c0101773 <vector66>:
.global vector66
vector66:
  pushl $0
c0101773:	6a 00                	push   $0x0
  pushl $66
c0101775:	6a 42                	push   $0x42
  jmp __alltraps
c0101777:	e9 25 08 00 00       	jmp    c0101fa1 <__alltraps>

c010177c <vector67>:
.global vector67
vector67:
  pushl $0
c010177c:	6a 00                	push   $0x0
  pushl $67
c010177e:	6a 43                	push   $0x43
  jmp __alltraps
c0101780:	e9 1c 08 00 00       	jmp    c0101fa1 <__alltraps>

c0101785 <vector68>:
.global vector68
vector68:
  pushl $0
c0101785:	6a 00                	push   $0x0
  pushl $68
c0101787:	6a 44                	push   $0x44
  jmp __alltraps
c0101789:	e9 13 08 00 00       	jmp    c0101fa1 <__alltraps>

c010178e <vector69>:
.global vector69
vector69:
  pushl $0
c010178e:	6a 00                	push   $0x0
  pushl $69
c0101790:	6a 45                	push   $0x45
  jmp __alltraps
c0101792:	e9 0a 08 00 00       	jmp    c0101fa1 <__alltraps>

c0101797 <vector70>:
.global vector70
vector70:
  pushl $0
c0101797:	6a 00                	push   $0x0
  pushl $70
c0101799:	6a 46                	push   $0x46
  jmp __alltraps
c010179b:	e9 01 08 00 00       	jmp    c0101fa1 <__alltraps>

c01017a0 <vector71>:
.global vector71
vector71:
  pushl $0
c01017a0:	6a 00                	push   $0x0
  pushl $71
c01017a2:	6a 47                	push   $0x47
  jmp __alltraps
c01017a4:	e9 f8 07 00 00       	jmp    c0101fa1 <__alltraps>

c01017a9 <vector72>:
.global vector72
vector72:
  pushl $0
c01017a9:	6a 00                	push   $0x0
  pushl $72
c01017ab:	6a 48                	push   $0x48
  jmp __alltraps
c01017ad:	e9 ef 07 00 00       	jmp    c0101fa1 <__alltraps>

c01017b2 <vector73>:
.global vector73
vector73:
  pushl $0
c01017b2:	6a 00                	push   $0x0
  pushl $73
c01017b4:	6a 49                	push   $0x49
  jmp __alltraps
c01017b6:	e9 e6 07 00 00       	jmp    c0101fa1 <__alltraps>

c01017bb <vector74>:
.global vector74
vector74:
  pushl $0
c01017bb:	6a 00                	push   $0x0
  pushl $74
c01017bd:	6a 4a                	push   $0x4a
  jmp __alltraps
c01017bf:	e9 dd 07 00 00       	jmp    c0101fa1 <__alltraps>

c01017c4 <vector75>:
.global vector75
vector75:
  pushl $0
c01017c4:	6a 00                	push   $0x0
  pushl $75
c01017c6:	6a 4b                	push   $0x4b
  jmp __alltraps
c01017c8:	e9 d4 07 00 00       	jmp    c0101fa1 <__alltraps>

c01017cd <vector76>:
.global vector76
vector76:
  pushl $0
c01017cd:	6a 00                	push   $0x0
  pushl $76
c01017cf:	6a 4c                	push   $0x4c
  jmp __alltraps
c01017d1:	e9 cb 07 00 00       	jmp    c0101fa1 <__alltraps>

c01017d6 <vector77>:
.global vector77
vector77:
  pushl $0
c01017d6:	6a 00                	push   $0x0
  pushl $77
c01017d8:	6a 4d                	push   $0x4d
  jmp __alltraps
c01017da:	e9 c2 07 00 00       	jmp    c0101fa1 <__alltraps>

c01017df <vector78>:
.global vector78
vector78:
  pushl $0
c01017df:	6a 00                	push   $0x0
  pushl $78
c01017e1:	6a 4e                	push   $0x4e
  jmp __alltraps
c01017e3:	e9 b9 07 00 00       	jmp    c0101fa1 <__alltraps>

c01017e8 <vector79>:
.global vector79
vector79:
  pushl $0
c01017e8:	6a 00                	push   $0x0
  pushl $79
c01017ea:	6a 4f                	push   $0x4f
  jmp __alltraps
c01017ec:	e9 b0 07 00 00       	jmp    c0101fa1 <__alltraps>

c01017f1 <vector80>:
.global vector80
vector80:
  pushl $0
c01017f1:	6a 00                	push   $0x0
  pushl $80
c01017f3:	6a 50                	push   $0x50
  jmp __alltraps
c01017f5:	e9 a7 07 00 00       	jmp    c0101fa1 <__alltraps>

c01017fa <vector81>:
.global vector81
vector81:
  pushl $0
c01017fa:	6a 00                	push   $0x0
  pushl $81
c01017fc:	6a 51                	push   $0x51
  jmp __alltraps
c01017fe:	e9 9e 07 00 00       	jmp    c0101fa1 <__alltraps>

c0101803 <vector82>:
.global vector82
vector82:
  pushl $0
c0101803:	6a 00                	push   $0x0
  pushl $82
c0101805:	6a 52                	push   $0x52
  jmp __alltraps
c0101807:	e9 95 07 00 00       	jmp    c0101fa1 <__alltraps>

c010180c <vector83>:
.global vector83
vector83:
  pushl $0
c010180c:	6a 00                	push   $0x0
  pushl $83
c010180e:	6a 53                	push   $0x53
  jmp __alltraps
c0101810:	e9 8c 07 00 00       	jmp    c0101fa1 <__alltraps>

c0101815 <vector84>:
.global vector84
vector84:
  pushl $0
c0101815:	6a 00                	push   $0x0
  pushl $84
c0101817:	6a 54                	push   $0x54
  jmp __alltraps
c0101819:	e9 83 07 00 00       	jmp    c0101fa1 <__alltraps>

c010181e <vector85>:
.global vector85
vector85:
  pushl $0
c010181e:	6a 00                	push   $0x0
  pushl $85
c0101820:	6a 55                	push   $0x55
  jmp __alltraps
c0101822:	e9 7a 07 00 00       	jmp    c0101fa1 <__alltraps>

c0101827 <vector86>:
.global vector86
vector86:
  pushl $0
c0101827:	6a 00                	push   $0x0
  pushl $86
c0101829:	6a 56                	push   $0x56
  jmp __alltraps
c010182b:	e9 71 07 00 00       	jmp    c0101fa1 <__alltraps>

c0101830 <vector87>:
.global vector87
vector87:
  pushl $0
c0101830:	6a 00                	push   $0x0
  pushl $87
c0101832:	6a 57                	push   $0x57
  jmp __alltraps
c0101834:	e9 68 07 00 00       	jmp    c0101fa1 <__alltraps>

c0101839 <vector88>:
.global vector88
vector88:
  pushl $0
c0101839:	6a 00                	push   $0x0
  pushl $88
c010183b:	6a 58                	push   $0x58
  jmp __alltraps
c010183d:	e9 5f 07 00 00       	jmp    c0101fa1 <__alltraps>

c0101842 <vector89>:
.global vector89
vector89:
  pushl $0
c0101842:	6a 00                	push   $0x0
  pushl $89
c0101844:	6a 59                	push   $0x59
  jmp __alltraps
c0101846:	e9 56 07 00 00       	jmp    c0101fa1 <__alltraps>

c010184b <vector90>:
.global vector90
vector90:
  pushl $0
c010184b:	6a 00                	push   $0x0
  pushl $90
c010184d:	6a 5a                	push   $0x5a
  jmp __alltraps
c010184f:	e9 4d 07 00 00       	jmp    c0101fa1 <__alltraps>

c0101854 <vector91>:
.global vector91
vector91:
  pushl $0
c0101854:	6a 00                	push   $0x0
  pushl $91
c0101856:	6a 5b                	push   $0x5b
  jmp __alltraps
c0101858:	e9 44 07 00 00       	jmp    c0101fa1 <__alltraps>

c010185d <vector92>:
.global vector92
vector92:
  pushl $0
c010185d:	6a 00                	push   $0x0
  pushl $92
c010185f:	6a 5c                	push   $0x5c
  jmp __alltraps
c0101861:	e9 3b 07 00 00       	jmp    c0101fa1 <__alltraps>

c0101866 <vector93>:
.global vector93
vector93:
  pushl $0
c0101866:	6a 00                	push   $0x0
  pushl $93
c0101868:	6a 5d                	push   $0x5d
  jmp __alltraps
c010186a:	e9 32 07 00 00       	jmp    c0101fa1 <__alltraps>

c010186f <vector94>:
.global vector94
vector94:
  pushl $0
c010186f:	6a 00                	push   $0x0
  pushl $94
c0101871:	6a 5e                	push   $0x5e
  jmp __alltraps
c0101873:	e9 29 07 00 00       	jmp    c0101fa1 <__alltraps>

c0101878 <vector95>:
.global vector95
vector95:
  pushl $0
c0101878:	6a 00                	push   $0x0
  pushl $95
c010187a:	6a 5f                	push   $0x5f
  jmp __alltraps
c010187c:	e9 20 07 00 00       	jmp    c0101fa1 <__alltraps>

c0101881 <vector96>:
.global vector96
vector96:
  pushl $0
c0101881:	6a 00                	push   $0x0
  pushl $96
c0101883:	6a 60                	push   $0x60
  jmp __alltraps
c0101885:	e9 17 07 00 00       	jmp    c0101fa1 <__alltraps>

c010188a <vector97>:
.global vector97
vector97:
  pushl $0
c010188a:	6a 00                	push   $0x0
  pushl $97
c010188c:	6a 61                	push   $0x61
  jmp __alltraps
c010188e:	e9 0e 07 00 00       	jmp    c0101fa1 <__alltraps>

c0101893 <vector98>:
.global vector98
vector98:
  pushl $0
c0101893:	6a 00                	push   $0x0
  pushl $98
c0101895:	6a 62                	push   $0x62
  jmp __alltraps
c0101897:	e9 05 07 00 00       	jmp    c0101fa1 <__alltraps>

c010189c <vector99>:
.global vector99
vector99:
  pushl $0
c010189c:	6a 00                	push   $0x0
  pushl $99
c010189e:	6a 63                	push   $0x63
  jmp __alltraps
c01018a0:	e9 fc 06 00 00       	jmp    c0101fa1 <__alltraps>

c01018a5 <vector100>:
.global vector100
vector100:
  pushl $0
c01018a5:	6a 00                	push   $0x0
  pushl $100
c01018a7:	6a 64                	push   $0x64
  jmp __alltraps
c01018a9:	e9 f3 06 00 00       	jmp    c0101fa1 <__alltraps>

c01018ae <vector101>:
.global vector101
vector101:
  pushl $0
c01018ae:	6a 00                	push   $0x0
  pushl $101
c01018b0:	6a 65                	push   $0x65
  jmp __alltraps
c01018b2:	e9 ea 06 00 00       	jmp    c0101fa1 <__alltraps>

c01018b7 <vector102>:
.global vector102
vector102:
  pushl $0
c01018b7:	6a 00                	push   $0x0
  pushl $102
c01018b9:	6a 66                	push   $0x66
  jmp __alltraps
c01018bb:	e9 e1 06 00 00       	jmp    c0101fa1 <__alltraps>

c01018c0 <vector103>:
.global vector103
vector103:
  pushl $0
c01018c0:	6a 00                	push   $0x0
  pushl $103
c01018c2:	6a 67                	push   $0x67
  jmp __alltraps
c01018c4:	e9 d8 06 00 00       	jmp    c0101fa1 <__alltraps>

c01018c9 <vector104>:
.global vector104
vector104:
  pushl $0
c01018c9:	6a 00                	push   $0x0
  pushl $104
c01018cb:	6a 68                	push   $0x68
  jmp __alltraps
c01018cd:	e9 cf 06 00 00       	jmp    c0101fa1 <__alltraps>

c01018d2 <vector105>:
.global vector105
vector105:
  pushl $0
c01018d2:	6a 00                	push   $0x0
  pushl $105
c01018d4:	6a 69                	push   $0x69
  jmp __alltraps
c01018d6:	e9 c6 06 00 00       	jmp    c0101fa1 <__alltraps>

c01018db <vector106>:
.global vector106
vector106:
  pushl $0
c01018db:	6a 00                	push   $0x0
  pushl $106
c01018dd:	6a 6a                	push   $0x6a
  jmp __alltraps
c01018df:	e9 bd 06 00 00       	jmp    c0101fa1 <__alltraps>

c01018e4 <vector107>:
.global vector107
vector107:
  pushl $0
c01018e4:	6a 00                	push   $0x0
  pushl $107
c01018e6:	6a 6b                	push   $0x6b
  jmp __alltraps
c01018e8:	e9 b4 06 00 00       	jmp    c0101fa1 <__alltraps>

c01018ed <vector108>:
.global vector108
vector108:
  pushl $0
c01018ed:	6a 00                	push   $0x0
  pushl $108
c01018ef:	6a 6c                	push   $0x6c
  jmp __alltraps
c01018f1:	e9 ab 06 00 00       	jmp    c0101fa1 <__alltraps>

c01018f6 <vector109>:
.global vector109
vector109:
  pushl $0
c01018f6:	6a 00                	push   $0x0
  pushl $109
c01018f8:	6a 6d                	push   $0x6d
  jmp __alltraps
c01018fa:	e9 a2 06 00 00       	jmp    c0101fa1 <__alltraps>

c01018ff <vector110>:
.global vector110
vector110:
  pushl $0
c01018ff:	6a 00                	push   $0x0
  pushl $110
c0101901:	6a 6e                	push   $0x6e
  jmp __alltraps
c0101903:	e9 99 06 00 00       	jmp    c0101fa1 <__alltraps>

c0101908 <vector111>:
.global vector111
vector111:
  pushl $0
c0101908:	6a 00                	push   $0x0
  pushl $111
c010190a:	6a 6f                	push   $0x6f
  jmp __alltraps
c010190c:	e9 90 06 00 00       	jmp    c0101fa1 <__alltraps>

c0101911 <vector112>:
.global vector112
vector112:
  pushl $0
c0101911:	6a 00                	push   $0x0
  pushl $112
c0101913:	6a 70                	push   $0x70
  jmp __alltraps
c0101915:	e9 87 06 00 00       	jmp    c0101fa1 <__alltraps>

c010191a <vector113>:
.global vector113
vector113:
  pushl $0
c010191a:	6a 00                	push   $0x0
  pushl $113
c010191c:	6a 71                	push   $0x71
  jmp __alltraps
c010191e:	e9 7e 06 00 00       	jmp    c0101fa1 <__alltraps>

c0101923 <vector114>:
.global vector114
vector114:
  pushl $0
c0101923:	6a 00                	push   $0x0
  pushl $114
c0101925:	6a 72                	push   $0x72
  jmp __alltraps
c0101927:	e9 75 06 00 00       	jmp    c0101fa1 <__alltraps>

c010192c <vector115>:
.global vector115
vector115:
  pushl $0
c010192c:	6a 00                	push   $0x0
  pushl $115
c010192e:	6a 73                	push   $0x73
  jmp __alltraps
c0101930:	e9 6c 06 00 00       	jmp    c0101fa1 <__alltraps>

c0101935 <vector116>:
.global vector116
vector116:
  pushl $0
c0101935:	6a 00                	push   $0x0
  pushl $116
c0101937:	6a 74                	push   $0x74
  jmp __alltraps
c0101939:	e9 63 06 00 00       	jmp    c0101fa1 <__alltraps>

c010193e <vector117>:
.global vector117
vector117:
  pushl $0
c010193e:	6a 00                	push   $0x0
  pushl $117
c0101940:	6a 75                	push   $0x75
  jmp __alltraps
c0101942:	e9 5a 06 00 00       	jmp    c0101fa1 <__alltraps>

c0101947 <vector118>:
.global vector118
vector118:
  pushl $0
c0101947:	6a 00                	push   $0x0
  pushl $118
c0101949:	6a 76                	push   $0x76
  jmp __alltraps
c010194b:	e9 51 06 00 00       	jmp    c0101fa1 <__alltraps>

c0101950 <vector119>:
.global vector119
vector119:
  pushl $0
c0101950:	6a 00                	push   $0x0
  pushl $119
c0101952:	6a 77                	push   $0x77
  jmp __alltraps
c0101954:	e9 48 06 00 00       	jmp    c0101fa1 <__alltraps>

c0101959 <vector120>:
.global vector120
vector120:
  pushl $0
c0101959:	6a 00                	push   $0x0
  pushl $120
c010195b:	6a 78                	push   $0x78
  jmp __alltraps
c010195d:	e9 3f 06 00 00       	jmp    c0101fa1 <__alltraps>

c0101962 <vector121>:
.global vector121
vector121:
  pushl $0
c0101962:	6a 00                	push   $0x0
  pushl $121
c0101964:	6a 79                	push   $0x79
  jmp __alltraps
c0101966:	e9 36 06 00 00       	jmp    c0101fa1 <__alltraps>

c010196b <vector122>:
.global vector122
vector122:
  pushl $0
c010196b:	6a 00                	push   $0x0
  pushl $122
c010196d:	6a 7a                	push   $0x7a
  jmp __alltraps
c010196f:	e9 2d 06 00 00       	jmp    c0101fa1 <__alltraps>

c0101974 <vector123>:
.global vector123
vector123:
  pushl $0
c0101974:	6a 00                	push   $0x0
  pushl $123
c0101976:	6a 7b                	push   $0x7b
  jmp __alltraps
c0101978:	e9 24 06 00 00       	jmp    c0101fa1 <__alltraps>

c010197d <vector124>:
.global vector124
vector124:
  pushl $0
c010197d:	6a 00                	push   $0x0
  pushl $124
c010197f:	6a 7c                	push   $0x7c
  jmp __alltraps
c0101981:	e9 1b 06 00 00       	jmp    c0101fa1 <__alltraps>

c0101986 <vector125>:
.global vector125
vector125:
  pushl $0
c0101986:	6a 00                	push   $0x0
  pushl $125
c0101988:	6a 7d                	push   $0x7d
  jmp __alltraps
c010198a:	e9 12 06 00 00       	jmp    c0101fa1 <__alltraps>

c010198f <vector126>:
.global vector126
vector126:
  pushl $0
c010198f:	6a 00                	push   $0x0
  pushl $126
c0101991:	6a 7e                	push   $0x7e
  jmp __alltraps
c0101993:	e9 09 06 00 00       	jmp    c0101fa1 <__alltraps>

c0101998 <vector127>:
.global vector127
vector127:
  pushl $0
c0101998:	6a 00                	push   $0x0
  pushl $127
c010199a:	6a 7f                	push   $0x7f
  jmp __alltraps
c010199c:	e9 00 06 00 00       	jmp    c0101fa1 <__alltraps>

c01019a1 <vector128>:
.global vector128
vector128:
  pushl $0
c01019a1:	6a 00                	push   $0x0
  pushl $128
c01019a3:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
c01019a8:	e9 f4 05 00 00       	jmp    c0101fa1 <__alltraps>

c01019ad <vector129>:
.global vector129
vector129:
  pushl $0
c01019ad:	6a 00                	push   $0x0
  pushl $129
c01019af:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
c01019b4:	e9 e8 05 00 00       	jmp    c0101fa1 <__alltraps>

c01019b9 <vector130>:
.global vector130
vector130:
  pushl $0
c01019b9:	6a 00                	push   $0x0
  pushl $130
c01019bb:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
c01019c0:	e9 dc 05 00 00       	jmp    c0101fa1 <__alltraps>

c01019c5 <vector131>:
.global vector131
vector131:
  pushl $0
c01019c5:	6a 00                	push   $0x0
  pushl $131
c01019c7:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
c01019cc:	e9 d0 05 00 00       	jmp    c0101fa1 <__alltraps>

c01019d1 <vector132>:
.global vector132
vector132:
  pushl $0
c01019d1:	6a 00                	push   $0x0
  pushl $132
c01019d3:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
c01019d8:	e9 c4 05 00 00       	jmp    c0101fa1 <__alltraps>

c01019dd <vector133>:
.global vector133
vector133:
  pushl $0
c01019dd:	6a 00                	push   $0x0
  pushl $133
c01019df:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
c01019e4:	e9 b8 05 00 00       	jmp    c0101fa1 <__alltraps>

c01019e9 <vector134>:
.global vector134
vector134:
  pushl $0
c01019e9:	6a 00                	push   $0x0
  pushl $134
c01019eb:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
c01019f0:	e9 ac 05 00 00       	jmp    c0101fa1 <__alltraps>

c01019f5 <vector135>:
.global vector135
vector135:
  pushl $0
c01019f5:	6a 00                	push   $0x0
  pushl $135
c01019f7:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
c01019fc:	e9 a0 05 00 00       	jmp    c0101fa1 <__alltraps>

c0101a01 <vector136>:
.global vector136
vector136:
  pushl $0
c0101a01:	6a 00                	push   $0x0
  pushl $136
c0101a03:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
c0101a08:	e9 94 05 00 00       	jmp    c0101fa1 <__alltraps>

c0101a0d <vector137>:
.global vector137
vector137:
  pushl $0
c0101a0d:	6a 00                	push   $0x0
  pushl $137
c0101a0f:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
c0101a14:	e9 88 05 00 00       	jmp    c0101fa1 <__alltraps>

c0101a19 <vector138>:
.global vector138
vector138:
  pushl $0
c0101a19:	6a 00                	push   $0x0
  pushl $138
c0101a1b:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
c0101a20:	e9 7c 05 00 00       	jmp    c0101fa1 <__alltraps>

c0101a25 <vector139>:
.global vector139
vector139:
  pushl $0
c0101a25:	6a 00                	push   $0x0
  pushl $139
c0101a27:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
c0101a2c:	e9 70 05 00 00       	jmp    c0101fa1 <__alltraps>

c0101a31 <vector140>:
.global vector140
vector140:
  pushl $0
c0101a31:	6a 00                	push   $0x0
  pushl $140
c0101a33:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
c0101a38:	e9 64 05 00 00       	jmp    c0101fa1 <__alltraps>

c0101a3d <vector141>:
.global vector141
vector141:
  pushl $0
c0101a3d:	6a 00                	push   $0x0
  pushl $141
c0101a3f:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
c0101a44:	e9 58 05 00 00       	jmp    c0101fa1 <__alltraps>

c0101a49 <vector142>:
.global vector142
vector142:
  pushl $0
c0101a49:	6a 00                	push   $0x0
  pushl $142
c0101a4b:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
c0101a50:	e9 4c 05 00 00       	jmp    c0101fa1 <__alltraps>

c0101a55 <vector143>:
.global vector143
vector143:
  pushl $0
c0101a55:	6a 00                	push   $0x0
  pushl $143
c0101a57:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
c0101a5c:	e9 40 05 00 00       	jmp    c0101fa1 <__alltraps>

c0101a61 <vector144>:
.global vector144
vector144:
  pushl $0
c0101a61:	6a 00                	push   $0x0
  pushl $144
c0101a63:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
c0101a68:	e9 34 05 00 00       	jmp    c0101fa1 <__alltraps>

c0101a6d <vector145>:
.global vector145
vector145:
  pushl $0
c0101a6d:	6a 00                	push   $0x0
  pushl $145
c0101a6f:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
c0101a74:	e9 28 05 00 00       	jmp    c0101fa1 <__alltraps>

c0101a79 <vector146>:
.global vector146
vector146:
  pushl $0
c0101a79:	6a 00                	push   $0x0
  pushl $146
c0101a7b:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
c0101a80:	e9 1c 05 00 00       	jmp    c0101fa1 <__alltraps>

c0101a85 <vector147>:
.global vector147
vector147:
  pushl $0
c0101a85:	6a 00                	push   $0x0
  pushl $147
c0101a87:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
c0101a8c:	e9 10 05 00 00       	jmp    c0101fa1 <__alltraps>

c0101a91 <vector148>:
.global vector148
vector148:
  pushl $0
c0101a91:	6a 00                	push   $0x0
  pushl $148
c0101a93:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
c0101a98:	e9 04 05 00 00       	jmp    c0101fa1 <__alltraps>

c0101a9d <vector149>:
.global vector149
vector149:
  pushl $0
c0101a9d:	6a 00                	push   $0x0
  pushl $149
c0101a9f:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
c0101aa4:	e9 f8 04 00 00       	jmp    c0101fa1 <__alltraps>

c0101aa9 <vector150>:
.global vector150
vector150:
  pushl $0
c0101aa9:	6a 00                	push   $0x0
  pushl $150
c0101aab:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
c0101ab0:	e9 ec 04 00 00       	jmp    c0101fa1 <__alltraps>

c0101ab5 <vector151>:
.global vector151
vector151:
  pushl $0
c0101ab5:	6a 00                	push   $0x0
  pushl $151
c0101ab7:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
c0101abc:	e9 e0 04 00 00       	jmp    c0101fa1 <__alltraps>

c0101ac1 <vector152>:
.global vector152
vector152:
  pushl $0
c0101ac1:	6a 00                	push   $0x0
  pushl $152
c0101ac3:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
c0101ac8:	e9 d4 04 00 00       	jmp    c0101fa1 <__alltraps>

c0101acd <vector153>:
.global vector153
vector153:
  pushl $0
c0101acd:	6a 00                	push   $0x0
  pushl $153
c0101acf:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
c0101ad4:	e9 c8 04 00 00       	jmp    c0101fa1 <__alltraps>

c0101ad9 <vector154>:
.global vector154
vector154:
  pushl $0
c0101ad9:	6a 00                	push   $0x0
  pushl $154
c0101adb:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
c0101ae0:	e9 bc 04 00 00       	jmp    c0101fa1 <__alltraps>

c0101ae5 <vector155>:
.global vector155
vector155:
  pushl $0
c0101ae5:	6a 00                	push   $0x0
  pushl $155
c0101ae7:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
c0101aec:	e9 b0 04 00 00       	jmp    c0101fa1 <__alltraps>

c0101af1 <vector156>:
.global vector156
vector156:
  pushl $0
c0101af1:	6a 00                	push   $0x0
  pushl $156
c0101af3:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
c0101af8:	e9 a4 04 00 00       	jmp    c0101fa1 <__alltraps>

c0101afd <vector157>:
.global vector157
vector157:
  pushl $0
c0101afd:	6a 00                	push   $0x0
  pushl $157
c0101aff:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
c0101b04:	e9 98 04 00 00       	jmp    c0101fa1 <__alltraps>

c0101b09 <vector158>:
.global vector158
vector158:
  pushl $0
c0101b09:	6a 00                	push   $0x0
  pushl $158
c0101b0b:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
c0101b10:	e9 8c 04 00 00       	jmp    c0101fa1 <__alltraps>

c0101b15 <vector159>:
.global vector159
vector159:
  pushl $0
c0101b15:	6a 00                	push   $0x0
  pushl $159
c0101b17:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
c0101b1c:	e9 80 04 00 00       	jmp    c0101fa1 <__alltraps>

c0101b21 <vector160>:
.global vector160
vector160:
  pushl $0
c0101b21:	6a 00                	push   $0x0
  pushl $160
c0101b23:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
c0101b28:	e9 74 04 00 00       	jmp    c0101fa1 <__alltraps>

c0101b2d <vector161>:
.global vector161
vector161:
  pushl $0
c0101b2d:	6a 00                	push   $0x0
  pushl $161
c0101b2f:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
c0101b34:	e9 68 04 00 00       	jmp    c0101fa1 <__alltraps>

c0101b39 <vector162>:
.global vector162
vector162:
  pushl $0
c0101b39:	6a 00                	push   $0x0
  pushl $162
c0101b3b:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
c0101b40:	e9 5c 04 00 00       	jmp    c0101fa1 <__alltraps>

c0101b45 <vector163>:
.global vector163
vector163:
  pushl $0
c0101b45:	6a 00                	push   $0x0
  pushl $163
c0101b47:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
c0101b4c:	e9 50 04 00 00       	jmp    c0101fa1 <__alltraps>

c0101b51 <vector164>:
.global vector164
vector164:
  pushl $0
c0101b51:	6a 00                	push   $0x0
  pushl $164
c0101b53:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
c0101b58:	e9 44 04 00 00       	jmp    c0101fa1 <__alltraps>

c0101b5d <vector165>:
.global vector165
vector165:
  pushl $0
c0101b5d:	6a 00                	push   $0x0
  pushl $165
c0101b5f:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
c0101b64:	e9 38 04 00 00       	jmp    c0101fa1 <__alltraps>

c0101b69 <vector166>:
.global vector166
vector166:
  pushl $0
c0101b69:	6a 00                	push   $0x0
  pushl $166
c0101b6b:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
c0101b70:	e9 2c 04 00 00       	jmp    c0101fa1 <__alltraps>

c0101b75 <vector167>:
.global vector167
vector167:
  pushl $0
c0101b75:	6a 00                	push   $0x0
  pushl $167
c0101b77:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
c0101b7c:	e9 20 04 00 00       	jmp    c0101fa1 <__alltraps>

c0101b81 <vector168>:
.global vector168
vector168:
  pushl $0
c0101b81:	6a 00                	push   $0x0
  pushl $168
c0101b83:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
c0101b88:	e9 14 04 00 00       	jmp    c0101fa1 <__alltraps>

c0101b8d <vector169>:
.global vector169
vector169:
  pushl $0
c0101b8d:	6a 00                	push   $0x0
  pushl $169
c0101b8f:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
c0101b94:	e9 08 04 00 00       	jmp    c0101fa1 <__alltraps>

c0101b99 <vector170>:
.global vector170
vector170:
  pushl $0
c0101b99:	6a 00                	push   $0x0
  pushl $170
c0101b9b:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
c0101ba0:	e9 fc 03 00 00       	jmp    c0101fa1 <__alltraps>

c0101ba5 <vector171>:
.global vector171
vector171:
  pushl $0
c0101ba5:	6a 00                	push   $0x0
  pushl $171
c0101ba7:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
c0101bac:	e9 f0 03 00 00       	jmp    c0101fa1 <__alltraps>

c0101bb1 <vector172>:
.global vector172
vector172:
  pushl $0
c0101bb1:	6a 00                	push   $0x0
  pushl $172
c0101bb3:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
c0101bb8:	e9 e4 03 00 00       	jmp    c0101fa1 <__alltraps>

c0101bbd <vector173>:
.global vector173
vector173:
  pushl $0
c0101bbd:	6a 00                	push   $0x0
  pushl $173
c0101bbf:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
c0101bc4:	e9 d8 03 00 00       	jmp    c0101fa1 <__alltraps>

c0101bc9 <vector174>:
.global vector174
vector174:
  pushl $0
c0101bc9:	6a 00                	push   $0x0
  pushl $174
c0101bcb:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
c0101bd0:	e9 cc 03 00 00       	jmp    c0101fa1 <__alltraps>

c0101bd5 <vector175>:
.global vector175
vector175:
  pushl $0
c0101bd5:	6a 00                	push   $0x0
  pushl $175
c0101bd7:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
c0101bdc:	e9 c0 03 00 00       	jmp    c0101fa1 <__alltraps>

c0101be1 <vector176>:
.global vector176
vector176:
  pushl $0
c0101be1:	6a 00                	push   $0x0
  pushl $176
c0101be3:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
c0101be8:	e9 b4 03 00 00       	jmp    c0101fa1 <__alltraps>

c0101bed <vector177>:
.global vector177
vector177:
  pushl $0
c0101bed:	6a 00                	push   $0x0
  pushl $177
c0101bef:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
c0101bf4:	e9 a8 03 00 00       	jmp    c0101fa1 <__alltraps>

c0101bf9 <vector178>:
.global vector178
vector178:
  pushl $0
c0101bf9:	6a 00                	push   $0x0
  pushl $178
c0101bfb:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
c0101c00:	e9 9c 03 00 00       	jmp    c0101fa1 <__alltraps>

c0101c05 <vector179>:
.global vector179
vector179:
  pushl $0
c0101c05:	6a 00                	push   $0x0
  pushl $179
c0101c07:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
c0101c0c:	e9 90 03 00 00       	jmp    c0101fa1 <__alltraps>

c0101c11 <vector180>:
.global vector180
vector180:
  pushl $0
c0101c11:	6a 00                	push   $0x0
  pushl $180
c0101c13:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
c0101c18:	e9 84 03 00 00       	jmp    c0101fa1 <__alltraps>

c0101c1d <vector181>:
.global vector181
vector181:
  pushl $0
c0101c1d:	6a 00                	push   $0x0
  pushl $181
c0101c1f:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
c0101c24:	e9 78 03 00 00       	jmp    c0101fa1 <__alltraps>

c0101c29 <vector182>:
.global vector182
vector182:
  pushl $0
c0101c29:	6a 00                	push   $0x0
  pushl $182
c0101c2b:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
c0101c30:	e9 6c 03 00 00       	jmp    c0101fa1 <__alltraps>

c0101c35 <vector183>:
.global vector183
vector183:
  pushl $0
c0101c35:	6a 00                	push   $0x0
  pushl $183
c0101c37:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
c0101c3c:	e9 60 03 00 00       	jmp    c0101fa1 <__alltraps>

c0101c41 <vector184>:
.global vector184
vector184:
  pushl $0
c0101c41:	6a 00                	push   $0x0
  pushl $184
c0101c43:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
c0101c48:	e9 54 03 00 00       	jmp    c0101fa1 <__alltraps>

c0101c4d <vector185>:
.global vector185
vector185:
  pushl $0
c0101c4d:	6a 00                	push   $0x0
  pushl $185
c0101c4f:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
c0101c54:	e9 48 03 00 00       	jmp    c0101fa1 <__alltraps>

c0101c59 <vector186>:
.global vector186
vector186:
  pushl $0
c0101c59:	6a 00                	push   $0x0
  pushl $186
c0101c5b:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
c0101c60:	e9 3c 03 00 00       	jmp    c0101fa1 <__alltraps>

c0101c65 <vector187>:
.global vector187
vector187:
  pushl $0
c0101c65:	6a 00                	push   $0x0
  pushl $187
c0101c67:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
c0101c6c:	e9 30 03 00 00       	jmp    c0101fa1 <__alltraps>

c0101c71 <vector188>:
.global vector188
vector188:
  pushl $0
c0101c71:	6a 00                	push   $0x0
  pushl $188
c0101c73:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
c0101c78:	e9 24 03 00 00       	jmp    c0101fa1 <__alltraps>

c0101c7d <vector189>:
.global vector189
vector189:
  pushl $0
c0101c7d:	6a 00                	push   $0x0
  pushl $189
c0101c7f:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
c0101c84:	e9 18 03 00 00       	jmp    c0101fa1 <__alltraps>

c0101c89 <vector190>:
.global vector190
vector190:
  pushl $0
c0101c89:	6a 00                	push   $0x0
  pushl $190
c0101c8b:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
c0101c90:	e9 0c 03 00 00       	jmp    c0101fa1 <__alltraps>

c0101c95 <vector191>:
.global vector191
vector191:
  pushl $0
c0101c95:	6a 00                	push   $0x0
  pushl $191
c0101c97:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
c0101c9c:	e9 00 03 00 00       	jmp    c0101fa1 <__alltraps>

c0101ca1 <vector192>:
.global vector192
vector192:
  pushl $0
c0101ca1:	6a 00                	push   $0x0
  pushl $192
c0101ca3:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
c0101ca8:	e9 f4 02 00 00       	jmp    c0101fa1 <__alltraps>

c0101cad <vector193>:
.global vector193
vector193:
  pushl $0
c0101cad:	6a 00                	push   $0x0
  pushl $193
c0101caf:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
c0101cb4:	e9 e8 02 00 00       	jmp    c0101fa1 <__alltraps>

c0101cb9 <vector194>:
.global vector194
vector194:
  pushl $0
c0101cb9:	6a 00                	push   $0x0
  pushl $194
c0101cbb:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
c0101cc0:	e9 dc 02 00 00       	jmp    c0101fa1 <__alltraps>

c0101cc5 <vector195>:
.global vector195
vector195:
  pushl $0
c0101cc5:	6a 00                	push   $0x0
  pushl $195
c0101cc7:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
c0101ccc:	e9 d0 02 00 00       	jmp    c0101fa1 <__alltraps>

c0101cd1 <vector196>:
.global vector196
vector196:
  pushl $0
c0101cd1:	6a 00                	push   $0x0
  pushl $196
c0101cd3:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
c0101cd8:	e9 c4 02 00 00       	jmp    c0101fa1 <__alltraps>

c0101cdd <vector197>:
.global vector197
vector197:
  pushl $0
c0101cdd:	6a 00                	push   $0x0
  pushl $197
c0101cdf:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
c0101ce4:	e9 b8 02 00 00       	jmp    c0101fa1 <__alltraps>

c0101ce9 <vector198>:
.global vector198
vector198:
  pushl $0
c0101ce9:	6a 00                	push   $0x0
  pushl $198
c0101ceb:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
c0101cf0:	e9 ac 02 00 00       	jmp    c0101fa1 <__alltraps>

c0101cf5 <vector199>:
.global vector199
vector199:
  pushl $0
c0101cf5:	6a 00                	push   $0x0
  pushl $199
c0101cf7:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
c0101cfc:	e9 a0 02 00 00       	jmp    c0101fa1 <__alltraps>

c0101d01 <vector200>:
.global vector200
vector200:
  pushl $0
c0101d01:	6a 00                	push   $0x0
  pushl $200
c0101d03:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
c0101d08:	e9 94 02 00 00       	jmp    c0101fa1 <__alltraps>

c0101d0d <vector201>:
.global vector201
vector201:
  pushl $0
c0101d0d:	6a 00                	push   $0x0
  pushl $201
c0101d0f:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
c0101d14:	e9 88 02 00 00       	jmp    c0101fa1 <__alltraps>

c0101d19 <vector202>:
.global vector202
vector202:
  pushl $0
c0101d19:	6a 00                	push   $0x0
  pushl $202
c0101d1b:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
c0101d20:	e9 7c 02 00 00       	jmp    c0101fa1 <__alltraps>

c0101d25 <vector203>:
.global vector203
vector203:
  pushl $0
c0101d25:	6a 00                	push   $0x0
  pushl $203
c0101d27:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
c0101d2c:	e9 70 02 00 00       	jmp    c0101fa1 <__alltraps>

c0101d31 <vector204>:
.global vector204
vector204:
  pushl $0
c0101d31:	6a 00                	push   $0x0
  pushl $204
c0101d33:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
c0101d38:	e9 64 02 00 00       	jmp    c0101fa1 <__alltraps>

c0101d3d <vector205>:
.global vector205
vector205:
  pushl $0
c0101d3d:	6a 00                	push   $0x0
  pushl $205
c0101d3f:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
c0101d44:	e9 58 02 00 00       	jmp    c0101fa1 <__alltraps>

c0101d49 <vector206>:
.global vector206
vector206:
  pushl $0
c0101d49:	6a 00                	push   $0x0
  pushl $206
c0101d4b:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
c0101d50:	e9 4c 02 00 00       	jmp    c0101fa1 <__alltraps>

c0101d55 <vector207>:
.global vector207
vector207:
  pushl $0
c0101d55:	6a 00                	push   $0x0
  pushl $207
c0101d57:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
c0101d5c:	e9 40 02 00 00       	jmp    c0101fa1 <__alltraps>

c0101d61 <vector208>:
.global vector208
vector208:
  pushl $0
c0101d61:	6a 00                	push   $0x0
  pushl $208
c0101d63:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
c0101d68:	e9 34 02 00 00       	jmp    c0101fa1 <__alltraps>

c0101d6d <vector209>:
.global vector209
vector209:
  pushl $0
c0101d6d:	6a 00                	push   $0x0
  pushl $209
c0101d6f:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
c0101d74:	e9 28 02 00 00       	jmp    c0101fa1 <__alltraps>

c0101d79 <vector210>:
.global vector210
vector210:
  pushl $0
c0101d79:	6a 00                	push   $0x0
  pushl $210
c0101d7b:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
c0101d80:	e9 1c 02 00 00       	jmp    c0101fa1 <__alltraps>

c0101d85 <vector211>:
.global vector211
vector211:
  pushl $0
c0101d85:	6a 00                	push   $0x0
  pushl $211
c0101d87:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
c0101d8c:	e9 10 02 00 00       	jmp    c0101fa1 <__alltraps>

c0101d91 <vector212>:
.global vector212
vector212:
  pushl $0
c0101d91:	6a 00                	push   $0x0
  pushl $212
c0101d93:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
c0101d98:	e9 04 02 00 00       	jmp    c0101fa1 <__alltraps>

c0101d9d <vector213>:
.global vector213
vector213:
  pushl $0
c0101d9d:	6a 00                	push   $0x0
  pushl $213
c0101d9f:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
c0101da4:	e9 f8 01 00 00       	jmp    c0101fa1 <__alltraps>

c0101da9 <vector214>:
.global vector214
vector214:
  pushl $0
c0101da9:	6a 00                	push   $0x0
  pushl $214
c0101dab:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
c0101db0:	e9 ec 01 00 00       	jmp    c0101fa1 <__alltraps>

c0101db5 <vector215>:
.global vector215
vector215:
  pushl $0
c0101db5:	6a 00                	push   $0x0
  pushl $215
c0101db7:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
c0101dbc:	e9 e0 01 00 00       	jmp    c0101fa1 <__alltraps>

c0101dc1 <vector216>:
.global vector216
vector216:
  pushl $0
c0101dc1:	6a 00                	push   $0x0
  pushl $216
c0101dc3:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
c0101dc8:	e9 d4 01 00 00       	jmp    c0101fa1 <__alltraps>

c0101dcd <vector217>:
.global vector217
vector217:
  pushl $0
c0101dcd:	6a 00                	push   $0x0
  pushl $217
c0101dcf:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
c0101dd4:	e9 c8 01 00 00       	jmp    c0101fa1 <__alltraps>

c0101dd9 <vector218>:
.global vector218
vector218:
  pushl $0
c0101dd9:	6a 00                	push   $0x0
  pushl $218
c0101ddb:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
c0101de0:	e9 bc 01 00 00       	jmp    c0101fa1 <__alltraps>

c0101de5 <vector219>:
.global vector219
vector219:
  pushl $0
c0101de5:	6a 00                	push   $0x0
  pushl $219
c0101de7:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
c0101dec:	e9 b0 01 00 00       	jmp    c0101fa1 <__alltraps>

c0101df1 <vector220>:
.global vector220
vector220:
  pushl $0
c0101df1:	6a 00                	push   $0x0
  pushl $220
c0101df3:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
c0101df8:	e9 a4 01 00 00       	jmp    c0101fa1 <__alltraps>

c0101dfd <vector221>:
.global vector221
vector221:
  pushl $0
c0101dfd:	6a 00                	push   $0x0
  pushl $221
c0101dff:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
c0101e04:	e9 98 01 00 00       	jmp    c0101fa1 <__alltraps>

c0101e09 <vector222>:
.global vector222
vector222:
  pushl $0
c0101e09:	6a 00                	push   $0x0
  pushl $222
c0101e0b:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
c0101e10:	e9 8c 01 00 00       	jmp    c0101fa1 <__alltraps>

c0101e15 <vector223>:
.global vector223
vector223:
  pushl $0
c0101e15:	6a 00                	push   $0x0
  pushl $223
c0101e17:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
c0101e1c:	e9 80 01 00 00       	jmp    c0101fa1 <__alltraps>

c0101e21 <vector224>:
.global vector224
vector224:
  pushl $0
c0101e21:	6a 00                	push   $0x0
  pushl $224
c0101e23:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
c0101e28:	e9 74 01 00 00       	jmp    c0101fa1 <__alltraps>

c0101e2d <vector225>:
.global vector225
vector225:
  pushl $0
c0101e2d:	6a 00                	push   $0x0
  pushl $225
c0101e2f:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
c0101e34:	e9 68 01 00 00       	jmp    c0101fa1 <__alltraps>

c0101e39 <vector226>:
.global vector226
vector226:
  pushl $0
c0101e39:	6a 00                	push   $0x0
  pushl $226
c0101e3b:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
c0101e40:	e9 5c 01 00 00       	jmp    c0101fa1 <__alltraps>

c0101e45 <vector227>:
.global vector227
vector227:
  pushl $0
c0101e45:	6a 00                	push   $0x0
  pushl $227
c0101e47:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
c0101e4c:	e9 50 01 00 00       	jmp    c0101fa1 <__alltraps>

c0101e51 <vector228>:
.global vector228
vector228:
  pushl $0
c0101e51:	6a 00                	push   $0x0
  pushl $228
c0101e53:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
c0101e58:	e9 44 01 00 00       	jmp    c0101fa1 <__alltraps>

c0101e5d <vector229>:
.global vector229
vector229:
  pushl $0
c0101e5d:	6a 00                	push   $0x0
  pushl $229
c0101e5f:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
c0101e64:	e9 38 01 00 00       	jmp    c0101fa1 <__alltraps>

c0101e69 <vector230>:
.global vector230
vector230:
  pushl $0
c0101e69:	6a 00                	push   $0x0
  pushl $230
c0101e6b:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
c0101e70:	e9 2c 01 00 00       	jmp    c0101fa1 <__alltraps>

c0101e75 <vector231>:
.global vector231
vector231:
  pushl $0
c0101e75:	6a 00                	push   $0x0
  pushl $231
c0101e77:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
c0101e7c:	e9 20 01 00 00       	jmp    c0101fa1 <__alltraps>

c0101e81 <vector232>:
.global vector232
vector232:
  pushl $0
c0101e81:	6a 00                	push   $0x0
  pushl $232
c0101e83:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
c0101e88:	e9 14 01 00 00       	jmp    c0101fa1 <__alltraps>

c0101e8d <vector233>:
.global vector233
vector233:
  pushl $0
c0101e8d:	6a 00                	push   $0x0
  pushl $233
c0101e8f:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
c0101e94:	e9 08 01 00 00       	jmp    c0101fa1 <__alltraps>

c0101e99 <vector234>:
.global vector234
vector234:
  pushl $0
c0101e99:	6a 00                	push   $0x0
  pushl $234
c0101e9b:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
c0101ea0:	e9 fc 00 00 00       	jmp    c0101fa1 <__alltraps>

c0101ea5 <vector235>:
.global vector235
vector235:
  pushl $0
c0101ea5:	6a 00                	push   $0x0
  pushl $235
c0101ea7:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
c0101eac:	e9 f0 00 00 00       	jmp    c0101fa1 <__alltraps>

c0101eb1 <vector236>:
.global vector236
vector236:
  pushl $0
c0101eb1:	6a 00                	push   $0x0
  pushl $236
c0101eb3:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
c0101eb8:	e9 e4 00 00 00       	jmp    c0101fa1 <__alltraps>

c0101ebd <vector237>:
.global vector237
vector237:
  pushl $0
c0101ebd:	6a 00                	push   $0x0
  pushl $237
c0101ebf:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
c0101ec4:	e9 d8 00 00 00       	jmp    c0101fa1 <__alltraps>

c0101ec9 <vector238>:
.global vector238
vector238:
  pushl $0
c0101ec9:	6a 00                	push   $0x0
  pushl $238
c0101ecb:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
c0101ed0:	e9 cc 00 00 00       	jmp    c0101fa1 <__alltraps>

c0101ed5 <vector239>:
.global vector239
vector239:
  pushl $0
c0101ed5:	6a 00                	push   $0x0
  pushl $239
c0101ed7:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
c0101edc:	e9 c0 00 00 00       	jmp    c0101fa1 <__alltraps>

c0101ee1 <vector240>:
.global vector240
vector240:
  pushl $0
c0101ee1:	6a 00                	push   $0x0
  pushl $240
c0101ee3:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
c0101ee8:	e9 b4 00 00 00       	jmp    c0101fa1 <__alltraps>

c0101eed <vector241>:
.global vector241
vector241:
  pushl $0
c0101eed:	6a 00                	push   $0x0
  pushl $241
c0101eef:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
c0101ef4:	e9 a8 00 00 00       	jmp    c0101fa1 <__alltraps>

c0101ef9 <vector242>:
.global vector242
vector242:
  pushl $0
c0101ef9:	6a 00                	push   $0x0
  pushl $242
c0101efb:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
c0101f00:	e9 9c 00 00 00       	jmp    c0101fa1 <__alltraps>

c0101f05 <vector243>:
.global vector243
vector243:
  pushl $0
c0101f05:	6a 00                	push   $0x0
  pushl $243
c0101f07:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
c0101f0c:	e9 90 00 00 00       	jmp    c0101fa1 <__alltraps>

c0101f11 <vector244>:
.global vector244
vector244:
  pushl $0
c0101f11:	6a 00                	push   $0x0
  pushl $244
c0101f13:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
c0101f18:	e9 84 00 00 00       	jmp    c0101fa1 <__alltraps>

c0101f1d <vector245>:
.global vector245
vector245:
  pushl $0
c0101f1d:	6a 00                	push   $0x0
  pushl $245
c0101f1f:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
c0101f24:	e9 78 00 00 00       	jmp    c0101fa1 <__alltraps>

c0101f29 <vector246>:
.global vector246
vector246:
  pushl $0
c0101f29:	6a 00                	push   $0x0
  pushl $246
c0101f2b:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
c0101f30:	e9 6c 00 00 00       	jmp    c0101fa1 <__alltraps>

c0101f35 <vector247>:
.global vector247
vector247:
  pushl $0
c0101f35:	6a 00                	push   $0x0
  pushl $247
c0101f37:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
c0101f3c:	e9 60 00 00 00       	jmp    c0101fa1 <__alltraps>

c0101f41 <vector248>:
.global vector248
vector248:
  pushl $0
c0101f41:	6a 00                	push   $0x0
  pushl $248
c0101f43:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
c0101f48:	e9 54 00 00 00       	jmp    c0101fa1 <__alltraps>

c0101f4d <vector249>:
.global vector249
vector249:
  pushl $0
c0101f4d:	6a 00                	push   $0x0
  pushl $249
c0101f4f:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
c0101f54:	e9 48 00 00 00       	jmp    c0101fa1 <__alltraps>

c0101f59 <vector250>:
.global vector250
vector250:
  pushl $0
c0101f59:	6a 00                	push   $0x0
  pushl $250
c0101f5b:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
c0101f60:	e9 3c 00 00 00       	jmp    c0101fa1 <__alltraps>

c0101f65 <vector251>:
.global vector251
vector251:
  pushl $0
c0101f65:	6a 00                	push   $0x0
  pushl $251
c0101f67:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
c0101f6c:	e9 30 00 00 00       	jmp    c0101fa1 <__alltraps>

c0101f71 <vector252>:
.global vector252
vector252:
  pushl $0
c0101f71:	6a 00                	push   $0x0
  pushl $252
c0101f73:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
c0101f78:	e9 24 00 00 00       	jmp    c0101fa1 <__alltraps>

c0101f7d <vector253>:
.global vector253
vector253:
  pushl $0
c0101f7d:	6a 00                	push   $0x0
  pushl $253
c0101f7f:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
c0101f84:	e9 18 00 00 00       	jmp    c0101fa1 <__alltraps>

c0101f89 <vector254>:
.global vector254
vector254:
  pushl $0
c0101f89:	6a 00                	push   $0x0
  pushl $254
c0101f8b:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
c0101f90:	e9 0c 00 00 00       	jmp    c0101fa1 <__alltraps>

c0101f95 <vector255>:
.global vector255
vector255:
  pushl $0
c0101f95:	6a 00                	push   $0x0
  pushl $255
c0101f97:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
c0101f9c:	e9 00 00 00 00       	jmp    c0101fa1 <__alltraps>

c0101fa1 <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
c0101fa1:	1e                   	push   %ds
    pushl %es
c0101fa2:	06                   	push   %es
    pushal
c0101fa3:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
c0101fa4:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
c0101fa9:	8e d8                	mov    %eax,%ds
    movw %ax, %es
c0101fab:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
c0101fad:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call trap
c0101fae:	e8 57 f5 ff ff       	call   c010150a <trap>

    # pop the pushed stack pointer
    popl %esp
c0101fb3:	5c                   	pop    %esp

c0101fb4 <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
c0101fb4:	61                   	popa   

    # restore %ds and %es
    popl %es
c0101fb5:	07                   	pop    %es
    popl %ds
c0101fb6:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
c0101fb7:	83 c4 08             	add    $0x8,%esp
    iret
c0101fba:	cf                   	iret   

c0101fbb <get_bootinfo>:
#include <monitor.h>
#include <memlayout.h>

const struct BOOTINFO *binfo = (struct BOOTINFO *) (ADR_BOOTINFO);

struct BOOTINFO* get_bootinfo() {
c0101fbb:	55                   	push   %ebp
c0101fbc:	89 e5                	mov    %esp,%ebp
	return binfo;
c0101fbe:	a1 e0 48 11 c0       	mov    0xc01148e0,%eax
}
c0101fc3:	5d                   	pop    %ebp
c0101fc4:	c3                   	ret    

c0101fc5 <is_pixel_valid>:

static BOOL is_pixel_valid(int32_t x, int32_t y)
{
c0101fc5:	55                   	push   %ebp
c0101fc6:	89 e5                	mov    %esp,%ebp
	if(x<0 || y<0 || (uint32_t)x >= binfo->scrnx || (uint32_t)y >= binfo->scrny)
c0101fc8:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0101fcc:	78 2c                	js     c0101ffa <is_pixel_valid+0x35>
c0101fce:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0101fd2:	78 26                	js     c0101ffa <is_pixel_valid+0x35>
c0101fd4:	a1 e0 48 11 c0       	mov    0xc01148e0,%eax
c0101fd9:	0f b7 40 04          	movzwl 0x4(%eax),%eax
c0101fdd:	0f b7 d0             	movzwl %ax,%edx
c0101fe0:	8b 45 08             	mov    0x8(%ebp),%eax
c0101fe3:	39 c2                	cmp    %eax,%edx
c0101fe5:	76 13                	jbe    c0101ffa <is_pixel_valid+0x35>
c0101fe7:	a1 e0 48 11 c0       	mov    0xc01148e0,%eax
c0101fec:	0f b7 40 06          	movzwl 0x6(%eax),%eax
c0101ff0:	0f b7 d0             	movzwl %ax,%edx
c0101ff3:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101ff6:	39 c2                	cmp    %eax,%edx
c0101ff8:	77 07                	ja     c0102001 <is_pixel_valid+0x3c>
		return FALSE;
c0101ffa:	b8 00 00 00 00       	mov    $0x0,%eax
c0101fff:	eb 05                	jmp    c0102006 <is_pixel_valid+0x41>
	return TRUE;
c0102001:	b8 01 00 00 00       	mov    $0x1,%eax
}
c0102006:	5d                   	pop    %ebp
c0102007:	c3                   	ret    

c0102008 <setpixel>:

inline BOOL setpixel(int32_t x, int32_t y, rgb_t c)
{
c0102008:	55                   	push   %ebp
c0102009:	89 e5                	mov    %esp,%ebp
c010200b:	83 ec 10             	sub    $0x10,%esp
//	if(!is_pixel_valid(x, y))
//		return FALSE;
	int nBppixel = binfo->bitspixel>>3;
c010200e:	a1 e0 48 11 c0       	mov    0xc01148e0,%eax
c0102013:	0f b6 40 08          	movzbl 0x8(%eax),%eax
c0102017:	c0 e8 03             	shr    $0x3,%al
c010201a:	0f b6 c0             	movzbl %al,%eax
c010201d:	89 45 fc             	mov    %eax,-0x4(%ebp)
	uint8_t * pvram = (binfo->vram + nBppixel*binfo->scrnx*y + nBppixel*x);
c0102020:	a1 e0 48 11 c0       	mov    0xc01148e0,%eax
c0102025:	8b 50 0c             	mov    0xc(%eax),%edx
c0102028:	a1 e0 48 11 c0       	mov    0xc01148e0,%eax
c010202d:	0f b7 40 04          	movzwl 0x4(%eax),%eax
c0102031:	0f b7 c0             	movzwl %ax,%eax
c0102034:	0f af 45 fc          	imul   -0x4(%ebp),%eax
c0102038:	0f af 45 0c          	imul   0xc(%ebp),%eax
c010203c:	89 c1                	mov    %eax,%ecx
c010203e:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102041:	0f af 45 08          	imul   0x8(%ebp),%eax
c0102045:	01 c8                	add    %ecx,%eax
c0102047:	01 d0                	add    %edx,%eax
c0102049:	89 45 f8             	mov    %eax,-0x8(%ebp)
	*pvram = c.r;
c010204c:	0f b6 55 10          	movzbl 0x10(%ebp),%edx
c0102050:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0102053:	88 10                	mov    %dl,(%eax)
	*(pvram+1) = c.g;
c0102055:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0102058:	8d 50 01             	lea    0x1(%eax),%edx
c010205b:	0f b6 45 11          	movzbl 0x11(%ebp),%eax
c010205f:	88 02                	mov    %al,(%edx)
	*(pvram+2) = c.b;
c0102061:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0102064:	8d 50 02             	lea    0x2(%eax),%edx
c0102067:	0f b6 45 12          	movzbl 0x12(%ebp),%eax
c010206b:	88 02                	mov    %al,(%edx)
	return TRUE;
c010206d:	b8 01 00 00 00       	mov    $0x1,%eax
}
c0102072:	c9                   	leave  
c0102073:	c3                   	ret    

c0102074 <_gGetPixel>:

rgb_t _gGetPixel(int32_t x, int32_t y)
{
c0102074:	55                   	push   %ebp
c0102075:	89 e5                	mov    %esp,%ebp
	if(!is_pixel_valid(x,y))
c0102077:	ff 75 10             	pushl  0x10(%ebp)
c010207a:	ff 75 0c             	pushl  0xc(%ebp)
c010207d:	e8 43 ff ff ff       	call   c0101fc5 <is_pixel_valid>
c0102082:	83 c4 08             	add    $0x8,%esp
c0102085:	85 c0                	test   %eax,%eax
c0102087:	75 16                	jne    c010209f <_gGetPixel+0x2b>
		return (rgb_t){0,0,0};
c0102089:	8b 45 08             	mov    0x8(%ebp),%eax
c010208c:	c6 00 00             	movb   $0x0,(%eax)
c010208f:	8b 45 08             	mov    0x8(%ebp),%eax
c0102092:	c6 40 01 00          	movb   $0x0,0x1(%eax)
c0102096:	8b 45 08             	mov    0x8(%ebp),%eax
c0102099:	c6 40 02 00          	movb   $0x0,0x2(%eax)
c010209d:	eb 14                	jmp    c01020b3 <_gGetPixel+0x3f>
	//uint8_t * pvram = binfo->vram + y*binfo->scrnx + x;
	//return *pvram;
	return (rgb_t){0,0,0};
c010209f:	8b 45 08             	mov    0x8(%ebp),%eax
c01020a2:	c6 00 00             	movb   $0x0,(%eax)
c01020a5:	8b 45 08             	mov    0x8(%ebp),%eax
c01020a8:	c6 40 01 00          	movb   $0x0,0x1(%eax)
c01020ac:	8b 45 08             	mov    0x8(%ebp),%eax
c01020af:	c6 40 02 00          	movb   $0x0,0x2(%eax)
}
c01020b3:	8b 45 08             	mov    0x8(%ebp),%eax
c01020b6:	c9                   	leave  
c01020b7:	c2 04 00             	ret    $0x4

c01020ba <_gGetScrnRect>:

rect_t _gGetScrnRect()
{
c01020ba:	55                   	push   %ebp
c01020bb:	89 e5                	mov    %esp,%ebp
c01020bd:	83 ec 10             	sub    $0x10,%esp
	rect_t rect;
	rect.left = 0;
c01020c0:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
	rect.top = 0;
c01020c7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	rect.width = binfo->scrnx;
c01020ce:	a1 e0 48 11 c0       	mov    0xc01148e0,%eax
c01020d3:	0f b7 40 04          	movzwl 0x4(%eax),%eax
c01020d7:	0f b7 c0             	movzwl %ax,%eax
c01020da:	89 45 f8             	mov    %eax,-0x8(%ebp)
	rect.height = binfo->scrny;
c01020dd:	a1 e0 48 11 c0       	mov    0xc01148e0,%eax
c01020e2:	0f b7 40 06          	movzwl 0x6(%eax),%eax
c01020e6:	0f b7 c0             	movzwl %ax,%eax
c01020e9:	89 45 fc             	mov    %eax,-0x4(%ebp)
	return rect;
c01020ec:	8b 45 08             	mov    0x8(%ebp),%eax
c01020ef:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01020f2:	89 10                	mov    %edx,(%eax)
c01020f4:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01020f7:	89 50 04             	mov    %edx,0x4(%eax)
c01020fa:	8b 55 f8             	mov    -0x8(%ebp),%edx
c01020fd:	89 50 08             	mov    %edx,0x8(%eax)
c0102100:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0102103:	89 50 0c             	mov    %edx,0xc(%eax)
}
c0102106:	8b 45 08             	mov    0x8(%ebp),%eax
c0102109:	c9                   	leave  
c010210a:	c2 04 00             	ret    $0x4

c010210d <graphic_init>:


void graphic_init() 
{
c010210d:	55                   	push   %ebp
c010210e:	89 e5                	mov    %esp,%ebp
c0102110:	81 ec b8 03 00 00    	sub    $0x3b8,%esp
	cprintf("graphic_init\n");
c0102116:	83 ec 0c             	sub    $0xc,%esp
c0102119:	68 29 46 10 c0       	push   $0xc0104629
c010211e:	e8 c1 df ff ff       	call   c01000e4 <cprintf>
c0102123:	83 c4 10             	add    $0x10,%esp
	init_screen8();
c0102126:	e8 91 01 00 00       	call   c01022bc <init_screen8>

	draw_asc16('>', (point_t){22, 2}, MediumBlue);
c010212b:	c6 45 e1 00          	movb   $0x0,-0x1f(%ebp)
c010212f:	c6 45 e2 00          	movb   $0x0,-0x1e(%ebp)
c0102133:	c6 45 e3 cd          	movb   $0xcd,-0x1d(%ebp)
c0102137:	c7 45 e4 16 00 00 00 	movl   $0x16,-0x1c(%ebp)
c010213e:	c7 45 e8 02 00 00 00 	movl   $0x2,-0x18(%ebp)
c0102145:	83 ec 04             	sub    $0x4,%esp
c0102148:	89 e0                	mov    %esp,%eax
c010214a:	0f b7 55 e1          	movzwl -0x1f(%ebp),%edx
c010214e:	66 89 10             	mov    %dx,(%eax)
c0102151:	0f b6 55 e3          	movzbl -0x1d(%ebp),%edx
c0102155:	88 50 02             	mov    %dl,0x2(%eax)
c0102158:	ff 75 e8             	pushl  -0x18(%ebp)
c010215b:	ff 75 e4             	pushl  -0x1c(%ebp)
c010215e:	6a 3e                	push   $0x3e
c0102160:	e8 fe 09 00 00       	call   c0102b63 <draw_asc16>
c0102165:	83 c4 10             	add    $0x10,%esp
	draw_str16("Chill out!", (point_t){30, 2}, (rgb_t){32,33,22});
c0102168:	c6 45 ed 20          	movb   $0x20,-0x13(%ebp)
c010216c:	c6 45 ee 21          	movb   $0x21,-0x12(%ebp)
c0102170:	c6 45 ef 16          	movb   $0x16,-0x11(%ebp)
c0102174:	c7 45 f0 1e 00 00 00 	movl   $0x1e,-0x10(%ebp)
c010217b:	c7 45 f4 02 00 00 00 	movl   $0x2,-0xc(%ebp)
c0102182:	83 ec 04             	sub    $0x4,%esp
c0102185:	89 e0                	mov    %esp,%eax
c0102187:	0f b7 55 ed          	movzwl -0x13(%ebp),%edx
c010218b:	66 89 10             	mov    %dx,(%eax)
c010218e:	0f b6 55 ef          	movzbl -0x11(%ebp),%edx
c0102192:	88 50 02             	mov    %dl,0x2(%eax)
c0102195:	ff 75 f4             	pushl  -0xc(%ebp)
c0102198:	ff 75 f0             	pushl  -0x10(%ebp)
c010219b:	68 37 46 10 c0       	push   $0xc0104637
c01021a0:	e8 59 0a 00 00       	call   c0102bfe <draw_str16>
c01021a5:	83 c4 10             	add    $0x10,%esp

    rgb_t buff[16*16];
    init_mouse_cursor8(buff);
c01021a8:	83 ec 0c             	sub    $0xc,%esp
c01021ab:	8d 85 e1 fc ff ff    	lea    -0x31f(%ebp),%eax
c01021b1:	50                   	push   %eax
c01021b2:	e8 81 07 00 00       	call   c0102938 <init_mouse_cursor8>
c01021b7:	83 c4 10             	add    $0x10,%esp
    draw_mouse(buff);
c01021ba:	83 ec 0c             	sub    $0xc,%esp
c01021bd:	8d 85 e1 fc ff ff    	lea    -0x31f(%ebp),%eax
c01021c3:	50                   	push   %eax
c01021c4:	e8 92 03 00 00       	call   c010255b <draw_mouse>
c01021c9:	83 c4 10             	add    $0x10,%esp

	char buf[100];
	memset(buf,'\0',100);
c01021cc:	83 ec 04             	sub    $0x4,%esp
c01021cf:	6a 64                	push   $0x64
c01021d1:	6a 00                	push   $0x0
c01021d3:	8d 85 7d fc ff ff    	lea    -0x383(%ebp),%eax
c01021d9:	50                   	push   %eax
c01021da:	e8 91 17 00 00       	call   c0103970 <memset>
c01021df:	83 c4 10             	add    $0x10,%esp

	editbox_t eb;
	eb.point = (point_t){100,100};
c01021e2:	c7 85 54 fc ff ff 64 	movl   $0x64,-0x3ac(%ebp)
c01021e9:	00 00 00 
c01021ec:	c7 85 58 fc ff ff 64 	movl   $0x64,-0x3a8(%ebp)
c01021f3:	00 00 00 
	eb.ch_x = 60;
c01021f6:	c7 85 5c fc ff ff 3c 	movl   $0x3c,-0x3a4(%ebp)
c01021fd:	00 00 00 
	eb.ch_y = 30;
c0102200:	c7 85 60 fc ff ff 1e 	movl   $0x1e,-0x3a0(%ebp)
c0102207:	00 00 00 
	eb.bg_c = Pink;
c010220a:	c6 85 64 fc ff ff ff 	movb   $0xff,-0x39c(%ebp)
c0102211:	c6 85 65 fc ff ff c0 	movb   $0xc0,-0x39b(%ebp)
c0102218:	c6 85 66 fc ff ff cb 	movb   $0xcb,-0x39a(%ebp)
	eb.text_c = Black;
c010221f:	c6 85 67 fc ff ff 00 	movb   $0x0,-0x399(%ebp)
c0102226:	c6 85 68 fc ff ff 00 	movb   $0x0,-0x398(%ebp)
c010222d:	c6 85 69 fc ff ff 00 	movb   $0x0,-0x397(%ebp)
	eb.ch = buf;
c0102234:	8d 85 7d fc ff ff    	lea    -0x383(%ebp),%eax
c010223a:	89 85 74 fc ff ff    	mov    %eax,-0x38c(%ebp)
	eb.ch_size = 100;
c0102240:	c7 85 78 fc ff ff 64 	movl   $0x64,-0x388(%ebp)
c0102247:	00 00 00 
	eb.cur_x = eb.cur_y = 0;
c010224a:	c7 85 70 fc ff ff 00 	movl   $0x0,-0x390(%ebp)
c0102251:	00 00 00 
c0102254:	8b 85 70 fc ff ff    	mov    -0x390(%ebp),%eax
c010225a:	89 85 6c fc ff ff    	mov    %eax,-0x394(%ebp)
	
	draw_editbox(eb);
c0102260:	83 ec 08             	sub    $0x8,%esp
c0102263:	ff b5 78 fc ff ff    	pushl  -0x388(%ebp)
c0102269:	ff b5 74 fc ff ff    	pushl  -0x38c(%ebp)
c010226f:	ff b5 70 fc ff ff    	pushl  -0x390(%ebp)
c0102275:	ff b5 6c fc ff ff    	pushl  -0x394(%ebp)
c010227b:	ff b5 68 fc ff ff    	pushl  -0x398(%ebp)
c0102281:	ff b5 64 fc ff ff    	pushl  -0x39c(%ebp)
c0102287:	ff b5 60 fc ff ff    	pushl  -0x3a0(%ebp)
c010228d:	ff b5 5c fc ff ff    	pushl  -0x3a4(%ebp)
c0102293:	ff b5 58 fc ff ff    	pushl  -0x3a8(%ebp)
c0102299:	ff b5 54 fc ff ff    	pushl  -0x3ac(%ebp)
c010229f:	e8 66 02 00 00       	call   c010250a <draw_editbox>
c01022a4:	83 c4 30             	add    $0x30,%esp
 	getcontent(&eb);
c01022a7:	83 ec 0c             	sub    $0xc,%esp
c01022aa:	8d 85 54 fc ff ff    	lea    -0x3ac(%ebp),%eax
c01022b0:	50                   	push   %eax
c01022b1:	e8 b2 09 00 00       	call   c0102c68 <getcontent>
c01022b6:	83 c4 10             	add    $0x10,%esp
	
}
c01022b9:	90                   	nop
c01022ba:	c9                   	leave  
c01022bb:	c3                   	ret    

c01022bc <init_screen8>:

void init_screen8()
{
c01022bc:	55                   	push   %ebp
c01022bd:	89 e5                	mov    %esp,%ebp
c01022bf:	81 ec 88 00 00 00    	sub    $0x88,%esp
	cprintf("scrnx:%d binfo:%x", binfo->scrnx, binfo);
c01022c5:	8b 15 e0 48 11 c0    	mov    0xc01148e0,%edx
c01022cb:	a1 e0 48 11 c0       	mov    0xc01148e0,%eax
c01022d0:	0f b7 40 04          	movzwl 0x4(%eax),%eax
c01022d4:	0f b7 c0             	movzwl %ax,%eax
c01022d7:	83 ec 04             	sub    $0x4,%esp
c01022da:	52                   	push   %edx
c01022db:	50                   	push   %eax
c01022dc:	68 42 46 10 c0       	push   $0xc0104642
c01022e1:	e8 fe dd ff ff       	call   c01000e4 <cprintf>
c01022e6:	83 c4 10             	add    $0x10,%esp
	_gfillrect2((rgb_t){20,40,100}, (rect_t){0,0,binfo->scrnx,binfo->scrny}); 
c01022e9:	c7 45 84 00 00 00 00 	movl   $0x0,-0x7c(%ebp)
c01022f0:	c7 45 88 00 00 00 00 	movl   $0x0,-0x78(%ebp)
c01022f7:	a1 e0 48 11 c0       	mov    0xc01148e0,%eax
c01022fc:	0f b7 40 04          	movzwl 0x4(%eax),%eax
c0102300:	0f b7 c0             	movzwl %ax,%eax
c0102303:	89 45 8c             	mov    %eax,-0x74(%ebp)
c0102306:	a1 e0 48 11 c0       	mov    0xc01148e0,%eax
c010230b:	0f b7 40 06          	movzwl 0x6(%eax),%eax
c010230f:	0f b7 c0             	movzwl %ax,%eax
c0102312:	89 45 90             	mov    %eax,-0x70(%ebp)
c0102315:	c6 45 95 14          	movb   $0x14,-0x6b(%ebp)
c0102319:	c6 45 96 28          	movb   $0x28,-0x6a(%ebp)
c010231d:	c6 45 97 64          	movb   $0x64,-0x69(%ebp)
c0102321:	83 ec 0c             	sub    $0xc,%esp
c0102324:	ff 75 90             	pushl  -0x70(%ebp)
c0102327:	ff 75 8c             	pushl  -0x74(%ebp)
c010232a:	ff 75 88             	pushl  -0x78(%ebp)
c010232d:	ff 75 84             	pushl  -0x7c(%ebp)
c0102330:	83 ec 04             	sub    $0x4,%esp
c0102333:	89 e0                	mov    %esp,%eax
c0102335:	0f b7 55 95          	movzwl -0x6b(%ebp),%edx
c0102339:	66 89 10             	mov    %dx,(%eax)
c010233c:	0f b6 55 97          	movzbl -0x69(%ebp),%edx
c0102340:	88 50 02             	mov    %dl,0x2(%eax)
c0102343:	e8 8c 05 00 00       	call   c01028d4 <_gfillrect2>
c0102348:	83 c4 20             	add    $0x20,%esp
	cprintf("wtf");
c010234b:	83 ec 0c             	sub    $0xc,%esp
c010234e:	68 54 46 10 c0       	push   $0xc0104654
c0102353:	e8 8c dd ff ff       	call   c01000e4 <cprintf>
c0102358:	83 c4 10             	add    $0x10,%esp
	_gdrawrect((rgb_t){100,100,100}, (rect_t){0, 0, 64, 700});
c010235b:	c7 45 98 00 00 00 00 	movl   $0x0,-0x68(%ebp)
c0102362:	c7 45 9c 00 00 00 00 	movl   $0x0,-0x64(%ebp)
c0102369:	c7 45 a0 40 00 00 00 	movl   $0x40,-0x60(%ebp)
c0102370:	c7 45 a4 bc 02 00 00 	movl   $0x2bc,-0x5c(%ebp)
c0102377:	c6 45 a9 64          	movb   $0x64,-0x57(%ebp)
c010237b:	c6 45 aa 64          	movb   $0x64,-0x56(%ebp)
c010237f:	c6 45 ab 64          	movb   $0x64,-0x55(%ebp)
c0102383:	83 ec 0c             	sub    $0xc,%esp
c0102386:	ff 75 a4             	pushl  -0x5c(%ebp)
c0102389:	ff 75 a0             	pushl  -0x60(%ebp)
c010238c:	ff 75 9c             	pushl  -0x64(%ebp)
c010238f:	ff 75 98             	pushl  -0x68(%ebp)
c0102392:	83 ec 04             	sub    $0x4,%esp
c0102395:	89 e0                	mov    %esp,%eax
c0102397:	0f b7 55 a9          	movzwl -0x57(%ebp),%edx
c010239b:	66 89 10             	mov    %dx,(%eax)
c010239e:	0f b6 55 ab          	movzbl -0x55(%ebp),%edx
c01023a2:	88 50 02             	mov    %dl,0x2(%eax)
c01023a5:	e8 68 03 00 00       	call   c0102712 <_gdrawrect>
c01023aa:	83 c4 20             	add    $0x20,%esp

	for(int i=0; i<10; i++)
c01023ad:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01023b4:	e9 b2 00 00 00       	jmp    c010246b <init_screen8+0x1af>
	{
		_gfillrect2((rgb_t){200,220,10}, (rect_t){2, 2+70*i, 60, 60});
c01023b9:	c7 45 ac 02 00 00 00 	movl   $0x2,-0x54(%ebp)
c01023c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01023c3:	6b c0 46             	imul   $0x46,%eax,%eax
c01023c6:	83 c0 02             	add    $0x2,%eax
c01023c9:	89 45 b0             	mov    %eax,-0x50(%ebp)
c01023cc:	c7 45 b4 3c 00 00 00 	movl   $0x3c,-0x4c(%ebp)
c01023d3:	c7 45 b8 3c 00 00 00 	movl   $0x3c,-0x48(%ebp)
c01023da:	c6 45 bd c8          	movb   $0xc8,-0x43(%ebp)
c01023de:	c6 45 be dc          	movb   $0xdc,-0x42(%ebp)
c01023e2:	c6 45 bf 0a          	movb   $0xa,-0x41(%ebp)
c01023e6:	83 ec 0c             	sub    $0xc,%esp
c01023e9:	ff 75 b8             	pushl  -0x48(%ebp)
c01023ec:	ff 75 b4             	pushl  -0x4c(%ebp)
c01023ef:	ff 75 b0             	pushl  -0x50(%ebp)
c01023f2:	ff 75 ac             	pushl  -0x54(%ebp)
c01023f5:	83 ec 04             	sub    $0x4,%esp
c01023f8:	89 e0                	mov    %esp,%eax
c01023fa:	0f b7 55 bd          	movzwl -0x43(%ebp),%edx
c01023fe:	66 89 10             	mov    %dx,(%eax)
c0102401:	0f b6 55 bf          	movzbl -0x41(%ebp),%edx
c0102405:	88 50 02             	mov    %dl,0x2(%eax)
c0102408:	e8 c7 04 00 00       	call   c01028d4 <_gfillrect2>
c010240d:	83 c4 20             	add    $0x20,%esp
		_gdrawrect((rgb_t){32,33,44}, (rect_t){2, 2+70*i, 60, 60});
c0102410:	c7 45 c0 02 00 00 00 	movl   $0x2,-0x40(%ebp)
c0102417:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010241a:	6b c0 46             	imul   $0x46,%eax,%eax
c010241d:	83 c0 02             	add    $0x2,%eax
c0102420:	89 45 c4             	mov    %eax,-0x3c(%ebp)
c0102423:	c7 45 c8 3c 00 00 00 	movl   $0x3c,-0x38(%ebp)
c010242a:	c7 45 cc 3c 00 00 00 	movl   $0x3c,-0x34(%ebp)
c0102431:	c6 45 d1 20          	movb   $0x20,-0x2f(%ebp)
c0102435:	c6 45 d2 21          	movb   $0x21,-0x2e(%ebp)
c0102439:	c6 45 d3 2c          	movb   $0x2c,-0x2d(%ebp)
c010243d:	83 ec 0c             	sub    $0xc,%esp
c0102440:	ff 75 cc             	pushl  -0x34(%ebp)
c0102443:	ff 75 c8             	pushl  -0x38(%ebp)
c0102446:	ff 75 c4             	pushl  -0x3c(%ebp)
c0102449:	ff 75 c0             	pushl  -0x40(%ebp)
c010244c:	83 ec 04             	sub    $0x4,%esp
c010244f:	89 e0                	mov    %esp,%eax
c0102451:	0f b7 55 d1          	movzwl -0x2f(%ebp),%edx
c0102455:	66 89 10             	mov    %dx,(%eax)
c0102458:	0f b6 55 d3          	movzbl -0x2d(%ebp),%edx
c010245c:	88 50 02             	mov    %dl,0x2(%eax)
c010245f:	e8 ae 02 00 00       	call   c0102712 <_gdrawrect>
c0102464:	83 c4 20             	add    $0x20,%esp
	cprintf("scrnx:%d binfo:%x", binfo->scrnx, binfo);
	_gfillrect2((rgb_t){20,40,100}, (rect_t){0,0,binfo->scrnx,binfo->scrny}); 
	cprintf("wtf");
	_gdrawrect((rgb_t){100,100,100}, (rect_t){0, 0, 64, 700});

	for(int i=0; i<10; i++)
c0102467:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c010246b:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
c010246f:	0f 8e 44 ff ff ff    	jle    c01023b9 <init_screen8+0xfd>
	{
		_gfillrect2((rgb_t){200,220,10}, (rect_t){2, 2+70*i, 60, 60});
		_gdrawrect((rgb_t){32,33,44}, (rect_t){2, 2+70*i, 60, 60});
	}

	_gdrawline((rgb_t){211,22,32}, (point_t){100, 70}, (point_t){800, 70}); 
c0102475:	c7 45 d4 20 03 00 00 	movl   $0x320,-0x2c(%ebp)
c010247c:	c7 45 d8 46 00 00 00 	movl   $0x46,-0x28(%ebp)
c0102483:	c7 45 dc 64 00 00 00 	movl   $0x64,-0x24(%ebp)
c010248a:	c7 45 e0 46 00 00 00 	movl   $0x46,-0x20(%ebp)
c0102491:	c6 45 e6 d3          	movb   $0xd3,-0x1a(%ebp)
c0102495:	c6 45 e7 16          	movb   $0x16,-0x19(%ebp)
c0102499:	c6 45 e8 20          	movb   $0x20,-0x18(%ebp)
c010249d:	83 ec 0c             	sub    $0xc,%esp
c01024a0:	ff 75 d8             	pushl  -0x28(%ebp)
c01024a3:	ff 75 d4             	pushl  -0x2c(%ebp)
c01024a6:	ff 75 e0             	pushl  -0x20(%ebp)
c01024a9:	ff 75 dc             	pushl  -0x24(%ebp)
c01024ac:	83 ec 04             	sub    $0x4,%esp
c01024af:	89 e0                	mov    %esp,%eax
c01024b1:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c01024b5:	66 89 10             	mov    %dx,(%eax)
c01024b8:	0f b6 55 e8          	movzbl -0x18(%ebp),%edx
c01024bc:	88 50 02             	mov    %dl,0x2(%eax)
c01024bf:	e8 d6 00 00 00       	call   c010259a <_gdrawline>
c01024c4:	83 c4 20             	add    $0x20,%esp
	draw_str16("Rolling in the deep", (point_t){120,20}, Black);
c01024c7:	c6 45 e9 00          	movb   $0x0,-0x17(%ebp)
c01024cb:	c6 45 ea 00          	movb   $0x0,-0x16(%ebp)
c01024cf:	c6 45 eb 00          	movb   $0x0,-0x15(%ebp)
c01024d3:	c7 45 ec 78 00 00 00 	movl   $0x78,-0x14(%ebp)
c01024da:	c7 45 f0 14 00 00 00 	movl   $0x14,-0x10(%ebp)
c01024e1:	83 ec 04             	sub    $0x4,%esp
c01024e4:	89 e0                	mov    %esp,%eax
c01024e6:	0f b7 55 e9          	movzwl -0x17(%ebp),%edx
c01024ea:	66 89 10             	mov    %dx,(%eax)
c01024ed:	0f b6 55 eb          	movzbl -0x15(%ebp),%edx
c01024f1:	88 50 02             	mov    %dl,0x2(%eax)
c01024f4:	ff 75 f0             	pushl  -0x10(%ebp)
c01024f7:	ff 75 ec             	pushl  -0x14(%ebp)
c01024fa:	68 58 46 10 c0       	push   $0xc0104658
c01024ff:	e8 fa 06 00 00       	call   c0102bfe <draw_str16>
c0102504:	83 c4 10             	add    $0x10,%esp

	

	return;
c0102507:	90                   	nop
}
c0102508:	c9                   	leave  
c0102509:	c3                   	ret    

c010250a <draw_editbox>:

void draw_editbox(editbox_t eb) {
c010250a:	55                   	push   %ebp
c010250b:	89 e5                	mov    %esp,%ebp
c010250d:	83 ec 18             	sub    $0x18,%esp
	_gfillrect2(eb.bg_c, (rect_t){eb.point.x, eb.point.y, eb.ch_x*ASC16_WIDTH, eb.ch_y*ASC16_HEIGHT});
c0102510:	8b 45 08             	mov    0x8(%ebp),%eax
c0102513:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0102516:	8b 45 0c             	mov    0xc(%ebp),%eax
c0102519:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010251c:	8b 45 10             	mov    0x10(%ebp),%eax
c010251f:	c1 e0 03             	shl    $0x3,%eax
c0102522:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0102525:	8b 45 14             	mov    0x14(%ebp),%eax
c0102528:	c1 e0 04             	shl    $0x4,%eax
c010252b:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010252e:	83 ec 0c             	sub    $0xc,%esp
c0102531:	ff 75 f4             	pushl  -0xc(%ebp)
c0102534:	ff 75 f0             	pushl  -0x10(%ebp)
c0102537:	ff 75 ec             	pushl  -0x14(%ebp)
c010253a:	ff 75 e8             	pushl  -0x18(%ebp)
c010253d:	83 ec 04             	sub    $0x4,%esp
c0102540:	89 e0                	mov    %esp,%eax
c0102542:	0f b7 55 18          	movzwl 0x18(%ebp),%edx
c0102546:	66 89 10             	mov    %dx,(%eax)
c0102549:	0f b6 55 1a          	movzbl 0x1a(%ebp),%edx
c010254d:	88 50 02             	mov    %dl,0x2(%eax)
c0102550:	e8 7f 03 00 00       	call   c01028d4 <_gfillrect2>
c0102555:	83 c4 20             	add    $0x20,%esp
}
c0102558:	90                   	nop
c0102559:	c9                   	leave  
c010255a:	c3                   	ret    

c010255b <draw_mouse>:

void draw_mouse(rgb_t *mouse) 
{
c010255b:	55                   	push   %ebp
c010255c:	89 e5                	mov    %esp,%ebp
c010255e:	83 ec 18             	sub    $0x18,%esp
	rect_t rect = {30,40,16,16};
c0102561:	c7 45 e8 1e 00 00 00 	movl   $0x1e,-0x18(%ebp)
c0102568:	c7 45 ec 28 00 00 00 	movl   $0x28,-0x14(%ebp)
c010256f:	c7 45 f0 10 00 00 00 	movl   $0x10,-0x10(%ebp)
c0102576:	c7 45 f4 10 00 00 00 	movl   $0x10,-0xc(%ebp)
	_gfillrect(mouse, rect);
c010257d:	83 ec 0c             	sub    $0xc,%esp
c0102580:	ff 75 f4             	pushl  -0xc(%ebp)
c0102583:	ff 75 f0             	pushl  -0x10(%ebp)
c0102586:	ff 75 ec             	pushl  -0x14(%ebp)
c0102589:	ff 75 e8             	pushl  -0x18(%ebp)
c010258c:	ff 75 08             	pushl  0x8(%ebp)
c010258f:	e8 af 02 00 00       	call   c0102843 <_gfillrect>
c0102594:	83 c4 20             	add    $0x20,%esp
}
c0102597:	90                   	nop
c0102598:	c9                   	leave  
c0102599:	c3                   	ret    

c010259a <_gdrawline>:

void _gdrawline(rgb_t c, point_t p1, point_t p2)
{
c010259a:	55                   	push   %ebp
c010259b:	89 e5                	mov    %esp,%ebp
c010259d:	83 ec 2c             	sub    $0x2c,%esp
	BOOL type = (p2.x-p1.x) > (p2.y-p1.y);
c01025a0:	8b 55 14             	mov    0x14(%ebp),%edx
c01025a3:	8b 45 0c             	mov    0xc(%ebp),%eax
c01025a6:	89 d1                	mov    %edx,%ecx
c01025a8:	29 c1                	sub    %eax,%ecx
c01025aa:	8b 55 18             	mov    0x18(%ebp),%edx
c01025ad:	8b 45 10             	mov    0x10(%ebp),%eax
c01025b0:	29 c2                	sub    %eax,%edx
c01025b2:	89 d0                	mov    %edx,%eax
c01025b4:	39 c1                	cmp    %eax,%ecx
c01025b6:	0f 9f c0             	setg   %al
c01025b9:	0f b6 c0             	movzbl %al,%eax
c01025bc:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if(type) {
c01025bf:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c01025c3:	0f 84 a7 00 00 00    	je     c0102670 <_gdrawline+0xd6>
		float yt1 = p1.y, dy = (float)(p2.y-p1.y)/(p2.x-p1.x);
c01025c9:	8b 45 10             	mov    0x10(%ebp),%eax
c01025cc:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c01025cf:	db 45 d4             	fildl  -0x2c(%ebp)
c01025d2:	d9 5d fc             	fstps  -0x4(%ebp)
c01025d5:	8b 55 18             	mov    0x18(%ebp),%edx
c01025d8:	8b 45 10             	mov    0x10(%ebp),%eax
c01025db:	29 c2                	sub    %eax,%edx
c01025dd:	89 d0                	mov    %edx,%eax
c01025df:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c01025e2:	db 45 d4             	fildl  -0x2c(%ebp)
c01025e5:	8b 55 14             	mov    0x14(%ebp),%edx
c01025e8:	8b 45 0c             	mov    0xc(%ebp),%eax
c01025eb:	29 c2                	sub    %eax,%edx
c01025ed:	89 d0                	mov    %edx,%eax
c01025ef:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c01025f2:	db 45 d4             	fildl  -0x2c(%ebp)
c01025f5:	de f9                	fdivrp %st,%st(1)
c01025f7:	d9 5d e8             	fstps  -0x18(%ebp)
		int xt1=p1.x;
c01025fa:	8b 45 0c             	mov    0xc(%ebp),%eax
c01025fd:	89 45 f8             	mov    %eax,-0x8(%ebp)
		for(;yt1<=p2.y && xt1<=p2.x; yt1+=dy, xt1++)
c0102600:	eb 48                	jmp    c010264a <_gdrawline+0xb0>
			setpixel(xt1,yt1,c);
c0102602:	d9 45 fc             	flds   -0x4(%ebp)
c0102605:	d9 7d de             	fnstcw -0x22(%ebp)
c0102608:	0f b7 45 de          	movzwl -0x22(%ebp),%eax
c010260c:	b4 0c                	mov    $0xc,%ah
c010260e:	66 89 45 dc          	mov    %ax,-0x24(%ebp)
c0102612:	d9 6d dc             	fldcw  -0x24(%ebp)
c0102615:	db 5d d8             	fistpl -0x28(%ebp)
c0102618:	d9 6d de             	fldcw  -0x22(%ebp)
c010261b:	8b 4d d8             	mov    -0x28(%ebp),%ecx
c010261e:	83 ec 04             	sub    $0x4,%esp
c0102621:	89 e0                	mov    %esp,%eax
c0102623:	0f b7 55 08          	movzwl 0x8(%ebp),%edx
c0102627:	66 89 10             	mov    %dx,(%eax)
c010262a:	0f b6 55 0a          	movzbl 0xa(%ebp),%edx
c010262e:	88 50 02             	mov    %dl,0x2(%eax)
c0102631:	51                   	push   %ecx
c0102632:	ff 75 f8             	pushl  -0x8(%ebp)
c0102635:	e8 ce f9 ff ff       	call   c0102008 <setpixel>
c010263a:	83 c4 0c             	add    $0xc,%esp
{
	BOOL type = (p2.x-p1.x) > (p2.y-p1.y);
	if(type) {
		float yt1 = p1.y, dy = (float)(p2.y-p1.y)/(p2.x-p1.x);
		int xt1=p1.x;
		for(;yt1<=p2.y && xt1<=p2.x; yt1+=dy, xt1++)
c010263d:	d9 45 fc             	flds   -0x4(%ebp)
c0102640:	d8 45 e8             	fadds  -0x18(%ebp)
c0102643:	d9 5d fc             	fstps  -0x4(%ebp)
c0102646:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
c010264a:	8b 45 18             	mov    0x18(%ebp),%eax
c010264d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c0102650:	db 45 d4             	fildl  -0x2c(%ebp)
c0102653:	d9 45 fc             	flds   -0x4(%ebp)
c0102656:	d9 c9                	fxch   %st(1)
c0102658:	df e9                	fucomip %st(1),%st
c010265a:	dd d8                	fstp   %st(0)
c010265c:	73 05                	jae    c0102663 <_gdrawline+0xc9>
		for(;xt2<=p2.x && yt2<=p2.y; xt2+=dx, yt2++)
			setpixel(xt2, yt2,c);
	}


}
c010265e:	e9 ac 00 00 00       	jmp    c010270f <_gdrawline+0x175>
{
	BOOL type = (p2.x-p1.x) > (p2.y-p1.y);
	if(type) {
		float yt1 = p1.y, dy = (float)(p2.y-p1.y)/(p2.x-p1.x);
		int xt1=p1.x;
		for(;yt1<=p2.y && xt1<=p2.x; yt1+=dy, xt1++)
c0102663:	8b 45 14             	mov    0x14(%ebp),%eax
c0102666:	3b 45 f8             	cmp    -0x8(%ebp),%eax
c0102669:	7d 97                	jge    c0102602 <_gdrawline+0x68>
		for(;xt2<=p2.x && yt2<=p2.y; xt2+=dx, yt2++)
			setpixel(xt2, yt2,c);
	}


}
c010266b:	e9 9f 00 00 00       	jmp    c010270f <_gdrawline+0x175>
		float yt1 = p1.y, dy = (float)(p2.y-p1.y)/(p2.x-p1.x);
		int xt1=p1.x;
		for(;yt1<=p2.y && xt1<=p2.x; yt1+=dy, xt1++)
			setpixel(xt1,yt1,c);
	} else{
		float xt2 = p1.x, dx = (float)(p2.x-p1.x)/(p2.y-p1.y);
c0102670:	8b 45 0c             	mov    0xc(%ebp),%eax
c0102673:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c0102676:	db 45 d4             	fildl  -0x2c(%ebp)
c0102679:	d9 5d f4             	fstps  -0xc(%ebp)
c010267c:	8b 55 14             	mov    0x14(%ebp),%edx
c010267f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0102682:	29 c2                	sub    %eax,%edx
c0102684:	89 d0                	mov    %edx,%eax
c0102686:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c0102689:	db 45 d4             	fildl  -0x2c(%ebp)
c010268c:	8b 55 18             	mov    0x18(%ebp),%edx
c010268f:	8b 45 10             	mov    0x10(%ebp),%eax
c0102692:	29 c2                	sub    %eax,%edx
c0102694:	89 d0                	mov    %edx,%eax
c0102696:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c0102699:	db 45 d4             	fildl  -0x2c(%ebp)
c010269c:	de f9                	fdivrp %st,%st(1)
c010269e:	d9 5d e4             	fstps  -0x1c(%ebp)
		int yt2 = p1.y;
c01026a1:	8b 45 10             	mov    0x10(%ebp),%eax
c01026a4:	89 45 f0             	mov    %eax,-0x10(%ebp)
		for(;xt2<=p2.x && yt2<=p2.y; xt2+=dx, yt2++)
c01026a7:	eb 48                	jmp    c01026f1 <_gdrawline+0x157>
			setpixel(xt2, yt2,c);
c01026a9:	d9 45 f4             	flds   -0xc(%ebp)
c01026ac:	d9 7d de             	fnstcw -0x22(%ebp)
c01026af:	0f b7 45 de          	movzwl -0x22(%ebp),%eax
c01026b3:	b4 0c                	mov    $0xc,%ah
c01026b5:	66 89 45 dc          	mov    %ax,-0x24(%ebp)
c01026b9:	d9 6d dc             	fldcw  -0x24(%ebp)
c01026bc:	db 5d d8             	fistpl -0x28(%ebp)
c01026bf:	d9 6d de             	fldcw  -0x22(%ebp)
c01026c2:	8b 4d d8             	mov    -0x28(%ebp),%ecx
c01026c5:	83 ec 04             	sub    $0x4,%esp
c01026c8:	89 e0                	mov    %esp,%eax
c01026ca:	0f b7 55 08          	movzwl 0x8(%ebp),%edx
c01026ce:	66 89 10             	mov    %dx,(%eax)
c01026d1:	0f b6 55 0a          	movzbl 0xa(%ebp),%edx
c01026d5:	88 50 02             	mov    %dl,0x2(%eax)
c01026d8:	ff 75 f0             	pushl  -0x10(%ebp)
c01026db:	51                   	push   %ecx
c01026dc:	e8 27 f9 ff ff       	call   c0102008 <setpixel>
c01026e1:	83 c4 0c             	add    $0xc,%esp
		for(;yt1<=p2.y && xt1<=p2.x; yt1+=dy, xt1++)
			setpixel(xt1,yt1,c);
	} else{
		float xt2 = p1.x, dx = (float)(p2.x-p1.x)/(p2.y-p1.y);
		int yt2 = p1.y;
		for(;xt2<=p2.x && yt2<=p2.y; xt2+=dx, yt2++)
c01026e4:	d9 45 f4             	flds   -0xc(%ebp)
c01026e7:	d8 45 e4             	fadds  -0x1c(%ebp)
c01026ea:	d9 5d f4             	fstps  -0xc(%ebp)
c01026ed:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
c01026f1:	8b 45 14             	mov    0x14(%ebp),%eax
c01026f4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c01026f7:	db 45 d4             	fildl  -0x2c(%ebp)
c01026fa:	d9 45 f4             	flds   -0xc(%ebp)
c01026fd:	d9 c9                	fxch   %st(1)
c01026ff:	df e9                	fucomip %st(1),%st
c0102701:	dd d8                	fstp   %st(0)
c0102703:	73 02                	jae    c0102707 <_gdrawline+0x16d>
			setpixel(xt2, yt2,c);
	}


}
c0102705:	eb 08                	jmp    c010270f <_gdrawline+0x175>
		for(;yt1<=p2.y && xt1<=p2.x; yt1+=dy, xt1++)
			setpixel(xt1,yt1,c);
	} else{
		float xt2 = p1.x, dx = (float)(p2.x-p1.x)/(p2.y-p1.y);
		int yt2 = p1.y;
		for(;xt2<=p2.x && yt2<=p2.y; xt2+=dx, yt2++)
c0102707:	8b 45 18             	mov    0x18(%ebp),%eax
c010270a:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c010270d:	7d 9a                	jge    c01026a9 <_gdrawline+0x10f>
			setpixel(xt2, yt2,c);
	}


}
c010270f:	90                   	nop
c0102710:	c9                   	leave  
c0102711:	c3                   	ret    

c0102712 <_gdrawrect>:

void _gdrawrect(rgb_t c, rect_t	rect)
{
c0102712:	55                   	push   %ebp
c0102713:	89 e5                	mov    %esp,%ebp
c0102715:	83 ec 50             	sub    $0x50,%esp
	int x1 = rect.left, x2 = rect.left+rect.width-1;
c0102718:	8b 45 0c             	mov    0xc(%ebp),%eax
c010271b:	89 45 fc             	mov    %eax,-0x4(%ebp)
c010271e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0102721:	89 c2                	mov    %eax,%edx
c0102723:	8b 45 14             	mov    0x14(%ebp),%eax
c0102726:	01 d0                	add    %edx,%eax
c0102728:	83 e8 01             	sub    $0x1,%eax
c010272b:	89 45 f8             	mov    %eax,-0x8(%ebp)
	int y1 = rect.top, y2 = rect.top+rect.height-1;
c010272e:	8b 45 10             	mov    0x10(%ebp),%eax
c0102731:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0102734:	8b 45 10             	mov    0x10(%ebp),%eax
c0102737:	89 c2                	mov    %eax,%edx
c0102739:	8b 45 18             	mov    0x18(%ebp),%eax
c010273c:	01 d0                	add    %edx,%eax
c010273e:	83 e8 01             	sub    $0x1,%eax
c0102741:	89 45 f0             	mov    %eax,-0x10(%ebp)
	_gdrawline(c, (point_t){x1, y1}, (point_t){x2, y1});
c0102744:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0102747:	89 45 b0             	mov    %eax,-0x50(%ebp)
c010274a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010274d:	89 45 b4             	mov    %eax,-0x4c(%ebp)
c0102750:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102753:	89 45 b8             	mov    %eax,-0x48(%ebp)
c0102756:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102759:	89 45 bc             	mov    %eax,-0x44(%ebp)
c010275c:	ff 75 b4             	pushl  -0x4c(%ebp)
c010275f:	ff 75 b0             	pushl  -0x50(%ebp)
c0102762:	ff 75 bc             	pushl  -0x44(%ebp)
c0102765:	ff 75 b8             	pushl  -0x48(%ebp)
c0102768:	83 ec 04             	sub    $0x4,%esp
c010276b:	89 e0                	mov    %esp,%eax
c010276d:	0f b7 55 08          	movzwl 0x8(%ebp),%edx
c0102771:	66 89 10             	mov    %dx,(%eax)
c0102774:	0f b6 55 0a          	movzbl 0xa(%ebp),%edx
c0102778:	88 50 02             	mov    %dl,0x2(%eax)
c010277b:	e8 1a fe ff ff       	call   c010259a <_gdrawline>
c0102780:	83 c4 14             	add    $0x14,%esp
	_gdrawline(c, (point_t){x1, y1}, (point_t){x1, y2});
c0102783:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102786:	89 45 c0             	mov    %eax,-0x40(%ebp)
c0102789:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010278c:	89 45 c4             	mov    %eax,-0x3c(%ebp)
c010278f:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102792:	89 45 c8             	mov    %eax,-0x38(%ebp)
c0102795:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102798:	89 45 cc             	mov    %eax,-0x34(%ebp)
c010279b:	ff 75 c4             	pushl  -0x3c(%ebp)
c010279e:	ff 75 c0             	pushl  -0x40(%ebp)
c01027a1:	ff 75 cc             	pushl  -0x34(%ebp)
c01027a4:	ff 75 c8             	pushl  -0x38(%ebp)
c01027a7:	83 ec 04             	sub    $0x4,%esp
c01027aa:	89 e0                	mov    %esp,%eax
c01027ac:	0f b7 55 08          	movzwl 0x8(%ebp),%edx
c01027b0:	66 89 10             	mov    %dx,(%eax)
c01027b3:	0f b6 55 0a          	movzbl 0xa(%ebp),%edx
c01027b7:	88 50 02             	mov    %dl,0x2(%eax)
c01027ba:	e8 db fd ff ff       	call   c010259a <_gdrawline>
c01027bf:	83 c4 14             	add    $0x14,%esp
	_gdrawline(c, (point_t){x2, y1}, (point_t){x2, y2});
c01027c2:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01027c5:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01027c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01027cb:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c01027ce:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01027d1:	89 45 d8             	mov    %eax,-0x28(%ebp)
c01027d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01027d7:	89 45 dc             	mov    %eax,-0x24(%ebp)
c01027da:	ff 75 d4             	pushl  -0x2c(%ebp)
c01027dd:	ff 75 d0             	pushl  -0x30(%ebp)
c01027e0:	ff 75 dc             	pushl  -0x24(%ebp)
c01027e3:	ff 75 d8             	pushl  -0x28(%ebp)
c01027e6:	83 ec 04             	sub    $0x4,%esp
c01027e9:	89 e0                	mov    %esp,%eax
c01027eb:	0f b7 55 08          	movzwl 0x8(%ebp),%edx
c01027ef:	66 89 10             	mov    %dx,(%eax)
c01027f2:	0f b6 55 0a          	movzbl 0xa(%ebp),%edx
c01027f6:	88 50 02             	mov    %dl,0x2(%eax)
c01027f9:	e8 9c fd ff ff       	call   c010259a <_gdrawline>
c01027fe:	83 c4 14             	add    $0x14,%esp
	_gdrawline(c, (point_t){x1, y2}, (point_t){x2, y2});
c0102801:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0102804:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0102807:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010280a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010280d:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102810:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0102813:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102816:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0102819:	ff 75 e4             	pushl  -0x1c(%ebp)
c010281c:	ff 75 e0             	pushl  -0x20(%ebp)
c010281f:	ff 75 ec             	pushl  -0x14(%ebp)
c0102822:	ff 75 e8             	pushl  -0x18(%ebp)
c0102825:	83 ec 04             	sub    $0x4,%esp
c0102828:	89 e0                	mov    %esp,%eax
c010282a:	0f b7 55 08          	movzwl 0x8(%ebp),%edx
c010282e:	66 89 10             	mov    %dx,(%eax)
c0102831:	0f b6 55 0a          	movzbl 0xa(%ebp),%edx
c0102835:	88 50 02             	mov    %dl,0x2(%eax)
c0102838:	e8 5d fd ff ff       	call   c010259a <_gdrawline>
c010283d:	83 c4 14             	add    $0x14,%esp
}
c0102840:	90                   	nop
c0102841:	c9                   	leave  
c0102842:	c3                   	ret    

c0102843 <_gfillrect>:

void _gfillrect(rgb_t *buf, rect_t rect)
{	
c0102843:	55                   	push   %ebp
c0102844:	89 e5                	mov    %esp,%ebp
c0102846:	53                   	push   %ebx
c0102847:	83 ec 10             	sub    $0x10,%esp
	for(int x=rect.left; x<rect.left+rect.width; x++)
c010284a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010284d:	89 45 f8             	mov    %eax,-0x8(%ebp)
c0102850:	eb 6b                	jmp    c01028bd <_gfillrect+0x7a>
		for(int y=rect.top; y<rect.top+rect.height; y++) 
c0102852:	8b 45 10             	mov    0x10(%ebp),%eax
c0102855:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0102858:	eb 4e                	jmp    c01028a8 <_gfillrect+0x65>
			setpixel(x, y, buf[(x-rect.left) + rect.width*(y-rect.top)]);
c010285a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010285d:	8b 55 f8             	mov    -0x8(%ebp),%edx
c0102860:	29 c2                	sub    %eax,%edx
c0102862:	89 d0                	mov    %edx,%eax
c0102864:	89 c3                	mov    %eax,%ebx
c0102866:	8b 45 14             	mov    0x14(%ebp),%eax
c0102869:	8b 55 10             	mov    0x10(%ebp),%edx
c010286c:	8b 4d f4             	mov    -0xc(%ebp),%ecx
c010286f:	29 d1                	sub    %edx,%ecx
c0102871:	89 ca                	mov    %ecx,%edx
c0102873:	0f af c2             	imul   %edx,%eax
c0102876:	8d 14 03             	lea    (%ebx,%eax,1),%edx
c0102879:	89 d0                	mov    %edx,%eax
c010287b:	01 c0                	add    %eax,%eax
c010287d:	01 c2                	add    %eax,%edx
c010287f:	8b 45 08             	mov    0x8(%ebp),%eax
c0102882:	01 d0                	add    %edx,%eax
c0102884:	83 ec 04             	sub    $0x4,%esp
c0102887:	89 e2                	mov    %esp,%edx
c0102889:	0f b7 08             	movzwl (%eax),%ecx
c010288c:	66 89 0a             	mov    %cx,(%edx)
c010288f:	0f b6 40 02          	movzbl 0x2(%eax),%eax
c0102893:	88 42 02             	mov    %al,0x2(%edx)
c0102896:	ff 75 f4             	pushl  -0xc(%ebp)
c0102899:	ff 75 f8             	pushl  -0x8(%ebp)
c010289c:	e8 67 f7 ff ff       	call   c0102008 <setpixel>
c01028a1:	83 c4 0c             	add    $0xc,%esp
}

void _gfillrect(rgb_t *buf, rect_t rect)
{	
	for(int x=rect.left; x<rect.left+rect.width; x++)
		for(int y=rect.top; y<rect.top+rect.height; y++) 
c01028a4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c01028a8:	8b 45 10             	mov    0x10(%ebp),%eax
c01028ab:	89 c2                	mov    %eax,%edx
c01028ad:	8b 45 18             	mov    0x18(%ebp),%eax
c01028b0:	01 c2                	add    %eax,%edx
c01028b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01028b5:	39 c2                	cmp    %eax,%edx
c01028b7:	77 a1                	ja     c010285a <_gfillrect+0x17>
	_gdrawline(c, (point_t){x1, y2}, (point_t){x2, y2});
}

void _gfillrect(rgb_t *buf, rect_t rect)
{	
	for(int x=rect.left; x<rect.left+rect.width; x++)
c01028b9:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
c01028bd:	8b 45 0c             	mov    0xc(%ebp),%eax
c01028c0:	89 c2                	mov    %eax,%edx
c01028c2:	8b 45 14             	mov    0x14(%ebp),%eax
c01028c5:	01 c2                	add    %eax,%edx
c01028c7:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01028ca:	39 c2                	cmp    %eax,%edx
c01028cc:	77 84                	ja     c0102852 <_gfillrect+0xf>
		for(int y=rect.top; y<rect.top+rect.height; y++) 
			setpixel(x, y, buf[(x-rect.left) + rect.width*(y-rect.top)]);
}
c01028ce:	90                   	nop
c01028cf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c01028d2:	c9                   	leave  
c01028d3:	c3                   	ret    

c01028d4 <_gfillrect2>:

void _gfillrect2(rgb_t c, rect_t rect)
{
c01028d4:	55                   	push   %ebp
c01028d5:	89 e5                	mov    %esp,%ebp
c01028d7:	83 ec 10             	sub    $0x10,%esp
	for(int x=rect.left; x<rect.left+rect.width; x++)
c01028da:	8b 45 0c             	mov    0xc(%ebp),%eax
c01028dd:	89 45 fc             	mov    %eax,-0x4(%ebp)
c01028e0:	eb 42                	jmp    c0102924 <_gfillrect2+0x50>
		for(int y=rect.top; y<rect.top+rect.height; y++) 
c01028e2:	8b 45 10             	mov    0x10(%ebp),%eax
c01028e5:	89 45 f8             	mov    %eax,-0x8(%ebp)
c01028e8:	eb 25                	jmp    c010290f <_gfillrect2+0x3b>
			setpixel(x, y, c);
c01028ea:	83 ec 04             	sub    $0x4,%esp
c01028ed:	89 e0                	mov    %esp,%eax
c01028ef:	0f b7 55 08          	movzwl 0x8(%ebp),%edx
c01028f3:	66 89 10             	mov    %dx,(%eax)
c01028f6:	0f b6 55 0a          	movzbl 0xa(%ebp),%edx
c01028fa:	88 50 02             	mov    %dl,0x2(%eax)
c01028fd:	ff 75 f8             	pushl  -0x8(%ebp)
c0102900:	ff 75 fc             	pushl  -0x4(%ebp)
c0102903:	e8 00 f7 ff ff       	call   c0102008 <setpixel>
c0102908:	83 c4 0c             	add    $0xc,%esp
}

void _gfillrect2(rgb_t c, rect_t rect)
{
	for(int x=rect.left; x<rect.left+rect.width; x++)
		for(int y=rect.top; y<rect.top+rect.height; y++) 
c010290b:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
c010290f:	8b 45 10             	mov    0x10(%ebp),%eax
c0102912:	89 c2                	mov    %eax,%edx
c0102914:	8b 45 18             	mov    0x18(%ebp),%eax
c0102917:	01 c2                	add    %eax,%edx
c0102919:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010291c:	39 c2                	cmp    %eax,%edx
c010291e:	77 ca                	ja     c01028ea <_gfillrect2+0x16>
			setpixel(x, y, buf[(x-rect.left) + rect.width*(y-rect.top)]);
}

void _gfillrect2(rgb_t c, rect_t rect)
{
	for(int x=rect.left; x<rect.left+rect.width; x++)
c0102920:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c0102924:	8b 45 0c             	mov    0xc(%ebp),%eax
c0102927:	89 c2                	mov    %eax,%edx
c0102929:	8b 45 14             	mov    0x14(%ebp),%eax
c010292c:	01 c2                	add    %eax,%edx
c010292e:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102931:	39 c2                	cmp    %eax,%edx
c0102933:	77 ad                	ja     c01028e2 <_gfillrect2+0xe>
		for(int y=rect.top; y<rect.top+rect.height; y++) 
			setpixel(x, y, c);
}
c0102935:	90                   	nop
c0102936:	c9                   	leave  
c0102937:	c3                   	ret    

c0102938 <init_mouse_cursor8>:

void init_mouse_cursor8(rgb_t *mouse)
{
c0102938:	55                   	push   %ebp
c0102939:	89 e5                	mov    %esp,%ebp
c010293b:	83 ec 10             	sub    $0x10,%esp
		"............*OO*",
		".............***"
	};
	int x, y;

	for (y = 0; y < 16; y++) {
c010293e:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
c0102945:	e9 d8 00 00 00       	jmp    c0102a22 <init_mouse_cursor8+0xea>
		for (x = 0; x < 16; x++) {
c010294a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c0102951:	e9 be 00 00 00       	jmp    c0102a14 <init_mouse_cursor8+0xdc>
			if (cursor[y][x] == '*') {
c0102956:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0102959:	c1 e0 04             	shl    $0x4,%eax
c010295c:	89 c2                	mov    %eax,%edx
c010295e:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102961:	01 d0                	add    %edx,%eax
c0102963:	05 80 39 11 c0       	add    $0xc0113980,%eax
c0102968:	0f b6 00             	movzbl (%eax),%eax
c010296b:	3c 2a                	cmp    $0x2a,%al
c010296d:	75 25                	jne    c0102994 <init_mouse_cursor8+0x5c>
				mouse[y * 16 + x] = LightPink;
c010296f:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0102972:	c1 e0 04             	shl    $0x4,%eax
c0102975:	89 c2                	mov    %eax,%edx
c0102977:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010297a:	01 d0                	add    %edx,%eax
c010297c:	89 c2                	mov    %eax,%edx
c010297e:	89 d0                	mov    %edx,%eax
c0102980:	01 c0                	add    %eax,%eax
c0102982:	01 c2                	add    %eax,%edx
c0102984:	8b 45 08             	mov    0x8(%ebp),%eax
c0102987:	01 d0                	add    %edx,%eax
c0102989:	c6 00 ff             	movb   $0xff,(%eax)
c010298c:	c6 40 01 b6          	movb   $0xb6,0x1(%eax)
c0102990:	c6 40 02 c1          	movb   $0xc1,0x2(%eax)
			}
			if (cursor[y][x] == 'O') {
c0102994:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0102997:	c1 e0 04             	shl    $0x4,%eax
c010299a:	89 c2                	mov    %eax,%edx
c010299c:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010299f:	01 d0                	add    %edx,%eax
c01029a1:	05 80 39 11 c0       	add    $0xc0113980,%eax
c01029a6:	0f b6 00             	movzbl (%eax),%eax
c01029a9:	3c 4f                	cmp    $0x4f,%al
c01029ab:	75 25                	jne    c01029d2 <init_mouse_cursor8+0x9a>
				mouse[y * 16 + x] = Navy;
c01029ad:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01029b0:	c1 e0 04             	shl    $0x4,%eax
c01029b3:	89 c2                	mov    %eax,%edx
c01029b5:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01029b8:	01 d0                	add    %edx,%eax
c01029ba:	89 c2                	mov    %eax,%edx
c01029bc:	89 d0                	mov    %edx,%eax
c01029be:	01 c0                	add    %eax,%eax
c01029c0:	01 c2                	add    %eax,%edx
c01029c2:	8b 45 08             	mov    0x8(%ebp),%eax
c01029c5:	01 d0                	add    %edx,%eax
c01029c7:	c6 00 00             	movb   $0x0,(%eax)
c01029ca:	c6 40 01 00          	movb   $0x0,0x1(%eax)
c01029ce:	c6 40 02 80          	movb   $0x80,0x2(%eax)
			}
			if (cursor[y][x] == '.') {
c01029d2:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01029d5:	c1 e0 04             	shl    $0x4,%eax
c01029d8:	89 c2                	mov    %eax,%edx
c01029da:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01029dd:	01 d0                	add    %edx,%eax
c01029df:	05 80 39 11 c0       	add    $0xc0113980,%eax
c01029e4:	0f b6 00             	movzbl (%eax),%eax
c01029e7:	3c 2e                	cmp    $0x2e,%al
c01029e9:	75 25                	jne    c0102a10 <init_mouse_cursor8+0xd8>
				mouse[y * 16 + x] = BlueViolet;
c01029eb:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01029ee:	c1 e0 04             	shl    $0x4,%eax
c01029f1:	89 c2                	mov    %eax,%edx
c01029f3:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01029f6:	01 d0                	add    %edx,%eax
c01029f8:	89 c2                	mov    %eax,%edx
c01029fa:	89 d0                	mov    %edx,%eax
c01029fc:	01 c0                	add    %eax,%eax
c01029fe:	01 c2                	add    %eax,%edx
c0102a00:	8b 45 08             	mov    0x8(%ebp),%eax
c0102a03:	01 d0                	add    %edx,%eax
c0102a05:	c6 00 8a             	movb   $0x8a,(%eax)
c0102a08:	c6 40 01 2b          	movb   $0x2b,0x1(%eax)
c0102a0c:	c6 40 02 e2          	movb   $0xe2,0x2(%eax)
		".............***"
	};
	int x, y;

	for (y = 0; y < 16; y++) {
		for (x = 0; x < 16; x++) {
c0102a10:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c0102a14:	83 7d fc 0f          	cmpl   $0xf,-0x4(%ebp)
c0102a18:	0f 8e 38 ff ff ff    	jle    c0102956 <init_mouse_cursor8+0x1e>
		"............*OO*",
		".............***"
	};
	int x, y;

	for (y = 0; y < 16; y++) {
c0102a1e:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
c0102a22:	83 7d f8 0f          	cmpl   $0xf,-0x8(%ebp)
c0102a26:	0f 8e 1e ff ff ff    	jle    c010294a <init_mouse_cursor8+0x12>
			if (cursor[y][x] == '.') {
				mouse[y * 16 + x] = BlueViolet;
			}
		}
	}
	return;
c0102a2c:	90                   	nop
}
c0102a2d:	c9                   	leave  
c0102a2e:	c3                   	ret    

c0102a2f <draw_bitmap>:
#include <math.h>

static bitmap_t* p_bmp_icon = (bitmap_t*)(BMP_ICON_ADDR);

BOOL draw_bitmap(bitmap_t* p_bmp, int x0, int y0)
{
c0102a2f:	55                   	push   %ebp
c0102a30:	89 e5                	mov    %esp,%ebp
c0102a32:	53                   	push   %ebx
c0102a33:	83 ec 24             	sub    $0x24,%esp
	uint8_t* p_bmp_data_addr = (uint8_t*)p_bmp + p_bmp->file_head.bf_offset_bits;
c0102a36:	8b 45 08             	mov    0x8(%ebp),%eax
c0102a39:	8b 50 0a             	mov    0xa(%eax),%edx
c0102a3c:	8b 45 08             	mov    0x8(%ebp),%eax
c0102a3f:	01 d0                	add    %edx,%eax
c0102a41:	89 45 ec             	mov    %eax,-0x14(%ebp)
	uint8_t* p_data;

	/* 不是24位位图 */
	if (p_bmp->info_head.bi_bit_count != 24)
c0102a44:	8b 45 08             	mov    0x8(%ebp),%eax
c0102a47:	0f b7 40 1c          	movzwl 0x1c(%eax),%eax
c0102a4b:	66 83 f8 18          	cmp    $0x18,%ax
c0102a4f:	74 0a                	je     c0102a5b <draw_bitmap+0x2c>
		return FALSE;
c0102a51:	b8 00 00 00 00       	mov    $0x0,%eax
c0102a56:	e9 e2 00 00 00       	jmp    c0102b3d <draw_bitmap+0x10e>

	/* 图像的宽、髙 */
	int bmp_cx = abs(p_bmp->info_head.bi_width);
c0102a5b:	8b 45 08             	mov    0x8(%ebp),%eax
c0102a5e:	8b 50 12             	mov    0x12(%eax),%edx
c0102a61:	89 d0                	mov    %edx,%eax
c0102a63:	c1 f8 1f             	sar    $0x1f,%eax
c0102a66:	31 c2                	xor    %eax,%edx
c0102a68:	89 55 e8             	mov    %edx,-0x18(%ebp)
c0102a6b:	29 45 e8             	sub    %eax,-0x18(%ebp)
	int bmp_cy = abs(p_bmp->info_head.bi_height);
c0102a6e:	8b 45 08             	mov    0x8(%ebp),%eax
c0102a71:	8b 50 16             	mov    0x16(%eax),%edx
c0102a74:	89 d0                	mov    %edx,%eax
c0102a76:	c1 f8 1f             	sar    $0x1f,%eax
c0102a79:	31 c2                	xor    %eax,%edx
c0102a7b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c0102a7e:	29 45 e4             	sub    %eax,-0x1c(%ebp)
 
	int nBpline = (((bmp_cx*p_bmp->info_head.bi_bit_count + 31) >> 5) << 2);
c0102a81:	8b 45 08             	mov    0x8(%ebp),%eax
c0102a84:	0f b7 40 1c          	movzwl 0x1c(%eax),%eax
c0102a88:	0f b7 c0             	movzwl %ax,%eax
c0102a8b:	0f af 45 e8          	imul   -0x18(%ebp),%eax
c0102a8f:	83 c0 1f             	add    $0x1f,%eax
c0102a92:	c1 f8 05             	sar    $0x5,%eax
c0102a95:	c1 e0 02             	shl    $0x2,%eax
c0102a98:	89 45 e0             	mov    %eax,-0x20(%ebp)

	for(int j=0; j<bmp_cy; j++) {
c0102a9b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0102aa2:	e9 85 00 00 00       	jmp    c0102b2c <draw_bitmap+0xfd>
		for(int i=0; i<bmp_cx; i++) {
c0102aa7:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
c0102aae:	eb 70                	jmp    c0102b20 <draw_bitmap+0xf1>
			p_data = p_bmp_data_addr + nBpline*j + 3*i;
c0102ab0:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0102ab3:	0f af 45 f4          	imul   -0xc(%ebp),%eax
c0102ab7:	89 c1                	mov    %eax,%ecx
c0102ab9:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0102abc:	89 d0                	mov    %edx,%eax
c0102abe:	01 c0                	add    %eax,%eax
c0102ac0:	01 d0                	add    %edx,%eax
c0102ac2:	8d 14 01             	lea    (%ecx,%eax,1),%edx
c0102ac5:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102ac8:	01 d0                	add    %edx,%eax
c0102aca:	89 45 dc             	mov    %eax,-0x24(%ebp)
			setpixel(x0+i, y0+j, (rgb_t){p_data[2], p_data[1], p_data[0]});
c0102acd:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0102ad0:	0f b6 40 02          	movzbl 0x2(%eax),%eax
c0102ad4:	88 45 d9             	mov    %al,-0x27(%ebp)
c0102ad7:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0102ada:	0f b6 40 01          	movzbl 0x1(%eax),%eax
c0102ade:	88 45 da             	mov    %al,-0x26(%ebp)
c0102ae1:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0102ae4:	0f b6 00             	movzbl (%eax),%eax
c0102ae7:	88 45 db             	mov    %al,-0x25(%ebp)
c0102aea:	8b 55 10             	mov    0x10(%ebp),%edx
c0102aed:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102af0:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
c0102af3:	8b 55 0c             	mov    0xc(%ebp),%edx
c0102af6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102af9:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
c0102afc:	83 ec 04             	sub    $0x4,%esp
c0102aff:	83 ec 04             	sub    $0x4,%esp
c0102b02:	89 e0                	mov    %esp,%eax
c0102b04:	0f b7 55 d9          	movzwl -0x27(%ebp),%edx
c0102b08:	66 89 10             	mov    %dx,(%eax)
c0102b0b:	0f b6 55 db          	movzbl -0x25(%ebp),%edx
c0102b0f:	88 50 02             	mov    %dl,0x2(%eax)
c0102b12:	53                   	push   %ebx
c0102b13:	51                   	push   %ecx
c0102b14:	e8 ef f4 ff ff       	call   c0102008 <setpixel>
c0102b19:	83 c4 10             	add    $0x10,%esp
	int bmp_cy = abs(p_bmp->info_head.bi_height);
 
	int nBpline = (((bmp_cx*p_bmp->info_head.bi_bit_count + 31) >> 5) << 2);

	for(int j=0; j<bmp_cy; j++) {
		for(int i=0; i<bmp_cx; i++) {
c0102b1c:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
c0102b20:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102b23:	3b 45 e8             	cmp    -0x18(%ebp),%eax
c0102b26:	7c 88                	jl     c0102ab0 <draw_bitmap+0x81>
	int bmp_cx = abs(p_bmp->info_head.bi_width);
	int bmp_cy = abs(p_bmp->info_head.bi_height);
 
	int nBpline = (((bmp_cx*p_bmp->info_head.bi_bit_count + 31) >> 5) << 2);

	for(int j=0; j<bmp_cy; j++) {
c0102b28:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0102b2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102b2f:	3b 45 e4             	cmp    -0x1c(%ebp),%eax
c0102b32:	0f 8c 6f ff ff ff    	jl     c0102aa7 <draw_bitmap+0x78>
			p_data = p_bmp_data_addr + nBpline*j + 3*i;
			setpixel(x0+i, y0+j, (rgb_t){p_data[2], p_data[1], p_data[0]});
		}
	}

	return TRUE;
c0102b38:	b8 01 00 00 00       	mov    $0x1,%eax
}
c0102b3d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0102b40:	c9                   	leave  
c0102b41:	c3                   	ret    

c0102b42 <draw_bmp_test>:


void draw_bmp_test()
{
c0102b42:	55                   	push   %ebp
c0102b43:	89 e5                	mov    %esp,%ebp
c0102b45:	83 ec 08             	sub    $0x8,%esp
	draw_bitmap(p_bmp_icon, 820, 20);
c0102b48:	a1 80 3a 11 c0       	mov    0xc0113a80,%eax
c0102b4d:	83 ec 04             	sub    $0x4,%esp
c0102b50:	6a 14                	push   $0x14
c0102b52:	68 34 03 00 00       	push   $0x334
c0102b57:	50                   	push   %eax
c0102b58:	e8 d2 fe ff ff       	call   c0102a2f <draw_bitmap>
c0102b5d:	83 c4 10             	add    $0x10,%esp
c0102b60:	90                   	nop
c0102b61:	c9                   	leave  
c0102b62:	c3                   	ret    

c0102b63 <draw_asc16>:
#include <font.h>

static uint8_t* p_font_asc16_b = (uint8_t*)(FONT_ASC16_ADDR);

BOOL draw_asc16(char ch, point_t point, rgb_t c)
{
c0102b63:	55                   	push   %ebp
c0102b64:	89 e5                	mov    %esp,%ebp
c0102b66:	53                   	push   %ebx
c0102b67:	83 ec 24             	sub    $0x24,%esp
c0102b6a:	8b 45 08             	mov    0x8(%ebp),%eax
c0102b6d:	88 45 e4             	mov    %al,-0x1c(%ebp)
	uint8_t * p_asc = p_font_asc16_b + (uint8_t)ch * 16;   
c0102b70:	a1 84 3a 11 c0       	mov    0xc0113a84,%eax
c0102b75:	0f b6 55 e4          	movzbl -0x1c(%ebp),%edx
c0102b79:	0f b6 d2             	movzbl %dl,%edx
c0102b7c:	c1 e2 04             	shl    $0x4,%edx
c0102b7f:	01 d0                	add    %edx,%eax
c0102b81:	89 45 f4             	mov    %eax,-0xc(%ebp)

	for(int y=0; y<ASC16_HEIGHT; y++){
c0102b84:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
c0102b8b:	eb 61                	jmp    c0102bee <draw_asc16+0x8b>
		uint8_t testbit = 1 << 7;
c0102b8d:	c6 45 ef 80          	movb   $0x80,-0x11(%ebp)
		for(int x=0; x<ASC16_WIDTH; x++) 
c0102b91:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
c0102b98:	eb 46                	jmp    c0102be0 <draw_asc16+0x7d>
		{ 
			if(*p_asc & testbit)
c0102b9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102b9d:	0f b6 00             	movzbl (%eax),%eax
c0102ba0:	22 45 ef             	and    -0x11(%ebp),%al
c0102ba3:	84 c0                	test   %al,%al
c0102ba5:	74 32                	je     c0102bd9 <draw_asc16+0x76>
				setpixel(point.x+x, point.y+y, c); 
c0102ba7:	8b 55 10             	mov    0x10(%ebp),%edx
c0102baa:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102bad:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
c0102bb0:	8b 55 0c             	mov    0xc(%ebp),%edx
c0102bb3:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0102bb6:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
c0102bb9:	83 ec 04             	sub    $0x4,%esp
c0102bbc:	83 ec 04             	sub    $0x4,%esp
c0102bbf:	89 e0                	mov    %esp,%eax
c0102bc1:	0f b7 55 14          	movzwl 0x14(%ebp),%edx
c0102bc5:	66 89 10             	mov    %dx,(%eax)
c0102bc8:	0f b6 55 16          	movzbl 0x16(%ebp),%edx
c0102bcc:	88 50 02             	mov    %dl,0x2(%eax)
c0102bcf:	53                   	push   %ebx
c0102bd0:	51                   	push   %ecx
c0102bd1:	e8 32 f4 ff ff       	call   c0102008 <setpixel>
c0102bd6:	83 c4 10             	add    $0x10,%esp
			testbit >>= 1;
c0102bd9:	d0 6d ef             	shrb   -0x11(%ebp)
{
	uint8_t * p_asc = p_font_asc16_b + (uint8_t)ch * 16;   

	for(int y=0; y<ASC16_HEIGHT; y++){
		uint8_t testbit = 1 << 7;
		for(int x=0; x<ASC16_WIDTH; x++) 
c0102bdc:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
c0102be0:	83 7d e8 07          	cmpl   $0x7,-0x18(%ebp)
c0102be4:	7e b4                	jle    c0102b9a <draw_asc16+0x37>
		{ 
			if(*p_asc & testbit)
				setpixel(point.x+x, point.y+y, c); 
			testbit >>= 1;
		}
		p_asc ++;
c0102be6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

BOOL draw_asc16(char ch, point_t point, rgb_t c)
{
	uint8_t * p_asc = p_font_asc16_b + (uint8_t)ch * 16;   

	for(int y=0; y<ASC16_HEIGHT; y++){
c0102bea:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
c0102bee:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
c0102bf2:	7e 99                	jle    c0102b8d <draw_asc16+0x2a>
				setpixel(point.x+x, point.y+y, c); 
			testbit >>= 1;
		}
		p_asc ++;
	}
	return TRUE;
c0102bf4:	b8 01 00 00 00       	mov    $0x1,%eax
}
c0102bf9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0102bfc:	c9                   	leave  
c0102bfd:	c3                   	ret    

c0102bfe <draw_str16>:

BOOL draw_str16(char* ch, point_t point, rgb_t c)
{
c0102bfe:	55                   	push   %ebp
c0102bff:	89 e5                	mov    %esp,%ebp
c0102c01:	83 ec 28             	sub    $0x28,%esp
	unsigned char * p = ch;
c0102c04:	8b 45 08             	mov    0x8(%ebp),%eax
c0102c07:	89 45 f4             	mov    %eax,-0xc(%ebp)
	int x=point.x, y=point.y;
c0102c0a:	8b 45 0c             	mov    0xc(%ebp),%eax
c0102c0d:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0102c10:	8b 45 10             	mov    0x10(%ebp),%eax
c0102c13:	89 45 ec             	mov    %eax,-0x14(%ebp)
	while(*p != '\0') {
c0102c16:	eb 3f                	jmp    c0102c57 <draw_str16+0x59>
		draw_asc16(*p, (point_t){x, y}, c);
c0102c18:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102c1b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0102c1e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102c21:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0102c24:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102c27:	0f b6 00             	movzbl (%eax),%eax
c0102c2a:	0f be d0             	movsbl %al,%edx
c0102c2d:	83 ec 04             	sub    $0x4,%esp
c0102c30:	89 e0                	mov    %esp,%eax
c0102c32:	0f b7 4d 14          	movzwl 0x14(%ebp),%ecx
c0102c36:	66 89 08             	mov    %cx,(%eax)
c0102c39:	0f b6 4d 16          	movzbl 0x16(%ebp),%ecx
c0102c3d:	88 48 02             	mov    %cl,0x2(%eax)
c0102c40:	ff 75 e8             	pushl  -0x18(%ebp)
c0102c43:	ff 75 e4             	pushl  -0x1c(%ebp)
c0102c46:	52                   	push   %edx
c0102c47:	e8 17 ff ff ff       	call   c0102b63 <draw_asc16>
c0102c4c:	83 c4 10             	add    $0x10,%esp
		x += 8;
c0102c4f:	83 45 f0 08          	addl   $0x8,-0x10(%ebp)
		p++;
c0102c53:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)

BOOL draw_str16(char* ch, point_t point, rgb_t c)
{
	unsigned char * p = ch;
	int x=point.x, y=point.y;
	while(*p != '\0') {
c0102c57:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102c5a:	0f b6 00             	movzbl (%eax),%eax
c0102c5d:	84 c0                	test   %al,%al
c0102c5f:	75 b7                	jne    c0102c18 <draw_str16+0x1a>
		draw_asc16(*p, (point_t){x, y}, c);
		x += 8;
		p++;
	}
	return TRUE;
c0102c61:	b8 01 00 00 00       	mov    $0x1,%eax
c0102c66:	c9                   	leave  
c0102c67:	c3                   	ret    

c0102c68 <getcontent>:
#include <stringbuffer.h>

keybuf_t kb;

void getcontent(editbox_t *peb) 
{
c0102c68:	55                   	push   %ebp
c0102c69:	89 e5                	mov    %esp,%ebp
c0102c6b:	83 ec 08             	sub    $0x8,%esp
    keybuf_init(&kb);
c0102c6e:	83 ec 0c             	sub    $0xc,%esp
c0102c71:	68 a0 49 11 c0       	push   $0xc01149a0
c0102c76:	e8 3d 15 00 00       	call   c01041b8 <keybuf_init>
c0102c7b:	83 c4 10             	add    $0x10,%esp
	while(1) {
		edit_readline(peb);
c0102c7e:	83 ec 0c             	sub    $0xc,%esp
c0102c81:	ff 75 08             	pushl  0x8(%ebp)
c0102c84:	e8 6a 01 00 00       	call   c0102df3 <edit_readline>
c0102c89:	83 c4 10             	add    $0x10,%esp
        edit_runcmd(peb);
c0102c8c:	83 ec 0c             	sub    $0xc,%esp
c0102c8f:	ff 75 08             	pushl  0x8(%ebp)
c0102c92:	e8 5a 02 00 00       	call   c0102ef1 <edit_runcmd>
c0102c97:	83 c4 10             	add    $0x10,%esp
	} 
c0102c9a:	eb e2                	jmp    c0102c7e <getcontent+0x16>

c0102c9c <edit_putchar>:
}

void edit_putchar(char ch, editbox_t *peb) 
{
c0102c9c:	55                   	push   %ebp
c0102c9d:	89 e5                	mov    %esp,%ebp
c0102c9f:	53                   	push   %ebx
c0102ca0:	83 ec 24             	sub    $0x24,%esp
c0102ca3:	8b 45 08             	mov    0x8(%ebp),%eax
c0102ca6:	88 45 e4             	mov    %al,-0x1c(%ebp)
    if(ch == '\n' || ch == '\t') {
c0102ca9:	80 7d e4 0a          	cmpb   $0xa,-0x1c(%ebp)
c0102cad:	74 06                	je     c0102cb5 <edit_putchar+0x19>
c0102caf:	80 7d e4 09          	cmpb   $0x9,-0x1c(%ebp)
c0102cb3:	75 3c                	jne    c0102cf1 <edit_putchar+0x55>
        peb->cur_y ++;
c0102cb5:	8b 45 0c             	mov    0xc(%ebp),%eax
c0102cb8:	8b 40 1c             	mov    0x1c(%eax),%eax
c0102cbb:	8d 50 01             	lea    0x1(%eax),%edx
c0102cbe:	8b 45 0c             	mov    0xc(%ebp),%eax
c0102cc1:	89 50 1c             	mov    %edx,0x1c(%eax)
        peb->cur_x = 0;
c0102cc4:	8b 45 0c             	mov    0xc(%ebp),%eax
c0102cc7:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
        if(peb->cur_y >= peb->ch_y)
c0102cce:	8b 45 0c             	mov    0xc(%ebp),%eax
c0102cd1:	8b 50 1c             	mov    0x1c(%eax),%edx
c0102cd4:	8b 45 0c             	mov    0xc(%ebp),%eax
c0102cd7:	8b 40 0c             	mov    0xc(%eax),%eax
c0102cda:	39 c2                	cmp    %eax,%edx
c0102cdc:	0f 8c bf 00 00 00    	jl     c0102da1 <edit_putchar+0x105>
            peb->cur_y = 0;
c0102ce2:	8b 45 0c             	mov    0xc(%ebp),%eax
c0102ce5:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
        return;
c0102cec:	e9 b0 00 00 00       	jmp    c0102da1 <edit_putchar+0x105>
    } 
	int x = peb->point.x + peb->cur_x*ASC16_WIDTH;
c0102cf1:	8b 45 0c             	mov    0xc(%ebp),%eax
c0102cf4:	8b 10                	mov    (%eax),%edx
c0102cf6:	8b 45 0c             	mov    0xc(%ebp),%eax
c0102cf9:	8b 40 18             	mov    0x18(%eax),%eax
c0102cfc:	c1 e0 03             	shl    $0x3,%eax
c0102cff:	01 d0                	add    %edx,%eax
c0102d01:	89 45 f4             	mov    %eax,-0xc(%ebp)
	int y = peb->point.y + peb->cur_y*ASC16_HEIGHT;
c0102d04:	8b 45 0c             	mov    0xc(%ebp),%eax
c0102d07:	8b 50 04             	mov    0x4(%eax),%edx
c0102d0a:	8b 45 0c             	mov    0xc(%ebp),%eax
c0102d0d:	8b 40 1c             	mov    0x1c(%eax),%eax
c0102d10:	c1 e0 04             	shl    $0x4,%eax
c0102d13:	01 d0                	add    %edx,%eax
c0102d15:	89 45 f0             	mov    %eax,-0x10(%ebp)
	
	draw_asc16(ch, (point_t){x, y}, peb->text_c);
c0102d18:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102d1b:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0102d1e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102d21:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0102d24:	0f be 4d e4          	movsbl -0x1c(%ebp),%ecx
c0102d28:	8b 45 0c             	mov    0xc(%ebp),%eax
c0102d2b:	83 ec 04             	sub    $0x4,%esp
c0102d2e:	89 e2                	mov    %esp,%edx
c0102d30:	0f b7 58 13          	movzwl 0x13(%eax),%ebx
c0102d34:	66 89 1a             	mov    %bx,(%edx)
c0102d37:	0f b6 40 15          	movzbl 0x15(%eax),%eax
c0102d3b:	88 42 02             	mov    %al,0x2(%edx)
c0102d3e:	ff 75 ec             	pushl  -0x14(%ebp)
c0102d41:	ff 75 e8             	pushl  -0x18(%ebp)
c0102d44:	51                   	push   %ecx
c0102d45:	e8 19 fe ff ff       	call   c0102b63 <draw_asc16>
c0102d4a:	83 c4 10             	add    $0x10,%esp
	peb->cur_x ++;
c0102d4d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0102d50:	8b 40 18             	mov    0x18(%eax),%eax
c0102d53:	8d 50 01             	lea    0x1(%eax),%edx
c0102d56:	8b 45 0c             	mov    0xc(%ebp),%eax
c0102d59:	89 50 18             	mov    %edx,0x18(%eax)
	if(peb->cur_x >= peb->ch_x) {
c0102d5c:	8b 45 0c             	mov    0xc(%ebp),%eax
c0102d5f:	8b 50 18             	mov    0x18(%eax),%edx
c0102d62:	8b 45 0c             	mov    0xc(%ebp),%eax
c0102d65:	8b 40 08             	mov    0x8(%eax),%eax
c0102d68:	39 c2                	cmp    %eax,%edx
c0102d6a:	7c 19                	jl     c0102d85 <edit_putchar+0xe9>
		peb->cur_x = 0;
c0102d6c:	8b 45 0c             	mov    0xc(%ebp),%eax
c0102d6f:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
		peb->cur_y ++;
c0102d76:	8b 45 0c             	mov    0xc(%ebp),%eax
c0102d79:	8b 40 1c             	mov    0x1c(%eax),%eax
c0102d7c:	8d 50 01             	lea    0x1(%eax),%edx
c0102d7f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0102d82:	89 50 1c             	mov    %edx,0x1c(%eax)
	}
	if(peb->cur_y >= peb->ch_y) 
c0102d85:	8b 45 0c             	mov    0xc(%ebp),%eax
c0102d88:	8b 50 1c             	mov    0x1c(%eax),%edx
c0102d8b:	8b 45 0c             	mov    0xc(%ebp),%eax
c0102d8e:	8b 40 0c             	mov    0xc(%eax),%eax
c0102d91:	39 c2                	cmp    %eax,%edx
c0102d93:	7c 0d                	jl     c0102da2 <edit_putchar+0x106>
		peb->cur_y = 0;
c0102d95:	8b 45 0c             	mov    0xc(%ebp),%eax
c0102d98:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
c0102d9f:	eb 01                	jmp    c0102da2 <edit_putchar+0x106>
    if(ch == '\n' || ch == '\t') {
        peb->cur_y ++;
        peb->cur_x = 0;
        if(peb->cur_y >= peb->ch_y)
            peb->cur_y = 0;
        return;
c0102da1:	90                   	nop
		peb->cur_x = 0;
		peb->cur_y ++;
	}
	if(peb->cur_y >= peb->ch_y) 
		peb->cur_y = 0;
}
c0102da2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0102da5:	c9                   	leave  
c0102da6:	c3                   	ret    

c0102da7 <edit_putstr>:
void edit_putstr(char *str, editbox_t *peb)
{
c0102da7:	55                   	push   %ebp
c0102da8:	89 e5                	mov    %esp,%ebp
c0102daa:	83 ec 18             	sub    $0x18,%esp
    int length = strlen(str);
c0102dad:	83 ec 0c             	sub    $0xc,%esp
c0102db0:	ff 75 08             	pushl  0x8(%ebp)
c0102db3:	e8 87 08 00 00       	call   c010363f <strlen>
c0102db8:	83 c4 10             	add    $0x10,%esp
c0102dbb:	89 45 f0             	mov    %eax,-0x10(%ebp)
    for(int i=0; i<length; i++) {
c0102dbe:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0102dc5:	eb 21                	jmp    c0102de8 <edit_putstr+0x41>
        edit_putchar(*(str+i), peb);
c0102dc7:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0102dca:	8b 45 08             	mov    0x8(%ebp),%eax
c0102dcd:	01 d0                	add    %edx,%eax
c0102dcf:	0f b6 00             	movzbl (%eax),%eax
c0102dd2:	0f be c0             	movsbl %al,%eax
c0102dd5:	83 ec 08             	sub    $0x8,%esp
c0102dd8:	ff 75 0c             	pushl  0xc(%ebp)
c0102ddb:	50                   	push   %eax
c0102ddc:	e8 bb fe ff ff       	call   c0102c9c <edit_putchar>
c0102de1:	83 c4 10             	add    $0x10,%esp
		peb->cur_y = 0;
}
void edit_putstr(char *str, editbox_t *peb)
{
    int length = strlen(str);
    for(int i=0; i<length; i++) {
c0102de4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0102de8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102deb:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0102dee:	7c d7                	jl     c0102dc7 <edit_putstr+0x20>
        edit_putchar(*(str+i), peb);
    }
}
c0102df0:	90                   	nop
c0102df1:	c9                   	leave  
c0102df2:	c3                   	ret    

c0102df3 <edit_readline>:

void edit_readline(editbox_t *peb) 
{
c0102df3:	55                   	push   %ebp
c0102df4:	89 e5                	mov    %esp,%ebp
c0102df6:	83 ec 18             	sub    $0x18,%esp
    int i = 0 , c;
c0102df9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    memset(peb->ch,'\0',peb->ch_size);
c0102e00:	8b 45 08             	mov    0x8(%ebp),%eax
c0102e03:	8b 50 24             	mov    0x24(%eax),%edx
c0102e06:	8b 45 08             	mov    0x8(%ebp),%eax
c0102e09:	8b 40 20             	mov    0x20(%eax),%eax
c0102e0c:	83 ec 04             	sub    $0x4,%esp
c0102e0f:	52                   	push   %edx
c0102e10:	6a 00                	push   $0x0
c0102e12:	50                   	push   %eax
c0102e13:	e8 58 0b 00 00       	call   c0103970 <memset>
c0102e18:	83 c4 10             	add    $0x10,%esp
    while (1) {
        while((c=keybuf_pop(&kb)) == 0);
c0102e1b:	90                   	nop
c0102e1c:	83 ec 0c             	sub    $0xc,%esp
c0102e1f:	68 a0 49 11 c0       	push   $0xc01149a0
c0102e24:	e8 3e 14 00 00       	call   c0104267 <keybuf_pop>
c0102e29:	83 c4 10             	add    $0x10,%esp
c0102e2c:	0f be c0             	movsbl %al,%eax
c0102e2f:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0102e32:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0102e36:	74 e4                	je     c0102e1c <edit_readline+0x29>
        if (c < 0) {
c0102e38:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0102e3c:	0f 88 a9 00 00 00    	js     c0102eeb <edit_readline+0xf8>
            return NULL;
        }
        else if (c >= ' ' && i < 800 - 1) {
c0102e42:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
c0102e46:	7e 36                	jle    c0102e7e <edit_readline+0x8b>
c0102e48:	81 7d f4 1e 03 00 00 	cmpl   $0x31e,-0xc(%ebp)
c0102e4f:	7f 2d                	jg     c0102e7e <edit_readline+0x8b>
            peb->ch[i ++] = c;
c0102e51:	8b 45 08             	mov    0x8(%ebp),%eax
c0102e54:	8b 48 20             	mov    0x20(%eax),%ecx
c0102e57:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102e5a:	8d 50 01             	lea    0x1(%eax),%edx
c0102e5d:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0102e60:	01 c8                	add    %ecx,%eax
c0102e62:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0102e65:	88 10                	mov    %dl,(%eax)
            edit_putchar(c, peb);
c0102e67:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102e6a:	0f be c0             	movsbl %al,%eax
c0102e6d:	83 ec 08             	sub    $0x8,%esp
c0102e70:	ff 75 08             	pushl  0x8(%ebp)
c0102e73:	50                   	push   %eax
c0102e74:	e8 23 fe ff ff       	call   c0102c9c <edit_putchar>
c0102e79:	83 c4 10             	add    $0x10,%esp
c0102e7c:	eb 68                	jmp    c0102ee6 <edit_readline+0xf3>
        }
        else if (c == '\b' && i > 0) {
c0102e7e:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
c0102e82:	75 0c                	jne    c0102e90 <edit_readline+0x9d>
c0102e84:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0102e88:	7e 06                	jle    c0102e90 <edit_readline+0x9d>
            i --;
c0102e8a:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
c0102e8e:	eb 56                	jmp    c0102ee6 <edit_readline+0xf3>
        }
        else if (c == '\n' || c == '\r') {
c0102e90:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
c0102e94:	74 0a                	je     c0102ea0 <edit_readline+0xad>
c0102e96:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
c0102e9a:	0f 85 7b ff ff ff    	jne    c0102e1b <edit_readline+0x28>
            peb->ch[i] = '\0';  
c0102ea0:	8b 45 08             	mov    0x8(%ebp),%eax
c0102ea3:	8b 50 20             	mov    0x20(%eax),%edx
c0102ea6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102ea9:	01 d0                	add    %edx,%eax
c0102eab:	c6 00 00             	movb   $0x0,(%eax)
            peb->cur_x = 0;
c0102eae:	8b 45 08             	mov    0x8(%ebp),%eax
c0102eb1:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
			peb->cur_y ++;
c0102eb8:	8b 45 08             	mov    0x8(%ebp),%eax
c0102ebb:	8b 40 1c             	mov    0x1c(%eax),%eax
c0102ebe:	8d 50 01             	lea    0x1(%eax),%edx
c0102ec1:	8b 45 08             	mov    0x8(%ebp),%eax
c0102ec4:	89 50 1c             	mov    %edx,0x1c(%eax)
			if(peb->cur_y >= peb->ch_y-1) peb->ch_y = 0;
c0102ec7:	8b 45 08             	mov    0x8(%ebp),%eax
c0102eca:	8b 50 1c             	mov    0x1c(%eax),%edx
c0102ecd:	8b 45 08             	mov    0x8(%ebp),%eax
c0102ed0:	8b 40 0c             	mov    0xc(%eax),%eax
c0102ed3:	83 e8 01             	sub    $0x1,%eax
c0102ed6:	39 c2                	cmp    %eax,%edx
c0102ed8:	7c 14                	jl     c0102eee <edit_readline+0xfb>
c0102eda:	8b 45 08             	mov    0x8(%ebp),%eax
c0102edd:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
            return;
c0102ee4:	eb 08                	jmp    c0102eee <edit_readline+0xfb>
        }
    }
c0102ee6:	e9 30 ff ff ff       	jmp    c0102e1b <edit_readline+0x28>
    int i = 0 , c;
    memset(peb->ch,'\0',peb->ch_size);
    while (1) {
        while((c=keybuf_pop(&kb)) == 0);
        if (c < 0) {
            return NULL;
c0102eeb:	90                   	nop
c0102eec:	eb 01                	jmp    c0102eef <edit_readline+0xfc>
        else if (c == '\n' || c == '\r') {
            peb->ch[i] = '\0';  
            peb->cur_x = 0;
			peb->cur_y ++;
			if(peb->cur_y >= peb->ch_y-1) peb->ch_y = 0;
            return;
c0102eee:	90                   	nop
        }
    }
}
c0102eef:	c9                   	leave  
c0102ef0:	c3                   	ret    

c0102ef1 <edit_runcmd>:

void edit_runcmd(editbox_t *peb)
{   
c0102ef1:	55                   	push   %ebp
c0102ef2:	89 e5                	mov    %esp,%ebp
c0102ef4:	83 ec 08             	sub    $0x8,%esp
    if(strcmp(peb->ch, "hello") == 0)
c0102ef7:	8b 45 08             	mov    0x8(%ebp),%eax
c0102efa:	8b 40 20             	mov    0x20(%eax),%eax
c0102efd:	83 ec 08             	sub    $0x8,%esp
c0102f00:	68 6c 46 10 c0       	push   $0xc010466c
c0102f05:	50                   	push   %eax
c0102f06:	e8 06 08 00 00       	call   c0103711 <strcmp>
c0102f0b:	83 c4 10             	add    $0x10,%esp
c0102f0e:	85 c0                	test   %eax,%eax
c0102f10:	75 15                	jne    c0102f27 <edit_runcmd+0x36>
        edit_putstr("great\n", peb);
c0102f12:	83 ec 08             	sub    $0x8,%esp
c0102f15:	ff 75 08             	pushl  0x8(%ebp)
c0102f18:	68 72 46 10 c0       	push   $0xc0104672
c0102f1d:	e8 85 fe ff ff       	call   c0102da7 <edit_putstr>
c0102f22:	83 c4 10             	add    $0x10,%esp
    else if(strcmp(peb->ch, "who are you") == 0)
        edit_putstr("I am joker\n", peb);
    else if(strcmp(peb->ch, "kerninfo") == 0)
        print_kerninfo();
    else;
c0102f25:	eb 72                	jmp    c0102f99 <edit_runcmd+0xa8>

void edit_runcmd(editbox_t *peb)
{   
    if(strcmp(peb->ch, "hello") == 0)
        edit_putstr("great\n", peb);
    else if(strcmp(peb->ch, "system") == 0)
c0102f27:	8b 45 08             	mov    0x8(%ebp),%eax
c0102f2a:	8b 40 20             	mov    0x20(%eax),%eax
c0102f2d:	83 ec 08             	sub    $0x8,%esp
c0102f30:	68 79 46 10 c0       	push   $0xc0104679
c0102f35:	50                   	push   %eax
c0102f36:	e8 d6 07 00 00       	call   c0103711 <strcmp>
c0102f3b:	83 c4 10             	add    $0x10,%esp
c0102f3e:	85 c0                	test   %eax,%eax
c0102f40:	75 07                	jne    c0102f49 <edit_runcmd+0x58>
        draw_bmp_test();
c0102f42:	e8 fb fb ff ff       	call   c0102b42 <draw_bmp_test>
    else if(strcmp(peb->ch, "who are you") == 0)
        edit_putstr("I am joker\n", peb);
    else if(strcmp(peb->ch, "kerninfo") == 0)
        print_kerninfo();
    else;
c0102f47:	eb 50                	jmp    c0102f99 <edit_runcmd+0xa8>
{   
    if(strcmp(peb->ch, "hello") == 0)
        edit_putstr("great\n", peb);
    else if(strcmp(peb->ch, "system") == 0)
        draw_bmp_test();
    else if(strcmp(peb->ch, "who are you") == 0)
c0102f49:	8b 45 08             	mov    0x8(%ebp),%eax
c0102f4c:	8b 40 20             	mov    0x20(%eax),%eax
c0102f4f:	83 ec 08             	sub    $0x8,%esp
c0102f52:	68 80 46 10 c0       	push   $0xc0104680
c0102f57:	50                   	push   %eax
c0102f58:	e8 b4 07 00 00       	call   c0103711 <strcmp>
c0102f5d:	83 c4 10             	add    $0x10,%esp
c0102f60:	85 c0                	test   %eax,%eax
c0102f62:	75 15                	jne    c0102f79 <edit_runcmd+0x88>
        edit_putstr("I am joker\n", peb);
c0102f64:	83 ec 08             	sub    $0x8,%esp
c0102f67:	ff 75 08             	pushl  0x8(%ebp)
c0102f6a:	68 8c 46 10 c0       	push   $0xc010468c
c0102f6f:	e8 33 fe ff ff       	call   c0102da7 <edit_putstr>
c0102f74:	83 c4 10             	add    $0x10,%esp
    else if(strcmp(peb->ch, "kerninfo") == 0)
        print_kerninfo();
    else;
c0102f77:	eb 20                	jmp    c0102f99 <edit_runcmd+0xa8>
        edit_putstr("great\n", peb);
    else if(strcmp(peb->ch, "system") == 0)
        draw_bmp_test();
    else if(strcmp(peb->ch, "who are you") == 0)
        edit_putstr("I am joker\n", peb);
    else if(strcmp(peb->ch, "kerninfo") == 0)
c0102f79:	8b 45 08             	mov    0x8(%ebp),%eax
c0102f7c:	8b 40 20             	mov    0x20(%eax),%eax
c0102f7f:	83 ec 08             	sub    $0x8,%esp
c0102f82:	68 98 46 10 c0       	push   $0xc0104698
c0102f87:	50                   	push   %eax
c0102f88:	e8 84 07 00 00       	call   c0103711 <strcmp>
c0102f8d:	83 c4 10             	add    $0x10,%esp
c0102f90:	85 c0                	test   %eax,%eax
c0102f92:	75 05                	jne    c0102f99 <edit_runcmd+0xa8>
        print_kerninfo();
c0102f94:	e8 4e d8 ff ff       	call   c01007e7 <print_kerninfo>
    else;
c0102f99:	90                   	nop
c0102f9a:	c9                   	leave  
c0102f9b:	c3                   	ret    

c0102f9c <init_pmm_manager>:
struct Page *pages;

const struct pmm_manager *pmm_manager;

static void init_pmm_manager(void)
{
c0102f9c:	55                   	push   %ebp
c0102f9d:	89 e5                	mov    %esp,%ebp
c0102f9f:	83 ec 08             	sub    $0x8,%esp
	cprintf("init_pmm_manager\n");
c0102fa2:	83 ec 0c             	sub    $0xc,%esp
c0102fa5:	68 a4 46 10 c0       	push   $0xc01046a4
c0102faa:	e8 35 d1 ff ff       	call   c01000e4 <cprintf>
c0102faf:	83 c4 10             	add    $0x10,%esp
	pmm_manager = &buddy_pmm_manager;
c0102fb2:	c7 05 c8 49 11 c0 ac 	movl   $0xc01047ac,0xc01149c8
c0102fb9:	47 10 c0 
	cprintf("memory management: %s\n", pmm_manager->name);
c0102fbc:	a1 c8 49 11 c0       	mov    0xc01149c8,%eax
c0102fc1:	8b 00                	mov    (%eax),%eax
c0102fc3:	83 ec 08             	sub    $0x8,%esp
c0102fc6:	50                   	push   %eax
c0102fc7:	68 b6 46 10 c0       	push   $0xc01046b6
c0102fcc:	e8 13 d1 ff ff       	call   c01000e4 <cprintf>
c0102fd1:	83 c4 10             	add    $0x10,%esp
	pmm_manager->init();
c0102fd4:	a1 c8 49 11 c0       	mov    0xc01149c8,%eax
c0102fd9:	8b 40 04             	mov    0x4(%eax),%eax
c0102fdc:	ff d0                	call   *%eax
}
c0102fde:	90                   	nop
c0102fdf:	c9                   	leave  
c0102fe0:	c3                   	ret    

c0102fe1 <init_memmap>:

static void init_memmap(struct Page *base, size_t n)
{
c0102fe1:	55                   	push   %ebp
c0102fe2:	89 e5                	mov    %esp,%ebp
c0102fe4:	83 ec 08             	sub    $0x8,%esp
	pmm_manager->init_memmap(base, n);
c0102fe7:	a1 c8 49 11 c0       	mov    0xc01149c8,%eax
c0102fec:	8b 40 08             	mov    0x8(%eax),%eax
c0102fef:	83 ec 08             	sub    $0x8,%esp
c0102ff2:	ff 75 0c             	pushl  0xc(%ebp)
c0102ff5:	ff 75 08             	pushl  0x8(%ebp)
c0102ff8:	ff d0                	call   *%eax
c0102ffa:	83 c4 10             	add    $0x10,%esp
}
c0102ffd:	90                   	nop
c0102ffe:	c9                   	leave  
c0102fff:	c3                   	ret    

c0103000 <page_init>:

static void page_init(void)
{
c0103000:	55                   	push   %ebp
c0103001:	89 e5                	mov    %esp,%ebp
c0103003:	57                   	push   %edi
c0103004:	56                   	push   %esi
c0103005:	53                   	push   %ebx
c0103006:	83 ec 6c             	sub    $0x6c,%esp
	struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
c0103009:	c7 45 c0 00 80 00 c0 	movl   $0xc0008000,-0x40(%ebp)

	uint64_t maxpa = 0, begin, free_end;
c0103010:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
c0103017:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

	for (int i = 0; i < memmap->nr_map; ++i)
c010301e:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
c0103025:	e9 fa 00 00 00       	jmp    c0103124 <page_init+0x124>
	{
		begin = memmap->map[i].addr;
c010302a:	8b 4d c0             	mov    -0x40(%ebp),%ecx
c010302d:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0103030:	89 d0                	mov    %edx,%eax
c0103032:	c1 e0 02             	shl    $0x2,%eax
c0103035:	01 d0                	add    %edx,%eax
c0103037:	c1 e0 02             	shl    $0x2,%eax
c010303a:	01 c8                	add    %ecx,%eax
c010303c:	8b 50 08             	mov    0x8(%eax),%edx
c010303f:	8b 40 04             	mov    0x4(%eax),%eax
c0103042:	89 45 d8             	mov    %eax,-0x28(%ebp)
c0103045:	89 55 dc             	mov    %edx,-0x24(%ebp)
		free_end = begin + memmap->map[i].size;
c0103048:	8b 4d c0             	mov    -0x40(%ebp),%ecx
c010304b:	8b 55 cc             	mov    -0x34(%ebp),%edx
c010304e:	89 d0                	mov    %edx,%eax
c0103050:	c1 e0 02             	shl    $0x2,%eax
c0103053:	01 d0                	add    %edx,%eax
c0103055:	c1 e0 02             	shl    $0x2,%eax
c0103058:	01 c8                	add    %ecx,%eax
c010305a:	8b 48 0c             	mov    0xc(%eax),%ecx
c010305d:	8b 58 10             	mov    0x10(%eax),%ebx
c0103060:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0103063:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103066:	01 c8                	add    %ecx,%eax
c0103068:	11 da                	adc    %ebx,%edx
c010306a:	89 45 d0             	mov    %eax,-0x30(%ebp)
c010306d:	89 55 d4             	mov    %edx,-0x2c(%ebp)
		cprintf("map[%d]: begin:%08llx free_end:%08llx size:%08llx type:%d\n", 
c0103070:	8b 4d c0             	mov    -0x40(%ebp),%ecx
c0103073:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0103076:	89 d0                	mov    %edx,%eax
c0103078:	c1 e0 02             	shl    $0x2,%eax
c010307b:	01 d0                	add    %edx,%eax
c010307d:	c1 e0 02             	shl    $0x2,%eax
c0103080:	01 c8                	add    %ecx,%eax
c0103082:	83 c0 14             	add    $0x14,%eax
c0103085:	8b 00                	mov    (%eax),%eax
c0103087:	89 45 94             	mov    %eax,-0x6c(%ebp)
c010308a:	8b 4d c0             	mov    -0x40(%ebp),%ecx
c010308d:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0103090:	89 d0                	mov    %edx,%eax
c0103092:	c1 e0 02             	shl    $0x2,%eax
c0103095:	01 d0                	add    %edx,%eax
c0103097:	c1 e0 02             	shl    $0x2,%eax
c010309a:	01 c8                	add    %ecx,%eax
c010309c:	8b 48 0c             	mov    0xc(%eax),%ecx
c010309f:	8b 58 10             	mov    0x10(%eax),%ebx
c01030a2:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01030a5:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01030a8:	83 c0 ff             	add    $0xffffffff,%eax
c01030ab:	83 d2 ff             	adc    $0xffffffff,%edx
c01030ae:	83 ec 0c             	sub    $0xc,%esp
c01030b1:	ff 75 94             	pushl  -0x6c(%ebp)
c01030b4:	53                   	push   %ebx
c01030b5:	51                   	push   %ecx
c01030b6:	52                   	push   %edx
c01030b7:	50                   	push   %eax
c01030b8:	ff 75 dc             	pushl  -0x24(%ebp)
c01030bb:	ff 75 d8             	pushl  -0x28(%ebp)
c01030be:	ff 75 cc             	pushl  -0x34(%ebp)
c01030c1:	68 d0 46 10 c0       	push   $0xc01046d0
c01030c6:	e8 19 d0 ff ff       	call   c01000e4 <cprintf>
c01030cb:	83 c4 30             	add    $0x30,%esp
			i, begin, free_end-1, memmap->map[i].size, memmap->map[i].type);
		if(memmap->map[i].type == E820_ARM) {
c01030ce:	8b 4d c0             	mov    -0x40(%ebp),%ecx
c01030d1:	8b 55 cc             	mov    -0x34(%ebp),%edx
c01030d4:	89 d0                	mov    %edx,%eax
c01030d6:	c1 e0 02             	shl    $0x2,%eax
c01030d9:	01 d0                	add    %edx,%eax
c01030db:	c1 e0 02             	shl    $0x2,%eax
c01030de:	01 c8                	add    %ecx,%eax
c01030e0:	83 c0 14             	add    $0x14,%eax
c01030e3:	8b 00                	mov    (%eax),%eax
c01030e5:	83 f8 01             	cmp    $0x1,%eax
c01030e8:	75 36                	jne    c0103120 <page_init+0x120>
			if(maxpa < free_end && begin < KMEMSIZE)
c01030ea:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01030ed:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01030f0:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c01030f3:	77 2b                	ja     c0103120 <page_init+0x120>
c01030f5:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c01030f8:	72 05                	jb     c01030ff <page_init+0xff>
c01030fa:	3b 45 d0             	cmp    -0x30(%ebp),%eax
c01030fd:	73 21                	jae    c0103120 <page_init+0x120>
c01030ff:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0103103:	77 1b                	ja     c0103120 <page_init+0x120>
c0103105:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0103109:	72 09                	jb     c0103114 <page_init+0x114>
c010310b:	81 7d d8 ff ff ff 37 	cmpl   $0x37ffffff,-0x28(%ebp)
c0103112:	77 0c                	ja     c0103120 <page_init+0x120>
				maxpa = free_end;
c0103114:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0103117:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010311a:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010311d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
{
	struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);

	uint64_t maxpa = 0, begin, free_end;

	for (int i = 0; i < memmap->nr_map; ++i)
c0103120:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
c0103124:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0103127:	8b 00                	mov    (%eax),%eax
c0103129:	3b 45 cc             	cmp    -0x34(%ebp),%eax
c010312c:	0f 8f f8 fe ff ff    	jg     c010302a <page_init+0x2a>
		if(memmap->map[i].type == E820_ARM) {
			if(maxpa < free_end && begin < KMEMSIZE)
				maxpa = free_end;
		}
	}
	if(maxpa > KMEMSIZE) maxpa = KMEMSIZE;
c0103132:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0103136:	72 1d                	jb     c0103155 <page_init+0x155>
c0103138:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010313c:	77 09                	ja     c0103147 <page_init+0x147>
c010313e:	81 7d e0 00 00 00 38 	cmpl   $0x38000000,-0x20(%ebp)
c0103145:	76 0e                	jbe    c0103155 <page_init+0x155>
c0103147:	c7 45 e0 00 00 00 38 	movl   $0x38000000,-0x20(%ebp)
c010314e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

	extern char end[];

	npage = maxpa / PGSIZE;
c0103155:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103158:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010315b:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c010315f:	c1 ea 0c             	shr    $0xc,%edx
c0103162:	a3 e4 48 11 c0       	mov    %eax,0xc01148e4
	pages = (struct Page *)ROUND_UP((void*)end, PGSIZE);
c0103167:	c7 45 bc 00 10 00 00 	movl   $0x1000,-0x44(%ebp)
c010316e:	b8 d0 49 11 c0       	mov    $0xc01149d0,%eax
c0103173:	8d 50 ff             	lea    -0x1(%eax),%edx
c0103176:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0103179:	01 d0                	add    %edx,%eax
c010317b:	89 45 b8             	mov    %eax,-0x48(%ebp)
c010317e:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0103181:	ba 00 00 00 00       	mov    $0x0,%edx
c0103186:	f7 75 bc             	divl   -0x44(%ebp)
c0103189:	8b 45 b8             	mov    -0x48(%ebp),%eax
c010318c:	29 d0                	sub    %edx,%eax
c010318e:	a3 cc 49 11 c0       	mov    %eax,0xc01149cc

	for(int i=0; i<npage; ++i)
c0103193:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
c010319a:	eb 24                	jmp    c01031c0 <page_init+0x1c0>
		SetPageReserved(pages+i);
c010319c:	a1 cc 49 11 c0       	mov    0xc01149cc,%eax
c01031a1:	8b 55 c8             	mov    -0x38(%ebp),%edx
c01031a4:	c1 e2 04             	shl    $0x4,%edx
c01031a7:	01 d0                	add    %edx,%eax
c01031a9:	c7 45 a0 00 00 00 00 	movl   $0x0,-0x60(%ebp)
c01031b0:	89 45 9c             	mov    %eax,-0x64(%ebp)
static inline void set_bit(int nr, volatile void *addr) __attribute__((always_inline));
static inline void clear_bit(int nr, volatile void *addr) __attribute__((always_inline));

static inline void set_bit(int nr, volatile void *addr)
{
	asm volatile ("btsl %1, %0" :"=m" (*(volatile long*)addr) : "Ir" (nr));
c01031b3:	8b 45 9c             	mov    -0x64(%ebp),%eax
c01031b6:	8b 55 a0             	mov    -0x60(%ebp),%edx
c01031b9:	0f ab 10             	bts    %edx,(%eax)
	extern char end[];

	npage = maxpa / PGSIZE;
	pages = (struct Page *)ROUND_UP((void*)end, PGSIZE);

	for(int i=0; i<npage; ++i)
c01031bc:	83 45 c8 01          	addl   $0x1,-0x38(%ebp)
c01031c0:	8b 55 c8             	mov    -0x38(%ebp),%edx
c01031c3:	a1 e4 48 11 c0       	mov    0xc01148e4,%eax
c01031c8:	39 c2                	cmp    %eax,%edx
c01031ca:	72 d0                	jb     c010319c <page_init+0x19c>
		SetPageReserved(pages+i);

	uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page)*npage);
c01031cc:	a1 e4 48 11 c0       	mov    0xc01148e4,%eax
c01031d1:	c1 e0 04             	shl    $0x4,%eax
c01031d4:	89 c2                	mov    %eax,%edx
c01031d6:	a1 cc 49 11 c0       	mov    0xc01149cc,%eax
c01031db:	01 d0                	add    %edx,%eax
c01031dd:	89 45 b4             	mov    %eax,-0x4c(%ebp)
c01031e0:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c01031e3:	05 00 00 00 40       	add    $0x40000000,%eax
c01031e8:	89 45 b0             	mov    %eax,-0x50(%ebp)

	for (int i=0; i<memmap->nr_map; ++i) {
c01031eb:	c7 45 c4 00 00 00 00 	movl   $0x0,-0x3c(%ebp)
c01031f2:	e9 79 01 00 00       	jmp    c0103370 <page_init+0x370>
		begin = memmap->map[i].addr;
c01031f7:	8b 4d c0             	mov    -0x40(%ebp),%ecx
c01031fa:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c01031fd:	89 d0                	mov    %edx,%eax
c01031ff:	c1 e0 02             	shl    $0x2,%eax
c0103202:	01 d0                	add    %edx,%eax
c0103204:	c1 e0 02             	shl    $0x2,%eax
c0103207:	01 c8                	add    %ecx,%eax
c0103209:	8b 50 08             	mov    0x8(%eax),%edx
c010320c:	8b 40 04             	mov    0x4(%eax),%eax
c010320f:	89 45 d8             	mov    %eax,-0x28(%ebp)
c0103212:	89 55 dc             	mov    %edx,-0x24(%ebp)
		free_end = begin + memmap->map[i].size;
c0103215:	8b 4d c0             	mov    -0x40(%ebp),%ecx
c0103218:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c010321b:	89 d0                	mov    %edx,%eax
c010321d:	c1 e0 02             	shl    $0x2,%eax
c0103220:	01 d0                	add    %edx,%eax
c0103222:	c1 e0 02             	shl    $0x2,%eax
c0103225:	01 c8                	add    %ecx,%eax
c0103227:	8b 48 0c             	mov    0xc(%eax),%ecx
c010322a:	8b 58 10             	mov    0x10(%eax),%ebx
c010322d:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0103230:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103233:	01 c8                	add    %ecx,%eax
c0103235:	11 da                	adc    %ebx,%edx
c0103237:	89 45 d0             	mov    %eax,-0x30(%ebp)
c010323a:	89 55 d4             	mov    %edx,-0x2c(%ebp)
		if(memmap->map[i].type == E820_ARM) 
c010323d:	8b 4d c0             	mov    -0x40(%ebp),%ecx
c0103240:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c0103243:	89 d0                	mov    %edx,%eax
c0103245:	c1 e0 02             	shl    $0x2,%eax
c0103248:	01 d0                	add    %edx,%eax
c010324a:	c1 e0 02             	shl    $0x2,%eax
c010324d:	01 c8                	add    %ecx,%eax
c010324f:	83 c0 14             	add    $0x14,%eax
c0103252:	8b 00                	mov    (%eax),%eax
c0103254:	83 f8 01             	cmp    $0x1,%eax
c0103257:	0f 85 0f 01 00 00    	jne    c010336c <page_init+0x36c>
		{
			if(begin < freemem) begin = freemem;
c010325d:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0103260:	ba 00 00 00 00       	mov    $0x0,%edx
c0103265:	3b 55 dc             	cmp    -0x24(%ebp),%edx
c0103268:	72 17                	jb     c0103281 <page_init+0x281>
c010326a:	3b 55 dc             	cmp    -0x24(%ebp),%edx
c010326d:	77 05                	ja     c0103274 <page_init+0x274>
c010326f:	3b 45 d8             	cmp    -0x28(%ebp),%eax
c0103272:	76 0d                	jbe    c0103281 <page_init+0x281>
c0103274:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0103277:	89 45 d8             	mov    %eax,-0x28(%ebp)
c010327a:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
			if(free_end > KMEMSIZE) free_end = KMEMSIZE;
c0103281:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
c0103285:	72 1d                	jb     c01032a4 <page_init+0x2a4>
c0103287:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
c010328b:	77 09                	ja     c0103296 <page_init+0x296>
c010328d:	81 7d d0 00 00 00 38 	cmpl   $0x38000000,-0x30(%ebp)
c0103294:	76 0e                	jbe    c01032a4 <page_init+0x2a4>
c0103296:	c7 45 d0 00 00 00 38 	movl   $0x38000000,-0x30(%ebp)
c010329d:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
			if(begin < free_end) 
c01032a4:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01032a7:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01032aa:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c01032ad:	0f 87 b9 00 00 00    	ja     c010336c <page_init+0x36c>
c01032b3:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c01032b6:	72 09                	jb     c01032c1 <page_init+0x2c1>
c01032b8:	3b 45 d0             	cmp    -0x30(%ebp),%eax
c01032bb:	0f 83 ab 00 00 00    	jae    c010336c <page_init+0x36c>
			{
				begin = ROUND_UP(begin, PGSIZE);
c01032c1:	c7 45 ac 00 10 00 00 	movl   $0x1000,-0x54(%ebp)
c01032c8:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01032cb:	8b 45 ac             	mov    -0x54(%ebp),%eax
c01032ce:	01 d0                	add    %edx,%eax
c01032d0:	83 e8 01             	sub    $0x1,%eax
c01032d3:	89 45 a8             	mov    %eax,-0x58(%ebp)
c01032d6:	8b 45 a8             	mov    -0x58(%ebp),%eax
c01032d9:	ba 00 00 00 00       	mov    $0x0,%edx
c01032de:	f7 75 ac             	divl   -0x54(%ebp)
c01032e1:	8b 45 a8             	mov    -0x58(%ebp),%eax
c01032e4:	29 d0                	sub    %edx,%eax
c01032e6:	ba 00 00 00 00       	mov    $0x0,%edx
c01032eb:	89 45 d8             	mov    %eax,-0x28(%ebp)
c01032ee:	89 55 dc             	mov    %edx,-0x24(%ebp)
				free_end = ROUND_DOWN(free_end, PGSIZE);
c01032f1:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01032f4:	89 45 a4             	mov    %eax,-0x5c(%ebp)
c01032f7:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c01032fa:	ba 00 00 00 00       	mov    $0x0,%edx
c01032ff:	89 c3                	mov    %eax,%ebx
c0103301:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
c0103307:	89 de                	mov    %ebx,%esi
c0103309:	89 d0                	mov    %edx,%eax
c010330b:	83 e0 00             	and    $0x0,%eax
c010330e:	89 c7                	mov    %eax,%edi
c0103310:	89 75 d0             	mov    %esi,-0x30(%ebp)
c0103313:	89 7d d4             	mov    %edi,-0x2c(%ebp)
				if(begin < free_end) {
c0103316:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0103319:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010331c:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c010331f:	77 4b                	ja     c010336c <page_init+0x36c>
c0103321:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c0103324:	72 05                	jb     c010332b <page_init+0x32b>
c0103326:	3b 45 d0             	cmp    -0x30(%ebp),%eax
c0103329:	73 41                	jae    c010336c <page_init+0x36c>
					cprintf("------- begin:%8llx free_end:%8llx\n", begin, free_end);
c010332b:	83 ec 0c             	sub    $0xc,%esp
c010332e:	ff 75 d4             	pushl  -0x2c(%ebp)
c0103331:	ff 75 d0             	pushl  -0x30(%ebp)
c0103334:	ff 75 dc             	pushl  -0x24(%ebp)
c0103337:	ff 75 d8             	pushl  -0x28(%ebp)
c010333a:	68 0c 47 10 c0       	push   $0xc010470c
c010333f:	e8 a0 cd ff ff       	call   c01000e4 <cprintf>
c0103344:	83 c4 20             	add    $0x20,%esp
					init_memmap(begin, (free_end-begin)/PGSIZE);
c0103347:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010334a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010334d:	2b 45 d8             	sub    -0x28(%ebp),%eax
c0103350:	1b 55 dc             	sbb    -0x24(%ebp),%edx
c0103353:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c0103357:	c1 ea 0c             	shr    $0xc,%edx
c010335a:	89 c2                	mov    %eax,%edx
c010335c:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010335f:	83 ec 08             	sub    $0x8,%esp
c0103362:	52                   	push   %edx
c0103363:	50                   	push   %eax
c0103364:	e8 78 fc ff ff       	call   c0102fe1 <init_memmap>
c0103369:	83 c4 10             	add    $0x10,%esp
	for(int i=0; i<npage; ++i)
		SetPageReserved(pages+i);

	uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page)*npage);

	for (int i=0; i<memmap->nr_map; ++i) {
c010336c:	83 45 c4 01          	addl   $0x1,-0x3c(%ebp)
c0103370:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0103373:	8b 00                	mov    (%eax),%eax
c0103375:	3b 45 c4             	cmp    -0x3c(%ebp),%eax
c0103378:	0f 8f 79 fe ff ff    	jg     c01031f7 <page_init+0x1f7>
					init_memmap(begin, (free_end-begin)/PGSIZE);
				}
			}
		}
	}
	cprintf("free_end:%x \n", free_end);
c010337e:	83 ec 04             	sub    $0x4,%esp
c0103381:	ff 75 d4             	pushl  -0x2c(%ebp)
c0103384:	ff 75 d0             	pushl  -0x30(%ebp)
c0103387:	68 30 47 10 c0       	push   $0xc0104730
c010338c:	e8 53 cd ff ff       	call   c01000e4 <cprintf>
c0103391:	83 c4 10             	add    $0x10,%esp

	cprintf("maxpa:%x \n", maxpa);
c0103394:	83 ec 04             	sub    $0x4,%esp
c0103397:	ff 75 e4             	pushl  -0x1c(%ebp)
c010339a:	ff 75 e0             	pushl  -0x20(%ebp)
c010339d:	68 3e 47 10 c0       	push   $0xc010473e
c01033a2:	e8 3d cd ff ff       	call   c01000e4 <cprintf>
c01033a7:	83 c4 10             	add    $0x10,%esp
	cprintf("npage:%d  pages:%x", npage, pages);
c01033aa:	8b 15 cc 49 11 c0    	mov    0xc01149cc,%edx
c01033b0:	a1 e4 48 11 c0       	mov    0xc01148e4,%eax
c01033b5:	83 ec 04             	sub    $0x4,%esp
c01033b8:	52                   	push   %edx
c01033b9:	50                   	push   %eax
c01033ba:	68 49 47 10 c0       	push   $0xc0104749
c01033bf:	e8 20 cd ff ff       	call   c01000e4 <cprintf>
c01033c4:	83 c4 10             	add    $0x10,%esp
}
c01033c7:	90                   	nop
c01033c8:	8d 65 f4             	lea    -0xc(%ebp),%esp
c01033cb:	5b                   	pop    %ebx
c01033cc:	5e                   	pop    %esi
c01033cd:	5f                   	pop    %edi
c01033ce:	5d                   	pop    %ebp
c01033cf:	c3                   	ret    

c01033d0 <check_alloc_page>:
static void check_alloc_page()
{
c01033d0:	55                   	push   %ebp
c01033d1:	89 e5                	mov    %esp,%ebp
c01033d3:	83 ec 08             	sub    $0x8,%esp
	pmm_manager->check();
c01033d6:	a1 c8 49 11 c0       	mov    0xc01149c8,%eax
c01033db:	8b 40 14             	mov    0x14(%eax),%eax
c01033de:	ff d0                	call   *%eax
}
c01033e0:	90                   	nop
c01033e1:	c9                   	leave  
c01033e2:	c3                   	ret    

c01033e3 <gdt_init>:
static void gdt_init(void)
{
c01033e3:	55                   	push   %ebp
c01033e4:	89 e5                	mov    %esp,%ebp
	// set boot kernel stack and default SS0
//	ts.ts_esp0 = (uintptr_t)bootstacktop;

}
c01033e6:	90                   	nop
c01033e7:	5d                   	pop    %ebp
c01033e8:	c3                   	ret    

c01033e9 <pmm_init>:
void pmm_init(void) 
{
c01033e9:	55                   	push   %ebp
c01033ea:	89 e5                	mov    %esp,%ebp
c01033ec:	83 ec 08             	sub    $0x8,%esp
	init_pmm_manager();
c01033ef:	e8 a8 fb ff ff       	call   c0102f9c <init_pmm_manager>
	while(1) { }
c01033f4:	eb fe                	jmp    c01033f4 <pmm_init+0xb>

c01033f6 <test_bit>:
static inline void clear_bit(int nr, volatile void *addr)
{
	asm volatile ("btcl %1, %0" :"=m" (*(volatile long*)addr) : "Ir" (nr));
}
static inline bool test_bit(int nr, volatile void *addr) 
{
c01033f6:	55                   	push   %ebp
c01033f7:	89 e5                	mov    %esp,%ebp
c01033f9:	83 ec 10             	sub    $0x10,%esp
	int oldbit;
	asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01033fc:	8b 45 0c             	mov    0xc(%ebp),%eax
c01033ff:	8b 55 08             	mov    0x8(%ebp),%edx
c0103402:	0f a3 10             	bt     %edx,(%eax)
c0103405:	19 c0                	sbb    %eax,%eax
c0103407:	89 45 fc             	mov    %eax,-0x4(%ebp)
	return oldbit != 0;
c010340a:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c010340e:	0f 95 c0             	setne  %al
c0103411:	0f b6 c0             	movzbl %al,%eax
c0103414:	c9                   	leave  
c0103415:	c3                   	ret    

c0103416 <buddy_init>:

#define free_list(x) (free_area[x].free_list)
#define nr_free(x) (free_area[x].nr_free)

static void buddy_init(void)
{
c0103416:	55                   	push   %ebp
c0103417:	89 e5                	mov    %esp,%ebp
c0103419:	83 ec 08             	sub    $0x8,%esp
	while(1) {
	    cprintf("buddy-");
c010341c:	83 ec 0c             	sub    $0xc,%esp
c010341f:	68 5c 47 10 c0       	push   $0xc010475c
c0103424:	e8 bb cc ff ff       	call   c01000e4 <cprintf>
c0103429:	83 c4 10             	add    $0x10,%esp
	}
c010342c:	eb ee                	jmp    c010341c <buddy_init+0x6>

c010342e <buddy_init_memmap>:
	}
	while(1){}
}

static void buddy_init_memmap(struct Page *base, size_t n)
{
c010342e:	55                   	push   %ebp
c010342f:	89 e5                	mov    %esp,%ebp
c0103431:	83 ec 38             	sub    $0x38,%esp
	struct Page *p = base;
c0103434:	8b 45 08             	mov    0x8(%ebp),%eax
c0103437:	89 45 f4             	mov    %eax,-0xc(%ebp)
	for (; p != base + n; p++) {
c010343a:	eb 19                	jmp    c0103455 <buddy_init_memmap+0x27>
//		if(!PageReserved(p))
//			cprintf("ERROR: buddy_init_memmap #1\n");
		p->flags = p->order = 0;
c010343c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010343f:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
c0103446:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103449:	8b 50 04             	mov    0x4(%eax),%edx
c010344c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010344f:	89 10                	mov    %edx,(%eax)
}

static void buddy_init_memmap(struct Page *base, size_t n)
{
	struct Page *p = base;
	for (; p != base + n; p++) {
c0103451:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
c0103455:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103458:	c1 e0 04             	shl    $0x4,%eax
c010345b:	89 c2                	mov    %eax,%edx
c010345d:	8b 45 08             	mov    0x8(%ebp),%eax
c0103460:	01 d0                	add    %edx,%eax
c0103462:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0103465:	75 d5                	jne    c010343c <buddy_init_memmap+0xe>
//		if(!PageReserved(p))
//			cprintf("ERROR: buddy_init_memmap #1\n");
		p->flags = p->order = 0;
	}
	p = base;
c0103467:	8b 45 08             	mov    0x8(%ebp),%eax
c010346a:	89 45 f4             	mov    %eax,-0xc(%ebp)
	size_t order = MAX_ORDER, order_size = (1<<order);
c010346d:	c7 45 f0 0a 00 00 00 	movl   $0xa,-0x10(%ebp)
c0103474:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103477:	ba 01 00 00 00       	mov    $0x1,%edx
c010347c:	89 c1                	mov    %eax,%ecx
c010347e:	d3 e2                	shl    %cl,%edx
c0103480:	89 d0                	mov    %edx,%eax
c0103482:	89 45 ec             	mov    %eax,-0x14(%ebp)
	while (n != 0) {
c0103485:	e9 02 01 00 00       	jmp    c010358c <buddy_init_memmap+0x15e>
		while(n >= order_size) {
			p->order = 1;
c010348a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010348d:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
			cprintf("wtf:%d p:%8x", p->order, p);
c0103494:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103497:	8b 40 04             	mov    0x4(%eax),%eax
c010349a:	83 ec 04             	sub    $0x4,%esp
c010349d:	ff 75 f4             	pushl  -0xc(%ebp)
c01034a0:	50                   	push   %eax
c01034a1:	68 63 47 10 c0       	push   $0xc0104763
c01034a6:	e8 39 cc ff ff       	call   c01000e4 <cprintf>
c01034ab:	83 c4 10             	add    $0x10,%esp
			SetPageReserved(p);
c01034ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01034b1:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
c01034b8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
static inline void set_bit(int nr, volatile void *addr) __attribute__((always_inline));
static inline void clear_bit(int nr, volatile void *addr) __attribute__((always_inline));

static inline void set_bit(int nr, volatile void *addr)
{
	asm volatile ("btsl %1, %0" :"=m" (*(volatile long*)addr) : "Ir" (nr));
c01034bb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01034be:	8b 55 e8             	mov    -0x18(%ebp),%edx
c01034c1:	0f ab 10             	bts    %edx,(%eax)
			cprintf("order:%d flags:%x >  ", order, p->flags);
c01034c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01034c7:	8b 00                	mov    (%eax),%eax
c01034c9:	83 ec 04             	sub    $0x4,%esp
c01034cc:	50                   	push   %eax
c01034cd:	ff 75 f0             	pushl  -0x10(%ebp)
c01034d0:	68 70 47 10 c0       	push   $0xc0104770
c01034d5:	e8 0a cc ff ff       	call   c01000e4 <cprintf>
c01034da:	83 c4 10             	add    $0x10,%esp
			list_add(&free_list(order), &(p->page_link));
c01034dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01034e0:	8d 48 08             	lea    0x8(%eax),%ecx
c01034e3:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01034e6:	89 d0                	mov    %edx,%eax
c01034e8:	01 c0                	add    %eax,%eax
c01034ea:	01 d0                	add    %edx,%eax
c01034ec:	c1 e0 02             	shl    $0x2,%eax
c01034ef:	05 00 49 11 c0       	add    $0xc0114900,%eax
c01034f4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01034f7:	89 4d e0             	mov    %ecx,-0x20(%ebp)
c01034fa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01034fd:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0103500:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103503:	89 45 d8             	mov    %eax,-0x28(%ebp)
	pcur->prev = pnode;
}

inline void list_add_after(list_entry_t * pcur, list_entry_t * pnode)
{
	pcur->next->prev = pnode;
c0103506:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103509:	8b 40 04             	mov    0x4(%eax),%eax
c010350c:	8b 55 d8             	mov    -0x28(%ebp),%edx
c010350f:	89 10                	mov    %edx,(%eax)
	pnode->next = pcur->next;
c0103511:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103514:	8b 50 04             	mov    0x4(%eax),%edx
c0103517:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010351a:	89 50 04             	mov    %edx,0x4(%eax)
	pnode->prev = pcur;
c010351d:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0103520:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103523:	89 10                	mov    %edx,(%eax)
	pcur->next = pnode;
c0103525:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103528:	8b 55 d8             	mov    -0x28(%ebp),%edx
c010352b:	89 50 04             	mov    %edx,0x4(%eax)
			p += order_size;
c010352e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103531:	c1 e0 04             	shl    $0x4,%eax
c0103534:	01 45 f4             	add    %eax,-0xc(%ebp)
			n -= order_size;
c0103537:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010353a:	29 45 0c             	sub    %eax,0xc(%ebp)
			nr_free(order)++;
c010353d:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0103540:	89 d0                	mov    %edx,%eax
c0103542:	01 c0                	add    %eax,%eax
c0103544:	01 d0                	add    %edx,%eax
c0103546:	c1 e0 02             	shl    $0x2,%eax
c0103549:	05 08 49 11 c0       	add    $0xc0114908,%eax
c010354e:	8b 00                	mov    (%eax),%eax
c0103550:	8d 48 01             	lea    0x1(%eax),%ecx
c0103553:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0103556:	89 d0                	mov    %edx,%eax
c0103558:	01 c0                	add    %eax,%eax
c010355a:	01 d0                	add    %edx,%eax
c010355c:	c1 e0 02             	shl    $0x2,%eax
c010355f:	05 08 49 11 c0       	add    $0xc0114908,%eax
c0103564:	89 08                	mov    %ecx,(%eax)

			cprintf("list order=%d ++\n", order);
c0103566:	83 ec 08             	sub    $0x8,%esp
c0103569:	ff 75 f0             	pushl  -0x10(%ebp)
c010356c:	68 86 47 10 c0       	push   $0xc0104786
c0103571:	e8 6e cb ff ff       	call   c01000e4 <cprintf>
c0103576:	83 c4 10             	add    $0x10,%esp
		p->flags = p->order = 0;
	}
	p = base;
	size_t order = MAX_ORDER, order_size = (1<<order);
	while (n != 0) {
		while(n >= order_size) {
c0103579:	8b 45 0c             	mov    0xc(%ebp),%eax
c010357c:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c010357f:	0f 83 05 ff ff ff    	jae    c010348a <buddy_init_memmap+0x5c>
			n -= order_size;
			nr_free(order)++;

			cprintf("list order=%d ++\n", order);
		}
		--order; 
c0103585:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
		order_size >>= 1;
c0103589:	d1 6d ec             	shrl   -0x14(%ebp)
//			cprintf("ERROR: buddy_init_memmap #1\n");
		p->flags = p->order = 0;
	}
	p = base;
	size_t order = MAX_ORDER, order_size = (1<<order);
	while (n != 0) {
c010358c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0103590:	75 e7                	jne    c0103579 <buddy_init_memmap+0x14b>
			cprintf("list order=%d ++\n", order);
		}
		--order; 
		order_size >>= 1;
	}
}
c0103592:	90                   	nop
c0103593:	c9                   	leave  
c0103594:	c3                   	ret    

c0103595 <buddy_alloc_pages>:

static struct Page * buddy_alloc_pages(size_t n)
{
c0103595:	55                   	push   %ebp
c0103596:	89 e5                	mov    %esp,%ebp

	return NULL;
c0103598:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010359d:	5d                   	pop    %ebp
c010359e:	c3                   	ret    

c010359f <buddy_free_pages>:

static void buddy_free_pages(struct Page *base, size_t n)
{
c010359f:	55                   	push   %ebp
c01035a0:	89 e5                	mov    %esp,%ebp

}
c01035a2:	90                   	nop
c01035a3:	5d                   	pop    %ebp
c01035a4:	c3                   	ret    

c01035a5 <buddy_check>:

static void buddy_check(void)
{
c01035a5:	55                   	push   %ebp
c01035a6:	89 e5                	mov    %esp,%ebp
c01035a8:	83 ec 20             	sub    $0x20,%esp
	int count=0, total=0;
c01035ab:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c01035b2:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
	for (int i = 0; i < MAX_ORDER; ++i)
c01035b9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01035c0:	eb 74                	jmp    c0103636 <buddy_check+0x91>
	{
		list_entry_t *list = &free_list(i), *le = list;
c01035c2:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01035c5:	89 d0                	mov    %edx,%eax
c01035c7:	01 c0                	add    %eax,%eax
c01035c9:	01 d0                	add    %edx,%eax
c01035cb:	c1 e0 02             	shl    $0x2,%eax
c01035ce:	05 00 49 11 c0       	add    $0xc0114900,%eax
c01035d3:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01035d6:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01035d9:	89 45 f0             	mov    %eax,-0x10(%ebp)
		while((le = list_next(le)) != list) {
c01035dc:	eb 3d                	jmp    c010361b <buddy_check+0x76>
			struct Page *p = tostruct(le, struct Page, page_link);
c01035de:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01035e1:	83 e8 08             	sub    $0x8,%eax
c01035e4:	89 45 e8             	mov    %eax,-0x18(%ebp)
//			cprintf("flags:%x order:%d\n", p->flags, p->order);
			if(!(PageProperty(p) && p->order == i))
c01035e7:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01035ea:	50                   	push   %eax
c01035eb:	6a 01                	push   $0x1
c01035ed:	e8 04 fe ff ff       	call   c01033f6 <test_bit>
c01035f2:	83 c4 08             	add    $0x8,%esp
c01035f5:	85 c0                	test   %eax,%eax
c01035f7:	74 0d                	je     c0103606 <buddy_check+0x61>
c01035f9:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01035fc:	8b 50 04             	mov    0x4(%eax),%edx
c01035ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103602:	39 c2                	cmp    %eax,%edx
c0103604:	74 15                	je     c010361b <buddy_check+0x76>
//				cprintf("ERROR: buddy_check #1\n");
			count++, total += (1<<i);
c0103606:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c010360a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010360d:	ba 01 00 00 00       	mov    $0x1,%edx
c0103612:	89 c1                	mov    %eax,%ecx
c0103614:	d3 e2                	shl    %cl,%edx
c0103616:	89 d0                	mov    %edx,%eax
c0103618:	01 45 f8             	add    %eax,-0x8(%ebp)
c010361b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010361e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	return phead->next == phead;
}

list_entry_t * list_next(list_entry_t * pcur)
{
	return pcur->next;
c0103621:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103624:	8b 40 04             	mov    0x4(%eax),%eax
{
	int count=0, total=0;
	for (int i = 0; i < MAX_ORDER; ++i)
	{
		list_entry_t *list = &free_list(i), *le = list;
		while((le = list_next(le)) != list) {
c0103627:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010362a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010362d:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0103630:	75 ac                	jne    c01035de <buddy_check+0x39>
}

static void buddy_check(void)
{
	int count=0, total=0;
	for (int i = 0; i < MAX_ORDER; ++i)
c0103632:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
c0103636:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
c010363a:	7e 86                	jle    c01035c2 <buddy_check+0x1d>
			if(!(PageProperty(p) && p->order == i))
//				cprintf("ERROR: buddy_check #1\n");
			count++, total += (1<<i);
		}
	}
}
c010363c:	90                   	nop
c010363d:	c9                   	leave  
c010363e:	c3                   	ret    

c010363f <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
c010363f:	55                   	push   %ebp
c0103640:	89 e5                	mov    %esp,%ebp
c0103642:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c0103645:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
c010364c:	eb 04                	jmp    c0103652 <strlen+0x13>
        cnt ++;
c010364e:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
c0103652:	8b 45 08             	mov    0x8(%ebp),%eax
c0103655:	8d 50 01             	lea    0x1(%eax),%edx
c0103658:	89 55 08             	mov    %edx,0x8(%ebp)
c010365b:	0f b6 00             	movzbl (%eax),%eax
c010365e:	84 c0                	test   %al,%al
c0103660:	75 ec                	jne    c010364e <strlen+0xf>
        cnt ++;
    }
    return cnt;
c0103662:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0103665:	c9                   	leave  
c0103666:	c3                   	ret    

c0103667 <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
c0103667:	55                   	push   %ebp
c0103668:	89 e5                	mov    %esp,%ebp
c010366a:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c010366d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
c0103674:	eb 04                	jmp    c010367a <strnlen+0x13>
        cnt ++;
c0103676:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
c010367a:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010367d:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0103680:	73 10                	jae    c0103692 <strnlen+0x2b>
c0103682:	8b 45 08             	mov    0x8(%ebp),%eax
c0103685:	8d 50 01             	lea    0x1(%eax),%edx
c0103688:	89 55 08             	mov    %edx,0x8(%ebp)
c010368b:	0f b6 00             	movzbl (%eax),%eax
c010368e:	84 c0                	test   %al,%al
c0103690:	75 e4                	jne    c0103676 <strnlen+0xf>
        cnt ++;
    }
    return cnt;
c0103692:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0103695:	c9                   	leave  
c0103696:	c3                   	ret    

c0103697 <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
c0103697:	55                   	push   %ebp
c0103698:	89 e5                	mov    %esp,%ebp
c010369a:	57                   	push   %edi
c010369b:	56                   	push   %esi
c010369c:	83 ec 20             	sub    $0x20,%esp
c010369f:	8b 45 08             	mov    0x8(%ebp),%eax
c01036a2:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01036a5:	8b 45 0c             	mov    0xc(%ebp),%eax
c01036a8:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
c01036ab:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01036ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01036b1:	89 d1                	mov    %edx,%ecx
c01036b3:	89 c2                	mov    %eax,%edx
c01036b5:	89 ce                	mov    %ecx,%esi
c01036b7:	89 d7                	mov    %edx,%edi
c01036b9:	ac                   	lods   %ds:(%esi),%al
c01036ba:	aa                   	stos   %al,%es:(%edi)
c01036bb:	84 c0                	test   %al,%al
c01036bd:	75 fa                	jne    c01036b9 <strcpy+0x22>
c01036bf:	89 fa                	mov    %edi,%edx
c01036c1:	89 f1                	mov    %esi,%ecx
c01036c3:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c01036c6:	89 55 e8             	mov    %edx,-0x18(%ebp)
c01036c9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
c01036cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
c01036cf:	90                   	nop
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
c01036d0:	83 c4 20             	add    $0x20,%esp
c01036d3:	5e                   	pop    %esi
c01036d4:	5f                   	pop    %edi
c01036d5:	5d                   	pop    %ebp
c01036d6:	c3                   	ret    

c01036d7 <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
c01036d7:	55                   	push   %ebp
c01036d8:	89 e5                	mov    %esp,%ebp
c01036da:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
c01036dd:	8b 45 08             	mov    0x8(%ebp),%eax
c01036e0:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
c01036e3:	eb 21                	jmp    c0103706 <strncpy+0x2f>
        if ((*p = *src) != '\0') {
c01036e5:	8b 45 0c             	mov    0xc(%ebp),%eax
c01036e8:	0f b6 10             	movzbl (%eax),%edx
c01036eb:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01036ee:	88 10                	mov    %dl,(%eax)
c01036f0:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01036f3:	0f b6 00             	movzbl (%eax),%eax
c01036f6:	84 c0                	test   %al,%al
c01036f8:	74 04                	je     c01036fe <strncpy+0x27>
            src ++;
c01036fa:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
        }
        p ++, len --;
c01036fe:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c0103702:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
    char *p = dst;
    while (len > 0) {
c0103706:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010370a:	75 d9                	jne    c01036e5 <strncpy+0xe>
        if ((*p = *src) != '\0') {
            src ++;
        }
        p ++, len --;
    }
    return dst;
c010370c:	8b 45 08             	mov    0x8(%ebp),%eax
}
c010370f:	c9                   	leave  
c0103710:	c3                   	ret    

c0103711 <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
c0103711:	55                   	push   %ebp
c0103712:	89 e5                	mov    %esp,%ebp
c0103714:	57                   	push   %edi
c0103715:	56                   	push   %esi
c0103716:	83 ec 20             	sub    $0x20,%esp
c0103719:	8b 45 08             	mov    0x8(%ebp),%eax
c010371c:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010371f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103722:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCMP
#define __HAVE_ARCH_STRCMP
static inline int
__strcmp(const char *s1, const char *s2) {
    int d0, d1, ret;
    asm volatile (
c0103725:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103728:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010372b:	89 d1                	mov    %edx,%ecx
c010372d:	89 c2                	mov    %eax,%edx
c010372f:	89 ce                	mov    %ecx,%esi
c0103731:	89 d7                	mov    %edx,%edi
c0103733:	ac                   	lods   %ds:(%esi),%al
c0103734:	ae                   	scas   %es:(%edi),%al
c0103735:	75 08                	jne    c010373f <strcmp+0x2e>
c0103737:	84 c0                	test   %al,%al
c0103739:	75 f8                	jne    c0103733 <strcmp+0x22>
c010373b:	31 c0                	xor    %eax,%eax
c010373d:	eb 04                	jmp    c0103743 <strcmp+0x32>
c010373f:	19 c0                	sbb    %eax,%eax
c0103741:	0c 01                	or     $0x1,%al
c0103743:	89 fa                	mov    %edi,%edx
c0103745:	89 f1                	mov    %esi,%ecx
c0103747:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010374a:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c010374d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
        "orb $1, %%al;"
        "3:"
        : "=a" (ret), "=&S" (d0), "=&D" (d1)
        : "1" (s1), "2" (s2)
        : "memory");
    return ret;
c0103750:	8b 45 ec             	mov    -0x14(%ebp),%eax
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
c0103753:	90                   	nop
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
c0103754:	83 c4 20             	add    $0x20,%esp
c0103757:	5e                   	pop    %esi
c0103758:	5f                   	pop    %edi
c0103759:	5d                   	pop    %ebp
c010375a:	c3                   	ret    

c010375b <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
c010375b:	55                   	push   %ebp
c010375c:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c010375e:	eb 0c                	jmp    c010376c <strncmp+0x11>
        n --, s1 ++, s2 ++;
c0103760:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
c0103764:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c0103768:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c010376c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0103770:	74 1a                	je     c010378c <strncmp+0x31>
c0103772:	8b 45 08             	mov    0x8(%ebp),%eax
c0103775:	0f b6 00             	movzbl (%eax),%eax
c0103778:	84 c0                	test   %al,%al
c010377a:	74 10                	je     c010378c <strncmp+0x31>
c010377c:	8b 45 08             	mov    0x8(%ebp),%eax
c010377f:	0f b6 10             	movzbl (%eax),%edx
c0103782:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103785:	0f b6 00             	movzbl (%eax),%eax
c0103788:	38 c2                	cmp    %al,%dl
c010378a:	74 d4                	je     c0103760 <strncmp+0x5>
        n --, s1 ++, s2 ++;
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
c010378c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0103790:	74 18                	je     c01037aa <strncmp+0x4f>
c0103792:	8b 45 08             	mov    0x8(%ebp),%eax
c0103795:	0f b6 00             	movzbl (%eax),%eax
c0103798:	0f b6 d0             	movzbl %al,%edx
c010379b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010379e:	0f b6 00             	movzbl (%eax),%eax
c01037a1:	0f b6 c0             	movzbl %al,%eax
c01037a4:	29 c2                	sub    %eax,%edx
c01037a6:	89 d0                	mov    %edx,%eax
c01037a8:	eb 05                	jmp    c01037af <strncmp+0x54>
c01037aa:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01037af:	5d                   	pop    %ebp
c01037b0:	c3                   	ret    

c01037b1 <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
c01037b1:	55                   	push   %ebp
c01037b2:	89 e5                	mov    %esp,%ebp
c01037b4:	83 ec 04             	sub    $0x4,%esp
c01037b7:	8b 45 0c             	mov    0xc(%ebp),%eax
c01037ba:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c01037bd:	eb 14                	jmp    c01037d3 <strchr+0x22>
        if (*s == c) {
c01037bf:	8b 45 08             	mov    0x8(%ebp),%eax
c01037c2:	0f b6 00             	movzbl (%eax),%eax
c01037c5:	3a 45 fc             	cmp    -0x4(%ebp),%al
c01037c8:	75 05                	jne    c01037cf <strchr+0x1e>
            return (char *)s;
c01037ca:	8b 45 08             	mov    0x8(%ebp),%eax
c01037cd:	eb 13                	jmp    c01037e2 <strchr+0x31>
        }
        s ++;
c01037cf:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
c01037d3:	8b 45 08             	mov    0x8(%ebp),%eax
c01037d6:	0f b6 00             	movzbl (%eax),%eax
c01037d9:	84 c0                	test   %al,%al
c01037db:	75 e2                	jne    c01037bf <strchr+0xe>
        if (*s == c) {
            return (char *)s;
        }
        s ++;
    }
    return NULL;
c01037dd:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01037e2:	c9                   	leave  
c01037e3:	c3                   	ret    

c01037e4 <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
c01037e4:	55                   	push   %ebp
c01037e5:	89 e5                	mov    %esp,%ebp
c01037e7:	83 ec 04             	sub    $0x4,%esp
c01037ea:	8b 45 0c             	mov    0xc(%ebp),%eax
c01037ed:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c01037f0:	eb 0f                	jmp    c0103801 <strfind+0x1d>
        if (*s == c) {
c01037f2:	8b 45 08             	mov    0x8(%ebp),%eax
c01037f5:	0f b6 00             	movzbl (%eax),%eax
c01037f8:	3a 45 fc             	cmp    -0x4(%ebp),%al
c01037fb:	74 10                	je     c010380d <strfind+0x29>
            break;
        }
        s ++;
c01037fd:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
    while (*s != '\0') {
c0103801:	8b 45 08             	mov    0x8(%ebp),%eax
c0103804:	0f b6 00             	movzbl (%eax),%eax
c0103807:	84 c0                	test   %al,%al
c0103809:	75 e7                	jne    c01037f2 <strfind+0xe>
c010380b:	eb 01                	jmp    c010380e <strfind+0x2a>
        if (*s == c) {
            break;
c010380d:	90                   	nop
        }
        s ++;
    }
    return (char *)s;
c010380e:	8b 45 08             	mov    0x8(%ebp),%eax
}
c0103811:	c9                   	leave  
c0103812:	c3                   	ret    

c0103813 <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
c0103813:	55                   	push   %ebp
c0103814:	89 e5                	mov    %esp,%ebp
c0103816:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
c0103819:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
c0103820:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
c0103827:	eb 04                	jmp    c010382d <strtol+0x1a>
        s ++;
c0103829:	83 45 08 01          	addl   $0x1,0x8(%ebp)
strtol(const char *s, char **endptr, int base) {
    int neg = 0;
    long val = 0;

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
c010382d:	8b 45 08             	mov    0x8(%ebp),%eax
c0103830:	0f b6 00             	movzbl (%eax),%eax
c0103833:	3c 20                	cmp    $0x20,%al
c0103835:	74 f2                	je     c0103829 <strtol+0x16>
c0103837:	8b 45 08             	mov    0x8(%ebp),%eax
c010383a:	0f b6 00             	movzbl (%eax),%eax
c010383d:	3c 09                	cmp    $0x9,%al
c010383f:	74 e8                	je     c0103829 <strtol+0x16>
        s ++;
    }

    // plus/minus sign
    if (*s == '+') {
c0103841:	8b 45 08             	mov    0x8(%ebp),%eax
c0103844:	0f b6 00             	movzbl (%eax),%eax
c0103847:	3c 2b                	cmp    $0x2b,%al
c0103849:	75 06                	jne    c0103851 <strtol+0x3e>
        s ++;
c010384b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c010384f:	eb 15                	jmp    c0103866 <strtol+0x53>
    }
    else if (*s == '-') {
c0103851:	8b 45 08             	mov    0x8(%ebp),%eax
c0103854:	0f b6 00             	movzbl (%eax),%eax
c0103857:	3c 2d                	cmp    $0x2d,%al
c0103859:	75 0b                	jne    c0103866 <strtol+0x53>
        s ++, neg = 1;
c010385b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c010385f:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
c0103866:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010386a:	74 06                	je     c0103872 <strtol+0x5f>
c010386c:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
c0103870:	75 24                	jne    c0103896 <strtol+0x83>
c0103872:	8b 45 08             	mov    0x8(%ebp),%eax
c0103875:	0f b6 00             	movzbl (%eax),%eax
c0103878:	3c 30                	cmp    $0x30,%al
c010387a:	75 1a                	jne    c0103896 <strtol+0x83>
c010387c:	8b 45 08             	mov    0x8(%ebp),%eax
c010387f:	83 c0 01             	add    $0x1,%eax
c0103882:	0f b6 00             	movzbl (%eax),%eax
c0103885:	3c 78                	cmp    $0x78,%al
c0103887:	75 0d                	jne    c0103896 <strtol+0x83>
        s += 2, base = 16;
c0103889:	83 45 08 02          	addl   $0x2,0x8(%ebp)
c010388d:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
c0103894:	eb 2a                	jmp    c01038c0 <strtol+0xad>
    }
    else if (base == 0 && s[0] == '0') {
c0103896:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010389a:	75 17                	jne    c01038b3 <strtol+0xa0>
c010389c:	8b 45 08             	mov    0x8(%ebp),%eax
c010389f:	0f b6 00             	movzbl (%eax),%eax
c01038a2:	3c 30                	cmp    $0x30,%al
c01038a4:	75 0d                	jne    c01038b3 <strtol+0xa0>
        s ++, base = 8;
c01038a6:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c01038aa:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
c01038b1:	eb 0d                	jmp    c01038c0 <strtol+0xad>
    }
    else if (base == 0) {
c01038b3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01038b7:	75 07                	jne    c01038c0 <strtol+0xad>
        base = 10;
c01038b9:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
c01038c0:	8b 45 08             	mov    0x8(%ebp),%eax
c01038c3:	0f b6 00             	movzbl (%eax),%eax
c01038c6:	3c 2f                	cmp    $0x2f,%al
c01038c8:	7e 1b                	jle    c01038e5 <strtol+0xd2>
c01038ca:	8b 45 08             	mov    0x8(%ebp),%eax
c01038cd:	0f b6 00             	movzbl (%eax),%eax
c01038d0:	3c 39                	cmp    $0x39,%al
c01038d2:	7f 11                	jg     c01038e5 <strtol+0xd2>
            dig = *s - '0';
c01038d4:	8b 45 08             	mov    0x8(%ebp),%eax
c01038d7:	0f b6 00             	movzbl (%eax),%eax
c01038da:	0f be c0             	movsbl %al,%eax
c01038dd:	83 e8 30             	sub    $0x30,%eax
c01038e0:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01038e3:	eb 48                	jmp    c010392d <strtol+0x11a>
        }
        else if (*s >= 'a' && *s <= 'z') {
c01038e5:	8b 45 08             	mov    0x8(%ebp),%eax
c01038e8:	0f b6 00             	movzbl (%eax),%eax
c01038eb:	3c 60                	cmp    $0x60,%al
c01038ed:	7e 1b                	jle    c010390a <strtol+0xf7>
c01038ef:	8b 45 08             	mov    0x8(%ebp),%eax
c01038f2:	0f b6 00             	movzbl (%eax),%eax
c01038f5:	3c 7a                	cmp    $0x7a,%al
c01038f7:	7f 11                	jg     c010390a <strtol+0xf7>
            dig = *s - 'a' + 10;
c01038f9:	8b 45 08             	mov    0x8(%ebp),%eax
c01038fc:	0f b6 00             	movzbl (%eax),%eax
c01038ff:	0f be c0             	movsbl %al,%eax
c0103902:	83 e8 57             	sub    $0x57,%eax
c0103905:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103908:	eb 23                	jmp    c010392d <strtol+0x11a>
        }
        else if (*s >= 'A' && *s <= 'Z') {
c010390a:	8b 45 08             	mov    0x8(%ebp),%eax
c010390d:	0f b6 00             	movzbl (%eax),%eax
c0103910:	3c 40                	cmp    $0x40,%al
c0103912:	7e 3c                	jle    c0103950 <strtol+0x13d>
c0103914:	8b 45 08             	mov    0x8(%ebp),%eax
c0103917:	0f b6 00             	movzbl (%eax),%eax
c010391a:	3c 5a                	cmp    $0x5a,%al
c010391c:	7f 32                	jg     c0103950 <strtol+0x13d>
            dig = *s - 'A' + 10;
c010391e:	8b 45 08             	mov    0x8(%ebp),%eax
c0103921:	0f b6 00             	movzbl (%eax),%eax
c0103924:	0f be c0             	movsbl %al,%eax
c0103927:	83 e8 37             	sub    $0x37,%eax
c010392a:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
c010392d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103930:	3b 45 10             	cmp    0x10(%ebp),%eax
c0103933:	7d 1a                	jge    c010394f <strtol+0x13c>
            break;
        }
        s ++, val = (val * base) + dig;
c0103935:	83 45 08 01          	addl   $0x1,0x8(%ebp)
c0103939:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010393c:	0f af 45 10          	imul   0x10(%ebp),%eax
c0103940:	89 c2                	mov    %eax,%edx
c0103942:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103945:	01 d0                	add    %edx,%eax
c0103947:	89 45 f8             	mov    %eax,-0x8(%ebp)
        // we don't properly detect overflow!
    }
c010394a:	e9 71 ff ff ff       	jmp    c01038c0 <strtol+0xad>
        }
        else {
            break;
        }
        if (dig >= base) {
            break;
c010394f:	90                   	nop
        }
        s ++, val = (val * base) + dig;
        // we don't properly detect overflow!
    }

    if (endptr) {
c0103950:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0103954:	74 08                	je     c010395e <strtol+0x14b>
        *endptr = (char *) s;
c0103956:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103959:	8b 55 08             	mov    0x8(%ebp),%edx
c010395c:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
c010395e:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c0103962:	74 07                	je     c010396b <strtol+0x158>
c0103964:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0103967:	f7 d8                	neg    %eax
c0103969:	eb 03                	jmp    c010396e <strtol+0x15b>
c010396b:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
c010396e:	c9                   	leave  
c010396f:	c3                   	ret    

c0103970 <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
c0103970:	55                   	push   %ebp
c0103971:	89 e5                	mov    %esp,%ebp
c0103973:	57                   	push   %edi
c0103974:	83 ec 24             	sub    $0x24,%esp
c0103977:	8b 45 0c             	mov    0xc(%ebp),%eax
c010397a:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
c010397d:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
c0103981:	8b 55 08             	mov    0x8(%ebp),%edx
c0103984:	89 55 f8             	mov    %edx,-0x8(%ebp)
c0103987:	88 45 f7             	mov    %al,-0x9(%ebp)
c010398a:	8b 45 10             	mov    0x10(%ebp),%eax
c010398d:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
c0103990:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c0103993:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
c0103997:	8b 55 f8             	mov    -0x8(%ebp),%edx
c010399a:	89 d7                	mov    %edx,%edi
c010399c:	f3 aa                	rep stos %al,%es:(%edi)
c010399e:	89 fa                	mov    %edi,%edx
c01039a0:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c01039a3:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
c01039a6:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01039a9:	90                   	nop
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
c01039aa:	83 c4 24             	add    $0x24,%esp
c01039ad:	5f                   	pop    %edi
c01039ae:	5d                   	pop    %ebp
c01039af:	c3                   	ret    

c01039b0 <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
c01039b0:	55                   	push   %ebp
c01039b1:	89 e5                	mov    %esp,%ebp
c01039b3:	57                   	push   %edi
c01039b4:	56                   	push   %esi
c01039b5:	53                   	push   %ebx
c01039b6:	83 ec 30             	sub    $0x30,%esp
c01039b9:	8b 45 08             	mov    0x8(%ebp),%eax
c01039bc:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01039bf:	8b 45 0c             	mov    0xc(%ebp),%eax
c01039c2:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01039c5:	8b 45 10             	mov    0x10(%ebp),%eax
c01039c8:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
c01039cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01039ce:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c01039d1:	73 42                	jae    c0103a15 <memmove+0x65>
c01039d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01039d6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01039d9:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01039dc:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01039df:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01039e2:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c01039e5:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01039e8:	c1 e8 02             	shr    $0x2,%eax
c01039eb:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
c01039ed:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01039f0:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01039f3:	89 d7                	mov    %edx,%edi
c01039f5:	89 c6                	mov    %eax,%esi
c01039f7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c01039f9:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c01039fc:	83 e1 03             	and    $0x3,%ecx
c01039ff:	74 02                	je     c0103a03 <memmove+0x53>
c0103a01:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c0103a03:	89 f0                	mov    %esi,%eax
c0103a05:	89 fa                	mov    %edi,%edx
c0103a07:	89 4d d8             	mov    %ecx,-0x28(%ebp)
c0103a0a:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0103a0d:	89 45 d0             	mov    %eax,-0x30(%ebp)
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
        : "memory");
    return dst;
c0103a10:	8b 45 e4             	mov    -0x1c(%ebp),%eax
#ifdef __HAVE_ARCH_MEMMOVE
    return __memmove(dst, src, n);
c0103a13:	eb 36                	jmp    c0103a4b <memmove+0x9b>
    asm volatile (
        "std;"
        "rep; movsb;"
        "cld;"
        : "=&c" (d0), "=&S" (d1), "=&D" (d2)
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
c0103a15:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103a18:	8d 50 ff             	lea    -0x1(%eax),%edx
c0103a1b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103a1e:	01 c2                	add    %eax,%edx
c0103a20:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103a23:	8d 48 ff             	lea    -0x1(%eax),%ecx
c0103a26:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103a29:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
        return __memcpy(dst, src, n);
    }
    int d0, d1, d2;
    asm volatile (
c0103a2c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103a2f:	89 c1                	mov    %eax,%ecx
c0103a31:	89 d8                	mov    %ebx,%eax
c0103a33:	89 d6                	mov    %edx,%esi
c0103a35:	89 c7                	mov    %eax,%edi
c0103a37:	fd                   	std    
c0103a38:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c0103a3a:	fc                   	cld    
c0103a3b:	89 f8                	mov    %edi,%eax
c0103a3d:	89 f2                	mov    %esi,%edx
c0103a3f:	89 4d cc             	mov    %ecx,-0x34(%ebp)
c0103a42:	89 55 c8             	mov    %edx,-0x38(%ebp)
c0103a45:	89 45 c4             	mov    %eax,-0x3c(%ebp)
        "rep; movsb;"
        "cld;"
        : "=&c" (d0), "=&S" (d1), "=&D" (d2)
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
        : "memory");
    return dst;
c0103a48:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
c0103a4b:	83 c4 30             	add    $0x30,%esp
c0103a4e:	5b                   	pop    %ebx
c0103a4f:	5e                   	pop    %esi
c0103a50:	5f                   	pop    %edi
c0103a51:	5d                   	pop    %ebp
c0103a52:	c3                   	ret    

c0103a53 <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
c0103a53:	55                   	push   %ebp
c0103a54:	89 e5                	mov    %esp,%ebp
c0103a56:	57                   	push   %edi
c0103a57:	56                   	push   %esi
c0103a58:	83 ec 20             	sub    $0x20,%esp
c0103a5b:	8b 45 08             	mov    0x8(%ebp),%eax
c0103a5e:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103a61:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103a64:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103a67:	8b 45 10             	mov    0x10(%ebp),%eax
c0103a6a:	89 45 ec             	mov    %eax,-0x14(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c0103a6d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103a70:	c1 e8 02             	shr    $0x2,%eax
c0103a73:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
c0103a75:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103a78:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103a7b:	89 d7                	mov    %edx,%edi
c0103a7d:	89 c6                	mov    %eax,%esi
c0103a7f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c0103a81:	8b 4d ec             	mov    -0x14(%ebp),%ecx
c0103a84:	83 e1 03             	and    $0x3,%ecx
c0103a87:	74 02                	je     c0103a8b <memcpy+0x38>
c0103a89:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c0103a8b:	89 f0                	mov    %esi,%eax
c0103a8d:	89 fa                	mov    %edi,%edx
c0103a8f:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c0103a92:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c0103a95:	89 45 e0             	mov    %eax,-0x20(%ebp)
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
        : "memory");
    return dst;
c0103a98:	8b 45 f4             	mov    -0xc(%ebp),%eax
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
c0103a9b:	90                   	nop
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
c0103a9c:	83 c4 20             	add    $0x20,%esp
c0103a9f:	5e                   	pop    %esi
c0103aa0:	5f                   	pop    %edi
c0103aa1:	5d                   	pop    %ebp
c0103aa2:	c3                   	ret    

c0103aa3 <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
c0103aa3:	55                   	push   %ebp
c0103aa4:	89 e5                	mov    %esp,%ebp
c0103aa6:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
c0103aa9:	8b 45 08             	mov    0x8(%ebp),%eax
c0103aac:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
c0103aaf:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103ab2:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
c0103ab5:	eb 30                	jmp    c0103ae7 <memcmp+0x44>
        if (*s1 != *s2) {
c0103ab7:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0103aba:	0f b6 10             	movzbl (%eax),%edx
c0103abd:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0103ac0:	0f b6 00             	movzbl (%eax),%eax
c0103ac3:	38 c2                	cmp    %al,%dl
c0103ac5:	74 18                	je     c0103adf <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
c0103ac7:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0103aca:	0f b6 00             	movzbl (%eax),%eax
c0103acd:	0f b6 d0             	movzbl %al,%edx
c0103ad0:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0103ad3:	0f b6 00             	movzbl (%eax),%eax
c0103ad6:	0f b6 c0             	movzbl %al,%eax
c0103ad9:	29 c2                	sub    %eax,%edx
c0103adb:	89 d0                	mov    %edx,%eax
c0103add:	eb 1a                	jmp    c0103af9 <memcmp+0x56>
        }
        s1 ++, s2 ++;
c0103adf:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
c0103ae3:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
    const char *s1 = (const char *)v1;
    const char *s2 = (const char *)v2;
    while (n -- > 0) {
c0103ae7:	8b 45 10             	mov    0x10(%ebp),%eax
c0103aea:	8d 50 ff             	lea    -0x1(%eax),%edx
c0103aed:	89 55 10             	mov    %edx,0x10(%ebp)
c0103af0:	85 c0                	test   %eax,%eax
c0103af2:	75 c3                	jne    c0103ab7 <memcmp+0x14>
        if (*s1 != *s2) {
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
        }
        s1 ++, s2 ++;
    }
    return 0;
c0103af4:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0103af9:	c9                   	leave  
c0103afa:	c3                   	ret    

c0103afb <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
c0103afb:	55                   	push   %ebp
c0103afc:	89 e5                	mov    %esp,%ebp
c0103afe:	83 ec 38             	sub    $0x38,%esp
c0103b01:	8b 45 10             	mov    0x10(%ebp),%eax
c0103b04:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0103b07:	8b 45 14             	mov    0x14(%ebp),%eax
c0103b0a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
c0103b0d:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0103b10:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0103b13:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0103b16:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
c0103b19:	8b 45 18             	mov    0x18(%ebp),%eax
c0103b1c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0103b1f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103b22:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0103b25:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0103b28:	89 55 f0             	mov    %edx,-0x10(%ebp)
c0103b2b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103b2e:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103b31:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0103b35:	74 1c                	je     c0103b53 <printnum+0x58>
c0103b37:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103b3a:	ba 00 00 00 00       	mov    $0x0,%edx
c0103b3f:	f7 75 e4             	divl   -0x1c(%ebp)
c0103b42:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0103b45:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103b48:	ba 00 00 00 00       	mov    $0x0,%edx
c0103b4d:	f7 75 e4             	divl   -0x1c(%ebp)
c0103b50:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103b53:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103b56:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103b59:	f7 75 e4             	divl   -0x1c(%ebp)
c0103b5c:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0103b5f:	89 55 dc             	mov    %edx,-0x24(%ebp)
c0103b62:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103b65:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0103b68:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0103b6b:	89 55 ec             	mov    %edx,-0x14(%ebp)
c0103b6e:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103b71:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
c0103b74:	8b 45 18             	mov    0x18(%ebp),%eax
c0103b77:	ba 00 00 00 00       	mov    $0x0,%edx
c0103b7c:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c0103b7f:	77 41                	ja     c0103bc2 <printnum+0xc7>
c0103b81:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c0103b84:	72 05                	jb     c0103b8b <printnum+0x90>
c0103b86:	3b 45 d0             	cmp    -0x30(%ebp),%eax
c0103b89:	77 37                	ja     c0103bc2 <printnum+0xc7>
        printnum(putch, putdat, result, base, width - 1, padc);
c0103b8b:	8b 45 1c             	mov    0x1c(%ebp),%eax
c0103b8e:	83 e8 01             	sub    $0x1,%eax
c0103b91:	83 ec 04             	sub    $0x4,%esp
c0103b94:	ff 75 20             	pushl  0x20(%ebp)
c0103b97:	50                   	push   %eax
c0103b98:	ff 75 18             	pushl  0x18(%ebp)
c0103b9b:	ff 75 ec             	pushl  -0x14(%ebp)
c0103b9e:	ff 75 e8             	pushl  -0x18(%ebp)
c0103ba1:	ff 75 0c             	pushl  0xc(%ebp)
c0103ba4:	ff 75 08             	pushl  0x8(%ebp)
c0103ba7:	e8 4f ff ff ff       	call   c0103afb <printnum>
c0103bac:	83 c4 20             	add    $0x20,%esp
c0103baf:	eb 1b                	jmp    c0103bcc <printnum+0xd1>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
c0103bb1:	83 ec 08             	sub    $0x8,%esp
c0103bb4:	ff 75 0c             	pushl  0xc(%ebp)
c0103bb7:	ff 75 20             	pushl  0x20(%ebp)
c0103bba:	8b 45 08             	mov    0x8(%ebp),%eax
c0103bbd:	ff d0                	call   *%eax
c0103bbf:	83 c4 10             	add    $0x10,%esp
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
c0103bc2:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
c0103bc6:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c0103bca:	7f e5                	jg     c0103bb1 <printnum+0xb6>
            putch(padc, putdat);
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
c0103bcc:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0103bcf:	05 44 48 10 c0       	add    $0xc0104844,%eax
c0103bd4:	0f b6 00             	movzbl (%eax),%eax
c0103bd7:	0f be c0             	movsbl %al,%eax
c0103bda:	83 ec 08             	sub    $0x8,%esp
c0103bdd:	ff 75 0c             	pushl  0xc(%ebp)
c0103be0:	50                   	push   %eax
c0103be1:	8b 45 08             	mov    0x8(%ebp),%eax
c0103be4:	ff d0                	call   *%eax
c0103be6:	83 c4 10             	add    $0x10,%esp
}
c0103be9:	90                   	nop
c0103bea:	c9                   	leave  
c0103beb:	c3                   	ret    

c0103bec <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
c0103bec:	55                   	push   %ebp
c0103bed:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c0103bef:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c0103bf3:	7e 14                	jle    c0103c09 <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
c0103bf5:	8b 45 08             	mov    0x8(%ebp),%eax
c0103bf8:	8b 00                	mov    (%eax),%eax
c0103bfa:	8d 48 08             	lea    0x8(%eax),%ecx
c0103bfd:	8b 55 08             	mov    0x8(%ebp),%edx
c0103c00:	89 0a                	mov    %ecx,(%edx)
c0103c02:	8b 50 04             	mov    0x4(%eax),%edx
c0103c05:	8b 00                	mov    (%eax),%eax
c0103c07:	eb 30                	jmp    c0103c39 <getuint+0x4d>
    }
    else if (lflag) {
c0103c09:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0103c0d:	74 16                	je     c0103c25 <getuint+0x39>
        return va_arg(*ap, unsigned long);
c0103c0f:	8b 45 08             	mov    0x8(%ebp),%eax
c0103c12:	8b 00                	mov    (%eax),%eax
c0103c14:	8d 48 04             	lea    0x4(%eax),%ecx
c0103c17:	8b 55 08             	mov    0x8(%ebp),%edx
c0103c1a:	89 0a                	mov    %ecx,(%edx)
c0103c1c:	8b 00                	mov    (%eax),%eax
c0103c1e:	ba 00 00 00 00       	mov    $0x0,%edx
c0103c23:	eb 14                	jmp    c0103c39 <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
c0103c25:	8b 45 08             	mov    0x8(%ebp),%eax
c0103c28:	8b 00                	mov    (%eax),%eax
c0103c2a:	8d 48 04             	lea    0x4(%eax),%ecx
c0103c2d:	8b 55 08             	mov    0x8(%ebp),%edx
c0103c30:	89 0a                	mov    %ecx,(%edx)
c0103c32:	8b 00                	mov    (%eax),%eax
c0103c34:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
c0103c39:	5d                   	pop    %ebp
c0103c3a:	c3                   	ret    

c0103c3b <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
c0103c3b:	55                   	push   %ebp
c0103c3c:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c0103c3e:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c0103c42:	7e 14                	jle    c0103c58 <getint+0x1d>
        return va_arg(*ap, long long);
c0103c44:	8b 45 08             	mov    0x8(%ebp),%eax
c0103c47:	8b 00                	mov    (%eax),%eax
c0103c49:	8d 48 08             	lea    0x8(%eax),%ecx
c0103c4c:	8b 55 08             	mov    0x8(%ebp),%edx
c0103c4f:	89 0a                	mov    %ecx,(%edx)
c0103c51:	8b 50 04             	mov    0x4(%eax),%edx
c0103c54:	8b 00                	mov    (%eax),%eax
c0103c56:	eb 28                	jmp    c0103c80 <getint+0x45>
    }
    else if (lflag) {
c0103c58:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0103c5c:	74 12                	je     c0103c70 <getint+0x35>
        return va_arg(*ap, long);
c0103c5e:	8b 45 08             	mov    0x8(%ebp),%eax
c0103c61:	8b 00                	mov    (%eax),%eax
c0103c63:	8d 48 04             	lea    0x4(%eax),%ecx
c0103c66:	8b 55 08             	mov    0x8(%ebp),%edx
c0103c69:	89 0a                	mov    %ecx,(%edx)
c0103c6b:	8b 00                	mov    (%eax),%eax
c0103c6d:	99                   	cltd   
c0103c6e:	eb 10                	jmp    c0103c80 <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
c0103c70:	8b 45 08             	mov    0x8(%ebp),%eax
c0103c73:	8b 00                	mov    (%eax),%eax
c0103c75:	8d 48 04             	lea    0x4(%eax),%ecx
c0103c78:	8b 55 08             	mov    0x8(%ebp),%edx
c0103c7b:	89 0a                	mov    %ecx,(%edx)
c0103c7d:	8b 00                	mov    (%eax),%eax
c0103c7f:	99                   	cltd   
    }
}
c0103c80:	5d                   	pop    %ebp
c0103c81:	c3                   	ret    

c0103c82 <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
c0103c82:	55                   	push   %ebp
c0103c83:	89 e5                	mov    %esp,%ebp
c0103c85:	83 ec 18             	sub    $0x18,%esp
    va_list ap;

    va_start(ap, fmt);
c0103c88:	8d 45 14             	lea    0x14(%ebp),%eax
c0103c8b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
c0103c8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103c91:	50                   	push   %eax
c0103c92:	ff 75 10             	pushl  0x10(%ebp)
c0103c95:	ff 75 0c             	pushl  0xc(%ebp)
c0103c98:	ff 75 08             	pushl  0x8(%ebp)
c0103c9b:	e8 06 00 00 00       	call   c0103ca6 <vprintfmt>
c0103ca0:	83 c4 10             	add    $0x10,%esp
    va_end(ap);
}
c0103ca3:	90                   	nop
c0103ca4:	c9                   	leave  
c0103ca5:	c3                   	ret    

c0103ca6 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
c0103ca6:	55                   	push   %ebp
c0103ca7:	89 e5                	mov    %esp,%ebp
c0103ca9:	56                   	push   %esi
c0103caa:	53                   	push   %ebx
c0103cab:	83 ec 20             	sub    $0x20,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c0103cae:	eb 17                	jmp    c0103cc7 <vprintfmt+0x21>
            if (ch == '\0') {
c0103cb0:	85 db                	test   %ebx,%ebx
c0103cb2:	0f 84 8e 03 00 00    	je     c0104046 <vprintfmt+0x3a0>
                return;
            }
            putch(ch, putdat);
c0103cb8:	83 ec 08             	sub    $0x8,%esp
c0103cbb:	ff 75 0c             	pushl  0xc(%ebp)
c0103cbe:	53                   	push   %ebx
c0103cbf:	8b 45 08             	mov    0x8(%ebp),%eax
c0103cc2:	ff d0                	call   *%eax
c0103cc4:	83 c4 10             	add    $0x10,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c0103cc7:	8b 45 10             	mov    0x10(%ebp),%eax
c0103cca:	8d 50 01             	lea    0x1(%eax),%edx
c0103ccd:	89 55 10             	mov    %edx,0x10(%ebp)
c0103cd0:	0f b6 00             	movzbl (%eax),%eax
c0103cd3:	0f b6 d8             	movzbl %al,%ebx
c0103cd6:	83 fb 25             	cmp    $0x25,%ebx
c0103cd9:	75 d5                	jne    c0103cb0 <vprintfmt+0xa>
            }
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
c0103cdb:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
c0103cdf:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
c0103ce6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103ce9:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
c0103cec:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0103cf3:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103cf6:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
c0103cf9:	8b 45 10             	mov    0x10(%ebp),%eax
c0103cfc:	8d 50 01             	lea    0x1(%eax),%edx
c0103cff:	89 55 10             	mov    %edx,0x10(%ebp)
c0103d02:	0f b6 00             	movzbl (%eax),%eax
c0103d05:	0f b6 d8             	movzbl %al,%ebx
c0103d08:	8d 43 dd             	lea    -0x23(%ebx),%eax
c0103d0b:	83 f8 55             	cmp    $0x55,%eax
c0103d0e:	0f 87 05 03 00 00    	ja     c0104019 <vprintfmt+0x373>
c0103d14:	8b 04 85 68 48 10 c0 	mov    -0x3fefb798(,%eax,4),%eax
c0103d1b:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
c0103d1d:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
c0103d21:	eb d6                	jmp    c0103cf9 <vprintfmt+0x53>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
c0103d23:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
c0103d27:	eb d0                	jmp    c0103cf9 <vprintfmt+0x53>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
c0103d29:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
c0103d30:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0103d33:	89 d0                	mov    %edx,%eax
c0103d35:	c1 e0 02             	shl    $0x2,%eax
c0103d38:	01 d0                	add    %edx,%eax
c0103d3a:	01 c0                	add    %eax,%eax
c0103d3c:	01 d8                	add    %ebx,%eax
c0103d3e:	83 e8 30             	sub    $0x30,%eax
c0103d41:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
c0103d44:	8b 45 10             	mov    0x10(%ebp),%eax
c0103d47:	0f b6 00             	movzbl (%eax),%eax
c0103d4a:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
c0103d4d:	83 fb 2f             	cmp    $0x2f,%ebx
c0103d50:	7e 39                	jle    c0103d8b <vprintfmt+0xe5>
c0103d52:	83 fb 39             	cmp    $0x39,%ebx
c0103d55:	7f 34                	jg     c0103d8b <vprintfmt+0xe5>
            padc = '0';
            goto reswitch;

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
c0103d57:	83 45 10 01          	addl   $0x1,0x10(%ebp)
                precision = precision * 10 + ch - '0';
                ch = *fmt;
                if (ch < '0' || ch > '9') {
                    break;
                }
            }
c0103d5b:	eb d3                	jmp    c0103d30 <vprintfmt+0x8a>
            goto process_precision;

        case '*':
            precision = va_arg(ap, int);
c0103d5d:	8b 45 14             	mov    0x14(%ebp),%eax
c0103d60:	8d 50 04             	lea    0x4(%eax),%edx
c0103d63:	89 55 14             	mov    %edx,0x14(%ebp)
c0103d66:	8b 00                	mov    (%eax),%eax
c0103d68:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
c0103d6b:	eb 1f                	jmp    c0103d8c <vprintfmt+0xe6>

        case '.':
            if (width < 0)
c0103d6d:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0103d71:	79 86                	jns    c0103cf9 <vprintfmt+0x53>
                width = 0;
c0103d73:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
c0103d7a:	e9 7a ff ff ff       	jmp    c0103cf9 <vprintfmt+0x53>

        case '#':
            altflag = 1;
c0103d7f:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
c0103d86:	e9 6e ff ff ff       	jmp    c0103cf9 <vprintfmt+0x53>
                ch = *fmt;
                if (ch < '0' || ch > '9') {
                    break;
                }
            }
            goto process_precision;
c0103d8b:	90                   	nop
        case '#':
            altflag = 1;
            goto reswitch;

        process_precision:
            if (width < 0)
c0103d8c:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0103d90:	0f 89 63 ff ff ff    	jns    c0103cf9 <vprintfmt+0x53>
                width = precision, precision = -1;
c0103d96:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103d99:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0103d9c:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
c0103da3:	e9 51 ff ff ff       	jmp    c0103cf9 <vprintfmt+0x53>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
c0103da8:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
            goto reswitch;
c0103dac:	e9 48 ff ff ff       	jmp    c0103cf9 <vprintfmt+0x53>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
c0103db1:	8b 45 14             	mov    0x14(%ebp),%eax
c0103db4:	8d 50 04             	lea    0x4(%eax),%edx
c0103db7:	89 55 14             	mov    %edx,0x14(%ebp)
c0103dba:	8b 00                	mov    (%eax),%eax
c0103dbc:	83 ec 08             	sub    $0x8,%esp
c0103dbf:	ff 75 0c             	pushl  0xc(%ebp)
c0103dc2:	50                   	push   %eax
c0103dc3:	8b 45 08             	mov    0x8(%ebp),%eax
c0103dc6:	ff d0                	call   *%eax
c0103dc8:	83 c4 10             	add    $0x10,%esp
            break;
c0103dcb:	e9 71 02 00 00       	jmp    c0104041 <vprintfmt+0x39b>

        // error message
        case 'e':
            err = va_arg(ap, int);
c0103dd0:	8b 45 14             	mov    0x14(%ebp),%eax
c0103dd3:	8d 50 04             	lea    0x4(%eax),%edx
c0103dd6:	89 55 14             	mov    %edx,0x14(%ebp)
c0103dd9:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
c0103ddb:	85 db                	test   %ebx,%ebx
c0103ddd:	79 02                	jns    c0103de1 <vprintfmt+0x13b>
                err = -err;
c0103ddf:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
c0103de1:	83 fb 06             	cmp    $0x6,%ebx
c0103de4:	7f 0b                	jg     c0103df1 <vprintfmt+0x14b>
c0103de6:	8b 34 9d 28 48 10 c0 	mov    -0x3fefb7d8(,%ebx,4),%esi
c0103ded:	85 f6                	test   %esi,%esi
c0103def:	75 19                	jne    c0103e0a <vprintfmt+0x164>
                printfmt(putch, putdat, "error %d", err);
c0103df1:	53                   	push   %ebx
c0103df2:	68 55 48 10 c0       	push   $0xc0104855
c0103df7:	ff 75 0c             	pushl  0xc(%ebp)
c0103dfa:	ff 75 08             	pushl  0x8(%ebp)
c0103dfd:	e8 80 fe ff ff       	call   c0103c82 <printfmt>
c0103e02:	83 c4 10             	add    $0x10,%esp
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
c0103e05:	e9 37 02 00 00       	jmp    c0104041 <vprintfmt+0x39b>
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
                printfmt(putch, putdat, "error %d", err);
            }
            else {
                printfmt(putch, putdat, "%s", p);
c0103e0a:	56                   	push   %esi
c0103e0b:	68 5e 48 10 c0       	push   $0xc010485e
c0103e10:	ff 75 0c             	pushl  0xc(%ebp)
c0103e13:	ff 75 08             	pushl  0x8(%ebp)
c0103e16:	e8 67 fe ff ff       	call   c0103c82 <printfmt>
c0103e1b:	83 c4 10             	add    $0x10,%esp
            }
            break;
c0103e1e:	e9 1e 02 00 00       	jmp    c0104041 <vprintfmt+0x39b>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
c0103e23:	8b 45 14             	mov    0x14(%ebp),%eax
c0103e26:	8d 50 04             	lea    0x4(%eax),%edx
c0103e29:	89 55 14             	mov    %edx,0x14(%ebp)
c0103e2c:	8b 30                	mov    (%eax),%esi
c0103e2e:	85 f6                	test   %esi,%esi
c0103e30:	75 05                	jne    c0103e37 <vprintfmt+0x191>
                p = "(null)";
c0103e32:	be 61 48 10 c0       	mov    $0xc0104861,%esi
            }
            if (width > 0 && padc != '-') {
c0103e37:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0103e3b:	7e 76                	jle    c0103eb3 <vprintfmt+0x20d>
c0103e3d:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
c0103e41:	74 70                	je     c0103eb3 <vprintfmt+0x20d>
                for (width -= strnlen(p, precision); width > 0; width --) {
c0103e43:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103e46:	83 ec 08             	sub    $0x8,%esp
c0103e49:	50                   	push   %eax
c0103e4a:	56                   	push   %esi
c0103e4b:	e8 17 f8 ff ff       	call   c0103667 <strnlen>
c0103e50:	83 c4 10             	add    $0x10,%esp
c0103e53:	89 c2                	mov    %eax,%edx
c0103e55:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103e58:	29 d0                	sub    %edx,%eax
c0103e5a:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0103e5d:	eb 17                	jmp    c0103e76 <vprintfmt+0x1d0>
                    putch(padc, putdat);
c0103e5f:	0f be 45 db          	movsbl -0x25(%ebp),%eax
c0103e63:	83 ec 08             	sub    $0x8,%esp
c0103e66:	ff 75 0c             	pushl  0xc(%ebp)
c0103e69:	50                   	push   %eax
c0103e6a:	8b 45 08             	mov    0x8(%ebp),%eax
c0103e6d:	ff d0                	call   *%eax
c0103e6f:	83 c4 10             	add    $0x10,%esp
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
                p = "(null)";
            }
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
c0103e72:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
c0103e76:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0103e7a:	7f e3                	jg     c0103e5f <vprintfmt+0x1b9>
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c0103e7c:	eb 35                	jmp    c0103eb3 <vprintfmt+0x20d>
                if (altflag && (ch < ' ' || ch > '~')) {
c0103e7e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0103e82:	74 1c                	je     c0103ea0 <vprintfmt+0x1fa>
c0103e84:	83 fb 1f             	cmp    $0x1f,%ebx
c0103e87:	7e 05                	jle    c0103e8e <vprintfmt+0x1e8>
c0103e89:	83 fb 7e             	cmp    $0x7e,%ebx
c0103e8c:	7e 12                	jle    c0103ea0 <vprintfmt+0x1fa>
                    putch('?', putdat);
c0103e8e:	83 ec 08             	sub    $0x8,%esp
c0103e91:	ff 75 0c             	pushl  0xc(%ebp)
c0103e94:	6a 3f                	push   $0x3f
c0103e96:	8b 45 08             	mov    0x8(%ebp),%eax
c0103e99:	ff d0                	call   *%eax
c0103e9b:	83 c4 10             	add    $0x10,%esp
c0103e9e:	eb 0f                	jmp    c0103eaf <vprintfmt+0x209>
                }
                else {
                    putch(ch, putdat);
c0103ea0:	83 ec 08             	sub    $0x8,%esp
c0103ea3:	ff 75 0c             	pushl  0xc(%ebp)
c0103ea6:	53                   	push   %ebx
c0103ea7:	8b 45 08             	mov    0x8(%ebp),%eax
c0103eaa:	ff d0                	call   *%eax
c0103eac:	83 c4 10             	add    $0x10,%esp
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c0103eaf:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
c0103eb3:	89 f0                	mov    %esi,%eax
c0103eb5:	8d 70 01             	lea    0x1(%eax),%esi
c0103eb8:	0f b6 00             	movzbl (%eax),%eax
c0103ebb:	0f be d8             	movsbl %al,%ebx
c0103ebe:	85 db                	test   %ebx,%ebx
c0103ec0:	74 26                	je     c0103ee8 <vprintfmt+0x242>
c0103ec2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0103ec6:	78 b6                	js     c0103e7e <vprintfmt+0x1d8>
c0103ec8:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
c0103ecc:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0103ed0:	79 ac                	jns    c0103e7e <vprintfmt+0x1d8>
                }
                else {
                    putch(ch, putdat);
                }
            }
            for (; width > 0; width --) {
c0103ed2:	eb 14                	jmp    c0103ee8 <vprintfmt+0x242>
                putch(' ', putdat);
c0103ed4:	83 ec 08             	sub    $0x8,%esp
c0103ed7:	ff 75 0c             	pushl  0xc(%ebp)
c0103eda:	6a 20                	push   $0x20
c0103edc:	8b 45 08             	mov    0x8(%ebp),%eax
c0103edf:	ff d0                	call   *%eax
c0103ee1:	83 c4 10             	add    $0x10,%esp
                }
                else {
                    putch(ch, putdat);
                }
            }
            for (; width > 0; width --) {
c0103ee4:	83 6d e8 01          	subl   $0x1,-0x18(%ebp)
c0103ee8:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0103eec:	7f e6                	jg     c0103ed4 <vprintfmt+0x22e>
                putch(' ', putdat);
            }
            break;
c0103eee:	e9 4e 01 00 00       	jmp    c0104041 <vprintfmt+0x39b>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
c0103ef3:	83 ec 08             	sub    $0x8,%esp
c0103ef6:	ff 75 e0             	pushl  -0x20(%ebp)
c0103ef9:	8d 45 14             	lea    0x14(%ebp),%eax
c0103efc:	50                   	push   %eax
c0103efd:	e8 39 fd ff ff       	call   c0103c3b <getint>
c0103f02:	83 c4 10             	add    $0x10,%esp
c0103f05:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103f08:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
c0103f0b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103f0e:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103f11:	85 d2                	test   %edx,%edx
c0103f13:	79 23                	jns    c0103f38 <vprintfmt+0x292>
                putch('-', putdat);
c0103f15:	83 ec 08             	sub    $0x8,%esp
c0103f18:	ff 75 0c             	pushl  0xc(%ebp)
c0103f1b:	6a 2d                	push   $0x2d
c0103f1d:	8b 45 08             	mov    0x8(%ebp),%eax
c0103f20:	ff d0                	call   *%eax
c0103f22:	83 c4 10             	add    $0x10,%esp
                num = -(long long)num;
c0103f25:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103f28:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103f2b:	f7 d8                	neg    %eax
c0103f2d:	83 d2 00             	adc    $0x0,%edx
c0103f30:	f7 da                	neg    %edx
c0103f32:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103f35:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
c0103f38:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c0103f3f:	e9 9f 00 00 00       	jmp    c0103fe3 <vprintfmt+0x33d>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
c0103f44:	83 ec 08             	sub    $0x8,%esp
c0103f47:	ff 75 e0             	pushl  -0x20(%ebp)
c0103f4a:	8d 45 14             	lea    0x14(%ebp),%eax
c0103f4d:	50                   	push   %eax
c0103f4e:	e8 99 fc ff ff       	call   c0103bec <getuint>
c0103f53:	83 c4 10             	add    $0x10,%esp
c0103f56:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103f59:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
c0103f5c:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c0103f63:	eb 7e                	jmp    c0103fe3 <vprintfmt+0x33d>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
c0103f65:	83 ec 08             	sub    $0x8,%esp
c0103f68:	ff 75 e0             	pushl  -0x20(%ebp)
c0103f6b:	8d 45 14             	lea    0x14(%ebp),%eax
c0103f6e:	50                   	push   %eax
c0103f6f:	e8 78 fc ff ff       	call   c0103bec <getuint>
c0103f74:	83 c4 10             	add    $0x10,%esp
c0103f77:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103f7a:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
c0103f7d:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
c0103f84:	eb 5d                	jmp    c0103fe3 <vprintfmt+0x33d>

        // pointer
        case 'p':
            putch('0', putdat);
c0103f86:	83 ec 08             	sub    $0x8,%esp
c0103f89:	ff 75 0c             	pushl  0xc(%ebp)
c0103f8c:	6a 30                	push   $0x30
c0103f8e:	8b 45 08             	mov    0x8(%ebp),%eax
c0103f91:	ff d0                	call   *%eax
c0103f93:	83 c4 10             	add    $0x10,%esp
            putch('x', putdat);
c0103f96:	83 ec 08             	sub    $0x8,%esp
c0103f99:	ff 75 0c             	pushl  0xc(%ebp)
c0103f9c:	6a 78                	push   $0x78
c0103f9e:	8b 45 08             	mov    0x8(%ebp),%eax
c0103fa1:	ff d0                	call   *%eax
c0103fa3:	83 c4 10             	add    $0x10,%esp
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
c0103fa6:	8b 45 14             	mov    0x14(%ebp),%eax
c0103fa9:	8d 50 04             	lea    0x4(%eax),%edx
c0103fac:	89 55 14             	mov    %edx,0x14(%ebp)
c0103faf:	8b 00                	mov    (%eax),%eax
c0103fb1:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103fb4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
c0103fbb:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
c0103fc2:	eb 1f                	jmp    c0103fe3 <vprintfmt+0x33d>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
c0103fc4:	83 ec 08             	sub    $0x8,%esp
c0103fc7:	ff 75 e0             	pushl  -0x20(%ebp)
c0103fca:	8d 45 14             	lea    0x14(%ebp),%eax
c0103fcd:	50                   	push   %eax
c0103fce:	e8 19 fc ff ff       	call   c0103bec <getuint>
c0103fd3:	83 c4 10             	add    $0x10,%esp
c0103fd6:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103fd9:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
c0103fdc:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
c0103fe3:	0f be 55 db          	movsbl -0x25(%ebp),%edx
c0103fe7:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103fea:	83 ec 04             	sub    $0x4,%esp
c0103fed:	52                   	push   %edx
c0103fee:	ff 75 e8             	pushl  -0x18(%ebp)
c0103ff1:	50                   	push   %eax
c0103ff2:	ff 75 f4             	pushl  -0xc(%ebp)
c0103ff5:	ff 75 f0             	pushl  -0x10(%ebp)
c0103ff8:	ff 75 0c             	pushl  0xc(%ebp)
c0103ffb:	ff 75 08             	pushl  0x8(%ebp)
c0103ffe:	e8 f8 fa ff ff       	call   c0103afb <printnum>
c0104003:	83 c4 20             	add    $0x20,%esp
            break;
c0104006:	eb 39                	jmp    c0104041 <vprintfmt+0x39b>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
c0104008:	83 ec 08             	sub    $0x8,%esp
c010400b:	ff 75 0c             	pushl  0xc(%ebp)
c010400e:	53                   	push   %ebx
c010400f:	8b 45 08             	mov    0x8(%ebp),%eax
c0104012:	ff d0                	call   *%eax
c0104014:	83 c4 10             	add    $0x10,%esp
            break;
c0104017:	eb 28                	jmp    c0104041 <vprintfmt+0x39b>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
c0104019:	83 ec 08             	sub    $0x8,%esp
c010401c:	ff 75 0c             	pushl  0xc(%ebp)
c010401f:	6a 25                	push   $0x25
c0104021:	8b 45 08             	mov    0x8(%ebp),%eax
c0104024:	ff d0                	call   *%eax
c0104026:	83 c4 10             	add    $0x10,%esp
            for (fmt --; fmt[-1] != '%'; fmt --)
c0104029:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
c010402d:	eb 04                	jmp    c0104033 <vprintfmt+0x38d>
c010402f:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
c0104033:	8b 45 10             	mov    0x10(%ebp),%eax
c0104036:	83 e8 01             	sub    $0x1,%eax
c0104039:	0f b6 00             	movzbl (%eax),%eax
c010403c:	3c 25                	cmp    $0x25,%al
c010403e:	75 ef                	jne    c010402f <vprintfmt+0x389>
                /* do nothing */;
            break;
c0104040:	90                   	nop
        }
    }
c0104041:	e9 68 fc ff ff       	jmp    c0103cae <vprintfmt+0x8>
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
            if (ch == '\0') {
                return;
c0104046:	90                   	nop
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
c0104047:	8d 65 f8             	lea    -0x8(%ebp),%esp
c010404a:	5b                   	pop    %ebx
c010404b:	5e                   	pop    %esi
c010404c:	5d                   	pop    %ebp
c010404d:	c3                   	ret    

c010404e <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
c010404e:	55                   	push   %ebp
c010404f:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
c0104051:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104054:	8b 40 08             	mov    0x8(%eax),%eax
c0104057:	8d 50 01             	lea    0x1(%eax),%edx
c010405a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010405d:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
c0104060:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104063:	8b 10                	mov    (%eax),%edx
c0104065:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104068:	8b 40 04             	mov    0x4(%eax),%eax
c010406b:	39 c2                	cmp    %eax,%edx
c010406d:	73 12                	jae    c0104081 <sprintputch+0x33>
        *b->buf ++ = ch;
c010406f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104072:	8b 00                	mov    (%eax),%eax
c0104074:	8d 48 01             	lea    0x1(%eax),%ecx
c0104077:	8b 55 0c             	mov    0xc(%ebp),%edx
c010407a:	89 0a                	mov    %ecx,(%edx)
c010407c:	8b 55 08             	mov    0x8(%ebp),%edx
c010407f:	88 10                	mov    %dl,(%eax)
    }
}
c0104081:	90                   	nop
c0104082:	5d                   	pop    %ebp
c0104083:	c3                   	ret    

c0104084 <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
c0104084:	55                   	push   %ebp
c0104085:	89 e5                	mov    %esp,%ebp
c0104087:	83 ec 18             	sub    $0x18,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c010408a:	8d 45 14             	lea    0x14(%ebp),%eax
c010408d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
c0104090:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104093:	50                   	push   %eax
c0104094:	ff 75 10             	pushl  0x10(%ebp)
c0104097:	ff 75 0c             	pushl  0xc(%ebp)
c010409a:	ff 75 08             	pushl  0x8(%ebp)
c010409d:	e8 0b 00 00 00       	call   c01040ad <vsnprintf>
c01040a2:	83 c4 10             	add    $0x10,%esp
c01040a5:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c01040a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01040ab:	c9                   	leave  
c01040ac:	c3                   	ret    

c01040ad <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
c01040ad:	55                   	push   %ebp
c01040ae:	89 e5                	mov    %esp,%ebp
c01040b0:	83 ec 18             	sub    $0x18,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
c01040b3:	8b 45 08             	mov    0x8(%ebp),%eax
c01040b6:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01040b9:	8b 45 0c             	mov    0xc(%ebp),%eax
c01040bc:	8d 50 ff             	lea    -0x1(%eax),%edx
c01040bf:	8b 45 08             	mov    0x8(%ebp),%eax
c01040c2:	01 d0                	add    %edx,%eax
c01040c4:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01040c7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
c01040ce:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01040d2:	74 0a                	je     c01040de <vsnprintf+0x31>
c01040d4:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01040d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01040da:	39 c2                	cmp    %eax,%edx
c01040dc:	76 07                	jbe    c01040e5 <vsnprintf+0x38>
        return -E_INVAL;
c01040de:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
c01040e3:	eb 20                	jmp    c0104105 <vsnprintf+0x58>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
c01040e5:	ff 75 14             	pushl  0x14(%ebp)
c01040e8:	ff 75 10             	pushl  0x10(%ebp)
c01040eb:	8d 45 ec             	lea    -0x14(%ebp),%eax
c01040ee:	50                   	push   %eax
c01040ef:	68 4e 40 10 c0       	push   $0xc010404e
c01040f4:	e8 ad fb ff ff       	call   c0103ca6 <vprintfmt>
c01040f9:	83 c4 10             	add    $0x10,%esp
    // null terminate the buffer
    *b.buf = '\0';
c01040fc:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01040ff:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
c0104102:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0104105:	c9                   	leave  
c0104106:	c3                   	ret    

c0104107 <buffer_init>:
#include <stringbuffer.h>
#include <string.h>


void buffer_init(StringBuffer *sb, char *buf, int size)
{
c0104107:	55                   	push   %ebp
c0104108:	89 e5                	mov    %esp,%ebp
	sb->base = buf;
c010410a:	8b 45 08             	mov    0x8(%ebp),%eax
c010410d:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104110:	89 10                	mov    %edx,(%eax)
	sb->top = sb->base;
c0104112:	8b 45 08             	mov    0x8(%ebp),%eax
c0104115:	8b 10                	mov    (%eax),%edx
c0104117:	8b 45 08             	mov    0x8(%ebp),%eax
c010411a:	89 50 04             	mov    %edx,0x4(%eax)
	sb->stacksize = size;
c010411d:	8b 45 08             	mov    0x8(%ebp),%eax
c0104120:	8b 55 10             	mov    0x10(%ebp),%edx
c0104123:	89 50 08             	mov    %edx,0x8(%eax)
}
c0104126:	90                   	nop
c0104127:	5d                   	pop    %ebp
c0104128:	c3                   	ret    

c0104129 <buffer_gettop>:

char buffer_gettop(StringBuffer sb)
{
c0104129:	55                   	push   %ebp
c010412a:	89 e5                	mov    %esp,%ebp
	if(sb.top == sb.base) return 0;
c010412c:	8b 55 0c             	mov    0xc(%ebp),%edx
c010412f:	8b 45 08             	mov    0x8(%ebp),%eax
c0104132:	39 c2                	cmp    %eax,%edx
c0104134:	75 07                	jne    c010413d <buffer_gettop+0x14>
c0104136:	b8 00 00 00 00       	mov    $0x0,%eax
c010413b:	eb 07                	jmp    c0104144 <buffer_gettop+0x1b>
	return *(sb.top-1);
c010413d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104140:	0f b6 40 ff          	movzbl -0x1(%eax),%eax
}
c0104144:	5d                   	pop    %ebp
c0104145:	c3                   	ret    

c0104146 <buffer_push>:

void buffer_push(StringBuffer *sb, char ch)
{
c0104146:	55                   	push   %ebp
c0104147:	89 e5                	mov    %esp,%ebp
c0104149:	83 ec 04             	sub    $0x4,%esp
c010414c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010414f:	88 45 fc             	mov    %al,-0x4(%ebp)
	if(sb->top-sb->base >= sb->stacksize) return;
c0104152:	8b 45 08             	mov    0x8(%ebp),%eax
c0104155:	8b 40 04             	mov    0x4(%eax),%eax
c0104158:	89 c2                	mov    %eax,%edx
c010415a:	8b 45 08             	mov    0x8(%ebp),%eax
c010415d:	8b 00                	mov    (%eax),%eax
c010415f:	29 c2                	sub    %eax,%edx
c0104161:	8b 45 08             	mov    0x8(%ebp),%eax
c0104164:	8b 40 08             	mov    0x8(%eax),%eax
c0104167:	39 c2                	cmp    %eax,%edx
c0104169:	7d 17                	jge    c0104182 <buffer_push+0x3c>
	*(sb->top++) = ch;
c010416b:	8b 45 08             	mov    0x8(%ebp),%eax
c010416e:	8b 40 04             	mov    0x4(%eax),%eax
c0104171:	8d 48 01             	lea    0x1(%eax),%ecx
c0104174:	8b 55 08             	mov    0x8(%ebp),%edx
c0104177:	89 4a 04             	mov    %ecx,0x4(%edx)
c010417a:	0f b6 55 fc          	movzbl -0x4(%ebp),%edx
c010417e:	88 10                	mov    %dl,(%eax)
c0104180:	eb 01                	jmp    c0104183 <buffer_push+0x3d>
	return *(sb.top-1);
}

void buffer_push(StringBuffer *sb, char ch)
{
	if(sb->top-sb->base >= sb->stacksize) return;
c0104182:	90                   	nop
	*(sb->top++) = ch;
}
c0104183:	c9                   	leave  
c0104184:	c3                   	ret    

c0104185 <buffer_pop>:

char buffer_pop(StringBuffer *sb) 
{
c0104185:	55                   	push   %ebp
c0104186:	89 e5                	mov    %esp,%ebp
	if(sb->top == sb->base) return 0;
c0104188:	8b 45 08             	mov    0x8(%ebp),%eax
c010418b:	8b 50 04             	mov    0x4(%eax),%edx
c010418e:	8b 45 08             	mov    0x8(%ebp),%eax
c0104191:	8b 00                	mov    (%eax),%eax
c0104193:	39 c2                	cmp    %eax,%edx
c0104195:	75 07                	jne    c010419e <buffer_pop+0x19>
c0104197:	b8 00 00 00 00       	mov    $0x0,%eax
c010419c:	eb 18                	jmp    c01041b6 <buffer_pop+0x31>
	return *(--sb->top);
c010419e:	8b 45 08             	mov    0x8(%ebp),%eax
c01041a1:	8b 40 04             	mov    0x4(%eax),%eax
c01041a4:	8d 50 ff             	lea    -0x1(%eax),%edx
c01041a7:	8b 45 08             	mov    0x8(%ebp),%eax
c01041aa:	89 50 04             	mov    %edx,0x4(%eax)
c01041ad:	8b 45 08             	mov    0x8(%ebp),%eax
c01041b0:	8b 40 04             	mov    0x4(%eax),%eax
c01041b3:	0f b6 00             	movzbl (%eax),%eax
}
c01041b6:	5d                   	pop    %ebp
c01041b7:	c3                   	ret    

c01041b8 <keybuf_init>:

void keybuf_init(keybuf_t *pkb)
{
c01041b8:	55                   	push   %ebp
c01041b9:	89 e5                	mov    %esp,%ebp
c01041bb:	83 ec 08             	sub    $0x8,%esp
	memset(pkb->data, 0, 32);
c01041be:	8b 45 08             	mov    0x8(%ebp),%eax
c01041c1:	83 ec 04             	sub    $0x4,%esp
c01041c4:	6a 20                	push   $0x20
c01041c6:	6a 00                	push   $0x0
c01041c8:	50                   	push   %eax
c01041c9:	e8 a2 f7 ff ff       	call   c0103970 <memset>
c01041ce:	83 c4 10             	add    $0x10,%esp
	pkb->front = 0;
c01041d1:	8b 45 08             	mov    0x8(%ebp),%eax
c01041d4:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)
	pkb->rear = 0;
c01041db:	8b 45 08             	mov    0x8(%ebp),%eax
c01041de:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
}
c01041e5:	90                   	nop
c01041e6:	c9                   	leave  
c01041e7:	c3                   	ret    

c01041e8 <keybuf_push>:

bool keybuf_push(keybuf_t *pkb, char ch)
{
c01041e8:	55                   	push   %ebp
c01041e9:	89 e5                	mov    %esp,%ebp
c01041eb:	83 ec 04             	sub    $0x4,%esp
c01041ee:	8b 45 0c             	mov    0xc(%ebp),%eax
c01041f1:	88 45 fc             	mov    %al,-0x4(%ebp)
	if(pkb->front-pkb->rear == 1)
c01041f4:	8b 45 08             	mov    0x8(%ebp),%eax
c01041f7:	8b 50 20             	mov    0x20(%eax),%edx
c01041fa:	8b 45 08             	mov    0x8(%ebp),%eax
c01041fd:	8b 40 24             	mov    0x24(%eax),%eax
c0104200:	29 c2                	sub    %eax,%edx
c0104202:	89 d0                	mov    %edx,%eax
c0104204:	83 f8 01             	cmp    $0x1,%eax
c0104207:	75 07                	jne    c0104210 <keybuf_push+0x28>
		return 0;
c0104209:	b8 00 00 00 00       	mov    $0x0,%eax
c010420e:	eb 55                	jmp    c0104265 <keybuf_push+0x7d>
	if((pkb->front==0 && pkb->rear==31))
c0104210:	8b 45 08             	mov    0x8(%ebp),%eax
c0104213:	8b 40 20             	mov    0x20(%eax),%eax
c0104216:	85 c0                	test   %eax,%eax
c0104218:	75 12                	jne    c010422c <keybuf_push+0x44>
c010421a:	8b 45 08             	mov    0x8(%ebp),%eax
c010421d:	8b 40 24             	mov    0x24(%eax),%eax
c0104220:	83 f8 1f             	cmp    $0x1f,%eax
c0104223:	75 07                	jne    c010422c <keybuf_push+0x44>
		return 0;
c0104225:	b8 00 00 00 00       	mov    $0x0,%eax
c010422a:	eb 39                	jmp    c0104265 <keybuf_push+0x7d>
	pkb->data[pkb->rear] = ch;
c010422c:	8b 45 08             	mov    0x8(%ebp),%eax
c010422f:	8b 40 24             	mov    0x24(%eax),%eax
c0104232:	0f b6 4d fc          	movzbl -0x4(%ebp),%ecx
c0104236:	8b 55 08             	mov    0x8(%ebp),%edx
c0104239:	88 0c 02             	mov    %cl,(%edx,%eax,1)
	if(++pkb->rear == 32)
c010423c:	8b 45 08             	mov    0x8(%ebp),%eax
c010423f:	8b 40 24             	mov    0x24(%eax),%eax
c0104242:	8d 50 01             	lea    0x1(%eax),%edx
c0104245:	8b 45 08             	mov    0x8(%ebp),%eax
c0104248:	89 50 24             	mov    %edx,0x24(%eax)
c010424b:	8b 45 08             	mov    0x8(%ebp),%eax
c010424e:	8b 40 24             	mov    0x24(%eax),%eax
c0104251:	83 f8 20             	cmp    $0x20,%eax
c0104254:	75 0a                	jne    c0104260 <keybuf_push+0x78>
		pkb->rear = 0;
c0104256:	8b 45 08             	mov    0x8(%ebp),%eax
c0104259:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
	return 1;
c0104260:	b8 01 00 00 00       	mov    $0x1,%eax
}
c0104265:	c9                   	leave  
c0104266:	c3                   	ret    

c0104267 <keybuf_pop>:

char keybuf_pop(keybuf_t *pkb)
{
c0104267:	55                   	push   %ebp
c0104268:	89 e5                	mov    %esp,%ebp
c010426a:	83 ec 10             	sub    $0x10,%esp
	if(pkb->front == pkb->rear)
c010426d:	8b 45 08             	mov    0x8(%ebp),%eax
c0104270:	8b 50 20             	mov    0x20(%eax),%edx
c0104273:	8b 45 08             	mov    0x8(%ebp),%eax
c0104276:	8b 40 24             	mov    0x24(%eax),%eax
c0104279:	39 c2                	cmp    %eax,%edx
c010427b:	75 07                	jne    c0104284 <keybuf_pop+0x1d>
		return 0;
c010427d:	b8 00 00 00 00       	mov    $0x0,%eax
c0104282:	eb 38                	jmp    c01042bc <keybuf_pop+0x55>
	char c = pkb->data[pkb->front];
c0104284:	8b 45 08             	mov    0x8(%ebp),%eax
c0104287:	8b 40 20             	mov    0x20(%eax),%eax
c010428a:	8b 55 08             	mov    0x8(%ebp),%edx
c010428d:	0f b6 04 02          	movzbl (%edx,%eax,1),%eax
c0104291:	88 45 ff             	mov    %al,-0x1(%ebp)
	if(++pkb->front == 32)
c0104294:	8b 45 08             	mov    0x8(%ebp),%eax
c0104297:	8b 40 20             	mov    0x20(%eax),%eax
c010429a:	8d 50 01             	lea    0x1(%eax),%edx
c010429d:	8b 45 08             	mov    0x8(%ebp),%eax
c01042a0:	89 50 20             	mov    %edx,0x20(%eax)
c01042a3:	8b 45 08             	mov    0x8(%ebp),%eax
c01042a6:	8b 40 20             	mov    0x20(%eax),%eax
c01042a9:	83 f8 20             	cmp    $0x20,%eax
c01042ac:	75 0a                	jne    c01042b8 <keybuf_pop+0x51>
		pkb->front = 0;
c01042ae:	8b 45 08             	mov    0x8(%ebp),%eax
c01042b1:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

	return c;
c01042b8:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
c01042bc:	c9                   	leave  
c01042bd:	c3                   	ret    
