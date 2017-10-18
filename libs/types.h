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



#define ROUNDDOWN(a, n) ({size_t __a = (size_t)(a);		\
						(typeof(a))(__a - __a%(n));})

#define ROUNDUP(a, n) ({size_t __n = (size_t)n; 			\
						(typeof(a))(ROUNDDOWN((size_t)(a) + __n-1, __n));})

#define offsetof(type, member) 	((size_t)(&((type*)0)->member))
#define to_struct(ptr, type, member)	((type*)((char*)(ptr) - offsetof(type, member)))

#endif /* !__LIBS_TYPES_H__ */
