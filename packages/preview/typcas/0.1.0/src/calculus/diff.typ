// =========================================================================
// CAS Calculus: Differentiation
// =========================================================================

#import "../expr.typ": *
#import "../simplify.typ": simplify
#import "../truths/calculus-rules.typ": calc-rules
#import "../helpers.typ": check-free-var as _check-free-var
#import "../core/expr-walk.typ": contains-var as _contains-var-core

// =========================================================================
// HELPERS
// =========================================================================

/// Check if an expression contains a given variable.
#let _contains-var(expr, v) = _contains-var-core(expr, v)

// =========================================================================
// DIFFERENTIATION
// =========================================================================

/// Symbolic differentiation of `expr` with respect to variable `v` (a string).
/// Returns the derivative as an expression (unsimplified).
#let diff(expr, v) = {
  _check-free-var(v)
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
      let exp-minus-one = simplify(add(exp, neg(num(1))))
      return mul(
        mul(exp, pow(base, exp-minus-one)),
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

  // Chain rule for named functions — table-driven
  if is-type(expr, "func") {
    let fname = expr.name
    if func-arity(expr) != 1 {
      return func("D[" + fname + "]", expr)
    }
    let u = func-args(expr).at(0)
    let du = diff(u, v)
    let rule = calc-rules.at(fname, default: none)
    if rule != none {
      return mul((rule.diff)(u), du)
    }
    // Unknown function: return symbolic derivative
    return func("D[" + fname + "]", u)
  }

  // Log with base: log_b(u) = ln(u)/ln(b)
  if is-type(expr, "log") {
    if not _contains-var(expr.base, v) {
      return cdiv(diff(expr.arg, v), mul(expr.arg, ln-of(expr.base)))
    }
    let rewritten = cdiv(ln-of(expr.arg), ln-of(expr.base))
    return diff(rewritten, v)
  }

  return expr
}
