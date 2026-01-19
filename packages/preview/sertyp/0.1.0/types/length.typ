#import "generic.typ" as generic;
#import "../utils.typ" as utils;

#let serializer(l) = {
  utils.assert_type(l, length);
  
  import "float.typ" as float_;

  let dict = generic.value_unit_serializer(repr(l.abs));
  dict.insert("em", float_.serializer(float(l.em)));
  
  return generic.str_dict_serializer(dict);
};

#let deserializer(l) = {
  utils.assert_type(l, dictionary);

  import "float.typ" as float_;

  let value_unit = generic.value_unit_deserializer(l);
  let em = float_.deserializer(l.at("em"));
  return value_unit + eval(str(em) + "em");
};

#let test() = {
  import "float.typ" as float_;

  for v in (10pt + 2em, 5.5pt + 0em, 0pt + 1.2em, -3.3cm + 4em) {
    generic.test_repr(v)
  }
};