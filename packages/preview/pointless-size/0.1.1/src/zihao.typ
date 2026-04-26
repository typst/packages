/// Terminology:
///
/// - points: 1pt, 2pt, …
/// - size number: 1, 2, "-0", …
/// - size name: "初号", "一号", "小五", …

/// Map from size numbers to points.
#let size_number_to_pt = (
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


/// Convert a size number to its name.
///
/// Examples: 5 ⇒ "五号", -5 ⇒ "小五", "-0" ⇒ "小初".
///
/// - size(int | "-0"): size number
/// -> str
#let number_to_name(size) = {
  if size == "-0" {
    "小初"
  } else {
    assert.eq(type(size), int, message: "expected an integer or \"-0\", found " + repr(size) + ".")

    if size == 0 {
      "初号"
    } else {
      numbering(
        if size > 0 { "一号" } else { "小一" },
        calc.abs(size),
      )
    }
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
/// - size (str): size name.
/// -> int | "-0" | none
#let name_to_number(size) = {
  if type(size) != str { return none }

  size = size.trim("号", at: end)

  if size == "小初" { return "-0" }

  let pos = "初一二三四五六七八九十".clusters().position(c => c == size.trim("小", at: start))
  if pos == none { return none }

  if size.starts-with("小") { -pos } else { pos }
}


/// Convert a size to length.
///
/// Example inputs:
/// - 5, "五", "五号"
/// - -5, "小五"
/// - "-0", "小初"
///
/// -> length
#let zh(size, overrides: ()) = {
  let rules = (..overrides, ..size_number_to_pt)
  let rule = rules.find(((s, p)) => s == size)
  if rule != none {
    rule.at(1)
  } else {
    // Try parsing it as a name
    let parsed = name_to_number(size)
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
