#import "generic.typ" as generic;
#import "../utils.typ" as utils;

#let serializer = generic.str_serializer(decimal);

#let deserializer(s) = {
  utils.assert_type(s, str);
  return decimal(s);
};

#let test(cycle) = {
  cycle(decimal("12.34"));
};