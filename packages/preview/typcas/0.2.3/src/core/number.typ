// =========================================================================
// typcas v2 Numeric Kernel
// =========================================================================
// Scalar helpers for exact-ish real/float + complex arithmetic.
// =========================================================================

#import "ast.typ": *

/// Complex scalar value helper (numeric runtime value, not AST).
#let cx(re, im: 0.0) = (re: re + 0.0, im: im + 0.0)

#let cx-add(a, b) = cx(a.re + b.re, a.im + b.im)
#let cx-sub(a, b) = cx(a.re - b.re, a.im - b.im)
#let cx-mul(a, b) = cx(a.re * b.re - a.im * b.im, a.re * b.im + a.im * b.re)

#let cx-div(a, b) = {
  let den = b.re * b.re + b.im * b.im
  if den == 0 { return none }
  cx((a.re * b.re + a.im * b.im) / den, (a.im * b.re - a.re * b.im) / den)
}

#let cx-abs2(a) = a.re * a.re + a.im * a.im
#let cx-abs(a) = calc.sqrt(cx-abs2(a))
#let cx-conj(a) = cx(a.re, -a.im)

/// Convert real scalar to complex scalar.
#let cx-from-real(x) = cx(x + 0.0, 0.0)

/// Convert native complex AST to numeric complex if both parts are numeric.
#let cx-from-expr(expr) = {
  if not is-complex(expr) { return none }
  if not is-type(expr.re, "num") or not is-type(expr.im, "num") { return none }
  cx(expr.re.val + 0.0, expr.im.val + 0.0)
}

/// Convert numeric complex scalar to native complex AST.
#let cx-to-expr(z) = complex(num(z.re), num(z.im))
