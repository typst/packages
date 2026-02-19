// =========================================================================
// CAS Simplification Engine
// =========================================================================
// Bottom-up recursive simplifier. Applies algebraic rules until fixed point.
// =========================================================================

#import "expr.typ": *
#import "rational.typ": rat, rat-add, rat-div, rat-eq, rat-from-expr, rat-is-one, rat-is-zero, rat-mul, rat-neg, rat-sub, rat-to-expr
#import "identities.typ": apply-identities-once
#import "truths/function-registry.typ": fn-canonical

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
  // Keep integration constant C at the end of sums (e.g., f(x) + C).
  if is-type(e, "var") and e.name == "C" { return 99 }
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
#let _is-func-canonical(expr, canonical) = {
  is-type(expr, "func") and fn-canonical(expr.name) == canonical
}

// Try to read a term as coefficient * var^degree for ordering.
/// Internal helper `_var-degree`.
#let _var-degree(term) = {
  let t = if is-type(term, "neg") { term.arg } else { term }
  if is-type(t, "var") and t.name != "C" {
    return (name: t.name, deg: 1)
  }
  if is-type(t, "pow") and is-type(t.base, "var") and t.base.name != "C" and is-type(t.exp, "num") {
    if type(t.exp.val) == int {
      return (name: t.base.name, deg: t.exp.val)
    }
  }
  if is-type(t, "mul") {
    let l = t.args.at(0)
    let r = t.args.at(1)
    if _as-rat(l) != none {
      return _var-degree(r)
    }
    if _as-rat(r) != none {
      return _var-degree(l)
    }
  }
  if is-type(t, "div") {
    let rd = _as-rat(t.den)
    if rd != none and not rat-is-zero(rd) {
      return _var-degree(t.num)
    }
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
      return (k: rat-mul(sign, rat-div(rat(1, 1), rd)), arg: func-args(t.num).at(0))
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

// --- Single-pass simplify helpers ---

/// Flatten nested add trees into a list of terms.
#let _flatten-add(expr) = {
  if is-type(expr, "add") {
    let left = _flatten-add(expr.args.at(0))
    let right = _flatten-add(expr.args.at(1))
    return left + right
  }
  return (expr,)
}

/// Flatten nested multiplication trees into a list of factors.
#let _flatten-mul(expr) = {
  if is-type(expr, "mul") {
    let left = _flatten-mul(expr.args.at(0))
    let right = _flatten-mul(expr.args.at(1))
    return left + right
  }
  (expr,)
}

/// Extract (coefficient, base) from a term.
/// 3x → (3, x), -x → (-1, x), x → (1, x), 5 → (5, 1), (1/2)x → (1/2, x)
#let _get-coeff-and-base(expr) = {
  let r-all = _as-rat(expr)
  if r-all != none {
    return (r-all, num(1))
  }
  if is-type(expr, "neg") {
    let (c, b) = _get-coeff-and-base(expr.arg)
    if c != none {
      return (rat-neg(c), b)
    }
    return (rat(-1, 1), expr.arg)
  }
  if is-type(expr, "mul") {
    // Extract coefficient from arbitrarily nested products, not only
    // immediate `num * base` shape.
    let factors = _flatten-mul(expr)
    let coeff = rat(1, 1)
    let symbolic = ()
    for f in factors {
      let f = if is-type(f, "neg") {
        coeff = rat-neg(coeff)
        f.arg
      } else {
        f
      }
      let rf = _as-rat(f)
      if rf != none {
        coeff = rat-mul(coeff, rf)
      } else {
        symbolic.push(f)
      }
    }
    if symbolic.len() == 0 {
      return (coeff, num(1))
    }
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
      let rn = _as-rat(expr.num)
      if rn != none {
        return (rat-div(rn, rd), num(1))
      }
      let (cn, bn) = _get-coeff-and-base(expr.num)
      return (rat-div(cn, rd), bn)
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
  let rest = add(_scale-term(q1, b1), _scale-term(q2, b2))
  (k: g, rest: rest)
}

/// Collect like terms from a flat list of expressions.
/// Returns a new list of simplified terms.
#let _collect-like-terms(terms) = {
  // Build groups: array of (coeff-rational, base-expr)
  let groups = ()

  for term in terms {
    let (coeff, base) = _get-coeff-and-base(term)
    let found = false
    let new-groups = ()
    for g in groups {
      if not found and expr-eq(g.at(1), base) {
        new-groups.push((rat-add(g.at(0), coeff), base))
        found = true
      } else {
        new-groups.push(g)
      }
    }
    if not found {
      new-groups.push((coeff, base))
    }
    groups = new-groups
  }

  // Canonical order by base type and structural key.
  let ordered-groups = ()
  for g in groups {
    if rat-is-zero(g.at(0)) { continue }
    let inserted = false
    let next = ()
    for h in ordered-groups {
      let gb = g.at(1)
      let hb = h.at(1)
      if not inserted and _before-expr(gb, hb) {
        next.push(g)
        inserted = true
      }
      next.push(h)
    }
    if not inserted { next.push(g) }
    ordered-groups = next
  }

  // Rebuild terms from groups
  let result = ()
  for g in ordered-groups {
    let (c, base) = g
    if expr-eq(base, num(1)) {
      result.push(rat-to-expr(c))
    } else if rat-eq(c, rat(1, 1)) {
      result.push(base)
    } else if rat-eq(c, rat(-1, 1)) {
      result.push(neg(base))
    } else {
      result.push(mul(rat-to-expr(c), base))
    }
  }
  result
}

/// Internal helper `_trig-square-parts`.
#let _trig-square-parts(term) = {
  if not is-type(term, "pow") { return none }
  if not is-type(term.exp, "num") or term.exp.val != 2 { return none }
  if not is-type(term.base, "func") { return none }
  if func-arity(term.base) != 1 { return none }
  let kind = fn-canonical(term.base.name)
  if kind == "sin" or kind == "cos" {
    return (kind: kind, arg: func-args(term.base).at(0))
  }
  none
}

/// Internal helper `_collapse-trig-pythagorean`.
#let _collapse-trig-pythagorean(terms) = {
  if terms.len() < 2 { return terms }
  let used = ()
  for _ in range(terms.len()) { used.push(false) }
  let out = ()
  let changed = false

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
          changed = true
          matched = true
          break
        }
      }
      if matched { continue }
    }
    used.at(i) = true
    out.push(ti)
  }

  if changed { _collect-like-terms(out) } else { terms }
}

// --- Single-pass simplify ---

/// One pass of bottom-up simplification.
#let _simplify-once(expr) = {
  // Base cases: leaves don't simplify further
  if is-type(expr, "num") or is-type(expr, "var") or is-type(expr, "const") {
    return expr
  }

  // --- Negation ---
  if is-type(expr, "neg") {
    let a = _simplify-once(expr.arg)
    // neg(num(n)) => num(-n)
    if _is-num(a) { return num(-a.val) }
    // neg(neg(x)) => x
    if is-type(a, "neg") { return a.arg }
    // Distribute negation over sums so additive normalization can collect terms.
    if is-type(a, "add") {
      return _simplify-once(add(neg(a.args.at(0)), neg(a.args.at(1))))
    }
    return neg(a)
  }

  // --- Addition ---
  if is-type(expr, "add") {
    let a = _simplify-once(expr.args.at(0))
    let b = _simplify-once(expr.args.at(1))

    // Constant/rational folding
    let ra = _as-rat(a)
    let rb = _as-rat(b)
    if ra != none and rb != none {
      return rat-to-expr(rat-add(ra, rb))
    }
    // Identity: x + 0 = x
    if _is-zero(b) { return a }
    if _is-zero(a) { return b }
    // x + neg(x) = 0  and neg(x) + x = 0
    if is-type(b, "neg") and expr-eq(a, b.arg) { return num(0) }
    if is-type(a, "neg") and expr-eq(a.arg, b) { return num(0) }
    // x + neg(y) where x and y are nums => fold
    if _is-num(a) and is-type(b, "neg") and _is-num(b.arg) {
      return num(a.val - b.arg.val)
    }

    // k*ln(A) + (-k)*ln(B) => k*ln(A/B)
    let ka = _extract-k-ln(a)
    let kb = _extract-k-ln(b)
    if ka != none and kb != none {
      if rat-eq(ka.k, rat-neg(kb.k)) {
        let k = ka.k
        let num-arg = ka.arg
        let den-arg = kb.arg
        if k.n < 0 {
          k = rat-neg(k)
          let tmp = num-arg
          num-arg = den-arg
          den-arg = tmp
        }
        let merged = ln-of(abs-of(cdiv(num-arg, den-arg)))
        if rat-eq(k, rat(1, 1)) { return merged }
        return mul(rat-to-expr(k), merged)
      }
    }

    // --- Flatten additions and collect like terms ---
    let terms = _flatten-add(add(a, b))
    if terms.len() >= 2 {
      let collected = _collapse-trig-pythagorean(_collect-like-terms(terms))
      if collected.len() == 0 { return num(0) }
      if collected.len() == 1 { return collected.at(0) }
      // Rebuild right-associatively for canonical ordering.
      let result = collected.at(collected.len() - 1)
      let idx = collected.len() - 2
      while idx >= 0 {
        result = add(collected.at(idx), result)
        idx -= 1
      }
      if not expr-eq(result, add(a, b)) {
        return result
      }
    }

    return add(a, b)
  }

  // --- Multiplication ---
  if is-type(expr, "mul") {
    let a = _simplify-once(expr.args.at(0))
    let b = _simplify-once(expr.args.at(1))

    // Constant/rational folding
    let ra = _as-rat(a)
    let rb = _as-rat(b)
    if ra != none and rb != none {
      return rat-to-expr(rat-mul(ra, rb))
    }
    // Annihilation: x * 0 = 0
    if _is-zero(a) or _is-zero(b) { return num(0) }
    // Identity: x * 1 = x
    if _is-one(a) { return b }
    if _is-one(b) { return a }
    // Normalize x^1 factors in products.
    if is-type(a, "pow") and _is-num(a.exp) and a.exp.val == 1 {
      return _simplify-once(mul(a.base, b))
    }
    if is-type(b, "pow") and _is-num(b.exp) and b.exp.val == 1 {
      return _simplify-once(mul(a, b.base))
    }
    // x * -1 = neg(x)
    if _is-num(a) and a.val == -1 { return neg(b) }
    if _is-num(b) and b.val == -1 { return neg(a) }
    // x * x = x^2 (but not when x is add — let distribution handle that)
    if expr-eq(a, b) and not is-type(a, "add") { return pow(a, num(2)) }
    // (u / v) * v = u and v * (u / v) = u
    if is-type(a, "div") and expr-eq(a.den, b) { return a.num }
    if is-type(b, "div") and expr-eq(b.den, a) { return b.num }
    // x^a * x^b = x^(a+b)
    if is-type(a, "pow") and is-type(b, "pow") and expr-eq(a.base, b.base) {
      return pow(a.base, _simplify-once(add(a.exp, b.exp)))
    }
    // x * x^n = x^(n+1)
    if is-type(b, "pow") and expr-eq(a, b.base) {
      return pow(a, _simplify-once(add(b.exp, num(1))))
    }
    if is-type(a, "pow") and expr-eq(a.base, b) {
      return pow(b, _simplify-once(add(a.exp, num(1))))
    }
    // Move numeric coefficients to the left: x * 3 => 3 * x
    if _is-num(b) and not _is-num(a) { return mul(b, a) }
    // num * div(n, d) => div(num * n, d)
    if _is-num(a) and is-type(b, "div") {
      return cdiv(mul(a, b.num), b.den)
    }
    // Flatten nested coefficients: n * (m * expr) => (n*m) * expr
    if _is-num(a) and is-type(b, "mul") and _is-num(b.args.at(0)) {
      return mul(num(a.val * b.args.at(0).val), b.args.at(1))
    }
    // Distribution: a * (b + c) => a*b + a*c
    if is-type(b, "add") {
      return add(mul(a, b.args.at(0)), mul(a, b.args.at(1)))
    }
    if is-type(a, "add") {
      return add(mul(a.args.at(0), b), mul(a.args.at(1), b))
    }

    // Canonical factor ordering and rational coefficient extraction.
    let factors = _flatten-mul(mul(a, b))
    let coeff = rat(1, 1)
    let symbolic = ()
    for f in factors {
      let f0 = if is-type(f, "pow") and is-type(f.exp, "num") and f.exp.val == 1 {
        f.base
      } else {
        f
      }

      // Pull explicit neg factors into the numeric coefficient so
      // terms like 2*cos(x)*(-sin(x)) canonicalize to -2*cos(x)*sin(x).
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
    if rat-is-zero(coeff) { return num(0) }

    // Stable order for non-numeric factors.
    let ordered = ()
    for f in symbolic {
      ordered = _insert-sorted(ordered, f)
    }

    if ordered.len() == 0 {
      return rat-to-expr(coeff)
    }

    let start = if rat-is-one(coeff) {
      ordered.at(0)
    } else {
      mul(rat-to-expr(coeff), ordered.at(0))
    }
    let i = 1
    let out = start
    while i < ordered.len() {
      out = mul(out, ordered.at(i))
      i += 1
    }
    return out
  }

  // --- Power ---
  if is-type(expr, "pow") {
    let b = _simplify-once(expr.base)
    let e = _simplify-once(expr.exp)

    // e^x => exp(x)
    if is-type(b, "const") and b.name == "e" {
      return func("exp", e)
    }

    // x^0 = 1
    if _is-zero(e) { return num(1) }
    // x^1 = x
    if _is-one(e) { return b }
    // 0^n = 0 (n > 0)
    if _is-zero(b) and _is-num(e) and e.val > 0 { return num(0) }
    // 1^n = 1
    if _is-one(b) { return num(1) }
    // num^num = constant fold (integers only)
    if _is-num(b) and _is-num(e) and type(e.val) == int and e.val >= 0 {
      let result = 1
      for _ in range(e.val) { result = result * b.val }
      return num(result)
    }
    // Rational^integer = exact rational
    let rb = _as-rat(b)
    if rb != none and _is-num(e) and type(e.val) == int {
      if e.val == 0 { return num(1) }
      let out = rat(1, 1)
      let n = calc.abs(e.val)
      for _ in range(n) { out = rat-mul(out, rb) }
      if e.val < 0 {
        if out.n == 0 { return pow(b, e) }
        out = rat-div(rat(1, 1), out)
      }
      return rat-to-expr(out)
    }
    // (x^a)^b = x^(a*b) is only safe for integer outer exponent.
    // Avoid collapsing sqrt(x^2) -> x; that should remain branch-aware.
    if is-type(b, "pow") and _is-num(e) and type(e.val) == int {
      return pow(b.base, _simplify-once(mul(b.exp, e)))
    }
    // n^(1/2) where n is a perfect square => sqrt(n)
    if _is-num(b) and is-type(e, "div") {
      if is-type(e.num, "num") and e.num.val == 1 and is-type(e.den, "num") and e.den.val == 2 {
        if type(b.val) == int and b.val >= 0 {
          let s = calc.sqrt(b.val)
          let si = int(s)
          if si * si == b.val {
            return num(si)
          }
        }
      }
    }
    // (a + b)^n: Do NOT expand automatically (keep factored form)
    return pow(b, e)
  }

  // --- Division ---
  if is-type(expr, "div") {
    let n = _simplify-once(expr.num)
    let d = _simplify-once(expr.den)

    // 0 / x = 0
    if _is-zero(n) { return num(0) }
    // x / 1 = x
    if _is-one(d) { return n }
    // x / x = 1
    if expr-eq(n, d) { return num(1) }
    // Rational folding and normalization
    let rn = _as-rat(n)
    let rd = _as-rat(d)
    if rn != none and rd != none and not rat-is-zero(rd) {
      return rat-to-expr(rat-div(rn, rd))
    }

    // Pull numeric coefficient out of numerator product:
    // (k*u)/d => (k/d) * u when d is rational.
    if rd != none and not rat-is-zero(rd) and is-type(n, "mul") {
      let l = n.args.at(0)
      let r = n.args.at(1)
      let rl = _as-rat(l)
      if rl != none {
        return _simplify-once(mul(rat-to-expr(rat-div(rl, rd)), r))
      }
      let rr = _as-rat(r)
      if rr != none {
        return _simplify-once(mul(rat-to-expr(rat-div(rr, rd)), l))
      }
    }

    // Cancel denominator directly from numerator product: (k*u)/u => k, (u*k)/u => k.
    if is-type(n, "mul") {
      let n1 = n.args.at(0)
      let n2 = n.args.at(1)
      if expr-eq(n1, d) { return _simplify-once(n2) }
      if expr-eq(n2, d) { return _simplify-once(n1) }
    }

    // (a/b)/c => a/(b*c), only when c is numeric/rational.
    if is-type(n, "div") and _as-rat(d) != none {
      return _simplify-once(cdiv(n.num, mul(n.den, d)))
    }

    // Cancel common additive rational factors:
    // (k*u)/(k*w) => u/w, and (k1*u)/(k2*w) => (k1/k2)*(u/w).
    let fn = _factor-common-rat-add(n)
    let fd = _factor-common-rat-add(d)
    if fn != none and fd != none and not rat-is-zero(fd.k) {
      let scale = rat-div(fn.k, fd.k)
      let core = cdiv(fn.rest, fd.rest)
      if rat-eq(scale, rat(1, 1)) {
        return _simplify-once(core)
      }
      return _simplify-once(mul(rat-to-expr(scale), core))
    }

    // Cancel powers with same base.
    if is-type(n, "pow") and is-type(d, "pow") and expr-eq(n.base, d.base) {
      return _simplify-once(pow(n.base, sub(n.exp, d.exp)))
    }
    if is-type(n, "pow") and expr-eq(n.base, d) {
      return _simplify-once(pow(d, sub(n.exp, num(1))))
    }
    if is-type(d, "pow") and expr-eq(n, d.base) {
      return _simplify-once(pow(n, sub(num(1), d.exp)))
    }

    // Cancel common multiplicative factors.
    if is-type(n, "mul") and is-type(d, "mul") {
      let n1 = n.args.at(0)
      let n2 = n.args.at(1)
      let d1 = d.args.at(0)
      let d2 = d.args.at(1)

      if expr-eq(n1, d1) { return _simplify-once(cdiv(n2, d2)) }
      if expr-eq(n1, d2) { return _simplify-once(cdiv(n2, d1)) }
      if expr-eq(n2, d1) { return _simplify-once(cdiv(n1, d2)) }
      if expr-eq(n2, d2) { return _simplify-once(cdiv(n1, d1)) }

      let rn1 = _as-rat(n1)
      let rn2 = _as-rat(n2)
      let rd1 = _as-rat(d1)
      let rd2 = _as-rat(d2)

      if rn1 != none and rd1 != none and not rat-is-zero(rd1) {
        return _simplify-once(mul(rat-to-expr(rat-div(rn1, rd1)), cdiv(n2, d2)))
      }
      if rn1 != none and rd2 != none and not rat-is-zero(rd2) {
        return _simplify-once(mul(rat-to-expr(rat-div(rn1, rd2)), cdiv(n2, d1)))
      }
      if rn2 != none and rd1 != none and not rat-is-zero(rd1) {
        return _simplify-once(mul(rat-to-expr(rat-div(rn2, rd1)), cdiv(n1, d2)))
      }
      if rn2 != none and rd2 != none and not rat-is-zero(rd2) {
        return _simplify-once(mul(rat-to-expr(rat-div(rn2, rd2)), cdiv(n1, d1)))
      }
    }

    // Cancel one factor against denominator powers: (a*b) / b^k.
    if is-type(d, "pow") and is-type(d.exp, "num") and type(d.exp.val) == int and d.exp.val > 0 {
      let base = d.base
      let k = d.exp.val
      if is-type(n, "mul") {
        let l = n.args.at(0)
        let r = n.args.at(1)
        if expr-eq(l, base) {
          let den = if k == 1 { num(1) } else { pow(base, num(k - 1)) }
          return _simplify-once(cdiv(r, den))
        }
        if expr-eq(r, base) {
          let den = if k == 1 { num(1) } else { pow(base, num(k - 1)) }
          return _simplify-once(cdiv(l, den))
        }
      }
    }
    // neg(x) / neg(y) = x / y
    if is-type(n, "neg") and is-type(d, "neg") {
      return _simplify-once(cdiv(n.arg, d.arg))
    }
    // neg(x) / y = neg(x / y)
    if is-type(n, "neg") {
      return neg(_simplify-once(cdiv(n.arg, d)))
    }
    // x / neg(y) = neg(x / y)
    if is-type(d, "neg") {
      return neg(_simplify-once(cdiv(n, d.arg)))
    }
    // num(-a) / num(-b) => num(a) / num(b) (raw negative numbers)
    if _is-num(n) and _is-num(d) and n.val < 0 and d.val < 0 {
      return _simplify-once(cdiv(num(-n.val), num(-d.val)))
    }
    // num(a) / num(-b) => neg(a/b) (normalize sign to numerator)
    if _is-num(d) and d.val < 0 {
      return neg(_simplify-once(cdiv(n, num(-d.val))))
    }
    return cdiv(n, d)
  }

  // --- Function ---
  if is-type(expr, "func") {
    let args = func-args(expr).map(_simplify-once)
    let unary = args.len() == 1
    if not unary {
      return func(expr.name, ..args)
    }
    let a = args.at(0)

    // --- Abs rules ---
    // |n| => abs(n) for numeric
    if _is-func-canonical(expr, "abs") and _is-num(a) {
      return num(calc.abs(a.val))
    }

    return func(expr.name, ..args)
  }

  // --- Log with base ---
  if is-type(expr, "log") {
    let b = _simplify-once(expr.base)
    let a = _simplify-once(expr.arg)
    // log_b(b) = 1
    if expr-eq(b, a) { return num(1) }
    // log_b(1) = 0
    if _is-one(a) { return num(0) }
    return (type: "log", base: b, arg: a)
  }


  // --- Sum/Prod: simplify body ---
  if is-type(expr, "sum") {
    return (
      type: "sum",
      body: _simplify-once(expr.body),
      idx: expr.idx,
      from: _simplify-once(expr.from),
      to: _simplify-once(expr.to),
    )
  }
  if is-type(expr, "prod") {
    return (
      type: "prod",
      body: _simplify-once(expr.body),
      idx: expr.idx,
      from: _simplify-once(expr.from),
      to: _simplify-once(expr.to),
    )
  }

  // --- Matrix: simplify each entry ---
  if is-type(expr, "matrix") {
    let rows = expr.rows.map(row => row.map(e => _simplify-once(e)))
    return (type: "matrix", rows: rows)
  }
  // --- Piecewise: simplify each branch ---
  if is-type(expr, "piecewise") {
    let new-cases = expr.cases.map(((e, c)) => (_simplify-once(e), c))
    return (type: "piecewise", cases: new-cases)
  }

  return expr
}

// --- Public API ---

/// Simplify an expression by applying rules until a fixed point (max 10 passes).
#let simplify(expr) = {
  let current = expr
  let max-passes = 10
  for _ in range(max-passes) {
    let next-core = _simplify-once(current)
    let next = apply-identities-once(next-core)
    if expr-eq(next, current) { return current }
    current = next
  }
  current
}

// =========================================================================
// EXPAND — distribute products, expand powers, no term collection
// =========================================================================

/// One pass of expansion.
#let _expand-once(expr) = {
  if is-type(expr, "num") or is-type(expr, "var") or is-type(expr, "const") {
    return expr
  }
  if is-type(expr, "neg") { return neg(_expand-once(expr.arg)) }
  if is-type(expr, "add") {
    return add(_expand-once(expr.args.at(0)), _expand-once(expr.args.at(1)))
  }
  if is-type(expr, "func") {
    let args = func-args(expr).map(_expand-once)
    return func(expr.name, ..args)
  }
  if is-type(expr, "div") { return cdiv(_expand-once(expr.num), _expand-once(expr.den)) }

  // Multiplication: distribute over addition
  if is-type(expr, "mul") {
    let a = _expand-once(expr.args.at(0))
    let b = _expand-once(expr.args.at(1))
    // a * (b + c) => a*b + a*c
    if is-type(b, "add") {
      return add(_expand-once(mul(a, b.args.at(0))), _expand-once(mul(a, b.args.at(1))))
    }
    // (a + b) * c => a*c + b*c
    if is-type(a, "add") {
      return add(_expand-once(mul(a.args.at(0), b)), _expand-once(mul(a.args.at(1), b)))
    }
    return mul(a, b)
  }

  // Power: (a + b)^n for positive integer n => expand by repeated multiplication
  if is-type(expr, "pow") {
    let base = _expand-once(expr.base)
    let exp = _expand-once(expr.exp)
    if is-type(exp, "num") and type(exp.val) == int and exp.val >= 2 and is-type(base, "add") {
      let result = base
      for _ in range(exp.val - 1) {
        result = _expand-once(mul(result, base))
      }
      return result
    }
    return pow(base, exp)
  }

  return expr
}

/// Fully expand an expression (distribute products, expand powers).
/// Does NOT collect like terms — use simplify() after if desired.
#let expand(expr) = {
  let current = expr
  let max-passes = 10
  for _ in range(max-passes) {
    let next = _expand-once(current)
    if expr-eq(next, current) { return current }
    current = next
  }
  current
}
