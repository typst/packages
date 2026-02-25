#import "generic.typ" as generic;
#import "../utils.typ" as utils;

#let serializer(d) = {
  utils.assert_type(d, duration);
  
  import "float.typ" as float_;
  return float_.serializer(float(d.seconds()));
};

#let deserializer(f) = {
  if type(f) == int {
    f = float(f);
  }
  utils.assert_type(f, float);
  return duration(seconds: int(f));
}

#let test(cycle) = {
  import "float.typ" as float_;

  let null = cycle(duration(seconds: 12));
  let null = cycle(duration(days: 2, hours: 5, minutes: 30, seconds: 42));
}