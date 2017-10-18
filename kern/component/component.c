#include <component.h>

void draw_frame(graphic_t *g, context_t *contex, frame_t *frame)
{
  int x = contex->rect.p.x;
  int y = contex->rect.p.y;
  rect_t frect = frame->rect;
  rect_t realrect = RECT(x+frect.p.x, y+frect.p.y, frect.width, frect.height);
  g->fill_rect(realrect, frame->bgc);
  g->draw_rect(realrect, frame->frc);
}

void draw_button(graphic_t *g, context_t *contex, button_t *button)
{
  draw_frame(g, contex, &button->frame);
  rect_t frect = button->frame.rect;
  int x1 = contex->rect.p.x + frect.p.x;
  int y1 = contex->rect.p.y + frect.p.y;
  int x2 = x1 + frect.width-1;
  int y2 = y1 + frect.height-1;
  g->draw_line(POINT(x1, y1),POINT(x2, y2), button->btc);
  g->draw_line(POINT(x1, y2),POINT(x2, y1), button->btc);
}

void draw_list(graphic_t *g, context_t *contex, list_t *list)
{
  draw_frame(g, contex, &list->frame);
  rect_t frect = list->frame.rect;
  int x1 = contex->rect.p.x + frect.p.x;
  int y1 = contex->rect.p.y + frect.p.y;
  for (size_t i = 0; i < list->n; i++) {
    g->draw_line(POINT(x1, y1), POINT(x1+frect.width, y1), list->sepc);
    y1 += LIST_H;
  }
}
