///! Scientific notation.
///!
///! The exponent is counted off the digits and the mantissa is cut from them,
///! rather than either being computed by arithmetic. That keeps every digit the
///! value had, and it works on magnitudes `decimal` cannot hold, which is
///! precisely what this notation exists for: Typst writes even 1.5e40 out in
///! full, so the digits are always there to read.

#import "../utils/errors.typ": fail, fail-enum
#import "number.typ": convention, format-family, format-value, resolve-decimals, unbounded

// A decimal holds 28 to 29 significant digits, and a mantissa needs far fewer,
// so the digit run is cut to what can be constructed.
#let _LIMIT = 28

// The magnitude as Typst writes it, with no sign and no exponent, or `none` for
// anything that is not a finite number.
#let _digits(value) = {
  let kind = type(value)
  // `str(decimal)` writes U+2212 rather than a hyphen, so the sign is dropped by
  // taking the magnitude rather than by slicing the string.
  if kind in (int, decimal) { return str(calc.abs(value)) }
  if kind == float {
    // NaN is the only value that differs from itself.
    if value != value { return none }
    if value == float.inf or value == -float.inf { return none }
    return str(calc.abs(value))
  }
  if kind == str {
    if value.match(regex("^[+-]?\d+(\.\d+)?$")) == none { return none }
    return value.trim("-", at: start).trim("+", at: start)
  }
  none
}

#let _negative(value) = {
  let kind = type(value)
  if kind in (int, float, decimal) { return value < 0 }
  if kind == str { return value.starts-with("-") }
  false
}

// The power of ten a value sits on, and its digits with the point moved to sit
// after the first of them.
#let _split(text) = {
  let parts = text.split(".")
  let integer = parts.first()
  let fraction = if parts.len() > 1 { parts.at(1) } else { "" }
  let significant = (integer + fraction).trim("0", at: start)

  // Zero sits on no power of ten in particular, and 0 × 10⁰ is how it is said.
  if significant == "" { return (exponent: 0, mantissa: "0") }

  // At or above one, the exponent counts the digits before the point; below it,
  // the zeros after the point that lead the first significant digit.
  let whole = integer.trim("0", at: start)
  let exponent = if whole != "" {
    whole.len() - 1
  } else {
    -(fraction.len() - fraction.trim("0", at: start).len()) - 1
  }

  let kept = significant.slice(0, calc.min(significant.len(), _LIMIT))
  (
    exponent: exponent,
    mantissa: kept.slice(0, 1) + if kept.len() > 1 { "." + kept.slice(1) } else { "" },
  )
}

#let _slots(value, options) = {
  let text = _digits(value)
  if text == none {
    let written = unbounded(value, options)
    if written != none { return written }
    fail(
      "format-scientific",
      "value is not a finite number",
      value: value,
      hint: "Only finite numbers are formatted here; use format() for anything else.",
    )
  }

  let (exponent, mantissa) = _split(text)
  let signed = decimal(if _negative(value) { "-" + mantissa } else { mantissa })

  // Rounding can carry into the next power: 9.99 at one decimal is 10.0, and
  // 10.0 × 10³ is not scientific notation. Formatting says whether it happened,
  // and shifting the mantissa once settles it.
  let slots = format-value(signed, options)
  if slots.integer.len() > 1 {
    slots = format-value(signed / decimal("10"), options)
    exponent += 1
  }

  slots.exponent = if options.notation == "e" {
    [e#exponent]
  } else {
    [#h(0.15em)#sym.times#h(0.15em)10#super[#exponent]]
  }
  slots
}

#let format-scientific(
  columns,
  rows: auto,
  // `auto` means two decimal places, as it does across the family.
  decimals: auto,
  exponent: "power",
  decimal-separator: auto,
  sign: false,
  // `auto` means the theme decides, through number-rounding.
  rounding: auto,
  negative-zero: false,
  infinity: none,
) = {
  if exponent not in ("power", "e") {
    fail-enum("format-scientific", "exponent", exponent, ("power", "e"))
  }
  let places = resolve-decimals("format-scientific", decimals, 2, minimum: 0)

  format-family(
    columns,
    rows: rows,
    scope: "format-scientific",
    conventions => value => _slots(value, (
      scope: "format-scientific",
      notation: exponent,
      prefix: none,
      suffix: none,
      infinity: infinity,
      decimals: places,
      significant: none,
      // A mantissa carries one digit before the point, so there is nothing to
      // group and no separator to choose.
      grouping: none,
      group-separator: "",
      decimal-separator: convention(decimal-separator, conventions.decimal),
      scale: 1,
      sign: sign,
      rounding: convention(rounding, conventions.rounding),
      negative-zero: negative-zero,
    )),
  )
}
