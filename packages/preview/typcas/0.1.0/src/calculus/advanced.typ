// =========================================================================
// CAS Calculus: Advanced Operations
// =========================================================================

#import "../expr.typ": *
#import "../simplify.typ": simplify
#import "../eval-num.typ": eval-expr, substitute
#import "../helpers.typ": check-free-var as _check-free-var, check-free-vars as _check-free-vars
#import "diff.typ": diff
#import "integrate.typ": integrate

// =========================================================================
// HIGHER-ORDER DIFFERENTIATION
// =========================================================================

/// Compute the nth derivative of `expr` with respect to `v`.
/// diff-n(expr, "x", 3) computes d³/dx³(expr).
#let diff-n(expr, v, n) = {
  _check-free-var(v)
  let result = expr
  let i = 0
  while i < n {
    result = simplify(diff(result, v))
    i += 1
  }
  result
}

// =========================================================================
// DEFINITE INTEGRALS
// =========================================================================

/// Compute the definite integral of `expr` from `a` to `b` w.r.t. `v`.
/// Returns F(b) - F(a) where F is the antiderivative.
/// Auto-wraps raw number bounds.
#let definite-integral(expr, v, a, b) = {
  _check-free-var(v)
  let a = if type(a) == int or type(a) == float { num(a) } else { a }
  let b = if type(b) == int or type(b) == float { num(b) } else { b }
  let antideriv = simplify(integrate(expr, v))
  // If integration failed (returned integral node), return symbolic
  if is-type(antideriv, "integral") {
    return (type: "def-integral", expr: expr, var: v, lo: a, hi: b)
  }
  let fb = simplify(substitute(antideriv, v, b))
  let fa = simplify(substitute(antideriv, v, a))
  simplify(sub(fb, fa))
}

// =========================================================================
// TAYLOR SERIES
// =========================================================================

/// Compute the Taylor series of `expr` around `x0` up to order `n`.
/// Returns the polynomial Σ f^(k)(x0)/k! * (x - x0)^k for k = 0..n.
/// Auto-wraps raw number for x0.
#let taylor(expr, v, x0, n) = {
  _check-free-var(v)
  let x0 = if type(x0) == int or type(x0) == float { num(x0) } else { x0 }
  let terms = ()
  let deriv = expr
  let i = 0
  let factorial = 1
  while i <= n {
    // Evaluate f^(i) at x0
    let coeff = simplify(substitute(deriv, v, x0))
    // term = coeff / i! * (x - x0)^i
    let scaled = if factorial == 1 { coeff } else { simplify(cdiv(coeff, num(factorial))) }
    let term = if i == 0 {
      scaled
    } else {
      let base = if is-type(x0, "num") and x0.val == 0 {
        cvar(v)
      } else {
        sub(cvar(v), x0)
      }
      let power-term = if i == 1 { base } else { pow(base, num(i)) }
      mul(scaled, power-term)
    }
    let sterm = simplify(term)
    if not (is-type(sterm, "num") and sterm.val == 0) {
      terms.push(sterm)
    }
    // Next derivative
    deriv = simplify(diff(deriv, v))
    i += 1
    factorial = factorial * i
  }
  if terms.len() == 0 { return num(0) }
  let result = terms.at(0)
  for j in range(1, terms.len()) {
    result = add(result, terms.at(j))
  }
  // Keep the generated series order stable (constant/low-order first)
  // instead of fully reordering by global simplifier heuristics.
  result
}

// =========================================================================
// LIMITS
// =========================================================================

/// Compute the limit of `expr` as variable `v` approaches `a`.
/// Uses direct substitution; applies L'Hôpital for 0/0 forms (up to 5 tries).
/// Auto-wraps raw number for a.
#let limit(expr, v, a) = {
  _check-free-var(v)
  let a = if type(a) == int or type(a) == float { num(a) } else { a }
  let e = simplify(expr)

  // Direct substitution
  let val = eval-expr(substitute(e, v, a), (:))
  if val != none and val == val {
    // val == val filters NaN
    return num(val)
  }

  // L'Hôpital: if expr = f/g and both f(a)=0 and g(a)=0
  if is-type(e, "div") {
    let f = e.num
    let g = e.den
    let fa = eval-expr(substitute(f, v, a), (:))
    let ga = eval-expr(substitute(g, v, a), (:))
    if fa != none and ga != none and fa == 0 and ga == 0 {
      let tries = 0
      let cf = f
      let cg = g
      while tries < 5 {
        cf = simplify(diff(cf, v))
        cg = simplify(diff(cg, v))
        let fv = eval-expr(substitute(cf, v, a), (:))
        let gv = eval-expr(substitute(cg, v, a), (:))
        if gv != none and gv != 0 {
          if fv != none {
            return num(fv / gv)
          }
          return simplify(cdiv(substitute(cf, v, a), substitute(cg, v, a)))
        }
        // Still 0/0, try again
        if fv == none or gv == none { break }
        tries += 1
      }
    }
  }

  // Return symbolic limit node
  return (type: "limit", expr: e, var: v, to: a)
}

// =========================================================================
// IMPLICIT DIFFERENTIATION
// =========================================================================

/// Given F(x, y) = 0, compute dy/dx = -F_x / F_y.
/// `expr` is F(x, y), `x` and `y` are variable name strings.
#let implicit-diff(expr, x, y) = {
  _check-free-vars(x, y)
  let fx = diff(expr, x)
  let fy = diff(expr, y)
  simplify(neg(cdiv(fx, fy)))
}
