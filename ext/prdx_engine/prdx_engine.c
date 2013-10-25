#include "prdx_engine.h"
#include "parser.h"

VALUE g_mPrdxEngine = 0;

void Init_prdx_engine()
{
  g_mPrdxEngine = rb_define_module("PrdxEngine");

  // initialize other modules
  init_parser();
}
