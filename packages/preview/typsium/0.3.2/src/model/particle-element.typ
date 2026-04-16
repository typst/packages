#import "@preview/elembic:1.1.1" as e
#import "../utils.typ": (
  charge-to-content, count-to-content, customizable-attach, is-default
)

#let symbols = (
  e:[e],
  p:[p],
  ap: math.accent([p], sym.macron),
  an: math.accent([n], sym.macron),
  n:[n],
  m: sym.mu,
  a: sym.alpha,
  b: sym.beta,
  g: sym.gamma,
  ne: math.attach(sym.nu, br:[e]),
  ane: math.attach(math.accent(sym.nu, sym.macron), br:[e]),
)

#let particle(
  symbol: "",
  count: 1,
  charge: 0,
  negative-symbol: math.minus,
  positive-symbol: math.plus,
  count-spacing: sym.space.nobreak,
) = {}

#let draw-particle(it) = {
  let result = count-to-content(it.count)
  if not is-default(result) {
    result += it.count-spacing
  }

  let base = if type(it.symbol) == str{
    symbols.at(it.symbol, default:it.symbol)
  } else{
    it.symbol
  }
  
  result += customizable-attach(
    base,
    tr: charge-to-content(
      it.charge,
      radical: false,
      roman: false,
      negative-symbol: it.negative-symbol,
      positive-symbol: it.positive-symbol,
    ),
  )

  return result
}

#let particle = e.element.declare(
  "particle",
  prefix: "@preview/typsium:0.3.2",

  display: draw-particle,

  fields: (
    e.field("symbol", e.types.union(str, content), default: none, required: true),
    e.field("count", e.types.union(int, content), default: 1),
    e.field("charge", e.types.union(int, content), default: 0),
    e.field("negative-symbol", content, default: math.minus),
    e.field("positive-symbol", content, default: math.plus),
    e.field("count-spacing", content, default: sym.space.nobreak),
  ),
)
