
obj/bootblock.o:     file format elf32-i386


Disassembly of section .text:

00007c00 <start>:
.section ".text"
.global start


start:
	xorw %ax, %ax
    7c00:	31 c0                	xor    %eax,%eax
	movw %ax, %ds
    7c02:	8e d8                	mov    %eax,%ds
	movw %ax, %es
    7c04:	8e c0                	mov    %eax,%es
	movw %ax, %ss 
    7c06:	8e d0                	mov    %eax,%ss

    movw $0x800, %di
    7c08:	bf 00 08 eb 4c       	mov    $0x4ceb0800,%edi

00007c0d <disk_addr_packet>:
    jmp main
    7c0d:	10 00                	adc    %al,(%eax)
    7c0f:	01 00                	add    %eax,(%eax)
    7c11:	00 00                	add    %al,(%eax)
    7c13:	00 00                	add    %al,(%eax)
    7c15:	01 00                	add    %eax,(%eax)
    7c17:	00 00                	add    %al,(%eax)
    7c19:	00 00                	add    %al,(%eax)
	...

00007c1d <read_a_sect_hd>:
    .word   0x00                        # [6] transfer buffer(16 bit offset)
    .long   0x01                        # [8] starting LBA
    .long   0x00                        # [12]used for upper part of 48 bit LBAs

read_a_sect_hd:
    lea     disk_addr_packet,   %si
    7c1d:	8d 36                	lea    (%esi),%esi
    7c1f:	0d 7c b4 42 b2       	or     $0xb242b47c,%eax
    movb    $0x42,              %ah
    movb    $0x80,              %dl
    7c24:	80 cd 13             	or     $0x13,%ch
    int     $0x13
    ret
    7c27:	c3                   	ret    

00007c28 <read_intbios>:

read_intbios:
	lea		disk_addr_packet, %si
    7c28:	8d 36                	lea    (%esi),%esi
    7c2a:	0d 7c c7 44 06       	or     $0x644c77c,%eax
	movw	$0x7e00>>4, 6(%si)
    7c2f:	e0 07                	loopne 7c38 <loop+0x5>
	xorw 	%cx, %cx
    7c31:	31 c9                	xor    %ecx,%ecx

00007c33 <loop>:
loop:	
	call    read_a_sect_hd
    7c33:	e8 e7 ff 8d 36       	call   368e7c1f <_end+0x368dffbb>
    lea     disk_addr_packet,   %si
    7c38:	0d 7c 66 8b 44       	or     $0x448b667c,%eax
    movl    8(%si),             %eax
    7c3d:	08 66 83             	or     %ah,-0x7d(%esi)
    addl    $0x01,              %eax
    7c40:	c0 01 66             	rolb   $0x66,(%ecx)
    movl    %eax,               (disk_addr_packet + 8)
    7c43:	a3 15 7c 66 8b       	mov    %eax,0x8b667c15

    movl    6(%si),             %eax
    7c48:	44                   	inc    %esp
    7c49:	06                   	push   %es
    addl    $512>>4,            %eax
    7c4a:	66 83 c0 20          	add    $0x20,%ax
    movl    %eax,               (disk_addr_packet + 6)
    7c4e:	66 a3 13 7c 41 83    	mov    %ax,0x83417c13

	incw	%cx
	cmpw	$0x02+1, %cx
    7c54:	f9                   	stc    
    7c55:	03 75 db             	add    -0x25(%ebp),%esi
	jne		loop
	
	ret 
    7c58:	c3                   	ret    

00007c59 <main>:

main:
	call read_intbios
    7c59:	e8 cc ff e9 a1       	call   a1ea7c2a <_end+0xa1e9ffc6>
	jmp 0x7e00
    7c5e:	01                   	.byte 0x1

00007c5f <spin>:

spin:
    7c5f:	eb fe                	jmp    7c5f <spin>
