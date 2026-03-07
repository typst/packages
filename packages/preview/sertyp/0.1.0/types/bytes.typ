#import "generic.typ" as generic;
#import "../utils.typ" as utils;

#let serializer(b) = {
  utils.assert_type(b, bytes);
  let body = "";
  for b in b {
    body += str.from-unicode(b);
  }
  return generic.str_serializer(body);
};

#let deserializer(s) = {
  utils.assert_type(s, str);
  let chars = ();
  for c in s {
    chars.push(str.to-unicode(c));
  }
  return bytes(chars);
};

#let test() = {
    generic.test(bytes((1,2,3,4,5,76,77,0)));
};