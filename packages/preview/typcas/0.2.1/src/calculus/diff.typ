// =========================================================================
// typcas v2 Differentiation
// =========================================================================

#import "../expr.typ": *
#import "../simplify.typ": simplify
#import "../core/expr-walk.typ": contains-var as _contains-var-core
#import "../truths/function-registry.typ": fn-spec, fn-canonical

#let _contains-var(expr, v) = _contains-var-core(expr, v)

#let _nest-variadic(name, args) = {
  if args.len() == 0 { return func(name) }
  if args.len() == 1 { return func(name, args.at(0)) }
  let out = func(name, args.at(0), args.at(1))
  let i = 2
  while i < args.len() {
    out = func(name, out, args.at(i))
    i += 1
  }
  out
}

#let _diff-key(expr, v) = v + ":" + repr(expr)

#let _diff-core(expr, v, memo) = {
  let key = _diff-key(expr, v)
  if key in memo { return memo.at(key) }

  let out = {
    if is-type(expr, "num") or is-type(expr, "const") { return num(0) }
    if is-type(expr, "var") { return if expr.name == v { num(1) } else { num(0) } }

    if is-type(expr, "neg") {
      return simplify(neg(_diff-core(expr.arg, v, memo)))
    }

    if is-type(expr, "add") {
      return simplify(add(_diff-core(expr.args.at(0), v, memo), _diff-core(expr.args.at(1), v, memo)))
    }

    if is-type(expr, "mul") {
      let f = expr.args.at(0)
      let g = expr.args.at(1)
      return simplify(add(mul(_diff-core(f, v, memo), g), mul(f, _diff-core(g, v, memo))))
    }

    if is-type(expr, "div") {
      let n = expr.num
      let d = expr.den
      return simplify(cdiv(sub(mul(_diff-core(n, v, memo), d), mul(n, _diff-core(d, v, memo))), pow(d, num(2))))
    }

    if is-type(expr, "pow") {
      let b = expr.base
      let e = expr.exp

      // u^n
      if is-type(e, "num") {
        return simplify(mul(mul(e, pow(b, sub(e, num(1)))), _diff-core(b, v, memo)))
      }
      // a^u
      if is-type(b, "num") {
        return simplify(mul(mul(pow(b, e), ln-of(b)), _diff-core(e, v, memo)))
      }
      // u^v = u^v * (v' ln u + v u'/u)
      return simplify(mul(pow(b, e), add(mul(_diff-core(e, v, memo), ln-of(b)), mul(e, cdiv(_diff-core(b, v, memo), b)))))
    }

    if is-type(expr, "log") {
      // d/dx log_b(u) = d/dx ln(u)/ln(b)
      return simplify(_diff-core(cdiv(ln-of(expr.arg), ln-of(expr.base)), v, memo))
    }

    if is-type(expr, "func") {
      let args = func-args(expr)
      let cname = fn-canonical(expr.name)

      // Non-smooth functions get explicit piecewise derivatives with boundary fallback.
      if cname == "abs" and args.len() == 1 {
        let u = args.at(0)
        let du = _diff-core(u, v, memo)
        let fallback = func("diff_" + v, expr)
        return simplify(piecewise((
          (du, cond-rel(u, ">", num(0))),
          (neg(du), cond-rel(u, "<", num(0))),
          (fallback, none),
        )))
      }

      if cname == "sign" and args.len() == 1 {
        let u = args.at(0)
        let fallback = func("diff_" + v, expr)
        return simplify(piecewise((
          (num(0), cond-rel(u, "!=", num(0))),
          (fallback, none),
        )))
      }

      if (cname == "min" or cname == "max") and args.len() >= 2 {
        if args.len() > 2 {
          return _diff-core(_nest-variadic(cname, args), v, memo)
        }
        let a = args.at(0)
        let b = args.at(1)
        let da = _diff-core(a, v, memo)
        let db = _diff-core(b, v, memo)
        let c1 = if cname == "min" { cond-rel(a, "<", b) } else { cond-rel(a, ">", b) }
        let c2 = if cname == "min" { cond-rel(b, "<", a) } else { cond-rel(b, ">", a) }
        let fallback = func("diff_" + v, expr)
        return simplify(piecewise((
          (da, c1),
          (db, c2),
          (fallback, none),
        )))
      }

      if cname == "clamp" and args.len() == 3 {
        let x = args.at(0)
        let lo = args.at(1)
        let hi = args.at(2)
        let dx = _diff-core(x, v, memo)
        let dlo = _diff-core(lo, v, memo)
        let dhi = _diff-core(hi, v, memo)
        let middle = cond-and(cond-rel(x, ">", lo), cond-rel(x, "<", hi))
        let fallback = func("diff_" + v, expr)
        return simplify(piecewise((
          (dlo, cond-rel(x, "<", lo)),
          (dx, middle),
          (dhi, cond-rel(x, ">", hi)),
          (fallback, none),
        )))
      }

      let spec = fn-spec(expr.name)
      if spec != none and spec.calculus != none and spec.calculus.diff != none and args.len() == 1 {
        let u = args.at(0)
        let du = _diff-core(u, v, memo)
        let outer = (spec.calculus.diff)(u)
        if is-type(du, "num") and du.val == 1 { return simplify(outer) }
        return simplify(mul(outer, du))
      }
      return func("diff_" + v, expr)
    }

    if is-type(expr, "sum") {
      if expr.idx == v { return num(0) }
      return csum(_diff-core(expr.body, v, memo), expr.idx, expr.from, expr.to)
    }
    if is-type(expr, "prod") {
      if expr.idx == v { return num(0) }
      return cprod(_diff-core(expr.body, v, memo), expr.idx, expr.from, expr.to)
    }

    if is-type(expr, "integral") {
      if expr.var == v { return expr.expr }
      return (type: "integral", expr: _diff-core(expr.expr, v, memo), var: expr.var)
    }
    if is-type(expr, "def-integral") {
      if expr.var == v { return num(0) }
      return (type: "def-integral", expr: _diff-core(expr.expr, v, memo), var: expr.var, lo: expr.lo, hi: expr.hi)
    }

    if is-type(expr, "matrix") {
      return cmat(expr.rows.map(row => row.map(x => _diff-core(x, v, memo))))
    }
    if is-type(expr, "piecewise") {
      return piecewise(expr.cases.map(c => (_diff-core(c.at(0), v, memo), c.at(1))))
    }
    if is-type(expr, "complex") {
      return (type: "complex", re: _diff-core(expr.re, v, memo), im: _diff-core(expr.im, v, memo))
    }

    func("diff_" + v, expr)
  }

  memo.insert(key, out)
  out
}

#let diff(expr, v) = _diff-core(expr, v, (:))
