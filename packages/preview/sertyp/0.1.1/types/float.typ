#import "generic.typ" as generic;
#import "../utils.typ" as utils;

#let serializer = generic.raw_serializer(float);

#let deserializer(f) = {
  if type(f) == int {
    f = float(f);
  }
  utils.assert_type(f, float);
  return f;
};

#let test(cycle) = {
  for v in (0.0, -1.5, 3.14159, 1e10, -2.7e-3) {
    let null = cycle(v);
  }
};