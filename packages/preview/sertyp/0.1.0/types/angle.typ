#import "generic.typ" as generic;
#import "../utils.typ" as utils;

#let serializer(a) = {
  utils.assert_type(a, angle);
  
  return generic.str_dict_serializer(generic.value_unit_serializer(repr(a)));
};

#let deserializer = generic.value_unit_deserializer;

#let test() = {
  import "dictionary.typ" as dict_;
  
  for v in (1deg, 0deg, -10deg, 3.3deg) {
    generic.test(v)
  }
};