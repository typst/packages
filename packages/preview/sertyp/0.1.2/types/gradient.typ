#import "generic.typ" as generic;
#import "../utils.typ" as utils;

#import "array.typ" as array_;
#import "function.typ" as func_;
#import "angle.typ" as angle_;
#import "ratio.typ" as ratio_;

#let FIELDS = (
  "linear": (
    "stops": generic, 
    "space": func_, 
    "relative": generic, 
    "angle": angle_
  ),
  "radial": (
    "stops": generic,
    "space": func_,
    "relative": generic,
    "center": array_,
    "radius": ratio_,
    "focal-center": generic, 
    "focal-radius": ratio_
  ),
  "conic": (
    "stops": generic,
    "angle": angle_,
    "center": array_,
    "relative": generic,
    "space": func_
  ),
);

#let serializer(g) = {
  utils.assert_type(g, gradient);
  
  import "function.typ" as func_;
  let kind = g.kind();
  let dict = (
    kind: func_.serializer(kind),
  );
  for (field, ty) in FIELDS.at(repr(kind)).pairs() {
    dict.insert(
      field, 
      ty.serializer(eval(
        "g."+field+"()", 
        scope: (g: g)
      ))
    );
  }
  return generic.raw_serializer(dictionary)(dict);
};

#let deserializer(d) = {
  utils.assert_type(d, dictionary);

  import "function.typ" as func_;
  let kind = func_.deserializer(d.remove("kind"));

  let args = utils.str_dict();
  for (field, val) in d.pairs() {
    let ty = FIELDS.at(repr(kind)).at(field);
    args.insert(field, ty.deserializer(val));
  };
  let stops = args.remove("stops");
  
  return kind(
      ..stops,
      ..args
  );
}

#let test(cycle) = {
  let null = cycle(gradient.linear(
    ..color.map.viridis,
  ));
};