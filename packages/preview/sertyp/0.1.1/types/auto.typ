#import "generic.typ" as generic;
#import "../utils.typ" as utils;

#let serializer(n) = {
  utils.assert_type(n, type(auto));
  return generic.no_value;
}

#let deserializer() = {
  return auto;
};

#let test(cycle) = {
  cycle(auto);
}