#import "@preview/elembic:1.1.1" as e
#import "../utils.typ": (
  charge-to-content, count-to-content, customizable-attach, is-default, none-coalesce, oxidation-to-content,
)

#let element(
  symbol: "",
  count: 1,
  charge: 0,
  oxidation: none,
  a: none,
  z: none,
  rest: none,
  radical: false,
  affect-layout: true,
  roman-oxidation: true,
  spaced-charge: false,
  roman-charge: false,
  radical-symbol: sym.bullet,
  negative-symbol: math.minus,
  positive-symbol: math.plus,
) = {}

#let draw-element(it) = {
  let base = it.symbol
  if it.rest != none {
    if type(it.rest) == content {
      base += it.rest
    } else if type(it.rest) == int {
      base += box['] * it.rest
    }
  }

  let mass-number = it.a
  if type(it.a) == int {
    mass-number = [#it.a]
  }
  let atomic-number = it.z
  if type(it.z) == int {
    atomic-number = [#it.z]
  }
  
  if it.spaced-charge and not is-default(it.charge) and not is-default(it.count) {
    customizable-attach(
      base,
      t: oxidation-to-content(
        it.oxidation,
        roman: it.roman-oxidation,
        negative-symbol: it.negative-symbol,
        positive-symbol: it.positive-symbol,
      ),
      br: count-to-content(it.count),
      tl: mass-number,
      bl: atomic-number,
      affect-layout: it.affect-layout,
    )
    math.attach(none, tr:charge-to-content(
        it.charge,
        radical: it.radical,
        roman: it.roman-charge,
        radical-symbol: it.radical-symbol,
        negative-symbol: it.negative-symbol,
        positive-symbol: it.positive-symbol,
      )
    )
  } else {
    customizable-attach(
      base,
      t: oxidation-to-content(
        it.oxidation,
        roman: it.roman-oxidation,
        negative-symbol: it.negative-symbol,
        positive-symbol: it.positive-symbol,
      ),
      tr: charge-to-content(
        it.charge,
        radical: it.radical,
        roman: it.roman-charge,
        radical-symbol: it.radical-symbol,
        negative-symbol: it.negative-symbol,
        positive-symbol: it.positive-symbol,
      ),
      br: count-to-content(it.count),
      tl: mass-number,
      bl: atomic-number,
      affect-layout: it.affect-layout,
    )
  }
}
}

#let element = e.element.declare(
  "element",
  prefix: "@preview/typsium:0.3.0",

  display: draw-element,

  fields: (
    e.field("symbol", e.types.union(str, content), default: none, required: true),
    e.field("count", e.types.union(int, content), default: 1),
    e.field("charge", e.types.union(int, content), default: 0),
    e.field("oxidation", e.types.union(int, content), default: none),
    e.field("a", e.types.union(int, content), default: none),
    e.field("z", e.types.union(int, content), default: none),
    e.field("rest", e.types.union(int, content), default: none),
    e.field("radical", bool, default: false),
    e.field("affect-layout", bool, default: true),
    e.field("roman-oxidation", bool, default: true),
    e.field("roman-charge", bool, default: false),
    e.field("spaced-charge", bool, default: false),
    e.field("radical-symbol", content, default: sym.bullet),
    e.field("negative-symbol", content, default: math.minus),
    e.field("positive-symbol", content, default: math.plus),
  ),
)
