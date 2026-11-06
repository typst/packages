#import "generic.typ" as generic;
#import "../utils.typ" as utils;

#let serializer(i) = {
  utils.assert_type(i, int);
  generic.raw_serializer(i);
};

#let deserializer(i) = {
  utils.assert_type(i, int);
  return i;
};

#let test() = {
  for v in (0, -123, 4567890123) {
    generic.test(v);
  }
};