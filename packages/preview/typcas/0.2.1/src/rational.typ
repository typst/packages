// =========================================================================
// CAS Rational Arithmetic Helpers
// =========================================================================
// Internal exact arithmetic helpers used by simplifier/solver paths.
// Rational numbers are represented as dictionaries: (n: int, d: int), d > 0.
// =========================================================================

#import "expr.typ": *

/// Internal helper `_abs-int`.
#let _abs-int(x) = int(calc.abs(x))

/// Internal helper `_gcd-int`.
#let _gcd-int(a, b) = {
  let aa = _abs-int(a)
  let bb = _abs-int(b)
  if aa == 0 and bb == 0 { return 1 }
  calc.gcd(aa, bb)
}

/// Public helper `rat`.
#let rat(n, d) = {
  let nn = int(calc.round(n))
  let dd = int(calc.round(d))
  if dd == 0 { panic("rat: denominator must be nonzero") }
  let sign = if dd < 0 { -1 } else { 1 }
  let n1 = nn * sign
  let d1 = _abs-int(dd)
  let g = _gcd-int(n1, d1)
  (n: int(n1 / g), d: int(d1 / g))
}

/// Public helper `rat-is-zero`.
#let rat-is-zero(r) = r.n == 0
/// Public helper `rat-is-one`.
#let rat-is-one(r) = r.n == r.d
/// Public helper `rat-neg`.
#let rat-neg(r) = (n: -r.n, d: r.d)
/// Public helper `rat-add`.
#let rat-add(a, b) = rat(a.n * b.d + b.n * a.d, a.d * b.d)
/// Public helper `rat-sub`.
#let rat-sub(a, b) = rat(a.n * b.d - b.n * a.d, a.d * b.d)
/// Public helper `rat-mul`.
#let rat-mul(a, b) = rat(a.n * b.n, a.d * b.d)
/// Public helper `rat-div`.
#let rat-div(a, b) = {
  if b.n == 0 { panic("rat-div: division by zero") }
  rat(a.n * b.d, a.d * b.n)
}
/// Public helper `rat-eq`.
#let rat-eq(a, b) = a.n == b.n and a.d == b.d
/// Public helper `rat-to-float`.
#let rat-to-float(r) = r.n / r.d

/// Internal helper `_rat-from-float`.
#let _rat-from-float(x, max-den: 1000000) = {
  let xr = calc.round(x)
  if calc.abs(x - xr) < 1e-12 {
    return rat(int(xr), 1)
  }

  let sign = if x < 0 { -1 } else { 1 }
  let ax = calc.abs(x)
  let den = 1
  let it = 0
  while it < 12 and den < max-den {
    let scaled = ax * den
    if calc.abs(scaled - calc.round(scaled)) < 1e-10 { break }
    den *= 10
    it += 1
  }
  let nume = int(calc.round(ax * den)) * sign
  rat(nume, den)
}

/// Public helper `rat-from-number`.
#let rat-from-number(x) = {
  if type(x) == int { return rat(x, 1) }
  if type(x) == float { return _rat-from-float(x) }
  none
}

// Parse numeric/rational CAS expressions into exact rationals when possible.
/// Public helper `rat-from-expr`.
#let rat-from-expr(expr) = {
  if is-type(expr, "num") {
    return rat-from-number(expr.val)
  }
  if is-type(expr, "neg") {
    let r = rat-from-expr(expr.arg)
    if r == none { return none }
    return rat-neg(r)
  }
  if is-type(expr, "div") {
    let rn = rat-from-expr(expr.num)
    let rd = rat-from-expr(expr.den)
    if rn == none or rd == none or rd.n == 0 { return none }
    return rat-div(rn, rd)
  }
  if is-type(expr, "add") {
    let ra = rat-from-expr(expr.args.at(0))
    let rb = rat-from-expr(expr.args.at(1))
    if ra == none or rb == none { return none }
    return rat-add(ra, rb)
  }
  if is-type(expr, "mul") {
    let ra = rat-from-expr(expr.args.at(0))
    let rb = rat-from-expr(expr.args.at(1))
    if ra == none or rb == none { return none }
    return rat-mul(ra, rb)
  }
  if is-type(expr, "pow") {
    let rb = rat-from-expr(expr.base)
    if rb == none { return none }
    if not is-type(expr.exp, "num") or type(expr.exp.val) != int { return none }
    let n = expr.exp.val
    if n == 0 { return rat(1, 1) }
    if n > 0 {
      let out = rat(1, 1)
      for _ in range(n) { out = rat-mul(out, rb) }
      return out
    }
    // Negative integer power
    let out = rat(1, 1)
    for _ in range(-n) { out = rat-mul(out, rb) }
    if out.n == 0 { return none }
    return rat(out.d, out.n)
  }
  none
}

/// Public helper `rat-to-expr`.
#let rat-to-expr(r) = {
  if r.d == 1 { return num(r.n) }
  cdiv(num(r.n), num(r.d))
}

/// Internal helper `_int-sqrt-exact`.
#let _int-sqrt-exact(n) = {
  if n < 0 { return none }
  let s0 = int(calc.sqrt(n))
  let s1 = if (s0 + 1) * (s0 + 1) <= n { s0 + 1 } else { s0 }
  let s2 = if s1 * s1 > n { s1 - 1 } else { s1 }
  if s2 * s2 == n { return s2 }
  none
}

/// Public helper `rat-sqrt-exact`.
#let rat-sqrt-exact(r) = {
  if r.n < 0 { return none }
  let ns = _int-sqrt-exact(_abs-int(r.n))
  let ds = _int-sqrt-exact(r.d)
  if ns == none or ds == none { return none }
  let sign = if r.n < 0 { -1 } else { 1 }
  rat(sign * ns, ds)
}

/// Public helper `rat-abs`.
#let rat-abs(r) = rat(_abs-int(r.n), r.d)
