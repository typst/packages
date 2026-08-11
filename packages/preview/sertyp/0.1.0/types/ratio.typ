#import "generic.typ" as generic;
#import "../utils.typ" as utils;

#let serializer(a) = {
  utils.assert_type(a, ratio);
  
  return generic.str_dict_serializer(generic.value_unit_serializer(repr(a)));
};

#let deserializer = generic.value_unit_deserializer;

#let test() = {
  for v in (1%, 0.5%, 120%, -3.12412%) {
    generic.test_repr(v)
  }
};