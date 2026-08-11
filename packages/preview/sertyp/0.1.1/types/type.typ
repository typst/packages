#import "generic.typ" as generic;
#import "../utils.typ" as utils;

#let serializer(t) = {
  utils.assert_type(t, type);

  import "string.typ" as string_;
  return string_.serializer(utils.type_str(t));
};

#let deserializer(t) = {
  utils.assert_type(t, str);
  let T = (
    "integer": "int",
    "string": "str",
    "auto": "type(auto)",
    "none": "type(none)",
    "panic": "\"panic\""
  )
  return eval(T.at(t, default: t));
}

#let test(cycle) = {
  for v in (int, float, type(auto), type(none), str, type, tiling, color) {
    let null = cycle(v);
  }
};