#import "generated/grades.typ": grades-table

/// Lowercase scale IDs with case-insensitive input. Unknown IDs yield
/// `none`; there is no fallback scale (a wrong system must never
/// silently convert).
#let lookup-entry(sys) = {
  let lowered = lower(sys)
  if lowered in grades-table.scales {
    (id: lowered, entry: grades-table.scales.at(lowered))
  } else {
    none
  }
}

/// Quantize a grade to integer thousandths (half away from zero), so the
/// division and truncation below run on integers and binary-float drift
/// can never flip a truncation boundary (see `tables/README.md`).
/// `calc.round` is a single correctly-rounded half-away operation (NOT
/// `floor(x + 0.5)`, whose `+ 0.5` itself rounds past 2**52 and flips
/// the boundary, e.g. `-7839950073357.209`); it returns a float, so the
/// exactly-integral result is converted to int for `quo`/`rem` below.
#let thousandths(value) = {
  let magnitude = int(calc.round(calc.abs(value) * 1000))
  if value < 0 { -magnitude } else { magnitude }
}

/// Raw modified Bavarian formula, foreign → German, truncated to
/// 1 decimal. `none` for degenerate scales, out-of-range grades, and
/// non-numeric input.
#let bavarian-to-de(nmax, nmin, value) = {
  if type(nmax) not in (int, float) or type(nmin) not in (int, float) or type(value) not in (int, float) {
    none
  } else if nmax == nmin {
    none
  } else if value < calc.min(nmax, nmin) or value > calc.max(nmax, nmin) {
    none
  } else {
    let nmax-t = thousandths(nmax)
    let denominator = nmax-t - thousandths(nmin)
    if denominator == 0 {
      none
    } else {
      // x = (den + 3*(Nmax-Nd)) / den; numerator and denominator share
      // their sign, so the quotient is positive and integer division
      // truncates it to tenths.
      let numerator = denominator + 3 * (nmax-t - thousandths(value))
      calc.quo(10 * numerator, denominator) / 10.0
    }
  }
}

/// Raw inverse Bavarian formula, German → foreign, truncated to
/// 2 decimals. `none` for degenerate scales, German grades outside
/// `[1.0, 4.0]`, and non-numeric input.
#let bavarian-from-de(nmax, nmin, x) = {
  if type(nmax) not in (int, float) or type(nmin) not in (int, float) or type(x) not in (int, float) {
    none
  } else if nmax == nmin {
    none
  } else if x < 1 or x > 4 {
    none
  } else {
    let nmax-t = thousandths(nmax)
    let delta = nmax-t - thousandths(nmin)
    if delta == 0 {
      none
    } else {
      // Nd = (Nmax*3000 - (x-1000)*delta) / 3_000_000, truncated to
      // hundredths. Valid inputs keep the numerator positive.
      let numerator = nmax-t * 3000 - (thousandths(x) - 1000) * delta
      calc.quo(numerator, 30000) / 100.0
    }
  }
}

#let in-full-range(entry, value) = {
  value >= calc.min(entry.best, entry.worst) and value <= calc.max(entry.best, entry.worst)
}

/// Grading scale for a (case-insensitive) ID, or `none` when unknown.
#let scale(sys) = {
  let found = lookup-entry(sys)
  if found == none {
    none
  } else {
    (id: found.id, best: found.entry.best, worst: found.entry.worst, pass: found.entry.pass, step: found.entry.step, higher_is_better: found.entry.higher_is_better)
  }
}

/// Lowercase scale IDs with a table entry, sorted.
#let available-scales() = grades-table.scales.keys().sorted()

/// Whether a scale ID is supported (present in the supported set).
#let is-supported(sys) = lower(sys) in grades-table.supported

/// Whether a grade passes in its system. `none` for unknown systems,
/// non-numeric values, and grades outside the full `[worst .. best]`
/// interval; existing but failing grades yield `false`.
#let is-pass(sys, value) = {
  let found = lookup-entry(sys)
  if found == none {
    none
  } else if type(value) not in (int, float) or not in-full-range(found.entry, value) {
    none
  } else if found.entry.higher_is_better {
    value >= found.entry.pass
  } else {
    value <= found.entry.pass
  }
}

/// Convert a passing foreign grade to the German scale with the modified
/// Bavarian formula (truncated to 1 decimal).
#let to-de(sys, value) = {
  let found = lookup-entry(sys)
  if found == none {
    none
  } else {
    bavarian-to-de(found.entry.best, found.entry.pass, value)
  }
}

/// Convert a German grade in `[1.0, 4.0]` to a foreign scale with the
/// inverse Bavarian formula (truncated to 2 decimals).
#let from-de(sys, x-de) = {
  let found = lookup-entry(sys)
  if found == none {
    none
  } else {
    bavarian-from-de(found.entry.best, found.entry.pass, x-de)
  }
}

/// Convert a grade from one system to another by pivoting through the
/// German scale. This is a documented approximation: the intermediate
/// 1-decimal truncation loses information, so same-system conversion is
/// not the identity.
#let convert(source, target, value) = {
  let x-de = to-de(source, value)
  if x-de == none {
    none
  } else {
    from-de(target, x-de)
  }
}

/// ASCII whitespace per Rust `char::is_ascii_whitespace`
/// (U+0009–U+000D, U+0020): `str.trim()` would also strip Unicode
/// whitespace, so trimming is done explicitly.
#let ascii-ws = (" ", "\t", "\n", "\r", "\u{000B}", "\u{000C}")

#let trim-ascii(text) = {
  let s = text
  let changed = true
  while changed {
    changed = false
    for w in ascii-ws {
      if s.starts-with(w) {
        s = s.slice(w.len())
        changed = true
      }
      if s.ends-with(w) and s.len() > 0 {
        s = s.slice(0, s.len() - w.len())
        changed = true
      }
    }
  }
  s
}

#let ascii-digits = ("0", "1", "2", "3", "4", "5", "6", "7", "8", "9")

/// Parse a grade numeral: ASCII-trimmed digits with a single dot OR comma
/// decimal separator, so `"6,0"` and `"6.0"` both yield `6.0`. Strict:
/// rejects empty input, multiple or mixed separators, inner whitespace,
/// trailing text and non-finite results. Scale-free (no range check).
#let parse-grade(text) = {
  if type(text) != str {
    none
  } else {
    let s = trim-ascii(text)
    let negative = false
    if s.starts-with("-") {
      negative = true
      s = s.slice(1)
    } else if s.starts-with("+") {
      s = s.slice(1)
    }
    if s.len() == 0 {
      none
    } else {
      let dots = 0
      let commas = 0
      let ok = true
      for c in s.codepoints() {
        if c == "." {
          dots += 1
        } else if c == "," {
          commas += 1
        } else if c not in ascii-digits {
          ok = false
          break
        }
      }
      if not ok or dots + commas > 1 {
        none
      } else {
        let canonical = s.replace(",", ".")
        if canonical == "." {
          none
        } else {
          // `float()` needs digits around the dot; values are
          // digits-and-one-dot only here, so this only pads `"5."`/`.5"`.
          let norm = canonical
          if norm.starts-with(".") {
            norm = "0" + norm
          }
          if norm.ends-with(".") {
            norm = norm + "0"
          }
          let value = float(norm)
          if value == calc.inf or value == -calc.inf {
            none
          } else if negative {
            -value
          } else {
            value
          }
        }
      }
    }
  }
}

/// Render a grade with an explicit decimal count, ALWAYS with a dot
/// decimal separator regardless of locale (`"6.0"`, never `"6,0"`).
/// Integer-exact like the formula paths: the value is quantized to
/// thousandths (half away from zero), then the requested places round
/// half away from zero on integers (`calc.quo`/`calc.rem` only, never
/// float division on the value itself). `decimals` must be `0..=3`.
/// Returns `none` for non-numeric values, out-of-range precision, and
/// magnitudes `>= 1e15`. A negative-zero quantization (e.g. `-0.0004`)
/// renders WITHOUT a minus sign, mirroring the Rust reference.
#let format-grade(value, decimals) = {
  if type(value) not in (int, float) or type(decimals) != int {
    none
  } else if decimals < 0 or decimals > 3 {
    none
  } else if value != value or calc.abs(value) >= 1e15 {
    // `value != value` is only true for NaN (`float("nan")` can produce
    // one; comparisons against it are always false, so it needs its own
    // test to mirror Rust's `is_finite` rejection).
    none
  } else {
    let quant = thousandths(value)
    let negative = quant < 0
    let magnitude = calc.abs(quant)
    let scale = 1
    let i = 0
    while i < 3 - decimals {
      scale *= 10
      i += 1
    }
    let base = calc.quo(magnitude, scale)
    let rest = calc.rem(magnitude, scale)
    let rounded = if rest * 2 >= scale { base + 1 } else { base }
    let rendered = if decimals == 0 {
      str(rounded)
    } else {
      let factor = 1
      let j = 0
      while j < decimals {
        factor *= 10
        j += 1
      }
      let frac = str(calc.rem(rounded, factor))
      while frac.len() < decimals {
        frac = "0" + frac
      }
      str(calc.quo(rounded, factor)) + "." + frac
    }
    if negative {
      "-" + rendered
    } else {
      rendered
    }
  }
}
