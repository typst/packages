#import "../loom-wrapper.typ": loom
#import loom.matcher as _matcher

#let require(value, value-name, ..types) = {
  import loom.matcher: *
  let allowed-types = types.pos().filter(t => type(t) == type)
  let allowed-values = types.pos().filter(t => type(t) != type)

  let message = (
    "variable `"
      + value-name
      + "`("
      + repr(value)
      + ") must be of "
      + if allowed-types.len() > 0 {
        (
          "type: ("
            + allowed-types.map(t => "`" + str(t) + "`").join(", ")
            + ") "
            + if allowed-values.len() > 0 { " or " } else { "" }
        )
      } else {
        ""
      }
      + if allowed-values.len() > 0 {
        (
          "value: ("
            + allowed-values.map(v => "`" + repr(v) + "`").join(", ")
            + ")"
        )
      }
  )

  assert(
    match(value, choice(..types)),
    message: message,
  )
}

// --- Primitive Unions ---
#let decimal-like = _matcher.choice(decimal, int, float, str)
#let ratio-like = _matcher.choice(ratio, float, decimal, int)
#let text-like = _matcher.choice(content, str)
#let date-like = _matcher.choice(datetime, (datetime, datetime))

// --- Domain Specific Enums
#let tax-mode = _matcher.choice("inclusive", "exclusive")
#let tax-code = _matcher.choice(
  "A",
  "AA",
  "AB",
  "AC",
  "AD",
  "AE",
  "B",
  "C",
  "D",
  "E",
  "F",
  "G",
  "H",
  "I",
  "J",
  "K",
  "L",
  "M",
  "N",
  "O",
  "S",
  "Z",
)

// --- Complex Object Types ---
#let tax-type = (
  rate: ratio-like,
  category: tax-code,
  label: text-like,
  grounds: _matcher.choice(none, text-like),
)

#let tax-like = _matcher.choice(ratio, tax-type)

#let unit-type = (
  code: str,
  symbol: _matcher.choice(str, none),
  name: str,
  description: _matcher.choice(str, none),
)

#let unit-like = _matcher.choice(str, unit-type)

#let modifier-type = (
  name: _matcher.choice(text-like),
  description: _matcher.choice(none, text-like),
  amount: _matcher.choice(ratio-like, decimal-like),
)
