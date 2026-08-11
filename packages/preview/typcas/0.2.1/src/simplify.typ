// =========================================================================
// typcas v2 Simplification Engine
// =========================================================================
// Native v2 fixed-point simplifier:
// 1) recursive algebraic simplification
// 2) canonical ordering
// 3) identity-table rewrite pass
// =========================================================================

#import "expr.typ": *
#import "rational.typ": rat, rat-add, rat-div, rat-eq, rat-from-expr, rat-is-one, rat-is-zero, rat-mul, rat-neg, rat-sub, rat-to-expr
#import "identities.typ": apply-identities-once-meta
#import "truths/function-registry.typ": fn-canonical
#import "restrictions.typ": collect-structural-restrictions, collect-function-restrictions, merge-restrictions, filter-restrictions-by-assumptions

// --- Internal helpers ---

/// Check if expr is num(0)
#let _is-zero(e) = is-type(e, "num") and e.val == 0

/// Check if expr is num(1)
#let _is-one(e) = is-type(e, "num") and e.val == 1

/// Check if expr is a numeric literal
#let _is-num(e) = is-type(e, "num")

/// Try to parse an expression as an exact rational.
#let _as-rat(e) = rat-from-expr(e)

/// Stable complexity rank for canonical ordering.
#let _expr-rank(e) = {
  if is-type(e, "var") and e.name == "C" { return 99 } // transitional compat: legacy var("C")
  if is-type(e, "const") and e.name == "C" { return 99 } // keep +C at end
  if is-type(e, "pow") and is-type(e.base, "var") { return 0 }
  if is-type(e, "var") { return 1 }
  if is-type(e, "mul") or is-type(e, "div") { return 2 }
  if is-type(e, "func") or is-type(e, "log") { return 3 }
  if is-type(e, "pow") { return 4 }
  if is-type(e, "const") { return 5 }
  if is-type(e, "num") { return 6 }
  7
}

/// Internal helper `_expr-key`.
#let _expr-key(e) = repr(e)

/// Internal helper `_is-func-canonical`.
#let _is-func-canonical(expr, canonical) = is-type(expr, "func") and fn-canonical(expr.name) == canonical

/// Internal helper `_var-degree`.
#let _var-degree(term) = {
  let t = if is-type(term, "neg") { term.arg } else { term }
  if is-type(t, "var") and t.name != "C" {
    return (name: t.name, deg: 1)
  }
  if is-type(t, "pow") and is-type(t.base, "var") and t.base.name != "C" and is-type(t.exp, "num") and type(t.exp.val) == int {
    return (name: t.base.name, deg: t.exp.val)
  }
  if is-type(t, "mul") {
    let l = _var-degree(t.args.at(0))
    let r = _var-degree(t.args.at(1))
    if l != none and r == none { return l }
    if r != none and l == none { return r }
  }
  if is-type(t, "div") {
    let rd = _as-rat(t.den)
    if rd != none and not rat-is-zero(rd) { return _var-degree(t.num) }
  }
  none
}

/// Internal helper `_before-expr`.
#let _before-expr(a, b) = {
  let da = _var-degree(a)
  let db = _var-degree(b)
  if da != none and db != none and da.name == db.name {
    if da.deg > db.deg { return true }
    if da.deg < db.deg { return false }
  }

  let ra = _expr-rank(a)
  let rb = _expr-rank(b)
  if ra < rb { return true }
  if ra > rb { return false }
  _expr-key(a) < _expr-key(b)
}

/// Internal helper `_extract-k-ln`.
#let _extract-k-ln(term) = {
  let t = term
  let sign = rat(1, 1)
  if is-type(t, "neg") {
    sign = rat(-1, 1)
    t = t.arg
  }
  if _is-func-canonical(t, "ln") and func-arity(t) == 1 {
    return (k: sign, arg: func-args(t).at(0))
  }
  if is-type(t, "mul") {
    let l = t.args.at(0)
    let r = t.args.at(1)
    let rl = _as-rat(l)
    if rl != none and _is-func-canonical(r, "ln") and func-arity(r) == 1 {
      return (k: rat-mul(sign, rl), arg: func-args(r).at(0))
    }
    let rr = _as-rat(r)
    if rr != none and _is-func-canonical(l, "ln") and func-arity(l) == 1 {
      return (k: rat-mul(sign, rr), arg: func-args(l).at(0))
    }
  }
  if is-type(t, "div") {
    let rd = _as-rat(t.den)
    if rd != none and not rat-is-zero(rd) and _is-func-canonical(t.num, "ln") and func-arity(t.num) == 1 {
      let inv = rat-div(rat(1, 1), rd)
      if inv != none { return (k: rat-mul(sign, inv), arg: func-args(t.num).at(0)) }
    }
  }
  none
}

/// Internal helper `_insert-sorted`.
#let _insert-sorted(items, item) = {
  let out = ()
  let inserted = false
  for it in items {
    if not inserted and _before-expr(item, it) {
      out.push(item)
      inserted = true
    }
    out.push(it)
  }
  if not inserted { out.push(item) }
  out
}

/// Internal helper `_rat-abs`.
#let _rat-abs(r) = if r.n < 0 { rat-neg(r) } else { r }

/// Internal helper `_lcm-int`.
#let _lcm-int(a, b) = {
  if a == 0 or b == 0 { return 0 }
  int(calc.abs(a * b) / calc.gcd(a, b))
}

/// Internal helper `_rat-gcd-mag`.
#let _rat-gcd-mag(a, b) = {
  let aa = _rat-abs(a)
  let bb = _rat-abs(b)
  if rat-is-zero(aa) { return bb }
  if rat-is-zero(bb) { return aa }
  let gn = calc.gcd(int(calc.abs(aa.n)), int(calc.abs(bb.n)))
  let gd = _lcm-int(aa.d, bb.d)
  rat(gn, gd)
}

/// Internal helper `_scale-term`.
#let _scale-term(coeff, base) = {
  if expr-eq(base, num(1)) { return rat-to-expr(coeff) }
  if rat-eq(coeff, rat(1, 1)) { return base }
  if rat-eq(coeff, rat(-1, 1)) { return neg(base) }
  mul(rat-to-expr(coeff), base)
}

/// Flatten nested add trees into a list of terms.
#let _flatten-add(expr) = {
  if is-type(expr, "add") {
    return _flatten-add(expr.args.at(0)) + _flatten-add(expr.args.at(1))
  }
  (expr,)
}

/// Flatten nested multiplication trees into a list of factors.
#let _flatten-mul(expr) = {
  if is-type(expr, "mul") {
    return _flatten-mul(expr.args.at(0)) + _flatten-mul(expr.args.at(1))
  }
  (expr,)
}

/// Extract `(coeff, base)` from a term.
#let _get-coeff-and-base(expr) = {
  let r-all = _as-rat(expr)
  if r-all != none {
    return (r-all, num(1))
  }

  if is-type(expr, "neg") {
    let (c, b) = _get-coeff-and-base(expr.arg)
    if c != none { return (rat-neg(c), b) }
    return (rat(-1, 1), expr.arg)
  }

  if is-type(expr, "mul") {
    let factors = _flatten-mul(expr)
    let coeff = rat(1, 1)
    let symbolic = ()
    for f0 in factors {
      let f = if is-type(f0, "neg") {
        coeff = rat-neg(coeff)
        f0.arg
      } else {
        f0
      }
      let rf = _as-rat(f)
      if rf != none {
        coeff = rat-mul(coeff, rf)
      } else {
        symbolic.push(f)
      }
    }
    if symbolic.len() == 0 { return (coeff, num(1)) }
    let base = symbolic.at(0)
    let i = 1
    while i < symbolic.len() {
      base = mul(base, symbolic.at(i))
      i += 1
    }
    return (coeff, base)
  }

  if is-type(expr, "div") {
    let rd = _as-rat(expr.den)
    if rd != none and not rat-is-zero(rd) {
      let (cn, bn) = _get-coeff-and-base(expr.num)
      let q = rat-div(cn, rd)
      if q != none { return (q, bn) }
    }
  }

  (rat(1, 1), expr)
}

/// Internal helper `_factor-common-rat-add`.
#let _factor-common-rat-add(expr) = {
  if not is-type(expr, "add") { return none }
  let (c1, b1) = _get-coeff-and-base(expr.args.at(0))
  let (c2, b2) = _get-coeff-and-base(expr.args.at(1))
  if c1 == none or c2 == none { return none }
  let g = _rat-gcd-mag(c1, c2)
  if rat-is-zero(g) or rat-eq(g, rat(1, 1)) { return none }
  let q1 = rat-div(c1, g)
  let q2 = rat-div(c2, g)
  if q1 == none or q2 == none { return none }
  (k: g, rest: add(_scale-term(q1, b1), _scale-term(q2, b2)))
}

/// Collect like terms from a flat list of expressions.
#let _collect-like-terms(terms) = {
  let groups = ()

  for term in terms {
    let (coeff, base) = _get-coeff-and-base(term)
    let found = false
    let next = ()
    for g in groups {
      if not found and expr-eq(g.base, base) {
        next.push((coeff: rat-add(g.coeff, coeff), base: base))
        found = true
      } else {
        next.push(g)
      }
    }
    if not found { next.push((coeff: coeff, base: base)) }
    groups = next
  }

  let result = ()
  for g in groups {
    if rat-is-zero(g.coeff) { continue }
    let term = if expr-eq(g.base, num(1)) {
      rat-to-expr(g.coeff)
    } else {
      _scale-term(g.coeff, g.base)
    }
    result = _insert-sorted(result, term)
  }
  result
}

/// Internal helper `_trig-square-parts`.
#let _trig-square-parts(term) = {
  if not is-type(term, "pow") { return none }
  if not is-type(term.exp, "num") or term.exp.val != 2 { return none }
  if not is-type(term.base, "func") or func-arity(term.base) != 1 { return none }
  let kind = fn-canonical(term.base.name)
  if kind == "sin" or kind == "cos" {
    return (kind: kind, arg: func-args(term.base).at(0))
  }
  none
}

/// Internal helper `_strip-leading-neg`.
#let _strip-leading-neg(term) = {
  if is-type(term, "neg") { return term.arg }
  let rt = _as-rat(term)
  if rt != none and rt.n < 0 {
    return rat-to-expr(rat-neg(rt))
  }
  if is-type(term, "mul") {
    let l = term.args.at(0)
    let r = term.args.at(1)
    let rl = _as-rat(l)
    if rl != none and rl.n < 0 {
      let m = rat-neg(rl)
      return if rat-eq(m, rat(1, 1)) { r } else { mul(rat-to-expr(m), r) }
    }
    let rr = _as-rat(r)
    if rr != none and rr.n < 0 {
      let m = rat-neg(rr)
      return if rat-eq(m, rat(1, 1)) { l } else { mul(rat-to-expr(m), l) }
    }
  }
  none
}

/// Internal helper `_square-base`.
#let _square-base(t) = {
  if is-type(t, "pow") and is-type(t.exp, "num") and t.exp.val == 2 {
    return t.base
  }
  let rt = _as-rat(t)
  if rt != none and rt.n >= 0 {
    let sn = calc.sqrt(rt.n)
    let sd = calc.sqrt(rt.d)
    let isn = int(sn)
    let isd = int(sd)
    if isn * isn == rt.n and isd * isd == rt.d {
      return rat-to-expr(rat(isn, isd))
    }
  }
  none
}

/// Internal helper `_difference-of-squares-cancel`.
#let _difference-of-squares-cancel(n, d) = {
  // (a^2 - b^2)/(a-b) -> a+b; (a^2 - b^2)/(b-a) -> -(a+b)
  if not is-type(n, "add") { return none }
  let t1 = n.args.at(0)
  let t2p = _strip-leading-neg(n.args.at(1))
  if t2p == none { return none }

  let a = _square-base(t1)
  let b = _square-base(t2p)
  if a == none or b == none { return none }

  let ab = {
    let rb = _as-rat(b)
    if rb != none {
      add(a, rat-to-expr(rat-neg(rb)))
    } else {
      add(a, neg(b))
    }
  }
  let ba = {
    let ra = _as-rat(a)
    if ra != none {
      add(b, rat-to-expr(rat-neg(ra)))
    } else {
      add(b, neg(a))
    }
  }
  if expr-eq(d, ab) { return add(a, b) }
  if expr-eq(d, ba) { return neg(add(a, b)) }
  none
}

/// Internal helper `_collapse-trig-pythagorean`.
#let _collapse-trig-pythagorean(terms) = {
  if terms.len() < 2 { return terms }
  let used = ()
  for _ in range(terms.len()) { used.push(false) }
  let out = ()

  for i in range(terms.len()) {
    if used.at(i) { continue }
    let ti = terms.at(i)
    let pi = _trig-square-parts(ti)
    if pi != none {
      let want = if pi.kind == "sin" { "cos" } else { "sin" }
      let matched = false
      for j in range(i + 1, terms.len()) {
        if used.at(j) { continue }
        let pj = _trig-square-parts(terms.at(j))
        if pj != none and pj.kind == want and expr-eq(pi.arg, pj.arg) {
          used.at(i) = true
          used.at(j) = true
          out.push(num(1))
          matched = true
          break
        }
      }
      if matched { continue }
    }
    used.at(i) = true
    out.push(ti)
  }
  out
}

/// Internal helper `_count-trig-pythagorean-terms`.
#let _count-trig-pythagorean-terms(terms) = {
  if terms.len() < 2 { return 0 }
  let used = ()
  for _ in range(terms.len()) { used.push(false) }
  let total = 0

  for i in range(terms.len()) {
    if used.at(i) { continue }
    let pi = _trig-square-parts(terms.at(i))
    if pi == none { continue }
    let want = if pi.kind == "sin" { "cos" } else { "sin" }
    for j in range(i + 1, terms.len()) {
      if used.at(j) { continue }
      let pj = _trig-square-parts(terms.at(j))
      if pj != none and pj.kind == want and expr-eq(pi.arg, pj.arg) {
        used.at(i) = true
        used.at(j) = true
        total += 1
        break
      }
    }
  }
  total
}

/// Internal helper `_count-trig-pythagorean-expr`.
#let _count-trig-pythagorean-expr(expr) = {
  let total = 0
  if is-type(expr, "add") {
    // Count once at the current additive level (flattened), then recurse only
    // into non-add subtrees to avoid counting the same pair on each nested add node.
    let terms = _flatten-add(expr)
    total += _count-trig-pythagorean-terms(terms)
    for t in terms { total += _count-trig-pythagorean-expr(t) }
    return total
  }
  if is-type(expr, "neg") { return _count-trig-pythagorean-expr(expr.arg) }
  if is-type(expr, "mul") {
    total += _count-trig-pythagorean-expr(expr.args.at(0))
    total += _count-trig-pythagorean-expr(expr.args.at(1))
    return total
  }
  if is-type(expr, "pow") {
    total += _count-trig-pythagorean-expr(expr.base)
    total += _count-trig-pythagorean-expr(expr.exp)
    return total
  }
  if is-type(expr, "div") {
    total += _count-trig-pythagorean-expr(expr.num)
    total += _count-trig-pythagorean-expr(expr.den)
    return total
  }
  if is-type(expr, "func") {
    for a in func-args(expr) { total += _count-trig-pythagorean-expr(a) }
    return total
  }
  if is-type(expr, "log") {
    total += _count-trig-pythagorean-expr(expr.base)
    total += _count-trig-pythagorean-expr(expr.arg)
    return total
  }
  if is-type(expr, "sum") or is-type(expr, "prod") {
    total += _count-trig-pythagorean-expr(expr.body)
    total += _count-trig-pythagorean-expr(expr.from)
    total += _count-trig-pythagorean-expr(expr.to)
    return total
  }
  if is-type(expr, "matrix") {
    for row in expr.rows {
      for item in row { total += _count-trig-pythagorean-expr(item) }
    }
    return total
  }
  if is-type(expr, "piecewise") {
    for c in expr.cases {
      total += _count-trig-pythagorean-expr(c.at(0))
      if is-expr(c.at(1)) { total += _count-trig-pythagorean-expr(c.at(1)) }
    }
    return total
  }
  if is-type(expr, "complex") {
    total += _count-trig-pythagorean-expr(expr.re)
    total += _count-trig-pythagorean-expr(expr.im)
    return total
  }
  total
}

/// Internal helper `_cond-truth`.
/// Returns `true`, `false`, or `none` when undecidable.
#let _cond-truth(cond) = {
  if cond == none { return none }
  if is-type(cond, "cond-rel") {
    if is-type(cond.lhs, "num") and is-type(cond.rhs, "num") {
      let a = cond.lhs.val
      let b = cond.rhs.val
      if cond.rel == ">" { return a > b }
      if cond.rel == ">=" { return a >= b }
      if cond.rel == "<" { return a < b }
      if cond.rel == "<=" { return a <= b }
      if cond.rel == "!=" { return a != b }
      if cond.rel == "=" or cond.rel == "==" { return a == b }
    }
    return none
  }
  if is-type(cond, "cond-and") {
    let all = true
    for c in cond.args {
      let t = _cond-truth(c)
      if t == false { return false }
      if t == none { all = false }
    }
    return if all { true } else { none }
  }
  none
}

/// Internal helper `_rebuild-add`.
#let _rebuild-add(terms) = {
  if terms.len() == 0 { return num(0) }
  let out = terms.at(0)
  let i = 1
  while i < terms.len() {
    out = add(out, terms.at(i))
    i += 1
  }
  out
}

/// Internal helper `_canonicalize-mul`.
#let _canonicalize-mul(expr) = {
  let factors = _flatten-mul(expr)
  let sorted = ()
  for f in factors {
    sorted = _insert-sorted(sorted, f)
  }
  if sorted.len() == 0 { return num(1) }
  let out = sorted.at(0)
  let i = 1
  while i < sorted.len() {
    out = mul(out, sorted.at(i))
    i += 1
  }
  out
}

/// Internal helper `_canonicalize-structure`.
#let _canonicalize-structure(expr) = {
  if is-type(expr, "add") {
    let terms = _flatten-add(expr)
    let sorted = ()
    for t in terms { sorted = _insert-sorted(sorted, t) }
    return _rebuild-add(sorted)
  }
  if is-type(expr, "mul") { return _canonicalize-mul(expr) }
  expr
}

// --- Single-pass simplify ---

/// One pass of bottom-up simplification.
#let _simplify-once(expr) = {
  if is-type(expr, "num") or is-type(expr, "var") or is-type(expr, "const") {
    return expr
  }

  // Negation
  if is-type(expr, "neg") {
    let a = _simplify-once(expr.arg)
    if _is-num(a) { return num(-a.val) }
    if is-type(a, "neg") { return a.arg }
    if is-type(a, "add") {
      return _simplify-once(add(neg(a.args.at(0)), neg(a.args.at(1))))
    }
    return neg(a)
  }

  // Addition
  if is-type(expr, "add") {
    let a = _simplify-once(expr.args.at(0))
    let b = _simplify-once(expr.args.at(1))

    let ra = _as-rat(a)
    let rb = _as-rat(b)
    if ra != none and rb != none { return rat-to-expr(rat-add(ra, rb)) }

    if _is-zero(a) { return b }
    if _is-zero(b) { return a }
    if is-type(a, "neg") and expr-eq(a.arg, b) { return num(0) }
    if is-type(b, "neg") and expr-eq(b.arg, a) { return num(0) }

    let ka = _extract-k-ln(a)
    let kb = _extract-k-ln(b)
    if ka != none and kb != none and rat-eq(ka.k, rat-neg(kb.k)) {
      let k = ka.k
      let top = ka.arg
      let bot = kb.arg
      if k.n < 0 {
        k = rat-neg(k)
        let t = top
        top = bot
        bot = t
      }
      let merged = ln-of(abs-of(cdiv(top, bot)))
      if rat-eq(k, rat(1, 1)) { return merged }
      return mul(rat-to-expr(k), merged)
    }

    let terms = _flatten-add(add(a, b))
    let collected = _collect-like-terms(_collapse-trig-pythagorean(terms))
    if collected.len() == 0 { return num(0) }
    if collected.len() == 1 { return collected.at(0) }
    return _rebuild-add(collected)
  }

  // Multiplication
  if is-type(expr, "mul") {
    let a = _simplify-once(expr.args.at(0))
    let b = _simplify-once(expr.args.at(1))

    let ra = _as-rat(a)
    let rb = _as-rat(b)
    if ra != none and rb != none { return rat-to-expr(rat-mul(ra, rb)) }

    if _is-zero(a) or _is-zero(b) { return num(0) }
    if _is-one(a) { return b }
    if _is-one(b) { return a }
    if _is-num(a) and a.val == -1 { return neg(b) }
    if _is-num(b) and b.val == -1 { return neg(a) }

    if expr-eq(a, b) { return pow(a, num(2)) }
    if is-type(a, "div") and expr-eq(a.den, b) { return a.num }
    if is-type(b, "div") and expr-eq(b.den, a) { return b.num }
    // Fold rational scalar through a symbolic quotient: k * (n/d) -> (k/d) * n.
    if ra != none and is-type(b, "div") {
      let rd = _as-rat(b.den)
      if rd != none {
        let coeff = rat-div(ra, rd)
        if coeff != none {
          if rat-is-one(coeff) { return b.num }
          return _simplify-once(mul(rat-to-expr(coeff), b.num))
        }
      }
    }
    if rb != none and is-type(a, "div") {
      let rd = _as-rat(a.den)
      if rd != none {
        let coeff = rat-div(rb, rd)
        if coeff != none {
          if rat-is-one(coeff) { return a.num }
          return _simplify-once(mul(rat-to-expr(coeff), a.num))
        }
      }
    }

    if is-type(a, "pow") and is-type(b, "pow") and expr-eq(a.base, b.base) {
      return pow(a.base, _simplify-once(add(a.exp, b.exp)))
    }
    if is-type(a, "pow") and expr-eq(a.base, b) {
      return pow(b, _simplify-once(add(a.exp, num(1))))
    }
    if is-type(b, "pow") and expr-eq(b.base, a) {
      return pow(a, _simplify-once(add(b.exp, num(1))))
    }

    // Flatten, combine rational coefficient, and keep canonical order.
    let factors = _flatten-mul(mul(a, b))
    let coeff = rat(1, 1)
    let symbolic = ()
    for f in factors {
      let rf = _as-rat(f)
      if rf != none {
        coeff = rat-mul(coeff, rf)
      } else {
        symbolic.push(f)
      }
    }
    if rat-is-zero(coeff) { return num(0) }

    let out-factors = ()
    if not rat-is-one(coeff) { out-factors.push(rat-to-expr(coeff)) }
    for s in symbolic { out-factors = _insert-sorted(out-factors, s) }

    if out-factors.len() == 0 { return rat-to-expr(coeff) }
    let out = out-factors.at(0)
    let i = 1
    while i < out-factors.len() {
      out = mul(out, out-factors.at(i))
      i += 1
    }
    return out
  }

  // Division
  if is-type(expr, "div") {
    let n = _simplify-once(expr.num)
    let d = _simplify-once(expr.den)

    // Preserve 0/0 as an indeterminate form. This is required for
    // limit logic (L'Hospital) and avoids unsound simplification.
    if _is-zero(n) and _is-zero(d) { return cdiv(n, d) }
    if _is-zero(n) { return num(0) }
    if _is-one(d) { return n }
    if expr-eq(n, d) { return num(1) }

    let rn = _as-rat(n)
    let rd = _as-rat(d)
    if rn != none and rd != none and not rat-is-zero(rd) {
      let q = rat-div(rn, rd)
      if q != none { return rat-to-expr(q) }
    }

    let dos = _difference-of-squares-cancel(n, d)
    if dos != none { return dos }

    // Cancel one identical multiplicative factor in numerator.
    let nf = _flatten-mul(n)
    for i in range(nf.len()) {
      if expr-eq(nf.at(i), d) {
        let rest = ()
        for j in range(nf.len()) {
          if j != i { rest.push(nf.at(j)) }
        }
        if rest.len() == 0 { return num(1) }
        let out = rest.at(0)
        let k = 1
        while k < rest.len() {
          out = mul(out, rest.at(k))
          k += 1
        }
        return out
      }
    }

    return cdiv(n, d)
  }

  // Power
  if is-type(expr, "pow") {
    let b = _simplify-once(expr.base)
    let e = _simplify-once(expr.exp)

    if _is-zero(e) { return num(1) }
    if _is-one(e) { return b }
    if _is-zero(b) { return num(0) }
    if _is-one(b) { return num(1) }

    // (a^m)^n -> a^(mn) is safe in real-domain generality when n is integer.
    if is-type(b, "pow") and is-type(e, "num") and type(e.val) == int {
      return _simplify-once(pow(b.base, mul(b.exp, e)))
    }

    if is-type(b, "num") and is-type(e, "num") {
      if type(e.val) == int {
        return num(calc.pow(b.val, e.val))
      }
      if b.val >= 0 {
        return num(calc.pow(b.val, e.val))
      }
    }

    return pow(b, e)
  }

  // Functions
  if is-type(expr, "func") {
    let args = func-args(expr).map(_simplify-once)
    return func(expr.name, ..args)
  }

  // Structural log node
  if is-type(expr, "log") {
    return log-of(_simplify-once(expr.base), _simplify-once(expr.arg))
  }

  if is-type(expr, "sum") {
    return csum(_simplify-once(expr.body), expr.idx, _simplify-once(expr.from), _simplify-once(expr.to))
  }
  if is-type(expr, "prod") {
    return cprod(_simplify-once(expr.body), expr.idx, _simplify-once(expr.from), _simplify-once(expr.to))
  }

  if is-type(expr, "integral") {
    return (type: "integral", expr: _simplify-once(expr.expr), var: expr.var)
  }
  if is-type(expr, "def-integral") {
    return (
      type: "def-integral",
      expr: _simplify-once(expr.expr),
      var: expr.var,
      lo: _simplify-once(expr.lo),
      hi: _simplify-once(expr.hi),
    )
  }

  if is-type(expr, "matrix") {
    return cmat(expr.rows.map(row => row.map(_simplify-once)))
  }
  if is-type(expr, "piecewise") {
    let next = ()
    let fallback = none
    for c in expr.cases {
      let body = _simplify-once(c.at(0))
      let cond0 = c.at(1)
      if cond0 == none {
        fallback = body
        continue
      }
      let cond = if is-expr(cond0) { _simplify-once(cond0) } else { cond0 }
      let truth = _cond-truth(cond)
      if truth == false { continue }
      if truth == true { return body }
      next.push((body, cond))
    }
    if fallback != none { next.push((fallback, none)) }
    if next.len() == 0 { return expr }
    if next.len() == 1 and next.at(0).at(1) == none { return next.at(0).at(0) }
    return piecewise(next)
  }
  if is-type(expr, "cond-rel") {
    return cond-rel(_simplify-once(expr.lhs), expr.rel, _simplify-once(expr.rhs))
  }
  if is-type(expr, "cond-and") {
    let args = ()
    for c in expr.args {
      let s = _simplify-once(c)
      let truth = _cond-truth(s)
      if truth == false { return cond-and(cond-rel(num(0), "=", num(1))) }
      if truth == true { continue }
      args.push(s)
    }
    if args.len() == 0 { return cond-rel(num(1), "=", num(1)) }
    return cond-and(..args)
  }
  if is-type(expr, "complex") {
    return (type: "complex", re: _simplify-once(expr.re), im: _simplify-once(expr.im))
  }

  expr
}

/// Internal helper `_identity-unique`.
#let _identity-unique(events) = {
  let out = ()
  let seen = (:)
  for ev in events {
    let id = ev.at("id", default: "unknown")
    if not (id in seen) {
      seen.insert(id, true)
      out.push(ev)
    }
  }
  out
}

/// Internal helper `_simplify-fixed-point-meta`.
#let _simplify-fixed-point-meta(expr, allow-domain-sensitive: false) = {
  let cur = expr
  let identity-events = ()
  let seq = 1
  let i = 0
  let seen = (:)
  let pass-cache = (:)
  while i < 12 {
    let id = repr(cur)
    if id in seen {
      return (
        expr: cur,
        identity-events: identity-events,
        identity-count: identity-events.len(),
        identity-unique: _identity-unique(identity-events),
      )
    }
    seen.insert(id, true)

    let pyth-before = _count-trig-pythagorean-expr(cur)
    let core = if id in pass-cache {
      pass-cache.at(id)
    } else {
      let s = _canonicalize-structure(_simplify-once(cur))
      pass-cache.insert(id, s)
      s
    }
    let pyth-after = _count-trig-pythagorean-expr(core)
    if pyth-before > pyth-after {
      let hidden = pyth-before - pyth-after
      for _ in range(hidden) {
        identity-events.push((
          id: "trig-pythagorean-core",
          label: "sin(u)^2 + cos(u)^2 = 1",
          domain-sensitive: false,
          pass: i + 1,
          seq: seq,
        ))
        seq += 1
      }
    }
    let idmeta = apply-identities-once-meta(core, allow-domain-sensitive: allow-domain-sensitive)
    let with-identities = idmeta.expr
    for ev in idmeta.events {
      identity-events.push((
        ..ev,
        pass: i + 1,
        seq: seq,
      ))
      seq += 1
    }
    let next = _canonicalize-structure(with-identities)
    if expr-eq(next, cur) {
      return (
        expr: next,
        identity-events: identity-events,
        identity-count: identity-events.len(),
        identity-unique: _identity-unique(identity-events),
      )
    }
    cur = next
    i += 1
  }
  (
    expr: cur,
    identity-events: identity-events,
    identity-count: identity-events.len(),
    identity-unique: _identity-unique(identity-events),
  )
}

/// Public helper `simplify`.
#let simplify(expr, allow-domain-sensitive: false) = _simplify-fixed-point-meta(
  expr,
  allow-domain-sensitive: allow-domain-sensitive,
).expr

/// Public helper `simplify-meta-core`.
/// Returns simplified expression plus filtered restriction metadata.
#let simplify-meta-core(expr, allow-domain-sensitive: false, assumptions: none) = {
  let smeta = _simplify-fixed-point-meta(expr, allow-domain-sensitive: allow-domain-sensitive)
  let out = smeta.expr
  let restrictions = merge-restrictions(
    collect-structural-restrictions(expr),
    collect-function-restrictions(expr, stage: "defined"),
  )
  let filtered = filter-restrictions-by-assumptions(restrictions, assumptions)
  (
    expr: out,
    restrictions: filtered.restrictions,
    satisfied: filtered.satisfied,
    conflicts: filtered.conflicts,
    residual: filtered.residual,
    variable-domains: filtered.variable-domains,
    identities-used: smeta.identity-events,
    identity-count: smeta.identity-count,
    identity-unique: smeta.identity-unique,
  )
}

// =========================================================================
// EXPAND — distribute products, expand small integer powers
// =========================================================================

/// One non-fixed-point expansion pass.
#let _expand-once(expr) = {
  if is-type(expr, "num") or is-type(expr, "var") or is-type(expr, "const") {
    return expr
  }

  if is-type(expr, "neg") {
    return neg(_expand-once(expr.arg))
  }

  if is-type(expr, "add") {
    return add(_expand-once(expr.args.at(0)), _expand-once(expr.args.at(1)))
  }

  if is-type(expr, "mul") {
    let a = _expand-once(expr.args.at(0))
    let b = _expand-once(expr.args.at(1))

    if is-type(a, "add") {
      return add(_expand-once(mul(a.args.at(0), b)), _expand-once(mul(a.args.at(1), b)))
    }
    if is-type(b, "add") {
      return add(_expand-once(mul(a, b.args.at(0))), _expand-once(mul(a, b.args.at(1))))
    }
    return mul(a, b)
  }

  if is-type(expr, "div") {
    return cdiv(_expand-once(expr.num), _expand-once(expr.den))
  }

  if is-type(expr, "pow") {
    let base = _expand-once(expr.base)
    let exp = _expand-once(expr.exp)
    if is-type(exp, "num") and type(exp.val) == int and exp.val >= 2 and exp.val <= 8 and is-type(base, "add") {
      let out = base
      let i = 1
      while i < exp.val {
        out = _expand-once(mul(out, base))
        i += 1
      }
      return out
    }
    return pow(base, exp)
  }

  if is-type(expr, "func") {
    return func(expr.name, ..func-args(expr).map(_expand-once))
  }

  if is-type(expr, "log") {
    return log-of(_expand-once(expr.base), _expand-once(expr.arg))
  }

  if is-type(expr, "sum") {
    return csum(_expand-once(expr.body), expr.idx, _expand-once(expr.from), _expand-once(expr.to))
  }
  if is-type(expr, "prod") {
    return cprod(_expand-once(expr.body), expr.idx, _expand-once(expr.from), _expand-once(expr.to))
  }

  expr
}

/// Fully expand an expression (distribute products, expand powers), then simplify.
#let expand(expr) = {
  let cur = expr
  let i = 0
  while i < 8 {
    let next = _expand-once(cur)
    if expr-eq(next, cur) { return simplify(next) }
    cur = next
    i += 1
  }
  simplify(cur)
}
