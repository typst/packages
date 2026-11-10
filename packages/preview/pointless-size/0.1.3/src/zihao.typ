/// Terminology:
///
/// - points: 1pt, 2pt, …
/// - size number: 1, 2, "-0", …
/// - size half: 1, 2, 5.5, …
/// - size name: "初号", "一号", "小五", …

/// Map from size numbers to points.
#let size-number-to-pt = (
  (8, 5pt),
  (7, 5.5pt),
  (-6, 6.5pt),
  (6, 7.5pt),
  (-5, 9pt),
  (5, 10.5pt),
  (-4, 12pt),
  (4, 14pt),
  (-3, 15pt),
  (3, 16pt),
  (-2, 18pt),
  (2, 22pt),
  (-1, 24pt),
  (1, 26pt),
  ("-0", 36pt),
  (0, 42pt),
)

#let assert-type-number(size) = if size != "-0" {
  assert.eq(type(size), int, message: "expected an integer or \"-0\", found " + repr(size) + ".")
}
#let number-types = (int, float, decimal)
#let assert-type-half(size) = assert(
  number-types.contains(type(size)),
  message: "expected a number, found " + repr(size) + ".",
)


/// Convert a size number to its name.
///
/// Examples: 5 ⇒ "五号", -5 ⇒ "小五", "-0" ⇒ "小初".
///
/// - size(int | "-0"): size number
/// -> str
#let number-to-name(size) = {
  assert-type-number(size)

  if size == "-0" {
    "小初"
  } else if size == 0 {
    "初号"
  } else {
    numbering(
      if size > 0 { "一号" } else { "小一" },
      calc.abs(size),
    )
  }
}

/// Convert a size name to its number.
///
/// Examples: "五号" ⇒ 5, "五" ⇒ 5, "小五" ⇒ -5, "小初" ⇒ "-0".
///
/// Known limitation: numbers greater than 10 are not supported.
///
/// Returns none if failed.
///
/// - size (str): size name
/// -> int | "-0" | none
#let name-to-number(size) = {
  if type(size) != str { return none }

  size = size.trim("号", at: end)

  if size == "小初" { return "-0" }

  let pos = "初一二三四五六七八九十".clusters().position(c => c == size.trim("小", at: start))
  if pos == none { return none }

  if size.starts-with("小") { -pos } else { pos }
}


/// Normalize a size half.
///
/// Examples: 5 ⇒ 5, 5.0 ⇒ 5, 5.5 ⇒ 5.5, 5.49 ⇒ 5.5.
///
/// - raw (int | float | decimal):
/// -> int | float
#let normalize-half(raw) = {
  let n = calc.floor(raw)
  let r = raw - n

  // Because of truncation errors, `raw < n + 0.1` is not equivalent to `raw - n < 0.1`.
  // We could have used `decimal`, but `float` is easier for end authors to input, and `decimal(0.5)` gives a warning.
  if raw < n + 0.1 {
    n
  } else if raw <= n + 0.9 {
    n + 0.5
  } else {
    n + 1
  }
}

/// Convert a size number to half.
///
/// Examples: 5 ⇒ 5, -5 ⇒ 5.5.
///
/// - size(int | "-0"): size number
/// -> int | float
#let number-to-half(size) = {
  assert-type-number(size)

  if size == "-0" {
    0.5
  } else {
    normalize-half(if size >= 0 { size } else { 0.5 - size })
  }
}

/// Convert a size half to number.
///
/// Examples: 5 ⇒ 5, 5.5 ⇒ -5.
///
/// - size (str): size half
/// -> int | "-0"
#let half-to-number(size) = {
  assert-type-half(size)

  let x = normalize-half(size)
  if type(x) == int {
    x
  } else if x == 0.5 {
    "-0"
  } else {
    int(calc.round(0.5 - x))
  }
}


/// Convert a size to length.
///
/// = Arguments
///
/// == `size`
///
/// Any acceptable representation of a size.
///
/// Examples:
/// - 5, "五", "五号"
/// - 5.5, -5, "小五"
/// - 0.5, "-0", "小初"
///
/// == `overrides`
///
/// A list of overrides of size number definitions. Each item in the list is `(⟨size number⟩, ⟨length⟩)`.
///
/// Examples:
///
/// - `#let zh = zh.with(overrides: ((7, 5.25pt),))`
///
///   Change the `zh(7)`, `zh("七")`, etc. from `5.5pt` to `5.25pt`.
///
/// - `#let zh = zh.with(overrides: ((-7, 4.5pt),))`
///
///   Define `zh(-7)`, `zh("小七")`, etc. to be `4.5pt`. 小七 is rarely used and not included in the default definition.
///
/// -> length
#let zh(size, overrides: ()) = {
  let rules = (..overrides, ..size-number-to-pt)
  let rule = rules.find(((s, p)) => s == size)
  if rule != none {
    rule.at(1)
  } else {
    // Try parsing it as a size half or name
    let parsed = if number-types.contains(type(size)) {
      half-to-number(size)
    } else {
      name-to-number(size)
    }

    if parsed != none {
      zh(parsed, overrides: overrides)
    } else {
      panic(
        "expected a valid size (zìhào), found "
          + repr(size)
          + ". (All valid sizes: "
          + rules.map(r => repr(r.at(0))).join(", ")
          + ".)",
      )
    }
  }
}

/// A rule that sets text sizes.
///
/// ```example
/// #show: zihao(5)
/// ```
///
/// -> content => content
#let zihao(size, overrides: ()) = {
  body => {
    set text(size: zh(size, overrides: overrides))
    body
  }
}
