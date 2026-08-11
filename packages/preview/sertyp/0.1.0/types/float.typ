#import "generic.typ" as generic;
#import "../utils.typ" as utils;

#let serializer(f) = {
  utils.assert_type(f, float);
  generic.raw_serializer(f);
};

#let deserializer(f) = {
  if type(f) == int {
    f = float(f);
  }
  utils.assert_type(f, float);
  return f;
};

#let test() = {
  for v in (0.0, -1.5, 3.14159, 1e10, -2.7e-3) {
    generic.test(v);
  }
};