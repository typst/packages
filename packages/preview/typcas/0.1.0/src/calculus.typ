// =========================================================================
// CAS Calculus: Differentiation, Integration, Taylor Series & Limits
// =========================================================================

#import "expr.typ": *
#import "simplify.typ": simplify
#import "eval-num.typ": eval-expr, substitute

// =========================================================================
// HELPERS
// =========================================================================

/// Check if an expression contains a given variable.
#let _contains-var(expr, v) = {
  if is-type(expr, "var") { return expr.name == v }
  if is-type(expr, "num") or is-type(expr, "const") { return false }
  if is-type(expr, "neg") { return _contains-var(expr.arg, v) }
  if is-type(expr, "add") or is-type(expr, "mul") {
    return _contains-var(expr.args.at(0), v) or _contains-var(expr.args.at(1), v)
  }
  if is-type(expr, "pow") { return _contains-var(expr.base, v) or _contains-var(expr.exp, v) }
  if is-type(expr, "div") { return _contains-var(expr.num, v) or _contains-var(expr.den, v) }
  if is-type(expr, "func") { return _contains-var(expr.arg, v) }
  return false
}

// =========================================================================
// DIFFERENTIATION
// =========================================================================

/// Symbolic differentiation of `expr` with respect to variable `v` (a string).
/// Returns the derivative as an expression (unsimplified).
#let diff(expr, v) = {
  // d/dx c = 0
  if is-type(expr, "num") or is-type(expr, "const") {
    return num(0)
  }

  // d/dx x = 1,  d/dx y = 0
  if is-type(expr, "var") {
    if expr.name == v { return num(1) }
    return num(0)
  }

  // d/dx (-u) = -(du/dx)
  if is-type(expr, "neg") {
    return neg(diff(expr.arg, v))
  }

  // Sum rule: d/dx (u + v) = du/dx + dv/dx
  if is-type(expr, "add") {
    return add(
      diff(expr.args.at(0), v),
      diff(expr.args.at(1), v),
    )
  }

  // Product rule: d/dx (u * v) = u'v + uv'
  if is-type(expr, "mul") {
    let u = expr.args.at(0)
    let w = expr.args.at(1)
    return add(
      mul(diff(u, v), w),
      mul(u, diff(w, v)),
    )
  }

  // Power rule with chain rule
  if is-type(expr, "pow") {
    let base = expr.base
    let exp = expr.exp
    let base-has-v = _contains-var(base, v)
    let exp-has-v = _contains-var(exp, v)

    // x^n (constant exponent): n * x^(n-1) * dx/dv
    if not exp-has-v {
      return mul(
        mul(exp, pow(base, add(exp, neg(num(1))))),
        diff(base, v),
      )
    }
    // a^x (constant base): a^x * ln(a) * dx/dv
    if not base-has-v {
      return mul(
        mul(expr, ln-of(base)),
        diff(exp, v),
      )
    }
    // f(x)^g(x): rewrite as e^(g*ln(f)) and differentiate
    let rewritten = func("exp", mul(exp, ln-of(base)))
    return diff(rewritten, v)
  }

  // Quotient rule: d/dx (u/v) = (u'v - uv') / v^2
  if is-type(expr, "div") {
    let u = expr.num
    let w = expr.den
    return cdiv(
      add(mul(diff(u, v), w), neg(mul(u, diff(w, v)))),
      pow(w, num(2)),
    )
  }

  // Chain rule for named functions
  if is-type(expr, "func") {
    let fname = expr.name
    let u = expr.arg
    let du = diff(u, v)

    // d/dx sin(u) = cos(u) * u'
    if fname == "sin" { return mul(cos-of(u), du) }
    // d/dx cos(u) = -sin(u) * u'
    if fname == "cos" { return mul(neg(sin-of(u)), du) }
    // d/dx tan(u) = (1/cos^2(u)) * u'  =  sec^2(u) * u'
    if fname == "tan" {
      return mul(cdiv(num(1), pow(cos-of(u), num(2))), du)
    }
    // d/dx csc(u) = -csc(u)*cot(u) * u'
    if fname == "csc" {
      return mul(neg(mul(csc-of(u), cot-of(u))), du)
    }
    // d/dx sec(u) = sec(u)*tan(u) * u'
    if fname == "sec" {
      return mul(mul(sec-of(u), tan-of(u)), du)
    }
    // d/dx cot(u) = -csc^2(u) * u'
    if fname == "cot" {
      return mul(neg(cdiv(num(1), pow(sin-of(u), num(2)))), du)
    }
    // d/dx ln(u) = u'/u
    if fname == "ln" { return mul(cdiv(num(1), u), du) }
    // d/dx exp(u) = exp(u) * u'
    if fname == "exp" { return mul(func("exp", u), du) }

    // --- Inverse trigonometric ---
    // d/dx arcsin(u) = u' / sqrt(1 - u^2)
    if fname == "arcsin" {
      return mul(cdiv(num(1), sqrt-of(sub(num(1), pow(u, num(2))))), du)
    }
    // d/dx arccos(u) = -u' / sqrt(1 - u^2)
    if fname == "arccos" {
      return mul(neg(cdiv(num(1), sqrt-of(sub(num(1), pow(u, num(2)))))), du)
    }
    // d/dx arctan(u) = u' / (1 + u^2)
    if fname == "arctan" {
      return mul(cdiv(num(1), add(num(1), pow(u, num(2)))), du)
    }

    // --- Hyperbolic ---
    // d/dx sinh(u) = cosh(u) * u'
    if fname == "sinh" { return mul(cosh-of(u), du) }
    // d/dx cosh(u) = sinh(u) * u'
    if fname == "cosh" { return mul(sinh-of(u), du) }
    // d/dx tanh(u) = (1 - tanh^2(u)) * u'  =  1/cosh^2(u) * u'
    if fname == "tanh" {
      return mul(cdiv(num(1), pow(cosh-of(u), num(2))), du)
    }

    // --- Inverse hyperbolic ---
    // d/dx arcsinh(u) = u' / sqrt(u^2 + 1)
    if fname == "arcsinh" {
      return mul(cdiv(num(1), sqrt-of(add(pow(u, num(2)), num(1)))), du)
    }
    // d/dx arccosh(u) = u' / sqrt(u^2 - 1)
    if fname == "arccosh" {
      return mul(cdiv(num(1), sqrt-of(sub(pow(u, num(2)), num(1)))), du)
    }
    // d/dx arctanh(u) = u' / (1 - u^2)
    if fname == "arctanh" {
      return mul(cdiv(num(1), sub(num(1), pow(u, num(2)))), du)
    }

    // --- Remaining inverse trig ---
    // d/dx arccsc(u) = -u' / (u * sqrt(u^2 - 1))
    if fname == "arccsc" {
      return mul(neg(cdiv(num(1), mul(u, sqrt-of(sub(pow(u, num(2)), num(1)))))), du)
    }
    // d/dx arcsec(u) = u' / (u * sqrt(u^2 - 1))
    if fname == "arcsec" {
      return mul(cdiv(num(1), mul(u, sqrt-of(sub(pow(u, num(2)), num(1))))), du)
    }
    // d/dx arccot(u) = -u' / (1 + u^2)
    if fname == "arccot" {
      return mul(neg(cdiv(num(1), add(num(1), pow(u, num(2))))), du)
    }

    // --- Remaining hyperbolic ---
    // d/dx csch(u) = -csch(u)*coth(u) * u'
    if fname == "csch" {
      return mul(neg(mul(csch-of(u), coth-of(u))), du)
    }
    // d/dx sech(u) = -sech(u)*tanh(u) * u'
    if fname == "sech" {
      return mul(neg(mul(sech-of(u), tanh-of(u))), du)
    }
    // d/dx coth(u) = -csch^2(u) * u'
    if fname == "coth" {
      return mul(neg(pow(csch-of(u), num(2))), du)
    }

    // --- Remaining inverse hyperbolic ---
    // d/dx arccsch(u) = -u' / (|u| * sqrt(u^2 + 1))  (simplified without abs)
    if fname == "arccsch" {
      return mul(neg(cdiv(num(1), mul(u, sqrt-of(add(pow(u, num(2)), num(1)))))), du)
    }
    // d/dx arcsech(u) = -u' / (u * sqrt(1 - u^2))
    if fname == "arcsech" {
      return mul(neg(cdiv(num(1), mul(u, sqrt-of(sub(num(1), pow(u, num(2))))))), du)
    }
    // d/dx arccoth(u) = u' / (1 - u^2)
    if fname == "arccoth" {
      return mul(cdiv(num(1), sub(num(1), pow(u, num(2)))), du)
    }

    // Unknown function: return symbolic derivative
    return func("D[" + fname + "]", u)
  }

  return expr
}

// =========================================================================
// INTEGRATION (basic symbolic rules)
// =========================================================================

/// Symbolic integration of `expr` with respect to variable `v` (string).
/// Returns antiderivative (no constant of integration).
/// For unrecognized patterns, returns an "integral" node.
#let integrate(expr, v) = {
  // ∫ c dx = c*x
  if is-type(expr, "num") {
    return mul(expr, cvar(v))
  }

  // ∫ constant dx = constant * x
  if is-type(expr, "const") {
    return mul(expr, cvar(v))
  }

  // ∫ x dx = x^2/2 (if var matches)
  if is-type(expr, "var") {
    if expr.name == v {
      return cdiv(pow(cvar(v), num(2)), num(2))
    }
    // ∫ y dx = y*x (treat as constant)
    return mul(expr, cvar(v))
  }

  // ∫ -u dx = -(∫ u dx)
  if is-type(expr, "neg") {
    return neg(integrate(expr.arg, v))
  }

  // ∫ (u + v) dx = ∫ u dx + ∫ v dx
  if is-type(expr, "add") {
    return add(
      integrate(expr.args.at(0), v),
      integrate(expr.args.at(1), v),
    )
  }

  // ∫ c * f(x) dx = c * ∫ f(x) dx (if c is constant w.r.t. v)
  if is-type(expr, "mul") {
    let a = expr.args.at(0)
    let b = expr.args.at(1)
    if not _contains-var(a, v) {
      return mul(a, integrate(b, v))
    }
    if not _contains-var(b, v) {
      return mul(b, integrate(a, v))
    }
  }

  // ∫ x^n dx = x^(n+1)/(n+1) for constant n ≠ -1
  if is-type(expr, "pow") {
    let base = expr.base
    let exp = expr.exp
    if is-type(base, "var") and base.name == v and not _contains-var(exp, v) {
      // Check for n = -1 => ln|x|
      if is-type(exp, "num") and exp.val == -1 {
        return ln-of(cvar(v))
      }
      let n-plus-1 = add(exp, num(1))
      return cdiv(pow(cvar(v), n-plus-1), n-plus-1)
    }
  }

  // ∫ 1/x dx = ln(x)
  if is-type(expr, "div") {
    let n = expr.num
    let d = expr.den
    if is-type(n, "num") and n.val == 1 and is-type(d, "var") and d.name == v {
      return ln-of(cvar(v))
    }
    // ∫ c/x dx = c * ln(x)
    if is-type(n, "num") and is-type(d, "var") and d.name == v {
      return mul(n, ln-of(cvar(v)))
    }
  }

  // ∫ sin(x) dx = -cos(x)
  if is-type(expr, "func") and expr.name == "sin" {
    if is-type(expr.arg, "var") and expr.arg.name == v {
      return neg(cos-of(cvar(v)))
    }
  }

  // ∫ cos(x) dx = sin(x)
  if is-type(expr, "func") and expr.name == "cos" {
    if is-type(expr.arg, "var") and expr.arg.name == v {
      return sin-of(cvar(v))
    }
  }

  // ∫ exp(x) dx = exp(x)
  if is-type(expr, "func") and expr.name == "exp" {
    if is-type(expr.arg, "var") and expr.arg.name == v {
      return exp-of(cvar(v))
    }
  }

  // ∫ csc(x) dx = -ln|csc(x) + cot(x)| (simplified: ln|csc(x) - cot(x)|)
  // We use: ∫ csc(x) dx = ln|csc(x) - cot(x)|
  if is-type(expr, "func") and expr.name == "csc" {
    if is-type(expr.arg, "var") and expr.arg.name == v {
      return neg(ln-of(add(csc-of(cvar(v)), cot-of(cvar(v)))))
    }
  }

  // ∫ sec(x) dx = ln|sec(x) + tan(x)|
  if is-type(expr, "func") and expr.name == "sec" {
    if is-type(expr.arg, "var") and expr.arg.name == v {
      return ln-of(add(sec-of(cvar(v)), tan-of(cvar(v))))
    }
  }

  // ∫ cot(x) dx = ln|sin(x)|
  if is-type(expr, "func") and expr.name == "cot" {
    if is-type(expr.arg, "var") and expr.arg.name == v {
      return ln-of(sin-of(cvar(v)))
    }
  }

  // ∫ sinh(x) dx = cosh(x)
  if is-type(expr, "func") and expr.name == "sinh" {
    if is-type(expr.arg, "var") and expr.arg.name == v {
      return cosh-of(cvar(v))
    }
  }

  // ∫ cosh(x) dx = sinh(x)
  if is-type(expr, "func") and expr.name == "cosh" {
    if is-type(expr.arg, "var") and expr.arg.name == v {
      return sinh-of(cvar(v))
    }
  }

  // ∫ tanh(x) dx = ln(cosh(x))
  if is-type(expr, "func") and expr.name == "tanh" {
    if is-type(expr.arg, "var") and expr.arg.name == v {
      return ln-of(cosh-of(cvar(v)))
    }
  }

  // ∫ 1/cos^2(x) dx = tan(x)  (sec^2)
  if is-type(expr, "div") {
    let n = expr.num
    let d = expr.den
    if is-type(n, "num") and n.val == 1 and is-type(d, "pow") {
      if is-type(d.base, "func") and d.base.name == "cos" and is-type(d.exp, "num") and d.exp.val == 2 {
        if is-type(d.base.arg, "var") and d.base.arg.name == v {
          return tan-of(cvar(v))
        }
      }
    }
  }

  // Unrecognized pattern: return symbolic integral node
  return (type: "integral", expr: expr, var: v)
}

// =========================================================================
// HIGHER-ORDER DIFFERENTIATION
// =========================================================================

/// Compute the nth derivative of `expr` with respect to `v`.
/// diff-n(expr, "x", 3) computes d³/dx³(expr).
#let diff-n(expr, v, n) = {
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
  let x0 = if type(x0) == int or type(x0) == float { num(x0) } else { x0 }
  let result = num(0)
  let deriv = expr
  let i = 0
  let factorial = 1
  while i <= n {
    // Evaluate f^(i) at x0
    let coeff = simplify(substitute(deriv, v, x0))
    // term = coeff / i! * (x - x0)^i
    let term = if i == 0 {
      coeff
    } else {
      let base = if is-type(x0, "num") and x0.val == 0 {
        cvar(v)
      } else {
        sub(cvar(v), x0)
      }
      let power-term = if i == 1 { base } else { pow(base, num(i)) }
      if factorial == 1 {
        mul(coeff, power-term)
      } else {
        mul(cdiv(coeff, num(factorial)), power-term)
      }
    }
    result = add(result, term)
    // Next derivative
    deriv = simplify(diff(deriv, v))
    i += 1
    factorial = factorial * i
  }
  simplify(result)
}

// =========================================================================
// LIMITS
// =========================================================================

/// Compute the limit of `expr` as variable `v` approaches `a`.
/// Uses direct substitution; applies L'Hôpital for 0/0 forms (up to 5 tries).
/// Auto-wraps raw number for a.
#let limit(expr, v, a) = {
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
