// =========================================================================
// typcas v2 Advanced Calculus Helpers
// =========================================================================

#import "../expr.typ": *
#import "../simplify.typ": simplify
#import "../eval-num.typ": eval-expr, substitute
#import "../poly.typ": poly-coeffs
#import "../core/expr-walk.typ": contains-var as _contains-var-core
#import "diff.typ": diff
#import "integrate.typ": integrate

#let _contains-var(expr, v) = _contains-var-core(expr, v)

#let _fact(n) = {
  let m = int(n)
  if m <= 1 { return 1 }
  let out = 1
  let i = 2
  while i <= m {
    out *= i
    i += 1
  }
  out
}

#let _is-inf-symbol(expr) = {
  if is-type(expr, "const") and (expr.name == "inf" or expr.name == "infinity") { return true }
  if is-type(expr, "var") and (expr.name == "inf" or expr.name == "infinity") { return true }
  false
}

#let _normalize-limit-target(target) = {
  if type(target) == dictionary and target.at("type", default: none) == "limit-target" {
    return (
      type: "limit-target",
      point: target.at("point", default: num(0)),
      side: target.at("side", default: "two-sided"),
      infinity: target.at("infinity", default: 0),
    )
  }

  if type(target) == str {
    let t = target.trim()
    if t == "inf" or t == "+inf" or t == "infinity" or t == "+infinity" or t == "∞" or t == "+∞" {
      return (type: "limit-target", point: const-expr("inf"), side: "two-sided", infinity: 1)
    }
    if t == "-inf" or t == "-infinity" or t == "-∞" {
      return (type: "limit-target", point: neg(const-expr("inf")), side: "two-sided", infinity: -1)
    }
    return (type: "limit-target", point: cvar(t), side: "two-sided", infinity: 0)
  }

  if _is-inf-symbol(target) {
    return (type: "limit-target", point: const-expr("inf"), side: "two-sided", infinity: 1)
  }
  if is-type(target, "neg") and _is-inf-symbol(target.arg) {
    return (type: "limit-target", point: neg(const-expr("inf")), side: "two-sided", infinity: -1)
  }

  (type: "limit-target", point: target, side: "two-sided", infinity: 0)
}

#let _target-sign(target) = if target.infinity < 0 { -1.0 } else { 1.0 }

#let _trim-coeffs(coeffs) = {
  let c = coeffs
  while c.len() > 1 and c.at(c.len() - 1) == 0 {
    c = c.slice(0, c.len() - 1)
  }
  c
}

#let _rational-infinity-limit(expr, v, target) = {
  if target.infinity == 0 { return none }
  if not is-type(expr, "div") { return none }

  let nc = poly-coeffs(expr.num, v)
  let dc = poly-coeffs(expr.den, v)
  if nc == none or dc == none { return none }

  let n = _trim-coeffs(nc)
  let d = _trim-coeffs(dc)
  let dn = n.len() - 1
  let dd = d.len() - 1
  if dd < 0 { return none }

  if dn < dd { return num(0) }
  if dn == dd {
    let ln = n.at(dn)
    let ld = d.at(dd)
    if ld == 0 { return none }
    return num(ln / ld)
  }

  let lead = n.at(dn) / d.at(dd)
  let parity = calc.rem(dn - dd, 2)
  let sign = if parity == 0 { if lead >= 0 { 1 } else { -1 } } else {
    let s = _target-sign(target)
    if s * lead >= 0 { 1 } else { -1 }
  }
  if sign > 0 { return const-expr("inf") }
  neg(const-expr("inf"))
}

#let _is-zero-at(expr, v, a) = {
  let s = simplify(substitute(expr, v, a))
  is-type(s, "num") and s.val == 0
}

#let _limit-trig-standard(expr, v, a) = {
  if not is-type(a, "num") or a.val != 0 { return none }

  // sin(u)/u -> 1 when u->0
  if is-type(expr, "div") and is-type(expr.num, "func") and func-args(expr.num).len() == 1 {
    let uname = expr.num.name
    let u = expr.num.arg
    if (uname == "sin" or uname == "tan") and expr-eq(simplify(u), simplify(expr.den)) and _is-zero-at(u, v, a) {
      return num(1)
    }
  }

  // (1-cos(u))/u^2 -> 1/2 when u->0
  if is-type(expr, "div") and is-type(expr.den, "pow") and is-type(expr.den.exp, "num") and expr.den.exp.val == 2 {
    let u = expr.den.base
    if _is-zero-at(u, v, a) and is-type(expr.num, "add") {
      let l = expr.num.args.at(0)
      let r = expr.num.args.at(1)
      let cos-term = if is-type(l, "neg") and is-type(l.arg, "func") and l.arg.name == "cos" { l.arg } else if is-type(r, "neg") and is-type(r.arg, "func") and r.arg.name == "cos" { r.arg } else { none }
      let one-term = if is-type(l, "num") and l.val == 1 { l } else if is-type(r, "num") and r.val == 1 { r } else { none }
      if cos-term != none and one-term != none and expr-eq(simplify(cos-term.arg), simplify(u)) {
        return cdiv(num(1), num(2))
      }
    }
  }

  none
}

#let diff-n(expr, v, n) = {
  let out = expr
  let i = 0
  while i < n {
    out = simplify(diff(out, v))
    i += 1
  }
  out
}

#let definite-integral(expr, v, a, b) = {
  let anti = simplify(integrate(expr, v))
  let av = simplify(substitute(anti, v, a))
  let bv = simplify(substitute(anti, v, b))
  simplify(sub(bv, av))
}

#let taylor(expr, v, x0, n) = {
  let x = cvar(v)
  let out = num(0)
  let k = 0
  while k <= n {
    let dk = diff-n(expr, v, k)
    let c = simplify(cdiv(substitute(dk, v, x0), num(_fact(k))))
    let term = if k == 0 { c } else { mul(c, pow(sub(x, x0), num(k))) }
    out = simplify(add(out, term))
    k += 1
  }
  out
}

#let limit(expr, v, a) = {
  let target = _normalize-limit-target(a)
  let s = simplify(expr)

  if target.infinity != 0 {
    let rational = _rational-infinity-limit(s, v, target)
    if rational != none { return simplify(rational) }

    // Numeric fallback at large magnitude for unresolved forms.
    let base = if target.infinity < 0 { -1e6 } else { 1e6 }
    let l = eval-expr(substitute(s, v, num(base)), (:))
    let r = eval-expr(substitute(s, v, num(base * 2.0)), (:))
    if l != none and r != none and type(l) != dictionary and type(r) != dictionary and calc.abs(l - r) < 1e-3 * (1 + calc.abs(r)) {
      return num((l + r) / 2.0)
    }

    return (type: "limit", expr: s, var: v, to: target.point, side: target.side)
  }

  let point = target.point
  let direct = simplify(substitute(s, v, point))

  // Trig standard forms around 0.
  let trig = _limit-trig-standard(s, v, point)
  if trig != none { return simplify(trig) }

  // Handle quotient limits directly from the original symbolic quotient
  // so L'Hospital differentiates pre-substitution numerator/denominator.
  if is-type(s, "div") and is-type(point, "num") {
    let cur-num = s.num
    let cur-den = s.den
    let step = 0
    while step < 6 {
      let n0 = simplify(substitute(cur-num, v, point))
      let d0 = simplify(substitute(cur-den, v, point))
      if is-type(n0, "num") and is-type(d0, "num") {
        if d0.val != 0 {
          return simplify(cdiv(n0, d0))
        }
        if n0.val == 0 and d0.val == 0 {
          cur-num = simplify(diff(cur-num, v))
          cur-den = simplify(diff(cur-den, v))
          step += 1
          continue
        }
      }
      break
    }
  }

  if not _contains-var(direct, v) { return direct }

  // Numeric fallback.
  if is-type(point, "num") {
    let av = point.val + 0.0
    let h = 1e-6

    if target.side == "left" {
      let left = eval-expr(substitute(s, v, num(av - h)), (:))
      if left != none and type(left) != dictionary { return num(left) }
    }
    if target.side == "right" {
      let right = eval-expr(substitute(s, v, num(av + h)), (:))
      if right != none and type(right) != dictionary { return num(right) }
    }

    let l = eval-expr(substitute(s, v, num(av - h)), (:))
    let r = eval-expr(substitute(s, v, num(av + h)), (:))
    if l != none and r != none and type(l) != dictionary and type(r) != dictionary {
      return num((l + r) / 2.0)
    }
  }

  (type: "limit", expr: s, var: v, to: point, side: target.side)
}

#let implicit-diff(expr, x, y) = {
  // For F(x,y)=0, dy/dx = -Fx/Fy
  let fx = simplify(diff(expr, x))
  let fy = simplify(diff(expr, y))
  simplify(neg(cdiv(fx, fy)))
}
