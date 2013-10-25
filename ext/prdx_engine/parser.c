#include "parser.h"
#include "prdx_engine.h"

#define MAX_ARRAY_SIZE (10*1024)
//VALUE rb_empty_string = ;

static void hash_add_value(VALUE rHash, const char *name, long nameLen, VALUE rValue)
{
  VALUE rName = rb_str_new(name, nameLen);
  //fprintf(stderr, "name %s\n", name, nameLen);

  VALUE rArray = rb_hash_lookup(rHash, rName);
  if (rArray == Qnil)
  {
    rArray = rb_ary_new();
    rb_hash_aset(rHash, rName, rArray);
  }

  rb_ary_push(rArray, rValue);
}

static void hash_add_string(VALUE rHash, const char *name, long nameLen, const char *value, long valueLen)
{
  //fprintf(stderr, "add hash, key %p/%ld value %p/%ld\n", name, nameLen, value, valueLen);
  VALUE rValue = rb_str_new(value, valueLen);
  hash_add_value(rHash, name, nameLen, rValue);
}

static long parse_internal(VALUE rOut, const char *str, long str_begin, long str_end, int *pIsArray)
{
  const char *name = 0;
  long nameLen = 0;

  // to speedup - preallocate memory
  const char *values[MAX_ARRAY_SIZE];
  long valuesLen[MAX_ARRAY_SIZE];
  //long valuesBegin = 0;
  long valuesTotal = 0;

  // current string position 
  long pos = str_begin;

  // additional counter
  int i = 0;

  while (pos < str_end)
  {
    // skip spaces / tabs / CRLFs etc
    while (pos < str_end && str[pos] <= ' ')
      pos++;
    // stop if the end is reached already
    if (pos >= str_end)
      break;
    switch (str[pos])
    {
      case '=':
        if (valuesTotal > 1)
        {
          for (i = 0; i < valuesTotal - 1; i++)
          {
            hash_add_string(rOut, "", 0, values[i], valuesLen[i]);
          }
        }

        if (valuesTotal <= 0)
        {
          name = "";
          nameLen = 0;
        }
        else
        {
          name = values[valuesTotal - 1];
          nameLen = valuesLen[valuesTotal - 1];
        }
        //fprintf(stderr, "Name: '%.10s' len %d, values = %d\n", name, nameLen, valuesTotal);

        valuesTotal = 0;
        break;
      case '{':
            /*res = Hash.new { |h,k| h[k] = [] }
            #res.compare_by_identity
            i = _sav_parse(res, str, i + 1, str_end)
            # name might be nil but it is ok
            if res.keys == ['']
              out[name] << res['']
            else
              out[name] << res
            end
            name = ''*/
        {
          VALUE rNewHash = rb_hash_new();
          int isNewArray = 1;
          pos = parse_internal(rNewHash, str, pos + 1, str_end, &isNewArray);
          //fprintf(stderr, "'%.20s' / hash size %d, pos %d (%.5s)---\n", &str[str_begin], RHASH_SIZE(rNewHash), pos, &str[pos]);
          if (isNewArray)
          {
            VALUE rb_empty_string = rb_str_new("", 0);
            rNewHash = rb_hash_lookup(rNewHash, rb_empty_string);
          }
          hash_add_value(rOut, name, nameLen, rNewHash);
          if (nameLen && pIsArray)
            *pIsArray = 0;
        }
        name = 0;
        nameLen = 0;
        break;
      case '}':
        pos--;
        str_end = pos;
        //fprintf(stderr, "} found, begin %d end %d: %.20s\n", str_begin, str_end, &str[str_begin]);
        // todo: more checks for validity?..
        break;
      case '"':
        values[valuesTotal] = &str[pos];
        do
        {
          pos++;
        } while (pos < str_end && str[pos] != '"');
        //pos++;
        valuesLen[valuesTotal] = &str[pos] - values[valuesTotal] + 1;
        valuesTotal++;
        break;
      default:
        values[valuesTotal] = &str[pos];
        do
        {
          pos++;
        } while (pos < str_end && str[pos] > ' ' && str[pos] != '=' && str[pos] != '}');
        valuesLen[valuesTotal] = &str[pos] - values[valuesTotal];
        //fprintf(stderr, "Value: '%.10s' len %d, values = %d\n", values[valuesTotal], valuesLen[valuesTotal], valuesTotal + 1);
        valuesTotal++;
        // return back 1 character as pos++ will be done later
        pos--; 
        break;
    }

    if (name && valuesTotal > 0)
    {
      hash_add_string(rOut, name, nameLen, values[0], valuesLen[0]);
      if (nameLen && pIsArray)
        *pIsArray = 0;

      memmove(&values[0], &values[1], sizeof(values[0]) * (valuesTotal - 1));
      memmove(&valuesLen[0], &valuesLen[1], sizeof(valuesLen[0]) * (valuesTotal - 1));
      valuesTotal--;

      name = 0;
      nameLen = 0;
    }

    pos++;
  }

  // add all remaining values
  for (i = 0; i < valuesTotal; i++)
  {
    hash_add_string(rOut, "", 0, values[i], valuesLen[i]);
  }

  //fprintf(stderr, "Finish, begin %d end %d: %.20s\n", str_begin, str_end, &str[str_begin]);

  return pos;
}

static VALUE parse(VALUE self, VALUE rParam)
{
  VALUE rStr = rb_String(rParam);
  //Check_Type(rStr, T_STRING);

  long len = rb_str_strlen(rStr);
  const char *str = rb_string_value_ptr(&rStr);

  VALUE out = rb_hash_new();
  parse_internal(out, str, 0, len, 0);

  return out;
}

void init_parser()
{
  VALUE cSavParser = rb_define_class_under(g_mPrdxEngine, "SavParser", rb_cObject);
  rb_define_singleton_method(cSavParser, "parse", parse, 1);
}
