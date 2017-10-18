#include <window.h>
#include <slab.h>
#include <kerninfo.h>
#include <color.h>
#include <stdlib.h>
#include <font.h>
#include <editbox.h>

Define_Method(window_t)

/*********** global value ************/
window_t * parent = NULL;
static bitmap_t* p_bmp_icon2 = (bitmap_t*)(BMP_ICON_ADDR+KERNBASE);

/********* member function *******************/
void show()
{
  MethodOf(window_t);

  graphic_t * g = get_graphic();

  if(this->bgbmp) {
    g->fill_bitmap(get_scrn_rect(), this->bgbmp);
  }
  else {
    g->fill_rect(this->contex.rect, this->contex.bgc);
  }

  g->draw_rect(this->contex.rect, SkyBlue);
  g->fill_rect(RECTP(this->contex.rect.p, this->contex.rect.width, TITLE_H), TITLE_C);


  // editbox_t * peb = this->edit;
  // if(peb) {
  //   g->fill_rect(RECTP(peb->point, peb->ch_x*ASC16_WIDTH, peb->ch_y*ASC16_HEIGHT), peb->bg_c);
  // }
}

void destroy()
{
  MethodOf(window_t);

  if(this->edit) {
    //TODO: there should be destroy_editbox
    kfree(this->edit);
  }
  kfree(this);
}





/********* create *******************/
window_t* get_parent_window()
{
  if(!parent) {
    window_t * win = (window_t*) kmalloc(sizeof(window_t));
    win->contex.rect = get_scrn_rect();
    win->contex.bgc = DarkOliveGreen;
    win->bgbmp = p_bmp_icon2;
    win->edit = NULL;
    Register_Method(win, window_t)
    win->show = show;
    win->destroy = destroy;
    return win;
  }
  return parent;
}

window_t * create_window(int width, int height)
{
  window_t * parent = get_parent_window();
  window_t * win = (window_t*) kmalloc(sizeof(window_t));
  int randx = rand()%(parent->contex.rect.width-width);
  int randy = TITLE_H + rand()%(parent->contex.rect.height-height-TITLE_H);
  win->contex.rect = RECT(randx, randy, width, height);
  win->contex.bgc = Khaki;
  Register_Method(win, window_t)
  win->show = show;
  win->destroy = destroy;
  return win;
}

void draw_mouse(uint32_t x, uint32_t y)
{
  graphic_t *g = get_graphic();
  g->fill_rect(RECT(x,y,6,6), Navy);
  g->fill_rect(RECT(x+3,y+3,10,10), CornflowerBlue);
}
