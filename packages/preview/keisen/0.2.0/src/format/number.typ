///! Number formatting over decimal arithmetic.
///!
///! Every scaling and rounding step happens in Typst's `decimal` type, which is
///! fixed-point with 28 to 29 significant digits, so 0.145 at two decimals is
///! not at the mercy of binary representation. Floats reach it through their
///! shortest round-trip string, since `decimal(3.14)` is documented as
///! imprecise and warns.

#import "../utils/errors.typ": check, fail, fail-enum, fail-type

// A decimal holds 28 to 29 significant digits and raises rather than saturating
// on overflow, so both ends of the range are checked before construction: too
// large to represent, and too small to represent without more fractional digits
// than it has. Typst has no try, so neither can be attempted and recovered.
#let _limit = 7.9e28

// The exact largest decimal, which the rounding below measures its shift
// against. `_limit` above is a conservative float bound that sits under it, and
// `_fits` closes the gap between the two by counting digits.
#let _decimal-max = decimal("79228162514264337593543950335")

#let _numeric = regex("^[+-]?\d+(\.\d+)?$")

// Digits a decimal literal would need, counting the fractional ones that a
// leading run of zeroes pushes beyond the scale.
#let _fits(text) = {
  let parts = text.trim("-", at: start).trim("+", at: start).split(".")
  let integer = parts.first().trim("0", at: start)
  let fraction = if parts.len() > 1 { parts.at(1) } else { "" }
  integer.len() + fraction.len() <= 28
}

#let to-decimal(value) = {
  let kind = type(value)
  if kind == decimal { return value }
  if kind == int { return decimal(value) }
  if kind == float {
    // NaN is the only value that differs from itself.
    if value != value { return none }
    if value == float.inf or value == -float.inf { return none }
    if calc.abs(value) >= _limit { return none }
    let text = str(value)
    // Exponent forms are the scientific formatter's business, not this one's.
    if "e" in text or "E" in text { return none }
    if not _fits(text) { return none }
    return decimal(text)
  }
  if kind == str {
    if value.match(_numeric) == none { return none }
    if not _fits(value) { return none }
    return decimal(value)
  }
  none
}

// Even without an int to divide: halving an even number lands on a whole one,
// and doubling it back returns what it started as.
#let _is-even(whole) = calc.round(whole / decimal(2), digits: 0) * decimal(2) == whole

// `value` rounded to a multiple of ten to the `places`, counted in units of it
// and signed like `value`. Zero places rounds to a whole number.
//
// Dividing by the scale would round whenever the quotient needs more than the
// 28 fractional digits a decimal holds, and a value just past a tie would then
// read as one. The whole count is read off the integer digits instead, and the
// remainder beside it is exact, since the count times the scale never exceeds
// the value. Nothing passes through an int, so the 64-bit range plays no part.
#let _round-count(value, places, mode) = {
  let scale = calc.pow(decimal(10), places)
  let magnitude = calc.abs(value)
  let integer = str(magnitude).split(".").first()
  let count = if integer.len() > places {
    decimal(integer.slice(0, integer.len() - places))
  } else {
    decimal(0)
  }
  let remainder = magnitude - count * scale
  let half = scale / decimal(2)
  let up = remainder > half or (remainder == half and (mode == "half-up" or not _is-even(count)))
  if up { count += decimal(1) }
  if value < decimal(0) { -count } else { count }
}

// `digits` may be negative, which rounds to tens, hundreds, and so on; that is
// how significant-digit formatting reaches the integer part.
//
// It must lie within -28 to 28, which is what a decimal holds as places: the
// scale below is ten to its magnitude, and a wider one raises before anything
// here can report it.
//
// A written count is bounded by `resolve-decimals`. A resolved place is bounded
// by the check in `_decimals-for-significant`, which reads the first of its two
// measurements; the second is what arrives here, and it cannot be wider, since
// rounding to the first place never pushes the place out. That is a proof rather
// than a check, and the bound is stated here rather than tested twice.
//
// A place above the point asks for a multiple of ten, and the one nearest a
// large value can be larger than the type holds. The answer is measured against
// the range before it is taken, in both modes: a decimal raises rather than
// saturating, and Typst has no try. The count of the scale is read from the
// digits rather than by dividing, so it is exact and the safe place to measure
// from.
#let round-decimal(value, digits, mode) = {
  if mode not in ("half-up", "half-even") {
    fail-enum("format-number", "rounding", mode, ("half-up", "half-even"))
  }

  let scale = calc.pow(decimal(10), calc.abs(digits))

  // `rounded` is the answer in units of the scale, so the answer itself is that
  // many times the scale and holds exactly while the count does.
  let _check-holds(rounded) = check(
    calc.abs(rounded) <= _decimal-max / scale,
    "format-number",
    // The count is written without its sign: str() spells a negative number
    // with a minus sign a reader cannot type, and a negative count is what
    // rounding to a place above the point is written as.
    "the answer " + str(calc.abs(digits)) + " places above the point is larger than a decimal holds",
    value: value,
    hint: "Round to a place nearer the point, or use format-scientific.",
  )

  if digits < 0 {
    let rounded = _round-count(value, -digits, mode)
    _check-holds(rounded)
    return rounded * scale
  }

  if mode == "half-up" { return calc.round(value, digits: digits) }

  // The shift is measured before it is taken: a decimal raises rather than
  // saturating, and Typst has no try, so an overflow cannot be caught after the
  // fact. The room falls as the place rises, and a value with none left has no
  // fractional digit at that place to sit a tie on, so plain rounding is exact
  // for it.
  if digits > 0 and calc.abs(value) > _decimal-max / scale {
    return calc.round(value, digits: digits)
  }

  _round-count(value * scale, 0, mode) / scale
}

// A size of `none` or anything below one means no grouping; a size of zero
// would otherwise never shorten the remainder and loop forever.
#let group-digits(digits, size, separator) = {
  if size == none or size < 1 or digits.len() <= size { return digits }
  let blocks = ()
  let rest = digits
  while rest.len() > size {
    blocks.push(rest.slice(rest.len() - size))
    rest = rest.slice(0, rest.len() - size)
  }
  blocks.push(rest)
  blocks.rev().join(separator)
}

// Decimal places that leave `count` significant digits in `number`.
#let _places-for-significant(number, count) = {
  let digits = str(calc.abs(number)).split(".")
  let integer = digits.first().trim("0", at: start)
  if integer != "" { return count - integer.len() }
  let fraction = if digits.len() > 1 { digits.at(1) } else { "" }
  // Zero has no significant digit to place, and the arithmetic below would read
  // its scale as leading zeros instead: `decimal("0.00")` writes two of them, so
  // a zero from a string counted four places where a zero from an integer
  // counted two. A decimal keeps the scale it was written with, and rounding
  // does not always keep it, so the scale must not reach the count at all.
  if fraction.trim("0") == "" { return count }
  let leading = fraction.len() - fraction.trim("0", at: start).len()
  leading + count
}

// The same, measured against the value that is printed rather than the value
// that arrived. Rounding carries into a new integer digit, and the place was
// read off the magnitude before it: 9.99 at two significant digits rounded to
// 10.0 and kept the place computed for a one-digit integer, printing three
// digits where two were asked for.
//
// One further measurement settles it. Rounding to the wider place shows the
// magnitude the number prints at, and rounding the original to the narrower
// place reaches the same magnitude, so a third pass reads what the second did.
//
// The place is checked before it is rounded to, since the rounding itself is
// what a place beyond the decimal's own would raise on.
#let _decimals-for-significant(number, count, mode, scope) = {
  let places = _places-for-significant(number, count)
  check(
    places <= 28,
    scope,
    "significant asks for more decimal places than a decimal holds",
    value: (significant: count, places: places),
    hint: "The zeros between the point and the first digit are places too; use format-scientific for a value this small.",
  )
  _places-for-significant(round-decimal(number, places, mode), count)
}

// An infinity written as whatever the caller said to write, or `none` when they
// said nothing. Alignment sees opaque content: an infinity has no digits to pad
// a column against.
#let unbounded(value, options) = {
  let written = options.at("infinity", default: none)
  if written == none or value not in (float.inf, -float.inf) { return none }
  if value == -float.inf { [#"\u{2212}"] + written } else { written }
}

#let format-value(value, options) = {
  // Every formatter in the family lands here, so the scope travels with the
  // options: a currency column that holds a word should say so as
  // format-currency rather than as something the caller never wrote.
  let scope = options.at("scope", default: "format-number")
  let number = to-decimal(value)
  if number == none {
    let written = unbounded(value, options)
    if written != none { return written }
    fail(
      scope,
      "value is not a finite number",
      value: value,
      hint: "Only finite numbers are formatted here; use format() for anything else.",
    )
  }

  if options.scale != 1 { number = number * decimal(str(options.scale)) }

  // A count inside its own range still resolves to a place outside one: ten
  // digits of 1e-20 are 29 places, and a decimal holds 28.
  let decimals = if options.at("significant", default: none) != none {
    _decimals-for-significant(number, options.significant, options.rounding, scope)
  } else {
    options.decimals
  }

  // Rounding -0.4 to zero drops the sign, so negativity is read from the value
  // that entered rounding rather than from the digits that came out.
  let negative = number < decimal(0)

  // `str(decimal)` writes U+2212 MINUS SIGN rather than an ASCII hyphen, so the
  // sign is removed by taking the magnitude instead of by slicing the string.
  let text = str(calc.abs(round-decimal(number, decimals, options.rounding)))

  // Negative rounding places round the integer part, so nothing is shown after
  // the separator and the padding below works on a non-negative count.
  let shown = calc.max(0, decimals)

  let parts = text.split(".")
  let integer = parts.first()
  let fraction = if parts.len() > 1 { parts.at(1) } else { "" }
  if fraction.len() > shown { fraction = fraction.slice(0, shown) }
  while fraction.len() < shown { fraction = fraction + "0" }

  // Significant-digit rounding zeroes trailing integer digits rather than
  // dropping them, which `str` already reflects.
  let zero = integer.trim("0") == "" and fraction.trim("0") == ""
  // U+2212 MINUS SIGN rather than a hyphen, as Typst itself writes a negative
  // number and as the exponent of `format-scientific` already reads.
  let sign = if negative and (not zero or options.negative-zero) {
    "\u{2212}"
  } else if options.sign and not negative and not zero {
    "+"
  } else {
    ""
  }

  (
    kind: "number",
    sign: sign,
    prefix: options.at("prefix", default: none),
    integer: group-digits(integer, options.grouping, options.group-separator),
    separator: if shown > 0 { options.decimal-separator } else { "" },
    fraction: fraction,
    exponent: options.at("exponent", default: none),
    suffix: options.at("suffix", default: none),
  )
}

// `columns` is a required positional argument throughout the format family:
// Typst positional parameters cannot carry defaults, so "every column" is
// written explicitly as `auto`.
#let format(columns, function, rows: auto, scope: "format") = (
  kind: "format",
  columns: columns,
  rows: rows,
  function: function,
  cell: false,
  // The name the caller wrote, so a directive naming a column the table does
  // not have reports under `format-date` rather than under `format`.
  scope: scope,
)

// What a directive was given, or what the theme says when it was given `auto`.
// Written out at eight sites across this file, `scientific.typ` and `bytes.typ`,
// which is enough of the same sentence to name once.
//
// The fallback is evaluated whether or not it is used, which costs nothing: a
// convention is a field of the dictionary `formatter-for` builds, and reading it
// neither fails nor computes anything.
#let convention(given, fallback) = if given == auto { fallback } else { given }

// A directive whose separators or rounding may be `auto`, meaning the theme
// decides.
//
// The theme is not resolved until render time, so such a directive carries how
// to build its formatter rather than the formatter itself: `build` takes the
// theme's number conventions and returns the `value => slots` closure. This is
// the same shape a nanoplot uses to reach the column it is drawn against.
//
// `function` is none deliberately. Every path that formats a cell resolves the
// directive through `formatter-for` in src/format/apply.typ, and one that
// forgot would rather fail than quietly pick a separator nobody asked for.
#let format-family(columns, build, rows: auto, scope: "format-number") = (
  kind: "format",
  columns: columns,
  rows: rows,
  function: none,
  family: build,
  cell: false,
  scope: scope,
)

// The one formatter that reads the row rather than the value, for a cell whose
// content depends on its neighbours. The row it receives is the input row, so
// hidden columns and the reserved `_index` key are both reachable.
//
// `columns-combine` covers the common case of building one cell from named
// neighbours, and reads better where it fits; this is the general form.
//
// A summary row is an aggregate of a column and has no row behind it, so a cell
// formatter covers no column: see `covering` in src/render/layout.typ.
#let format-cell(columns, function, rows: auto) = (
  kind: "format",
  columns: columns,
  rows: rows,
  function: function,
  cell: true,
  scope: "format-cell",
)

// A decimal count reaches arithmetic that pads or rounds whatever it is given,
// so it is held to being a count before it gets there. Every formatter in the
// family takes one, including the two that take no `significant`.
//
// `minimum` is -28 where a negative count means rounding to a place above the
// point, which format-number offers, and 0 where it means rounding the mantissa
// or the byte count away, which means nothing.
//
// The count a formatter formats with: its own `fallback` where the caller left
// `auto`, and the caller's count once it is held to being a count.
#let resolve-decimals(scope, decimals, fallback, minimum: -28) = {
  if decimals == auto { return fallback }
  if type(decimals) != int {
    fail-type(scope, "decimals", decimals, "an integer or auto")
  }
  // A decimal holds 28 places, so a larger count pads zeros the value never
  // had, and a smaller negative one rounds past every digit it has.
  check(
    decimals >= minimum and decimals <= 28,
    scope,
    // Written out rather than built from `minimum`: `str` spells a negative
    // number with U+2212, which is not what the source says.
    if minimum < 0 { "decimals must be between -28 and 28" } else { "decimals must be between 0 and 28" },
    value: decimals,
    hint: "A decimal holds 28 places; a count outside them writes digits the value does not carry.",
  )
  decimals
}

// Both counts reach that same arithmetic, and a caller who wrote both has
// written two answers to one question. The resolved count is returned, so a
// caller of this checks and resolves in one call.
#let _exclusive(scope, decimals, significant) = {
  if significant != none and type(significant) != int {
    fail-type(scope, "significant", significant, "an integer or none")
  }
  // Zero significant digits leave none of the value: 1234.5 at a count of zero
  // rounds to the ten thousands and prints 0. The upper end is the decimal's
  // own, since the count resolves to a place that same decimal has to hold.
  check(
    significant == none or (significant >= 1 and significant <= 28),
    scope,
    "significant must be between 1 and 28",
    value: significant,
    hint: "A decimal holds 28 digits; a count outside them writes digits the value does not carry.",
  )
  check(
    decimals == auto or significant == none,
    scope,
    "decimals and significant are mutually exclusive",
    value: (decimals: decimals, significant: significant),
    hint: "Write one of the two: decimals fixes the decimal places, significant derives them from the value.",
  )
  // Resolved last, so a caller who wrote both is told that before being told
  // anything about the range of either.
  resolve-decimals(scope, decimals, 2)
}

// The count a formatter in the family forwards. Its own default answers `auto`,
// and only when the caller asked for no significant digits: `auto` has to
// travel on, or the pair arrives at `_exclusive` as two answers to one question
// and is refused.
//
// `options` is the forwarding sink, since `significant` is a key such a
// formatter passes on rather than one it declares.
#let forward-decimals(decimals, options, fallback) = {
  if decimals != auto { return decimals }
  if options.named().at("significant", default: none) != none { return auto }
  fallback
}

#let format-number(
  columns,
  rows: auto,
  // `auto` here is the formatter's own count, two decimal places, and not the
  // theme's: there is no `number-decimals` option. It is a sentinel rather than
  // a 2 because a default cannot be told from a value the caller wrote, and
  // `decimals` and `significant` together are refused.
  decimals: auto,
  significant: none,
  grouping: 3,
  // `auto` means the theme decides, through number-group-separator and
  // number-decimal-separator, so a convention is set once for the table.
  group-separator: auto,
  decimal-separator: auto,
  scale: 1,
  sign: false,
  // `auto` means the theme decides, through number-rounding.
  rounding: auto,
  negative-zero: false,
  prefix: none,
  suffix: none,
  exponent: none,
  infinity: none,
  // Named by whichever formatter in the family called, so a failure reports the
  // function the caller actually wrote.
  scope: "format-number",
) = {
  let places = _exclusive(scope, decimals, significant)

  format-family(
    columns,
    conventions => value => format-value(
      value,
      (
        scope: scope,
        prefix: prefix,
        suffix: suffix,
        exponent: exponent,
        infinity: infinity,
        decimals: places,
        significant: significant,
        grouping: grouping,
        group-separator: convention(group-separator, conventions.group),
        decimal-separator: convention(decimal-separator, conventions.decimal),
        scale: scale,
        sign: sign,
        rounding: convention(rounding, conventions.rounding),
        negative-zero: negative-zero,
      ),
    ),
    rows: rows,
    scope: scope,
  )
}

// Forwarded options come after `decimals`, and a later named argument wins, so
// a decimal count is refused rather than quietly turning integers into
// fractions.
//
// A key that asks for nothing is not a refusal: `auto` and `none` are how the
// rest of the family says "no opinion", so a wrapper forwarding a fixed set of
// keys works here as it does everywhere else.
#let format-integer(columns, rows: auto, ..options) = {
  let named = options.named()
  check(
    named.at("decimals", default: auto) == auto and named.at("significant", default: none) == none,
    "format-integer",
    "decimals and significant do not apply to integers",
    hint: "Use format-number when a fractional part is wanted.",
  )
  // Forwarded options come after `decimals: 0`, and a later named argument wins,
  // so a key that asked for nothing is dropped rather than passed on: `auto`
  // reaching format-number would resolve to its own two places.
  let forwarded = (:)
  for (key, value) in named {
    if key not in ("decimals", "significant") { forwarded.insert(key, value) }
  }
  format-number(columns, rows: rows, decimals: 0, scope: "format-integer", ..forwarded)
}
