#import "generic.typ" as generic;
#import "../utils.typ" as utils;

#let serializer(r) = {
  utils.assert_type(r, relative);

  let relative = repr(r);
  let parts = relative.split(" + ").map(p => eval(p));
  
  import "array.typ" as array_;
  return array_.serializer(parts);      
};

#let deserializer(r) = {
  utils.assert_type(r, array);

  import "array.typ" as array_;

  let parts = array_.deserializer(r);
  let relative = 0%;
  for part in parts {
    relative = relative + part;
  }
  return relative;
}

#let test(cycle) = {
  for v in (0% + 2cm, 5% - 1cm + 2% -3pt) {
    let null = cycle(v);
  }
};