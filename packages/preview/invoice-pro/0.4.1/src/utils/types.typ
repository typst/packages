#import "../loom-wrapper.typ": loom
#import loom.matcher as _matcher
#import "display-matcher.typ"

#let require(value, value-name, ..types) = {
  import loom.matcher: *

  let pattern = choice(..types)
  let pattern-str = display-matcher.display(pattern)

  let message = (
    "variable `"
      + value-name
      + "`("
      + repr(value)
      + ") must be of "
      + pattern-str
  )

  assert(
    match(value, pattern),
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

// Dictionary form for ZUGFeRD-compliant unit specification.
// `display` is rendered on the PDF; `code` is the UN/CEFACT Rec. 20 code embedded in the XML.
#let unit-input-type = (
  display: text-like,
  code: str,
)

#let modifier-type = (
  name: _matcher.choice(text-like),
  description: _matcher.choice(none, text-like),
  amount: _matcher.choice(ratio-like, decimal-like),
)

// --- Polymorphic & Address Fields Matchers ---
#let polymorphic-text = _matcher.choice(
  none,
  str,
  content,
  _matcher.many(_matcher.choice(str, content)),
)

#let city-type = (
  name: _matcher.choice(none, str, content),
  post-code: _matcher.choice(none, str, content),
  state: _matcher.choice(none, str, content),
  display: _matcher.choice(none, str, content),
  inline-display: _matcher.choice(none, str, content),
)

#let city-like = _matcher.choice(
  none,
  str,
  content,
  city-type,
)

#let country-like = _matcher.choice(
  none,
  auto,
  function,
  dictionary,
)

#let party-type = (
  name: polymorphic-text,
  address: polymorphic-text,
  city: city-like,
  country: country-like,
  tax-nr: _matcher.choice(none, str, content),
  vat-id: _matcher.choice(none, str, content),
  extra: _matcher.choice(none, array, dictionary),
)

