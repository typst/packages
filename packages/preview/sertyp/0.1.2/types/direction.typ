#import "generic.typ" as generic;
#import "../utils.typ" as utils;

#let serializer = generic.repr_serializer(direction);

#let deserializer(s) = {
  utils.assert_type(s, str);
  return eval(s);
};

#let test(cycle) = {
  for v in (ltr, rtl) {
    let null = cycle(v);
  }
}