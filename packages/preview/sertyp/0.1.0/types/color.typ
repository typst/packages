#import "generic.typ" as generic;
#import "../utils.typ" as utils;

#let serializer(c) = {
  utils.assert_type(c, color);

  import "array.typ" as array_;
  import "function.typ" as func_;
  return generic.str_dict_serializer((
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

#let test() = {
  generic.test_repr(rgb(1,2,3));
  generic.test_repr(rgb(50%,25%,75%));
  generic.test_repr(color.hsv(120deg,50%,4));
  generic.test_repr(color.hsl(240deg,30%,60%));
};