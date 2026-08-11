#import "generic.typ" as generic;
#import "../utils.typ" as utils;

#let serializer(n) = {
  utils.assert_type(n, type(none));
  return generic.no_value;
}

#let deserializer() = {
  return none;
};

#let test(cycle) = {
  cycle(none);
}