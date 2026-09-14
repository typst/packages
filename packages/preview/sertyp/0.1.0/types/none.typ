#import "generic.typ" as generic;
#import "../utils.typ" as utils;

#let serializer(s) = {
  utils.assert_type(s, type(none));
  return repr(s);
};

#let deserializer = generic.plain_type_deserializer(type(none));

#let test() = {
  generic.test(none);
}