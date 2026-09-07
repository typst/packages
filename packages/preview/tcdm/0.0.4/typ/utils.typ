/// A simplified version of `best_of.utils.simplify_number`.
/// - num (int):
/// -> str
#let simplify-number(num) = {
  let magnitude = 0
  while calc.abs(num) >= 1000 {
    magnitude += 1
    num /= 1000.0
  }

  str(num).replace(regex("(\d+)\.(\d+)$"), m => {
    let (int-digits, frac-digits) = m.captures
    int-digits
    let frac-len = 3 - int-digits.len()
    if frac-len > 0 {
      "."
      (frac-digits + "00").slice(0, frac-len)
    }
  })
  ("", "K", "M", "B", "T").at(magnitude)
}
#{
  assert.eq(simplify-number(1), "1")
  assert.eq(simplify-number(19), "19")
  assert.eq(simplify-number(193), "193")
  assert.eq(simplify-number(-193), "−193")
  assert.eq(simplify-number(10.0), "10")
  assert.eq(simplify-number(1016), "1.01K")
  assert.eq(simplify-number(2100), "2.10K")
  assert.eq(simplify-number(2005), "2.00K")
  assert.eq(simplify-number(3382), "3.38K")
  assert.eq(simplify-number(26366), "26.3K")
  assert.eq(simplify-number(158342011), "158M")
}

/// Parse a string as datetime.
/// https://github.com/typst/typst/issues/4107
#let parse-datetime(s) = {
  // We have to discard the milliseconds, or it will become `$__toml_private_datetime`.
  let t = toml(bytes("date = " + s.replace(regex("\.\d+$"), "")))
  t.date
}

/// Equivalent to `best_of.utils.diff_month`.
///
/// Returns (a - b) / month, with an error up to two months.
///
/// - a (datetime):
/// - b (datetime):
/// -> int
#let diff-month(a, b) = {
  return (a.year() - b.year()) * 12 + a.month() - b.month()
}
