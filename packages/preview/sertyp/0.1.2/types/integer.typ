#import "generic.typ" as generic;
#import "../utils.typ" as utils;

#let serializer = generic.raw_serializer(int);

#let deserializer = generic.raw_deserializer(int);

#let test(cycle) = {
  for v in (0, -123, 4567890123) {
    let null = cycle(v);
  }
};