#import "generic.typ" as generic;
#import "../utils.typ" as utils;

/// Serializer for boolean values.
/// Returns "true" for `true` and "false" for `false`.
#let serializer(b) = {
  utils.assert_type(b, bool);
  if b { "true" } else { "false" }
};

#let deserializer = generic.plain_type_deserializer(bool);

#let test() = {
  generic.test(true);
  generic.test(false);
};