#pragma once

static inline void set_bit(int nr, volatile void *addr) __attribute__((always_inline));
static inline void clear_bit(int nr, volatile void *addr) __attribute__((always_inline));

static inline void set_bit(int nr, volatile void *addr)
{
	asm volatile ("btsl %1, %0" :"=m" (*(volatile long*)addr) : "Ir" (nr));
}
static inline void clear_bit(int nr, volatile void *addr)
{
	asm volatile ("btcl %1, %0" :"=m" (*(volatile long*)addr) : "Ir" (nr));
}
static inline bool test_bit(int nr, volatile void *addr) 
{
	int oldbit;
	asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
	return oldbit != 0;
}