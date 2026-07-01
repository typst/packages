// =========================================================================
// typcas v2 Integration Method Analyzer
// =========================================================================
// Shared method selection between:
// - core integrator
// - step-by-step integration trace
// =========================================================================

#import "../expr.typ": *
#import "../simplify.typ": simplify
#import "../core/expr-walk.typ": contains-var as _contains-var-core
#import "../truths/function-registry.typ": fn-spec, fn-square-power-integral-spec
#import "../poly.typ": partial-fractions as poly-partial-fractions
#import "diff.typ": diff

#let _contains-var(expr, v) = _contains-var-core(expr, v)
#let _is-const-wrt(expr, v) = not _contains-var(expr, v)
#let _is-zero(expr) = is-type(expr, "num") and expr.val == 0
#let _is-one(expr) = is-type(expr, "num") and expr.val == 1

/// Match denominator of the form (1 + u²) where u is linear in var.
/// Returns (u, du) or none.
#let _match-one-plus-u-squared(den, var) = {
  if not is-type(den, "add") { return none }
  let a = den.args.at(0)
  let b = den.args.at(1)
  let sq-part = if is-type(a, "num") and a.val == 1 { b }
                else if is-type(b, "num") and b.val == 1 { a }
                else { return none }
  if not is-type(sq-part, "pow") { return none }
  if not (is-type(sq-part.exp, "num") and sq-part.exp.val == 2) { return none }
  let u = sq-part.base
  if not _contains-var(u, var) { return none }
  let du = simplify(diff(u, var))
  if _is-zero(du) or not _is-const-wrt(du, var) { return none }
  (u: u, du: du)
}

/// Match radicand of the form (1 - u²) where u is linear in var.
/// Returns (u, du) or none.
#let _match-one-minus-u-squared(inner, var) = {
  if not is-type(inner, "add") { return none }
  let a = inner.args.at(0)
  let b = inner.args.at(1)
  let (one-found, other) = if is-type(a, "num") and a.val == 1 { (true, b) }
                            else if is-type(b, "num") and b.val == 1 { (true, a) }
                            else { (false, none) }
  if not one-found { return none }
  // other should be neg(u²) or num(-1)*u²
  let sq-part = if is-type(other, "neg") { other.arg }
                else if is-type(other, "mul") {
                  let l = other.args.at(0)
                  let r = other.args.at(1)
                  if is-type(l, "num") and l.val == -1 { r }
                  else if is-type(r, "num") and r.val == -1 { l }
                  else { return none }
                }
                else { return none }
  if not is-type(sq-part, "pow") { return none }
  if not (is-type(sq-part.exp, "num") and sq-part.exp.val == 2) { return none }
  let u = sq-part.base
  if not _contains-var(u, var) { return none }
  let du = simplify(diff(u, var))
  if _is-zero(du) or not _is-const-wrt(du, var) { return none }
  (u: u, du: du)
}

#let _is-polynomial-power(expr, v) = {
  return (
    is-type(expr, "pow")
      and is-type(expr.base, "var")
      and expr.base.name == v
      and is-type(expr.exp, "num")
      and type(expr.exp.val) == int
  )
}

#let _drop-power-one(expr) = {
  if is-type(expr, "pow") and is-type(expr.exp, "num") and expr.exp.val == 1 {
    return expr.base
  }
  expr
}

#let _flatten-mul(expr) = {
  if is-type(expr, "mul") {
    return _flatten-mul(expr.args.at(0)) + _flatten-mul(expr.args.at(1))
  }
  (expr,)
}

#let _prod(factors) = {
  if factors.len() == 0 { return num(1) }
  let out = factors.at(0)
  let i = 1
  while i < factors.len() {
    out = mul(out, factors.at(i))
    i += 1
  }
  simplify(out)
}

#let _subset-index-tuples(n, i: 0, picked: ()) = {
  if i == n {
    if picked.len() == 0 { return () }
    return (picked,)
  }
  _subset-index-tuples(n, i: i + 1, picked: picked) + _subset-index-tuples(n, i: i + 1, picked: picked + (i,))
}

#let _index-picked(idxs, i) = idxs.find(j => j == i) != none

#let _subset-factors(factors, idxs, select: true) = {
  let out = ()
  for (i, f) in factors.enumerate() {
    let hit = _index-picked(idxs, i)
    if (select and hit) or ((not select) and (not hit)) {
      out.push(f)
    }
  }
  out
}

#let _without-index(items, idx) = {
  let out = ()
  for (i, x) in items.enumerate() {
    if i != idx { out.push(x) }
  }
  out
}

#let _all-const-wrt(factors, v) = {
  for f in factors {
    if not _is-const-wrt(f, v) { return false }
  }
  true
}

#let _is-unary-on-var(expr, v) = {
  (
    is-type(expr, "func")
      and func-args(expr).len() == 1
      and is-type(expr.arg, "var")
      and expr.arg.name == v
  ) or (
    is-type(expr, "log")
      and is-type(expr.arg, "var")
      and expr.arg.name == v
  )
}

#let _trim-unit-factors(factors) = {
  let out = ()
  for f in factors {
    let s = simplify(f)
    if not _is-one(s) { out.push(s) }
  }
  out
}

#let _try-usub-mul(expr, v) = {
  if not is-type(expr, "mul") { return none }

  let factors = _trim-unit-factors(_flatten-mul(expr))
  if factors.len() < 2 or factors.len() > 10 { return none }

  for (outer-i, outer) in factors.enumerate() {
    if not is-type(outer, "func") or func-args(outer).len() != 1 { continue }

    let spec = fn-spec(outer.name)
    if spec == none or spec.calculus == none or spec.calculus.integ == none { continue }

    let u = outer.arg
    let du = simplify(diff(u, v))
    if _is-zero(du) { continue }

    let rest = _without-index(factors, outer-i)
    if rest.len() == 0 { continue }

    let matches = ()
    for idxs in _subset-index-tuples(rest.len()) {
      let du-factors = _subset-factors(rest, idxs, select: true)
      let rem-factors = _subset-factors(rest, idxs, select: false)
      let du-cand = _prod(du-factors)

      if expr-eq(du-cand, du) and _all-const-wrt(rem-factors, v) {
        matches.push((coeff: _prod(rem-factors),))
      }
    }

    // Conservative: accept only unique exact du match.
    if matches.len() == 1 {
      return (
        u: u,
        du: du,
        coeff: matches.at(0).coeff,
        outer-name: outer.name,
        antideriv: spec.calculus.integ,
      )
    }
  }
  none
}

#let _registry-by-parts-x(func-expr, v) = {
  if not _is-unary-on-var(func-expr, v) { return none }
  if is-type(func-expr, "log") {
    // ∫ x·log_b(x) dx = [ (x²/2)·ln(x) − x²/4 ] / ln(b)
    let core = sub(mul(cdiv(pow(cvar(v), num(2)), num(2)), ln-of(cvar(v))), cdiv(pow(cvar(v), num(2)), num(4)))
    if is-const-e(func-expr.base) { return core }
    return cdiv(core, ln-of(func-expr.base))
  }
  let spec = fn-spec(func-expr.name)
  if spec == none { return none }
  let hints = spec.at("hints", default: none)
  if hints == none { return none }
  let builder = hints.at("by-parts-x", default: none)
  if builder == none { return none }
  builder(v)
}

#let _direct-primitive-on-var(func-expr, v) = {
  if not _is-unary-on-var(func-expr, v) { return none }
  if is-type(func-expr, "log") {
    // ∫ log_b(x) dx = (x·ln(x) − x) / ln(b)
    let core = sub(mul(cvar(v), ln-of(cvar(v))), cvar(v))
    if is-const-e(func-expr.base) { return core }
    return cdiv(core, ln-of(func-expr.base))
  }
  let spec = fn-spec(func-expr.name)
  if spec == none { return none }
  let hints = spec.at("hints", default: none)
  if hints != none {
    let direct = hints.at("direct-integral-var", default: none)
    if direct != none { return direct(v) }
  }
  if spec.calculus != none and spec.calculus.integ != none {
    return (spec.calculus.integ)(cvar(v))
  }
  none
}

#let _affine-ax-plus-b(expr, v) = {
  if is-type(expr, "num") { return (a: 0.0, b: expr.val + 0.0) }
  if is-type(expr, "var") and expr.name == v { return (a: 1.0, b: 0.0) }
  if is-type(expr, "neg") {
    let p = _affine-ax-plus-b(expr.arg, v)
    if p == none { return none }
    return (a: -p.a, b: -p.b)
  }
  if is-type(expr, "add") {
    let p = _affine-ax-plus-b(expr.args.at(0), v)
    let q = _affine-ax-plus-b(expr.args.at(1), v)
    if p == none or q == none { return none }
    return (a: p.a + q.a, b: p.b + q.b)
  }
  if is-type(expr, "mul") {
    if is-type(expr.args.at(0), "num") {
      let p = _affine-ax-plus-b(expr.args.at(1), v)
      if p == none { return none }
      return (a: expr.args.at(0).val * p.a, b: expr.args.at(0).val * p.b)
    }
    if is-type(expr.args.at(1), "num") {
      let p = _affine-ax-plus-b(expr.args.at(0), v)
      if p == none { return none }
      return (a: expr.args.at(1).val * p.a, b: expr.args.at(1).val * p.b)
    }
  }
  none
}

#let _by-parts-result(expr, v) = {
  if not is-type(expr, "mul") { return none }
  let a = expr.args.at(0)
  let b = expr.args.at(1)

  if is-type(a, "var") and a.name == v {
    let hinted = _registry-by-parts-x(b, v)
    if hinted != none { return hinted }
  }

  if is-type(b, "var") and b.name == v {
    let hinted = _registry-by-parts-x(a, v)
    if hinted != none { return hinted }
  }

  let lin-a = _affine-ax-plus-b(a, v)
  if lin-a != none and calc.abs(lin-a.a) > 0 and _is-unary-on-var(b, v) {
    let hinted = _registry-by-parts-x(b, v)
    if hinted != none {
      let lead = if lin-a.a == 1 { hinted } else { mul(num(lin-a.a), hinted) }
      if lin-a.b == 0 { return simplify(lead) }
      let direct = _direct-primitive-on-var(b, v)
      if direct != none {
        return simplify(add(lead, mul(num(lin-a.b), direct)))
      }
    }
  }

  let lin-b = _affine-ax-plus-b(b, v)
  if lin-b != none and calc.abs(lin-b.a) > 0 and _is-unary-on-var(a, v) {
    let hinted = _registry-by-parts-x(a, v)
    if hinted != none {
      let lead = if lin-b.a == 1 { hinted } else { mul(num(lin-b.a), hinted) }
      if lin-b.b == 0 { return simplify(lead) }
      let direct = _direct-primitive-on-var(a, v)
      if direct != none {
        return simplify(add(lead, mul(num(lin-b.b), direct)))
      }
    }
  }

  none
}

#let _partial-fractions-result(expr, v) = {
  if not is-type(expr, "div") { return none }
  let decomposed = simplify(poly-partial-fractions(expr, v))
  if not expr-eq(decomposed, expr) { return decomposed }
  none
}

#let _mk(kind, expr, var, data: (:)) = (
  kind: kind,
  expr: expr,
  var: var,
  data: data,
)

/// Shared integration method analyzer.
#let analyze-integral(expr, var) = {
  let raw = expr
  let e = simplify(expr)

  if _is-const-wrt(e, var) { return _mk("const", e, var, data: (const: e)) }

  if is-type(e, "var") and e.name == var {
    return _mk("var", e, var)
  }

  if is-type(e, "add") {
    return _mk("add", e, var, data: (left: e.args.at(0), right: e.args.at(1)))
  }

  if is-type(e, "neg") {
    return _mk("neg", e, var, data: (inner: e.arg))
  }

  // Prefer raw multiplication shape to avoid over-collapsing factors.
  let mul-src = if is-type(raw, "mul") { raw } else { e }
  if is-type(mul-src, "mul") {
    let a = mul-src.args.at(0)
    let b = mul-src.args.at(1)

    if _is-const-wrt(a, var) {
      return _mk("const-factor", mul-src, var, data: (const: a, inner: b))
    }
    if _is-const-wrt(b, var) {
      return _mk("const-factor", mul-src, var, data: (const: b, inner: a))
    }

    let usub = _try-usub-mul(mul-src, var)
    if usub != none {
      return _mk("u-sub", mul-src, var, data: usub)
    }

    let parts = _by-parts-result(mul-src, var)
    if parts != none {
      return _mk("by-parts", mul-src, var, data: (result: parts))
    }
  }

  if _is-polynomial-power(e, var) {
    let n = e.exp.val
    if n != -1 {
      return _mk("power", e, var, data: (n: n))
    }
  }

  if is-type(e, "div") {
    if is-type(e.num, "num") and e.num.val == 1 and is-type(e.den, "var") and e.den.name == var {
      return _mk("reciprocal", e, var)
    }

    // 1/(1 + u²) → arctan(u) / u'
    if _is-one(simplify(e.num)) {
      let den = simplify(e.den)
      let m = _match-one-plus-u-squared(den, var)
      if m != none {
        let is-direct = is-type(m.u, "var") and m.u.name == var
        return _mk("func-primitive", e, var, data: (u: m.u, du: m.du, antideriv: u => arctan-of(u), direct: is-direct))
      }
    }

    // 1/sqrt(1 - u²) → arcsin(u) / u'
    if _is-one(simplify(e.num)) {
      let den = simplify(e.den)
      if is-type(den, "pow") and is-type(den.exp, "div") {
        let en = den.exp.num
        let ed = den.exp.den
        if is-type(en, "num") and en.val == 1 and is-type(ed, "num") and ed.val == 2 {
          let m = _match-one-minus-u-squared(simplify(den.base), var)
          if m != none {
            let is-direct = is-type(m.u, "var") and m.u.name == var
            return _mk("func-primitive", e, var, data: (u: m.u, du: m.du, antideriv: u => arcsin-of(u), direct: is-direct))
          }
        }
      }
      // Also handle den = (1 - u²)^(1/2) stored as float exponent 0.5
      if is-type(den, "pow") and is-type(den.exp, "num") and den.exp.val == 0.5 {
        let m = _match-one-minus-u-squared(simplify(den.base), var)
        if m != none {
          let is-direct = is-type(m.u, "var") and m.u.name == var
          return _mk("func-primitive", e, var, data: (u: m.u, du: m.du, antideriv: u => arcsin-of(u), direct: is-direct))
        }
      }
    }

    let pf = _partial-fractions-result(e, var)
    if pf != none {
      return _mk("partial-fraction", e, var, data: (result: pf))
    }
  }

  // ∫ log_b(x) dx = (x·ln(x) − x) / ln(b)   (= x·ln(x) − x for base e)
  if is-type(e, "log") and is-type(e.arg, "var") and e.arg.name == var {
    let prim = sub(mul(cvar(var), ln-of(cvar(var))), cvar(var))
    if is-const-e(e.base) {
      return _mk("by-parts", e, var, data: (result: prim))
    }
    return _mk("by-parts", e, var, data: (result: cdiv(prim, ln-of(e.base))))
  }

  if is-type(e, "func") and func-args(e).len() == 1 {
    let u = e.arg
    let spec = fn-spec(e.name)

    if spec != none and is-type(u, "var") and u.name == var {
      let hints = spec.at("hints", default: none)
      if hints != none {
        let direct = hints.at("direct-integral-var", default: none)
        if direct != none {
          return _mk("by-parts", e, var, data: (result: direct(var)))
        }
      }
    }

    if spec != none and spec.calculus != none and spec.calculus.integ != none {
      let du = simplify(diff(u, var))
      if is-type(u, "var") and u.name == var {
        return _mk("func-primitive", e, var, data: (u: u, du: du, antideriv: spec.calculus.integ, direct: true))
      }
      if _is-const-wrt(du, var) and not _is-zero(du) {
        return _mk("func-primitive", e, var, data: (u: u, du: du, antideriv: spec.calculus.integ, direct: false))
      }
    }
  }

  let is-square-family = (
    is-type(e, "pow")
      and is-type(e.base, "func")
      and is-type(e.exp, "num")
      and e.exp.val == 2
      and func-args(e.base).len() == 1
  )
  if is-square-family {
    let u = e.base.arg
    let spec = fn-square-power-integral-spec(e.base.name)
    if spec != none {
      let du = simplify(diff(u, var))
      if (is-type(u, "var") and u.name == var) or (_is-const-wrt(du, var) and not _is-zero(du)) {
        return _mk("square-family", e, var, data: (u: u, du: du, antideriv: spec.antideriv))
      }
    }
  }

  _mk("fallback", e, var, data: (expr: _drop-power-one(e)))
}
