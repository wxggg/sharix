#pragma once

#include <types.h>
#include <graphic.h>
#include <editbox.h>
#include <cpp.h>
#include <bitmap.h>

#define TITLE_H 30
#define TITLE_C DarkGray

#define LIST_H  30

typedef struct contex_s
{
  rect_t rect;  // window rect
  rgb_t bgc;    // window background color
} context_t;

typedef struct window_s
{
  Define_Member(window_s)

  char *name;
  context_t contex;

  bitmap_t *bgbmp;

  editbox_t *edit;          // editbox

  void (*show)();
  void (*destroy)();
} window_t;

window_t* get_parent_window();

window_t * create_window(int width, int height);
void destroy_window(window_t * win);

void draw_mouse(uint32_t x, uint32_t y);
