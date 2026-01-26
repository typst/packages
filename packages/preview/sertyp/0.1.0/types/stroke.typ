#import "generic.typ" as generic;
#import "../utils.typ" as utils;

#let serializer(s) = {
  utils.assert_type(s, stroke);
  
  return generic.str_dict_serializer((
    cap: generic.serialize(s.cap),
    dash: generic.serialize(s.dash),
    join: generic.serialize(s.join),
    miter-limit: generic.serialize(s.miter-limit),
    paint: generic.serialize(s.paint),
    thickness: generic.serialize(s.thickness)
  ));
};

#let deserializer(d) = {
  utils.assert_type(d, dictionary);
  
  import "dictionary.typ" as dict_;

  let args = dict_.deserializer(d);
  return stroke(..args);
};

#let test() = {
  generic.test(
    stroke(paint: blue, thickness: 4pt, cap: "round")
  );
}