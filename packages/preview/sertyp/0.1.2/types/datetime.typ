#import "generic.typ" as generic;
#import "../utils.typ" as utils;

#let serializer(d) = {
  utils.assert_type(d, datetime);
  
  let fields = generic.at_optional(
    d,
    ("year", "month", "day", "hour", "minute", "second")    
  );
  import "dictionary.typ" as dict_;
  import "integer.typ" as int_;
  return generic.raw_serializer(dictionary)(fields.pairs().map(((k,v))=>{
    (k, int_.serializer(v))
  }).to-dict())
};

#let deserializer(d) = {
  utils.assert_type(d, dictionary);

  return datetime(..arguments(..d));
}

#let test(cycle) = {
  import "dictionary.typ" as dict_;
  
  let null = cycle(datetime(
    year: 2024,
    month: 6,
    day: 15,
  ));

  let null = cycle(datetime(
    year: 2024,
    month: 6,
    day: 15,
    hour: 14,
    minute: 30,
    second: 45,
  ));
}