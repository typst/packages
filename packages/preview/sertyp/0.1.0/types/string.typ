#import "generic.typ" as generic;
#import "../utils.typ" as utils;

#let serializer(s) = {
  utils.assert_type(s, str);
  generic.str_serializer(s);
};

#let deserializer = generic.plain_type_deserializer(str);

#let test() = {
  for v in ("", "Hello, World!", "1234567890", "Special chars: !@#$%^&*()", "\n\r\t\b\x\\\²\"") {
    generic.test(v);
  }
};