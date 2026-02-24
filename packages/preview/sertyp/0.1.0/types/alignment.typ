#import "generic.typ" as generic;
#import "../utils.typ" as utils;

#let serializer(a) = {
  utils.assert_type(a, alignment);
  
  return generic.str_serializer(repr(a));
};

#let deserializer = generic.eval_deserializer;

#let test() = {
  utils.assert(
    serializer(left),
    "\"left\""
  );
 
  for v in (left, right, center) {
    generic.test(v)
  }
}
