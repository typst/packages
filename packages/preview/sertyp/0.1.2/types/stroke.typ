#import "generic.typ" as generic;
#import "../utils.typ" as utils;

#let serializer(s) = {
  utils.assert_type(s, stroke);
  
  import "dictionary.typ" as dict_;

  return dict_.serializer((
    cap: s.cap,
    dash: s.dash,
    join: s.join,
    miter-limit: s.miter-limit,
    paint: s.paint,
    thickness: s.thickness
  ));
};

#let deserializer(d) = {
  utils.assert_type(d, dictionary);
  
  import "dictionary.typ" as dict_;

  let args = dict_.deserializer(d);
  return stroke(..args);
};

#let test(cycle) = {
  let null = cycle(stroke(2pt));
  cycle(
    stroke(paint: blue, thickness: 4pt, cap: "round")
  );
}