// Compare two floats
#let _compare(a, b, eps: 1e-6) = {
  return calc.abs(a - b) <= eps
}

// Pre-computed table of fractions
#let _common-denoms = range(2, 11 + 1).map(d => {
  (d, range(1, d).map(n => n/d))
})

#let _find-fraction(v, denom: auto, eps: 1e-6) = {
  let i = calc.floor(v)
  let f = v - i
  if _compare(f, 0, eps: eps) {
    return $#v$
  }

  let denom = if denom != auto {
    for n in range(1, denom) {
      if _compare(f, n/denom, eps: eps) {
        denom
      }
    }
  } else {
    (() => {
      for ((denom, tab)) in _common-denoms {
        for vv in tab {
          if _compare(f, vv, eps: eps) {
            return denom
          }
        }
      }
    })()
  }

  if denom != none {
    return if v < 0 { $-$ } else {} + $#calc.round(calc.abs(v) * denom)/#denom$
  }
}

/// Fraction tick formatter
///
/// ```cexample
/// plot.plot(size: (5,1),
///           x-format: plot.formats.fraction,
///           x-tick-step: 1/5,
///           y-tick-step: none, {
///   plot.add(calc.sin, domain: (-1, 1))
/// })
/// ```
///
/// - value (number): Value to format
/// - denom (auto, int): Denominator for result fractions. If set to `auto`,
///   a hardcoded fraction table is used for finding fractions with a
///   denominator <= 11.
/// - eps (number): Epsilon used for comparison
/// -> Content if a matching fraction could be found or none
#let fraction(value, denom: auto, eps: 1e-6) = {
  return _find-fraction(value, denom: denom, eps: eps)
}

/// Multiple of tick formatter
///
/// ```cexample
/// plot.plot(size: (5,1),
///           x-format: plot.formats.multiple-of,
///           x-tick-step: calc.pi/4,
///           y-tick-step: none, {
///   plot.add(calc.sin, domain: (-calc.pi, 1.5 * calc.pi))
/// })
/// ```
///
/// - value (number): Value to format
/// - factor (number): Factor value is expected to be a multiple of.
/// - symbol (content): Suffix symbol. For `value` = 0, the symbol is not
///   appended.
/// - fraction (none, true, int): If not none, try finding matching fractions
///   using the same mechanism as `fraction`. If set to an integer, that integer
///   is used as denominator. If set to `none` or `false`, or if no fraction
///   could be found, a real number with `digits` digits is used.
/// - digits (int): Number of digits to use for rounding
/// - eps (number): Epsilon used for comparison
/// - prefix (content): Content to prefix
/// - suffix (content): Content to append
/// -> Content if a matching fraction could be found or none
#let multiple-of(value, factor: calc.pi, symbol: $pi$, fraction: true, digits: 2, eps: 1e-6, prefix: [], suffix: []) = {
  if _compare(value, 0, eps: eps) {
    return $0$
  }

  let a = value / factor
  if _compare(a, 1, eps: eps) {
    return prefix + symbol + suffix
  } else if _compare(a, -1, eps: eps) {
    return prefix + $-$ + symbol + suffix
  }

  if fraction != none {
    let frac = _find-fraction(a, denom: if fraction == true { auto } else { fraction })
    if frac != none {
      return prefix + frac + symbol + suffix
    }
  }

  return prefix + $#calc.round(a, digits: digits)$ + symbol + suffix
}

/// Scientific notation tick formatter
///
/// ```cexample
/// plot.plot(size: (5,1),
///           x-format: plot.formats.sci,
///           x-tick-step: 1e3,
///           y-tick-step: none, {
///   plot.add(x => x, domain: (-2e3, 2e3))
/// })
/// ```
///
/// - value (number): Value to format
/// - digits (int): Number of digits for rounding the factor
/// - prefix (content): Content to prefix
/// - suffix (content): Content to append
/// -> Content
#let sci(value, digits: 2, prefix: [], suffix: []) = {
  let exponent = if value != 0 {
    calc.floor(calc.log(calc.abs(value), base: 10))
  } else {
    0
  }

  let ee = calc.pow(10.0, calc.abs(exponent + 1))
  if exponent > 0 {
    value = value / ee * 10
  } else if exponent < 0 {
    value = value * ee * 10
  }

  value = calc.round(value, digits: digits)
  if exponent <= -1 or exponent >= 1 {
    return prefix + $#value times 10^#exponent$ + suffix
  }

  return prefix + $#value$ + suffix
}

/// Rounded decimal number formatter
///
/// ```cexample
/// plot.plot(size: (5,1),
///           x-format: plot.formats.decimal,
///           x-tick-step: .5,
///           y-tick-step: none, {
///   plot.add(x => x, domain: (-1, 1))
/// })
/// ```
///
/// - value (number): Value to format
/// - digits (int): Number of digits to round to
/// - prefix (content): Content to prefix
/// - suffix (content): Content to append
/// -> Content
#let decimal(value, digits: 2, prefix: [], suffix: []) = {
  prefix + $#calc.round(value, digits: digits)$ + suffix
}
