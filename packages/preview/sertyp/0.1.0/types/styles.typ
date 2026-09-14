#import "../utils.typ" as utils;
#import "generic.typ" as generic;

#let serializer(s) = {
  utils.assert(str(type(s)), "styles");
  
  return generic.serialize(s.child);
}

#let deserializer = generic.eval_deserializer;

#let test() = {
  // TODO: Implement test
}