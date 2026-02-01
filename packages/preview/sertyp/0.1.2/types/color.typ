#import "generic.typ" as generic;
#import "../utils.typ" as utils;

#let serializer(c) = {
  utils.assert_type(c, color);

  import "array.typ" as array_;
  import "function.typ" as func_;
  return generic.raw_serializer(dictionary)((
    components: array_.serializer(c.components()),
    space: func_.serializer(c.space(), ctx: "color")
  ));
};

#let deserializer(a) = {
  utils.assert_type(a, dictionary);

  import "array.typ" as array_;
  import "function.typ" as func_;
  let components = array_.deserializer(a.components);
  let space = func_.deserializer(a.space);
  return space(..components);
}

#let test(cycle) = {
  let null = cycle(rgb(1,2,3));
  let null = cycle(rgb(50%,25%,75%));
  let null = cycle(color.hsv(120deg,50%,4));
  let null = cycle(color.hsl(240deg,30%,60%));
};