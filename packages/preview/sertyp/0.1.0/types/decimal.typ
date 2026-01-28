#import "generic.typ" as generic;
#import "../utils.typ" as utils;

#let serializer(d) = {
  utils.assert_type(d, decimal);
  generic.str_serializer(d);
};

#let deserializer(s) = {
  utils.assert_type(s, str);
  return decimal(s);
};

#let test() = {
  generic.test(decimal("12.34"));
};