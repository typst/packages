#import "generic.typ" as generic;
#import "../utils.typ" as utils;

#let serializer(m) = {
  utils.assert_type(m, module);

  let fn = ();
  for (key, member) in dictionary(m).pairs() {
    fn.push(repr(member)); 
  }
  let name = repr(m).match(regex("\<module (.*?)\>")).captures.at(0);
  import "array.typ" as array_;
  generic.str_dict_serializer((
    name: generic.str_serializer(name),
    member: array_.serializer(fn)
  ))
}

#let deserializer(a) = {
  utils.assert_type(a, dictionary);

  return eval("{import \"" + a.at("name") + ".typ\" as __mod_; __mod_}");
}

#let test() = {
  import "module.typ" as mod_;
  import "array.typ" as array_;

  utils.assert(
    serializer(mod_),
    generic.str_dict_serializer((
      name: generic.str_serializer("module"),
      member: array_.serializer((
        "<module generic>",
        "<module utils>",
        "serializer",
        "deserializer",
        "test"
      ))
    ))
  );
  generic.test(mod_);
  generic.test(array_);
}