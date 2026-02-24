#import "generic.typ" as generic;
#import "../utils.typ" as utils;

#let serializer(r) = {
  utils.assert_type(r, regex);

  return ([#r].fields().at("text")).match(regex("regex\((.*?)\)")).captures.at(0);
};

#let deserializer(s) = {
  utils.assert_type(s, str);
  return regex(s);
};

#let test() = {
  utils.assert(
    serializer(regex("[a-z]+")),
    "\"[a-z]+\"",
  );

  generic.test(regex("^[0-9]{3}-[0-9]{2}-[0-9]{4}$"));
}