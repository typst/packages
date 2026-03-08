#import "generic.typ" as generic;
#import "../utils.typ" as utils;

#let serializer(d) = {
  utils.assert_type(d, datetime);
  
  let fields = generic.at_optional(
    d,
    ("year", "month", "day", "hour", "minute", "second")    
  );
  import "dictionary.typ" as dict_;
  return dict_.serializer(fields);
};

#let deserializer(d) = {
  utils.assert_type(d, dictionary);

  return datetime(..arguments(..d));
}

#let test() = {
  import "dictionary.typ" as dict_;
  
  generic.test(datetime(
    year: 2024,
    month: 6,
    day: 15,
  ));

  generic.test(datetime(
    year: 2024,
    month: 6,
    day: 15,
    hour: 14,
    minute: 30,
    second: 45,
  ));
}