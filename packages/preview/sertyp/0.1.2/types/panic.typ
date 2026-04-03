#import "generic.typ" as generic;
#import "../utils.typ" as utils;

#let serializer(n) = {
  panic("panic cannot be serialized. This is a utility type for WASM plugins to signal unrecoverable errors.This serilaizer method should never be called.");
};

#let deserializer(m) = {
  utils.assert_type(m, str);

  panic("WASM ERROR: " + m);
};

#let test(cycle) = {
};