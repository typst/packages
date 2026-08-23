#import "generic.typ" as generic;
#import "../utils.typ" as utils;

#let serializer(d) = {
  utils.assert_type(d, dictionary)

  let dict = utils.str_dict()
  for (key, value) in d.pairs() {
    dict.insert(key, generic.serializer(value))
  }
  return generic.raw_serializer(dictionary)(dict)
}

#let deserializer(d, ctx, request) = {
  if d == () {
    d = (:)
  }
  utils.assert_type(d, dictionary)
  return request(d.values().map(v => (v, generic)), d, (deps, d) => {
    d.keys().enumerate().map(((i, k)) => (k, deps.at(i))).to-dict()
  })
}

#let test(cycle) = {
  cycle(("a": 2, b: -1.1, c: "test", d: rgb("#ff0000")))
}
