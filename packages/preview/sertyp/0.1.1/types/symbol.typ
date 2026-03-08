#import "generic.typ" as generic;
#import "../utils.typ" as utils;

#let serializer(s) = {
  utils.assert_type(s, symbol);

  import "string.typ" as string_;
  return string_.serializer([#s].fields().at("text"));
};

#let deserializer(s) = {
  utils.assert_type(s, str);
  
  return symbol(s);
};

#let test(cycle) = {
  for v in (sym.plus, sym.minus, sym.arrow.l, sym.arrow.r) {
    cycle(symbol(v));
  }
}