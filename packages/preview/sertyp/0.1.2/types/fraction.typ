#import "generic.typ" as generic;
#import "../utils.typ" as utils;

#let serializer(f) = {
  utils.assert_type(f, fraction);
  
  return generic.value_unit_serializer(repr(f));
};

#let deserializer = generic.value_unit_deserializer;

#let test(cycle) = {
  for v in (1fr, 0.5fr, 3.3fr, -2fr) {
    let null = cycle(v)
  }
};