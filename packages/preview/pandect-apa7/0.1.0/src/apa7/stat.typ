/// Statistics Reporting module for APA 7th Edition.
///
/// Implements APA 7 statistical formatting rules (Sections 6.40-6.44):
/// - Italicization of statistical symbols (M, SD, t, F, r, d, z, p).
/// - No leading zero for numbers that cannot exceed 1 (p, r, eta^2): e.g. .018, -.42.
/// - Mandatory leading zero for statistics that can exceed 1: e.g. 0.45, 2.45.
/// - Consecutive degree of freedom in parentheses without space: t(48), F(2, 45).
/// - Exact p-values to 2 or 3 decimals, or "p < .001" when under .001.
/// - Accessible math tagging (PDF/UA-1) for Greek statistical symbols (chi^2, eta_p^2).

/// Formats a numeric value with specified decimal places and APA leading zero rules.
#let format-num(num, decimals: 2, leading-zero: true) = {
  if type(num) == str or type(num) == content {
    return str(num)
  }
  let is-neg = num < 0
  let abs-num = calc.abs(num)
  let rounded = calc.round(abs-num, digits: decimals)
  let s = str(rounded)

  // Ensure trailing zeroes (e.g. 2.4 -> 2.40)
  if "." in s {
    let parts = s.split(".")
    let dec = parts.at(1)
    while dec.len() < decimals {
      dec += "0"
    }
    s = parts.at(0) + "." + dec
  } else if decimals > 0 {
    s += "."
    let i = 0
    while i < decimals {
      s += "0"
      i += 1
    }
  }

  // APA 7 Section 6.36: Do not use leading zero if value cannot exceed 1
  if not leading-zero and s.starts-with("0.") {
    s = s.slice(1)
  }

  if is-neg {
    "-" + s
  } else {
    s
  }
}

/// Formats a p-value according to APA 7:
/// - If p < .001, formats as "p < .001"
/// - Otherwise formats to 2 or 3 decimals without leading zero: "p = .018"
#let format-p(p) = {
  if type(p) == str or type(p) == content {
    let s = str(p)
    if s.starts-with("<") or s.starts-with(">") or s.starts-with("=") {
      [_p_ #s]
    } else {
      [_p_ = #s]
    }
  } else if p < 0.001 {
    [_p_ < .001]
  } else {
    let s = format-num(p, decimals: 3, leading-zero: false)
    [_p_ = #s]
  }
}

/// Formats an independent or paired-samples t-test.
///
/// Example: `apa-t(48, 2.45, p: 0.018, d: 0.71)` -> `_t_(48) = 2.45, _p_ = .018, _d_ = 0.71`
#let apa-t(df, val, p: none, d: none) = {
  let parts = ()
  parts.push([_t_(#str(df)) = #format-num(val, decimals: 2)])
  if p != none {
    parts.push(format-p(p))
  }
  if d != none {
    parts.push([_d_ = #format-num(d, decimals: 2, leading-zero: true)])
  }
  parts.join(", ")
}

/// Formats an ANOVA F-test.
///
/// Example: `apa-f(2, 45, 4.23, p: 0.020, eta2: 0.16)` -> `_F_(2, 45) = 4.23, _p_ = .020, η² = .16`
#let apa-f(df1, df2, val, p: none, eta2: none) = {
  let parts = ()
  parts.push([_F_(#str(df1), #str(df2)) = #format-num(val, decimals: 2)])
  if p != none {
    parts.push(format-p(p))
  }
  if eta2 != none {
    let eta-sym = math.equation(alt: "partial eta squared", $eta_p^2$)
    parts.push([#eta-sym = #format-num(eta2, decimals: 2, leading-zero: false)])
  }
  parts.join(", ")
}

/// Formats a Pearson or Spearman correlation coefficient.
///
/// Example: `apa-r(0.42, p: 0.003, df: 98)` -> `_r_(98) = .42, _p_ = .003`
#let apa-r(val, p: none, df: none) = {
  let parts = ()
  let df-str = if df != none { [(#str(df))] } else { [] }
  parts.push([_r_#df-str = #format-num(val, decimals: 2, leading-zero: false)])
  if p != none {
    parts.push(format-p(p))
  }
  parts.join(", ")
}

/// Formats a Chi-Square test of independence or goodness-of-fit.
///
/// Example: `apa-chi2(2, 8.42, p: 0.015, n: 100)` -> `χ²(2, N = 100) = 8.42, _p_ = .015`
#let apa-chi2(df, val, p: none, n: none) = {
  let parts = ()
  let chi2-sym = math.equation(alt: "chi squared", $chi^2$)
  let n-str = if n != none { [, _N_ = #str(n)] } else { [] }
  parts.push([#chi2-sym (#str(df)#n-str) = #format-num(val, decimals: 2)])
  if p != none {
    parts.push(format-p(p))
  }
  parts.join(", ")
}

/// Formats a standardized normal z-test.
///
/// Example: `apa-z(2.15, p: 0.032)` -> `_z_ = 2.15, _p_ = .032`
#let apa-z(val, p: none) = {
  let parts = ()
  parts.push([_z_ = #format-num(val, decimals: 2)])
  if p != none {
    parts.push(format-p(p))
  }
  parts.join(", ")
}

/// Formats descriptive statistics (Mean, Standard Deviation, Sample Size).
///
/// Example: `apa-mean(24.5, sd: 3.2, n: 100)` -> `_M_ = 24.50, _SD_ = 3.20, _N_ = 100`
#let apa-mean(m, sd: none, n: none) = {
  let parts = ()
  parts.push([_M_ = #format-num(m, decimals: 2)])
  if sd != none {
    parts.push([_SD_ = #format-num(sd, decimals: 2)])
  }
  if n != none {
    parts.push([_N_ = #str(n)])
  }
  parts.join(", ")
}

/// Formats a Confidence Interval in APA style.
///
/// Example: `apa-ci(1.20, 3.45)` -> `95% CI [1.20, 3.45]`
#let apa-ci(lower, upper, level: 95) = {
  [#str(level)% CI [#format-num(lower, decimals: 2), #format-num(upper, decimals: 2)]]
}

/// Unified dispatcher helper for statistical reporting.
///
/// Examples:
/// - `apa-stat(t: 2.45, df: 48, p: .018, d: .71)`
/// - `apa-stat(f: 4.23, df1: 2, df2: 45, p: .020, eta2: .16)`
/// - `apa-stat(r: .42, p: .003, df: 98)`
/// - `apa-stat(m: 24.5, sd: 3.2)`
#let apa-stat(
  t: none,
  f: none,
  r: none,
  chi2: none,
  z: none,
  m: none,
  df: none,
  df1: none,
  df2: none,
  p: none,
  d: none,
  eta2: none,
  sd: none,
  n: none,
  ci: none,
) = {
  if t != none and df != none {
    apa-t(df, t, p: p, d: d)
  } else if f != none {
    let d1 = if df1 != none { df1 } else if type(df) == array { df.at(0) } else { 1 }
    let d2 = if df2 != none { df2 } else if type(df) == array { df.at(1) } else { 1 }
    apa-f(d1, d2, f, p: p, eta2: eta2)
  } else if r != none {
    apa-r(r, p: p, df: df)
  } else if chi2 != none and df != none {
    apa-chi2(df, chi2, p: p, n: n)
  } else if z != none {
    apa-z(z, p: p)
  } else if m != none {
    apa-mean(m, sd: sd, n: n)
  } else if ci != none and type(ci) == array {
    apa-ci(ci.at(0), ci.at(1))
  } else {
    none
  }
}
