#import "generic.typ" as generic;
#import "../utils.typ" as utils;

#let serializer(s) = {
  utils.assert_type(s, type(auto));
  return repr(s);
};

#let deserializer = generic.plain_type_deserializer(type(auto));

#let test() = {
  generic.test(auto);
}