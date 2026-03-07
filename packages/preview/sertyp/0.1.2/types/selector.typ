#import "generic.typ" as generic;
#import "../utils.typ" as utils;

#let serializer(s) = {
  utils.assert_type(s, selector);
  
  panic("Selector serialization is not yet supported");
};

#let deserializer(s) = {
  panic("Selector deserialization is not yet supported")
}

#let test_serializer(cycle) = {
  // TODO
}