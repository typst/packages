#import "../utils.typ" as utils;
#import "generic.typ" as generic;

#let serializer(s) = {
  utils.assert(str(type(s)), "styles");
  
  return generic.serialize(s.child);
}

#let deserializer(s) = {
  utils.assert_type(s, str);
  return eval(s);
}

#let test(cycle) = {
  // TODO: Implement test
}