#import "../utils.typ" as utils;
#import "generic.typ" as generic;

#let serializer(f, ctx: none) = {
  utils.assert_type(f, function);
  
  return generic.str_serializer(if ctx != none { ctx + "." } else { "" } + repr(f));
};

#let deserializer(s) = {
  utils.assert_type(s, str);

  if s == "(..) => .." {
    panic(s, "Inline function deserialization is not supported");
  }
  return eval(s);
};

#let test() = {
  utils.assert(
      serializer((x: int) => { return "test"; }),
      "\"(..) => ..\""
  );
  utils.assert(
    serializer(table.cell),
    "\"cell\""
  )
  utils.assert(
    deserializer("repr"),
    repr
  )
  generic.test(repr);
};