// =========================================================================
// CAS Assumptions
// =========================================================================
// Lightweight assumption system for domain-aware simplification.
// Assumptions are dictionaries keyed by variable name:
//   (x: (real: true, positive: true, nonzero: true))
// =========================================================================

#import "expr.typ": *
#import "truths/function-registry.typ": fn-canonical

/// Internal helper `_assume-get`.
#let _assume-get(assumptions, var, key) = {
  let rec = assumptions.at(var, default: (:))
  rec.at(key, default: false)
}

/// Public helper `assume`.
#let assume(var, real: false, positive: false, nonzero: false, nonnegative: false, negative: false) = {
  let out = (:)
  out.insert(var, (
    real: real,
    positive: positive,
    nonzero: nonzero,
    nonnegative: nonnegative,
    negative: negative,
  ))
  out
}

/// Public helper `merge-assumptions`.
#let merge-assumptions(..assumptions) = {
  let out = (:)
  for block in assumptions.pos() {
    for k in block.keys() {
      out.insert(k, block.at(k))
    }
  }
  out
}

/// Internal helper `_is-positive-var`.
#let _is-positive-var(expr, assumptions) = {
  if not is-type(expr, "var") { return false }
  let name = expr.name
  if _assume-get(assumptions, name, "positive") { return true }
  if _assume-get(assumptions, name, "nonnegative") { return true }
  false
}

/// Internal helper `_is-negative-var`.
#let _is-negative-var(expr, assumptions) = {
  if not is-type(expr, "var") { return false }
  _assume-get(assumptions, expr.name, "negative")
}

/// Internal helper `_is-real-var`.
#let _is-real-var(expr, assumptions) = {
  if not is-type(expr, "var") { return false }
  let name = expr.name
  if _assume-get(assumptions, name, "real") { return true }
  if _assume-get(assumptions, name, "positive") { return true }
  if _assume-get(assumptions, name, "nonnegative") { return true }
  if _assume-get(assumptions, name, "negative") { return true }
  false
}

/// Internal helper `_apply`.
#let _apply(expr, assumptions) = {
  if assumptions == none { return expr }

  if is-type(expr, "num") or is-type(expr, "var") or is-type(expr, "const") {
    return expr
  }

  if is-type(expr, "neg") {
    return neg(_apply(expr.arg, assumptions))
  }

  if is-type(expr, "add") {
    return add(_apply(expr.args.at(0), assumptions), _apply(expr.args.at(1), assumptions))
  }

  if is-type(expr, "mul") {
    return mul(_apply(expr.args.at(0), assumptions), _apply(expr.args.at(1), assumptions))
  }

  if is-type(expr, "div") {
    return cdiv(_apply(expr.num, assumptions), _apply(expr.den, assumptions))
  }

  if is-type(expr, "pow") {
    let base = _apply(expr.base, assumptions)
    let exp = _apply(expr.exp, assumptions)

    // sqrt(x^2) simplification under assumptions.
    if is-type(exp, "div") and is-type(exp.num, "num") and is-type(exp.den, "num") {
      if exp.num.val == 1 and exp.den.val == 2 and is-type(base, "pow") and is-type(base.exp, "num") and base.exp.val == 2 {
        let inner = base.base
        if _is-positive-var(inner, assumptions) {
          return inner
        }
        if _is-real-var(inner, assumptions) {
          return func("abs", inner)
        }
      }
    }

    return pow(base, exp)
  }

  if is-type(expr, "func") {
    let args = func-args(expr).map(a => _apply(a, assumptions))
    let unary = args.len() == 1
    let cname = fn-canonical(expr.name)

    if unary and cname == "abs" {
      let arg = args.at(0)
      if _is-positive-var(arg, assumptions) {
        return arg
      }
      if _is-negative-var(arg, assumptions) {
        return neg(arg)
      }
    }

    return func(expr.name, ..args)
  }

  if is-type(expr, "log") {
    return (type: "log", base: _apply(expr.base, assumptions), arg: _apply(expr.arg, assumptions))
  }

  if is-type(expr, "sum") {
    return (
      type: "sum",
      body: _apply(expr.body, assumptions),
      idx: expr.idx,
      from: _apply(expr.from, assumptions),
      to: _apply(expr.to, assumptions),
    )
  }

  if is-type(expr, "prod") {
    return (
      type: "prod",
      body: _apply(expr.body, assumptions),
      idx: expr.idx,
      from: _apply(expr.from, assumptions),
      to: _apply(expr.to, assumptions),
    )
  }

  expr
}

/// Public helper `apply-assumptions`.
#let apply-assumptions(expr, assumptions) = _apply(expr, assumptions)
