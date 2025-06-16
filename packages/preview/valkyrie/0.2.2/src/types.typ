#import "base-type.typ": base-type
#import "assertions.typ": one-of
#import "types/array.typ": array
#import "types/dictionary.typ": dictionary
#import "types/logical.typ": either
#import "types/number.typ": number, integer, floating-point
#import "types/sink.typ": sink
#import "types/string.typ": string, ip, email
#import "types/tuple.typ": tuple

#let alignment = base-type.with(name: "alignment", types: (alignment,))
#let angle = base-type.with(name: "angle", types: (angle,))
#let any = base-type.with(name: "any")
#let boolean = base-type.with(name: "bool", types: (bool,))
#let bytes = base-type.with(name: "bytes", types: (bytes,))
#let color = base-type.with(name: "color", types: (color,))
#let content = base-type.with(name: "content", types: (content, str, symbol))
#let date = base-type.with(name: "date", types: (datetime,))
#let direction = base-type.with(name: "direction", types: (direction,))
#let function = base-type.with(name: "function", types: (function,))
#let fraction = base-type.with(name: "fraction", types: (fraction,))
#let gradient = base-type.with(name: "gradient", types: (gradient,))
#let label = base-type.with(name: "label", types: (label,))
#let length = base-type.with(name: "length", types: (length,))
#let location = base-type.with(name: "location", types: (location,))
#let plugin = base-type.with(name: "plugin", types: (plugin,))
#let ratio = base-type.with(name: "ratio", types: (ratio,))
#let regex = base-type.with(name: "regex", types: (regex,))
#let relative = base-type.with(
  name: "relative",
  types: (relative, ratio, length),
)
#let selector = base-type.with(name: "selector", types: (selector,))
#let stroke = base-type.with(name: "stroke", types: (stroke,))
#let symbol = base-type.with(name: "symbol", types: (symbol,))
#let version = base-type.with(name: "version", types: (version,))

#let choice(list, assertions: (), ..args) = base-type(
  name: "enum",
  ..args,
  assertions: (one-of(list), ..assertions),
) + (
  choices: list,
)
