#pragma once

#include <types.h>
#include <graphic.h>
#include <window.h>

/*
  point or rect of the component are all relative
  for example:
  if the point of window is (xw, yw) and the point of frame is (xf, yf)
  then the real position of frame is (xw+xf, yw+yf)
*/


typedef struct frame_s
{
  rect_t rect;      // relative rect
  rgb_t bgc;        // background color
  rgb_t frc;        // frame color
} frame_t;
void draw_frame(graphic_t *g, context_t *contex, frame_t *frame);

typedef struct button_s
{
  frame_t frame;    // button frame
  rgb_t btc;        // button color
} button_t;
void draw_button(graphic_t *g, context_t *contex, button_t *button);

typedef struct list_s
{
  frame_t frame;    // list frame
  rgb_t sepc;       // separator color
  uint32_t n;       // n list item
} list_t;
void draw_list(graphic_t *g, context_t *contex, list_t *list);
