#pragma once

#ifndef __ASSEMBLER__

#include <types.h>


typedef struct list_entry {
	struct list_entry *prev, *next;	
} list_entry_t;

static inline void list_init(list_entry_t *phead) __attribute__((always_inline));
static inline void list_add(list_entry_t *pcur, list_entry_t *pnode) __attribute__((always_inline));
static inline void list_add_before(list_entry_t *pcur, list_entry_t *pnode) __attribute__((always_inline));
static inline void list_add_after(list_entry_t *pcur, list_entry_t *pnode) __attribute__((always_inline));
static inline void list_del(list_entry_t *pcur) __attribute__((always_inline));
static inline void list_del_init(list_entry_t *pcur) __attribute__((always_inline));
static inline bool list_empty(list_entry_t *phead) __attribute__((always_inline));
static list_entry_t* list_next(list_entry_t *pcur) __attribute__((always_inline));
static list_entry_t* list_prev(list_entry_t *pcur) __attribute__((always_inline));

inline void list_init(list_entry_t * phead)
{
	phead = phead->next = phead;
}

inline void list_add(list_entry_t * pcur, list_entry_t * pnode)
{
	list_add_after(pcur, pnode);
}

inline void list_add_before(list_entry_t * pcur, list_entry_t * pnode)
{
	pcur->prev->next = pnode;
	pnode->next = pcur;
	pnode->prev = pcur->prev;
	pcur->prev = pnode;
}

inline void list_add_after(list_entry_t * pcur, list_entry_t * pnode)
{
	pcur->next->prev = pnode;
	pnode->next = pcur->next;
	pnode->prev = pcur;
	pcur->next = pnode;
}

inline void list_del(list_entry_t * pcur)
{
	pcur->prev->next = pcur->next;
	pcur->next->prev = pcur->prev;
}

inline void list_del_init(list_entry_t * pcur)
{
	list_del(pcur);
	list_init(pcur);
}

inline bool list_empty(list_entry_t * phead)
{
	return phead->next == phead;
}

list_entry_t * list_next(list_entry_t * pcur)
{
	return pcur->next;
}

list_entry_t * list_prev(list_entry_t * pcur)
{
	return pcur->prev;
}


#endif