#import "../loom-wrapper.typ": loom
#import loom.matcher as _matcher
#import "display-matcher.typ"

/// Stops the compilation unless `value` matches one of `types` (loom
/// matchers). Every component checks its arguments with it, so the message
/// is only built when the check fails: rendering the pattern and the value
/// costs more than the check itself.
#let require(value, value-name, ..types) = {
  // Most values are of one of the types or one of the literals (e.g.
  // `none`), which a comparison tells without the matcher. (A dictionary
  // may be a pattern, which only the matcher reads.)
  let options = types.pos()
  let kind = type(value)
  if kind in options or kind != dictionary and value in options { return }
  let pattern = _matcher.choice(..types)
  if not _matcher.match(value, pattern) {
    assert(
      false,
      message: "variable `"
        + value-name
        + "`("
        + repr(value)
        + ") must be of "
        + display-matcher.display(pattern),
    )
  }
}

/// Stops the compilation if `value` is a date without a day: a `datetime` of
/// a time only (e.g. `datetime(hour: 9, minute: 0, second: 0)`), alone or in
/// a period `(start, end)`. Such a date can be neither printed as a date nor
/// written into the e-invoice. Any other value passes; `require` checks the
/// type.
#let require-day(value, value-name) = {
  let dates = if type(value) == datetime { (value,) } else if (
    type(value) == array
  ) { value } else { () }
  for date in dates {
    if type(date) == datetime and date.day() == none {
      panic(
        "`"
          + value-name
          + "` is a time without a day: "
          + repr(date)
          + ". Give a date, e.g. `datetime(year: 2026, month: 9, day: 1)`.",
      )
    }
  }
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

#let modifier-type-with-label = (
  name: _matcher.choice(text-like),
  label: _matcher.choice(none, auto, text-like),
  description: _matcher.choice(none, text-like),
  amount: _matcher.choice(ratio-like, decimal-like),
)

#let modifier-like = _matcher.choice(modifier-type, modifier-type-with-label)

#let prepayment-type = (
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

// A function or dictionary of the `country` module, or an ISO 3166-1 alpha-2
// code (e.g. "FR").
#let country-like = _matcher.choice(
  none,
  auto,
  function,
  dictionary,
  str,
  content,
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

