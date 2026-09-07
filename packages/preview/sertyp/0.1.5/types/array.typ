#import "generic.typ" as generic;
#import "../utils.typ" as utils;

#let serializer(a) = {
  utils.assert_type(a, array)
  return generic.raw_serializer(array)(a.map(item => {
    generic.serializer(item)
  }))
};

#let deserializer(a, ctx, request) = {
  utils.assert_type(a, array)

  return request(a.map(v => (v, generic)), none, (a, _n) => {
    a
  })
}

#let test(cycle) = {
  let arr = ()
  cycle(arr)
  for v in (1, 2.5, "test", rgb("#ff0000")) {
    arr = arr + (v,)
    cycle(arr)
  }
};
