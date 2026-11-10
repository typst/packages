#import "generic.typ" as generic;
#import "../utils.typ" as utils;

#let serializer(d) = {
  utils.assert_type(d, direction);
  
  return generic.str_serializer(repr(d));
};

#let deserializer = generic.eval_deserializer;

#let test() = {
  for v in (ltr, rtl) {
    generic.test(v);
  }
}