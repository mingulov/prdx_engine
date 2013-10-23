#include <ruby.h>

static VALUE _parse_to_hash(VALUE self, VALUE hash, VALUE str)
{
  Check_Type(hash, T_HASH);
  Check_Type(str, T_STRING);

  return rb_str_new2("hello world");
}

void Init_prdx_engine()
{
  VALUE mPrdxEngine = rb_define_module("PrdxEngine");
  rb_define_singleton_method(mPrdxEngine, "_parse_to_hash", _parse_to_hash, 2);
}
