// =========================================================================
// CAS Calculus: Integration Engine
// =========================================================================

#import "../expr.typ": *
#import "../simplify.typ": simplify
#import "../poly.typ": partial-fractions as _partial-fractions, poly-coeffs as _poly-coeffs
#import "../helpers.typ": check-free-var as _check-free-var
#import "../truths/calculus-rules.typ": calc-rules
#import "../truths/function-registry.typ": fn-canonical, fn-square-power-integral-spec
#import "../core/expr-walk.typ": contains-var as _contains-var-core
#import "diff.typ": diff

/// Check if an expression contains a given variable.
#let _contains-var(expr, v) = _contains-var-core(expr, v)

// =========================================================================
// INTEGRATION (basic symbolic rules)
// =========================================================================

/// Internal helper `_is-const-wrt`.
#let _is-const-wrt(expr, v) = not _contains-var(expr, v)

/// Internal helper `_is-polynomial-power`.
#let _is-polynomial-power(expr, v) = {
  if not is-type(expr, "pow") { return false }
  if not _contains-var(expr.base, v) { return false }
  if not is-type(expr.exp, "num") { return false }
  if _contains-var(expr.exp, v) { return false }
  true
}

/// Internal helper `_is-good-u-for-parts`.
#let _is-good-u-for-parts(expr, v) = {
  if is-type(expr, "var") and expr.name == v { return true }
  if is-type(expr, "pow") and is-type(expr.base, "var") and expr.base.name == v and is-type(expr.exp, "num") {
    return type(expr.exp.val) == int and expr.exp.val >= 1
  }
  if is-type(expr, "func") and fn-canonical(expr.name) == "ln" and func-arity(expr) == 1 and is-type(func-args(expr).at(0), "var") and func-args(expr).at(0).name == v {
    return true
  }
  false
}

/// Internal helper `_drop-power-one`.
#let _drop-power-one(expr) = {
  if is-type(expr, "pow") and is-type(expr.exp, "num") and expr.exp.val == 1 {
    return _drop-power-one(expr.base)
  }
  if is-type(expr, "neg") {
    return neg(_drop-power-one(expr.arg))
  }
  if is-type(expr, "add") {
    return add(_drop-power-one(expr.args.at(0)), _drop-power-one(expr.args.at(1)))
  }
  if is-type(expr, "mul") {
    return mul(_drop-power-one(expr.args.at(0)), _drop-power-one(expr.args.at(1)))
  }
  if is-type(expr, "div") {
    return cdiv(_drop-power-one(expr.num), _drop-power-one(expr.den))
  }
  if is-type(expr, "pow") {
    return pow(_drop-power-one(expr.base), _drop-power-one(expr.exp))
  }
  if is-type(expr, "func") {
    let args = func-args(expr).map(_drop-power-one)
    return func(expr.name, ..args)
  }
  if is-type(expr, "log") {
    return (type: "log", base: _drop-power-one(expr.base), arg: _drop-power-one(expr.arg))
  }
  expr
}

/// Internal helper `_try-usub-mul`.
#let _try-usub-mul(expr, v, depth) = {
  if not is-type(expr, "mul") { return none }
  let a = expr.args.at(0)
  let b = expr.args.at(1)

  let attempts = ((a, b), (b, a))
  for (dpart, other) in attempts {
    // Pattern 1: dpart * f(u)
    if is-type(other, "func") {
      let rule = calc-rules.at(other.name, default: none)
      if rule != none and rule.integ != none {
        if func-arity(other) != 1 { continue }
        let u = func-args(other).at(0)
        let dpart-n = simplify(_drop-power-one(dpart))
        let du = simplify(_drop-power-one(diff(u, v)))
        if _contains-var(du, v) {
          let ratio = simplify(cdiv(dpart-n, du))
          if _is-const-wrt(ratio, v) {
            return simplify(mul(ratio, (rule.integ)(u)))
          }
        }
      }
    }

    // Pattern 2: dpart * u^n
    if _is-polynomial-power(other, v) {
      let u = other.base
      let n = other.exp
      let dpart-n = simplify(_drop-power-one(dpart))
      let du = simplify(_drop-power-one(diff(u, v)))
      if _contains-var(du, v) {
        let ratio = simplify(cdiv(dpart-n, du))
        if _is-const-wrt(ratio, v) {
          if is-type(n, "num") and n.val == -1 {
            return simplify(mul(ratio, ln-of(abs-of(u))))
          }
          let np1 = simplify(add(n, num(1)))
          return simplify(mul(ratio, cdiv(pow(u, np1), np1)))
        }
      }
    }

    // Pattern 3: dpart * (1/u)
    if is-type(other, "div") and is-type(other.num, "num") and other.num.val == 1 {
      let u = other.den
      let dpart-n = simplify(_drop-power-one(dpart))
      let du = simplify(_drop-power-one(diff(u, v)))
      if _contains-var(du, v) {
        let ratio = simplify(cdiv(dpart-n, du))
        if _is-const-wrt(ratio, v) {
          return simplify(mul(ratio, ln-of(abs-of(u))))
        }
      }
    }
  }

  none
}

/// Internal helper `_try-by-parts`.
#let _try-by-parts(expr, v, depth, recurse) = {
  if not is-type(expr, "mul") { return none }
  if depth > 4 { return none }

  let a = expr.args.at(0)
  let b = expr.args.at(1)

  let attempts = ((a, b), (b, a))
  for (u, dv) in attempts {
    if not _is-good-u-for-parts(u, v) { continue }

    let v-ant = recurse(dv, v, depth + 1)
    if is-type(v-ant, "integral") { continue }

    let du = simplify(diff(u, v))
    let rem-int = recurse(simplify(mul(v-ant, du)), v, depth + 1)
    if is-type(rem-int, "integral") { continue }

    return simplify(sub(mul(u, v-ant), rem-int))
  }

  none
}

/// Internal helper `_try-partial-fractions`.
#let _try-partial-fractions(expr, v, depth, recurse) = {
  if not is-type(expr, "div") { return none }
  if depth > 4 { return none }

  let nc = _poly-coeffs(expr.num, v)
  let dc = _poly-coeffs(expr.den, v)
  if nc == none or dc == none { return none }
  if nc.len() >= dc.len() { return none }

  let decomp = simplify(_partial-fractions(expr, v))
  if expr-eq(decomp, expr) { return none }
  recurse(decomp, v, depth + 1)
}

/// Internal helper `_integrate-core`.
#let _integrate-core(expr, v, depth) = {
  // ∫ c dx = c*x
  if is-type(expr, "num") or is-type(expr, "const") {
    return mul(expr, cvar(v))
  }

  // ∫ x dx = x^2/2 (if var matches)
  if is-type(expr, "var") {
    if expr.name == v {
      return cdiv(pow(cvar(v), num(2)), num(2))
    }
    return mul(expr, cvar(v))
  }

  // ∫ -u dx
  if is-type(expr, "neg") {
    return neg(_integrate-core(expr.arg, v, depth + 1))
  }

  // ∫ (u + w) dx
  if is-type(expr, "add") {
    return add(
      _integrate-core(expr.args.at(0), v, depth + 1),
      _integrate-core(expr.args.at(1), v, depth + 1),
    )
  }

  // ∫ c*f(x) dx
  if is-type(expr, "mul") {
    let a = expr.args.at(0)
    let b = expr.args.at(1)
    if not _contains-var(a, v) {
      return mul(a, _integrate-core(b, v, depth + 1))
    }
    if not _contains-var(b, v) {
      return mul(b, _integrate-core(a, v, depth + 1))
    }
  }

  // e^x as power
  if is-type(expr, "pow") and is-type(expr.base, "const") and expr.base.name == "e" {
    if is-type(expr.exp, "var") and expr.exp.name == v {
      return exp-of(cvar(v))
    }
  }

  // ∫ x^n dx
  if is-type(expr, "pow") {
    let base = expr.base
    let exp = expr.exp
    // ∫sec(u)^2 dx = tan(u)/u' (for constant u')
    // ∫csc(u)^2 dx = -cot(u)/u'
    // ∫sech(u)^2 dx = tanh(u)/u'
    // ∫csch(u)^2 dx = -coth(u)/u'
    if is-type(exp, "num") and exp.val == 2 and is-type(base, "func") {
      let square-rule = fn-square-power-integral-spec(base.name)
      if square-rule != none and func-arity(base) == 1 {
        let inner = func-args(base).at(0)
        let du = simplify(diff(inner, v))
        if not _contains-var(du, v) and not expr-eq(du, num(0)) {
          let antideriv = (square-rule.antideriv)(inner)
          if is-type(du, "num") and du.val == 1 {
            return antideriv
          }
          return cdiv(antideriv, du)
        }
      }
    }
    if is-type(base, "var") and base.name == v and not _contains-var(exp, v) {
      if is-type(exp, "num") and exp.val == -1 {
        return ln-of(abs-of(cvar(v)))
      }
      let n-plus-1 = add(exp, num(1))
      return cdiv(pow(cvar(v), n-plus-1), n-plus-1)
    }
  }

  // ∫ 1/x dx and c/x
  if is-type(expr, "div") {
    let n = expr.num
    let d = expr.den
    if is-type(n, "num") and n.val == 1 and is-type(d, "var") and d.name == v {
      return ln-of(abs-of(cvar(v)))
    }
    if is-type(n, "num") and is-type(d, "var") and d.name == v {
      return mul(n, ln-of(abs-of(cvar(v))))
    }
    // General log-u rule: ∫ c/u(x) dx = c * ln|u| / u' when c and u' are constants wrt v.
    if not _contains-var(n, v) {
      let du = simplify(_drop-power-one(diff(d, v)))
      if not _contains-var(du, v) and not expr-eq(du, num(0)) {
        return simplify(cdiv(mul(n, ln-of(abs-of(d))), du))
      }
    }
  }

  // Table-driven ∫f(u(x)) dx where u' is constant.
  if is-type(expr, "func") {
    let fname = expr.name
    if func-arity(expr) != 1 { return (type: "integral", expr: expr, var: v) }
    let u = func-args(expr).at(0)
    let rule = calc-rules.at(fname, default: none)
    if rule != none and rule.integ != none {
      let du = simplify(diff(u, v))
      if not _contains-var(du, v) {
        let antideriv = (rule.integ)(u)
        if is-type(du, "num") and du.val == 1 {
          return antideriv
        }
        return cdiv(antideriv, du)
      }
    }
  }

  // sec^2 pattern
  if is-type(expr, "div") {
    let n = expr.num
    let d = expr.den
    if is-type(n, "num") and n.val == 1 and is-type(d, "pow") {
      if is-type(d.base, "func") and fn-canonical(d.base.name) == "cos" and is-type(d.exp, "num") and d.exp.val == 2 {
        if func-arity(d.base) == 1 {
          let inner = func-args(d.base).at(0)
          let du = simplify(diff(inner, v))
          if not _contains-var(du, v) {
            if is-type(du, "num") and du.val == 1 {
              return tan-of(inner)
            }
            return cdiv(tan-of(inner), du)
          }
        }
      }
    }
  }

  // Systematic u-sub for products.
  let usub = _try-usub-mul(expr, v, depth)
  if usub != none { return usub }

  // Partial-fraction workflow for rational functions.
  let pfd = _try-partial-fractions(expr, v, depth, _integrate-core)
  if pfd != none { return pfd }

  // Integration by parts fallback.
  let ibp = _try-by-parts(expr, v, depth, _integrate-core)
  if ibp != none { return ibp }

  (type: "integral", expr: expr, var: v)
}

/// Symbolic integration of `expr` with respect to variable `v` (string).
/// Returns antiderivative (no constant of integration).
/// For unrecognized patterns, returns an "integral" node.
#let integrate(expr, v) = {
  _check-free-var(v)
  simplify(_integrate-core(expr, v, 0))
}
