#import "generic.typ" as generic;
#import "../utils.typ" as utils;

#let FIELDS = (
  "linear": ("stops", "angle", "relative", "space"),
  "radial": ("stops", "center", "focal-center", "focal-radius", "radius", "relative", "space"),
  "conic": ("stops", "angle", "center", "relative", "space"),
);

#let serializer(a) = {
  utils.assert_type(a, gradient);
  
  let kind = a.kind();
  let dict = (
    kind: generic.serialize(kind),
  );
  for field in FIELDS.at(repr(kind)) {
    dict.insert(
      field, 
      generic.serialize(eval(
        "a."+field+"()", 
        scope: (a: a)
      ))
    );
  }
  generic.str_dict_serializer(dict)
};

#let deserializer(a) = {
  utils.assert_type(a, dictionary);

  a.kind.value = "gradient." + a.kind.value;
  let args = utils.str_dict();
  for (key, val) in a.pairs() {
      args.insert(key, generic.deserialize(val));
  };
  let kind = args.remove("kind");
  let stops = args.remove("stops");

  return kind(
      ..stops,
      ..args
  );
}

#let test() = {
  generic.test_repr(gradient.linear(
    ..color.map.viridis,
  ));
};