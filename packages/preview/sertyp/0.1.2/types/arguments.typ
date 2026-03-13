#import "generic.typ" as generic;
#import "../utils.typ" as utils;

#let serializer(a) = {
  utils.assert_type(a, arguments);
  
  import "dictionary.typ" as dict_;
  import "array.typ" as array_;
  return generic.raw_serializer(dictionary)((
    pos: array_.serializer(a.pos()),
    named: dict_.serializer(a.named())
  ));
};

#let deserializer(a) = {
  utils.assert_type(a, dictionary);

  import "dictionary.typ" as dict_;
  import "array.typ" as array_;
  return arguments(
    ..array_.deserializer(a.at("pos")),
    ..dict_.deserializer(a.at("named"))
  );
}

#let test(cycle) = {
  import "dictionary.typ" as dict_;
  import "array.typ" as array_;

  let args = arguments(3, 4, foo: "bar", baz: 42, qux: (1, 2));
  cycle(args); 
};