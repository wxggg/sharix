#ifndef __LIBS_TYPES_H__
#define __LIBS_TYPES_H__

#ifndef NULL
#define NULL ((void *)0)
#endif

/* Represents true-or-false values */
typedef int bool;
typedef int BOOL;

#define FALSE 0
#define TRUE 1

/* Explicitly-sized versions of integer types */
typedef char int8_t;
typedef unsigned char uint8_t;
typedef short int16_t;
typedef unsigned short uint16_t;
typedef int int32_t;
typedef unsigned int uint32_t;
typedef long long int64_t;
typedef unsigned long long uint64_t;

/* *
 * Pointers and addresses are 32 bits long.
 * We use pointer types to represent addresses,
 * uintptr_t to represent the numerical values of addresses.
 * */
typedef int32_t intptr_t;
typedef uint32_t uintptr_t;

/* size_t is used for memory object sizes */
typedef uintptr_t size_t;

typedef struct rgb_s
{
	uint8_t r;
	uint8_t g;
	uint8_t b;		
} rgb_t;

typedef struct point_s
{
	int32_t x;
	int32_t y;
} point_t;

typedef struct rect_s
{
	int32_t left;
	int32_t top;
	uint32_t width;
	uint32_t height;
//	struct rect_s(int32_t l=0, int32_t t=0, uint32_t w=0, uint32_t h=0):left(l), top(t), width(w), height(h) {}
} rect_t;

#define ROUND_DOWN(a, n) ({size_t __a = (size_t)(a);		\
						(typeof(a))(__a - __a%(n));})

#define ROUND_UP(a, n) ({size_t __n = (size_t)n; 			\
						(typeof(a))(ROUND_DOWN((size_t)(a) + __n-1, __n));})

#define offsetof(type, member) 	((size_t)(&((type*)0)->member))
#define tostruct(ptr, type, member)	((type*)((char*)(ptr) - offsetof(type, member)))

#endif /* !__LIBS_TYPES_H__ */

