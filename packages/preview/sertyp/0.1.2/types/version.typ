#import "generic.typ" as generic;
#import "../utils.typ" as utils;

#let serializer(v) = {
  utils.assert_type(v, version);
  
  import "integer.typ" as int_;
  return generic.raw_serializer(dictionary)((
      major: int_.serializer(v.major),
      minor: int_.serializer(v.minor),
      patch: int_.serializer(v.patch),
  ));
};

#let deserializer(d) = {
  utils.assert_type(d, dictionary);

  import "integer.typ" as int_;
  return version(
    int_.deserializer(d.at("major")),
    int_.deserializer(d.at("minor")),
    int_.deserializer(d.at("patch"))
  );
};

#let test(cycle) = {
  import "dictionary.typ" as dict_;
  
  for v in (
    version(1, 0, 0),
    version(2, 5, 3),
    version(0, 1, 10),
  ) {
    let null = cycle(v);
  }
}