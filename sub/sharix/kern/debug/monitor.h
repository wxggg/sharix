#ifndef __KERN_DEBUG_MONITOR_H__
#define __KERN_DEBUG_MONITOR_H__

#include <trap.h>

extern bool toc;

void monitor(struct trapframe *tf);

int mon_help(int argc, char **argv, struct trapframe *tf);
int mon_kerninfo(int argc, char **argv, struct trapframe *tf);
int mon_backtrace(int argc, char **argv, struct trapframe *tf);
int mon_bootinfo(int argc, char **argv, struct trapframe *tf);

int runcmd(char *buf, struct trapframe *tf);

#endif /* !__KERN_DEBUG_MONITOR_H__ */

