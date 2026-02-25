#import "generic.typ" as generic;
#import "../utils.typ" as utils;

#let serializer(t) = {
  utils.assert_type(t, type);
  generic.str_serializer(utils.type_str(t));
};

#let deserializer(t) = {
  utils.assert_type(t, str);
  let T = (
    "integer": "int",
    "string": "str",
    "auto": "type(auto)",
    "none": "type(none)",
  )
  return eval(T.at(t, default: t));
}

#let test() = {
  for v in (int, float, type(auto), type(none), str, type, tiling, color) {
    generic.test(v);
  }
};