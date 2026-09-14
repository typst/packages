#import "generic.typ" as generic;
#import "../utils.typ" as utils;

#let serializer = generic.str_serializer(label);

#let deserializer(l) = {
  utils.assert_type(l, str);
  return label(l);
};

#let test(cycle) = {
  cycle(<abc>);
};