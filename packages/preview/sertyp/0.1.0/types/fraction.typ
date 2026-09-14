#import "generic.typ" as generic;
#import "../utils.typ" as utils;

#let serializer(f) = {
  utils.assert_type(f, fraction);
  
  return generic.str_dict_serializer(generic.value_unit_serializer(repr(f)));
};

#let deserializer = generic.value_unit_deserializer;

#let test() = {
  for v in (1fr, 0.5fr, 3.3fr, -2fr) {
    generic.test(v)
  }
};