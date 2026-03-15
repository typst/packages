#import "generic.typ" as generic;
#import "../utils.typ" as utils;

#let serializer(d) = {
  utils.assert_type(d, dictionary);

  let dict = utils.str_dict();
  for (key, value) in d.pairs() {
      dict.insert(key, generic.serialize(value)); 
  }
  return generic.str_dict_serializer(dict);
}

#let deserializer(d) = {
  if d == () {
    d = (:);
  }
  utils.assert_type(d, dictionary);
  return d.pairs().map(((k, v)) => {
    return (k, generic.deserialize(v));
  }).to-dict();
}

#let test() = {
  generic.test(("a": 2, b: -1.1, c: "test", d: rgb("#ff0000")));
}