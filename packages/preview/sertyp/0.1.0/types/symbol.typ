#import "generic.typ" as generic;
#import "../utils.typ" as utils;

#let serializer(s) = {
  utils.assert_type(s, symbol);

  return generic.str_serializer([#s].fields().at("text"));
};

#let deserializer(s) = {
  utils.assert_type(s, str);
  
  return symbol(s);
};

#let test() = {
  for v in (sym.plus, sym.minus, sym.arrow.l, sym.arrow.r) {
    generic.test(symbol(v));
  }
}