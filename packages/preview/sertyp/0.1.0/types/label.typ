#import "generic.typ" as generic;
#import "../utils.typ" as utils;

#let serializer(l) = {
  utils.assert_type(l, label);
  generic.str_serializer(l);
};

#let deserializer(l) = {
  utils.assert_type(l, str);
  return label(l);
};

#let test() = {
  generic.test(<abc>);
};