#import "base-type.typ": base-type
#import "assertions.typ": one-of
#import "types/array.typ": array
#import "types/dictionary.typ": dictionary
#import "types/logical.typ": either
#import "types/string.typ": string, ip, email
#import "types/tuple.typ": tuple

#let any = base-type.with(name: "any")
#let boolean = base-type.with(name: "bool", types: (bool,))
#let color = base-type.with(name: "color", types: (color,))
#let content = base-type.with(name: "content", types: (content, str))
#let date = base-type.with(name: "date", types: (datetime,))
#let number = base-type.with(name: "number", types: (float, int))
#let integer = number.with(name: "integer", types: (int,))
#let floating-point = number.with(name: "float", types: (float,))

#let choice(list, assertions: (), ..args) = base-type(
  name: "enum",
  ..args,
  assertions: (one-of(list), ..assertions),
)
