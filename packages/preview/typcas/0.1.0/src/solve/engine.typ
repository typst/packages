// =========================================================================
// CAS Equation Solver
// =========================================================================
// Solves equations of the form lhs = rhs for a variable.
// Includes polynomial metadata with multiplicities, factor forms,
// exact-vs-numeric tags, square-free preprocessing, and complex roots.
// =========================================================================

#import "../expr.typ": *
#import "../simplify.typ": simplify, expand
#import "../helpers.typ": check-free-var as _check-free-var
#import "../core/int-math.typ": int-factors as _int-factors, int-gcd-array as _int-gcd-array-core, int-lcm as _int-lcm-core
#import "../core/expr-walk.typ": contains-var as _contains-var-core, contains-const as _contains-const-core
#import "../poly.typ": coeffs-to-expr as _coeffs-to-expr, poly-div as _poly-div, poly-gcd as _poly-gcd
#import "../rational.typ": rat, rat-add, rat-div, rat-eq, rat-from-expr, rat-from-number, rat-is-one, rat-is-zero, rat-mul, rat-neg, rat-sqrt-exact, rat-sub, rat-to-expr, rat-to-float

// --- Internal helpers ---

/// Internal helper `_contains-var-simple`.
#let _contains-var-simple(expr, v) = _contains-var-core(expr, v)

/// Internal helper `_contains-const-i`.
#let _contains-const-i(expr) = _contains-const-core(expr, "i")

/// Internal helper `_is-half-exp`.
#let _is-half-exp(e) = {
  if is-type(e, "num") and e.val == 0.5 { return true }
  if is-type(e, "div") {
    if is-type(e.num, "num") and e.num.val == 1 and is-type(e.den, "num") and e.den.val == 2 {
      return true
    }
  }
  false
}

/// Internal helper `_is-obviously-complex`.
#let _is-obviously-complex(expr) = {
  if _contains-const-i(expr) { return true }
  if is-type(expr, "pow") and _is-half-exp(expr.exp) {
    let b = simplify(expr.base)
    if is-type(b, "num") and b.val < 0 { return true }
  }
  false
}

/// Internal helper `_expr-to-rat`.
#let _expr-to-rat(expr) = rat-from-expr(simplify(expr))

/// Internal helper `_rat-array-to-floats`.
#let _rat-array-to-floats(coeffs) = coeffs.map(c => rat-to-float(c))

/// Internal helper `_trim-rat-coeffs`.
#let _trim-rat-coeffs(coeffs) = {
  let c = coeffs
  while c.len() > 1 and rat-is-zero(c.at(c.len() - 1)) {
    c = c.slice(0, c.len() - 1)
  }
  c
}

/// Internal helper `_trim-float-coeffs`.
#let _trim-float-coeffs(coeffs) = {
  let c = coeffs
  while c.len() > 1 and calc.abs(c.at(c.len() - 1)) < 1e-12 {
    c = c.slice(0, c.len() - 1)
  }
  c
}

/// Internal helper `_trim-int-coeffs`.
#let _trim-int-coeffs(coeffs) = {
  let c = coeffs
  while c.len() > 1 and c.at(c.len() - 1) == 0 {
    c = c.slice(0, c.len() - 1)
  }
  c
}

/// Internal helper `_int-gcd-array`.
#let _int-gcd-array(vals) = _int-gcd-array-core(vals)

/// Internal helper `_int-lcm`.
#let _int-lcm(a, b) = _int-lcm-core(a, b)

/// Internal helper `_rat-coeffs-to-int-primitive`.
#let _rat-coeffs-to-int-primitive(coeffs) = {
  let c = _trim-rat-coeffs(coeffs)
  let lcm = 1
  for r in c {
    lcm = _int-lcm(lcm, r.d)
  }
  let ints = ()
  for r in c {
    ints.push(int(r.n * (lcm / r.d)))
  }
  ints = _trim-int-coeffs(ints)
  let g = _int-gcd-array(ints)
  if g > 1 {
    ints = ints.map(x => int(x / g))
  }
  if ints.at(ints.len() - 1) < 0 {
    ints = ints.map(x => -x)
  }
  ints
}

/// Internal helper `_normalize-intish`.
#let _normalize-intish(coeffs) = {
  let out = ()
  for c in coeffs {
    if calc.abs(c - calc.round(c)) < 1e-8 {
      out.push(int(calc.round(c)))
    } else {
      out.push(c)
    }
  }
  out
}

/// Internal helper `_coeffs-expr-add`.
#let _coeffs-expr-add(a, b) = {
  let n = calc.max(a.len(), b.len())
  let out = (num(0),) * n
  for i in range(a.len()) {
    out.at(i) = simplify(add(out.at(i), a.at(i)))
  }
  for i in range(b.len()) {
    out.at(i) = simplify(add(out.at(i), b.at(i)))
  }
  out
}

/// Internal helper `_coeffs-expr-scale`.
#let _coeffs-expr-scale(k, coeffs) = {
  coeffs.map(c => simplify(mul(k, c)))
}

/// Internal helper `_coeffs-expr-conv`.
#let _coeffs-expr-conv(a, b) = {
  let out = (num(0),) * (a.len() + b.len() - 1)
  for i in range(a.len()) {
    for j in range(b.len()) {
      let term = simplify(mul(a.at(i), b.at(j)))
      out.at(i + j) = simplify(add(out.at(i + j), term))
    }
  }
  out
}

/// Internal helper `_trim-expr-coeffs`.
#let _trim-expr-coeffs(coeffs) = {
  let c = coeffs
  while c.len() > 1 and expr-eq(simplify(c.at(c.len() - 1)), num(0)) {
    c = c.slice(0, c.len() - 1)
  }
  c
}

// Extract polynomial coefficients as expressions (a0, a1, ..., an).
/// Internal helper `_extract-poly-coeffs-expr`.
#let _extract-poly-coeffs-expr(expr, v) = {
  let e = simplify(expr)

  if is-type(e, "num") or is-type(e, "const") {
    return (e,)
  }

  if is-type(e, "var") {
    if e.name == v { return (num(0), num(1)) }
    return (e,)
  }

  if is-type(e, "neg") {
    let inner = _extract-poly-coeffs-expr(e.arg, v)
    if inner == none { return none }
    return inner.map(c => simplify(neg(c)))
  }

  if is-type(e, "add") {
    let l = _extract-poly-coeffs-expr(e.args.at(0), v)
    let r = _extract-poly-coeffs-expr(e.args.at(1), v)
    if l == none or r == none { return none }
    return _trim-expr-coeffs(_coeffs-expr-add(l, r))
  }

  if is-type(e, "mul") {
    let l = _extract-poly-coeffs-expr(e.args.at(0), v)
    let r = _extract-poly-coeffs-expr(e.args.at(1), v)
    if l == none or r == none { return none }
    return _trim-expr-coeffs(_coeffs-expr-conv(l, r))
  }

  if is-type(e, "div") {
    if _contains-var-simple(e.den, v) { return none }
    let n = _extract-poly-coeffs-expr(e.num, v)
    if n == none { return none }
    return _trim-expr-coeffs(n.map(c => simplify(cdiv(c, e.den))))
  }

  if is-type(e, "pow") {
    if not is-type(e.exp, "num") or type(e.exp.val) != int or e.exp.val < 0 {
      return none
    }
    let base = _extract-poly-coeffs-expr(e.base, v)
    if base == none { return none }
    if e.exp.val == 0 { return (num(1),) }
    let out = base
    for _ in range(e.exp.val - 1) {
      out = _coeffs-expr-conv(out, base)
    }
    return _trim-expr-coeffs(out)
  }

  none
}

/// Internal helper `_extract-poly-rat-coeffs`.
#let _extract-poly-rat-coeffs(expr, v) = {
  let coeffs = _extract-poly-coeffs-expr(expr, v)
  if coeffs == none { return none }
  let rats = ()
  for c in coeffs {
    let r = _expr-to-rat(c)
    if r == none { return none }
    rats.push(r)
  }
  _trim-rat-coeffs(rats)
}

/// Internal helper `_rat-poly-eval`.
#let _rat-poly-eval(coeffs, x) = {
  let c = _trim-rat-coeffs(coeffs)
  let res = rat(0, 1)
  let i = c.len() - 1
  while i >= 0 {
    res = rat-add(rat-mul(res, x), c.at(i))
    i -= 1
  }
  res
}

/// Internal helper `_rat-poly-divide-linear`.
#let _rat-poly-divide-linear(coeffs, root) = {
  let c = _trim-rat-coeffs(coeffs)
  let n = c.len() - 1
  if n <= 0 { return ((rat(0, 1),), rat(0, 1)) }

  let b = (rat(0, 1),) * (n + 1)
  b.at(n) = c.at(n)
  let i = n - 1
  while i >= 0 {
    b.at(i) = rat-add(c.at(i), rat-mul(root, b.at(i + 1)))
    i -= 1
  }

  let q = ()
  for k in range(1, n + 1) {
    q.push(b.at(k))
  }
  (_trim-rat-coeffs(q), b.at(0))
}

/// Internal helper `_rat-candidate-roots`.
#let _rat-candidate-roots(int-coeffs) = {
  let c = _trim-int-coeffs(int-coeffs)
  let deg = c.len() - 1
  if deg < 1 { return () }

  let a0 = c.at(0)
  let an = c.at(deg)
  if an == 0 { return () }

  let p-factors = _int-factors(if a0 == 0 { 1 } else { a0 })
  let q-factors = _int-factors(an)
  let candidates = ()

  for p in p-factors {
    for q in q-factors {
      let g = calc.gcd(p, q)
      let pn = int(p / g)
      let qn = int(q / g)
      let r1 = rat(pn, qn)
      let r2 = rat(-pn, qn)
      let has-r1 = candidates.find(r => rat-eq(r, r1))
      if has-r1 == none { candidates.push(r1) }
      let has-r2 = candidates.find(r => rat-eq(r, r2))
      if has-r2 == none { candidates.push(r2) }
    }
  }

  candidates
}

/// Internal helper `_rat-is-integer`.
#let _rat-is-integer(r) = r.d == 1

/// Internal helper `_rat-to-root-expr`.
#let _rat-to-root-expr(r) = rat-to-expr(r)

/// Internal helper `_rat-to-complex-root`.
#let _rat-to-complex-root(re-r, im-r) = {
  let re-ex = rat-to-expr(re-r)
  let im-ex = rat-to-expr(im-r)
  if rat-is-zero(im-r) { return re-ex }
  if rat-is-zero(re-r) {
    return simplify(mul(im-ex, const-expr("i")))
  }
  simplify(add(re-ex, mul(im-ex, const-expr("i"))))
}

/// Internal helper `_rat-poly-squarefree`.
#let _rat-poly-squarefree(coeffs, v) = {
  let ints = _rat-coeffs-to-int-primitive(coeffs)
  if ints.len() <= 2 {
    return (
      primitive: ints,
      gcd: (1,),
      squarefree: ints,
    )
  }

  let deriv = ()
  for i in range(1, ints.len()) {
    deriv.push(int(i * ints.at(i)))
  }
  let gcd-coeffs = _poly-gcd(ints, deriv, v)
  let gcd-coeffs = _normalize-intish(gcd-coeffs)
  let sqf = ints
  if gcd-coeffs.len() > 1 {
    let (q, rem) = _poly-div(ints, gcd-coeffs, v)
    if rem.len() == 1 and calc.abs(rem.at(0)) < 1e-8 {
      sqf = _normalize-intish(q)
    }
  }

  (
    primitive: ints,
    gcd: gcd-coeffs,
    squarefree: sqf,
  )
}

/// Internal helper `_float-from-rat-coeffs`.
#let _float-from-rat-coeffs(coeffs) = coeffs.map(c => rat-to-float(c))

/// Internal helper `_poly-eval-at`.
#let _poly-eval-at(coeffs, x) = {
  let c = _trim-float-coeffs(coeffs)
  let y = 0.0
  let i = c.len() - 1
  while i >= 0 {
    y = y * x + c.at(i)
    i -= 1
  }
  y
}

/// Internal helper `_poly-deriv-coeffs`.
#let _poly-deriv-coeffs(coeffs) = {
  let c = _trim-float-coeffs(coeffs)
  if c.len() <= 1 { return (0.0,) }
  let d = ()
  for i in range(1, c.len()) {
    d.push(i * c.at(i))
  }
  _trim-float-coeffs(d)
}

/// Internal helper `_poly-cauchy-bound`.
#let _poly-cauchy-bound(coeffs) = {
  let c = _trim-float-coeffs(coeffs)
  let lead = calc.abs(c.at(c.len() - 1))
  if lead < 1e-16 { return 1.0 }
  let max-ratio = 0.0
  for i in range(c.len() - 1) {
    let r = calc.abs(c.at(i)) / lead
    if r > max-ratio { max-ratio = r }
  }
  1.0 + max-ratio
}

/// Internal helper `_poly-bisect-root`.
#let _poly-bisect-root(coeffs, left, right, tol: 1e-12, max-iters: 140) = {
  let a = left
  let b = right
  let fa = _poly-eval-at(coeffs, a)
  let fb = _poly-eval-at(coeffs, b)
  if calc.abs(fa) < tol { return a }
  if calc.abs(fb) < tol { return b }

  for _ in range(max-iters) {
    let m = (a + b) / 2.0
    let fm = _poly-eval-at(coeffs, m)
    if calc.abs(fm) < tol or calc.abs(b - a) < tol {
      return m
    }
    if fa * fm < 0 {
      b = m
      fb = fm
    } else {
      a = m
      fa = fm
    }
  }

  (a + b) / 2.0
}

/// Internal helper `_poly-newton-bracketed`.
#let _poly-newton-bracketed(coeffs, left, right, start, tol: 1e-12, max-iters: 50) = {
  let d = _poly-deriv-coeffs(coeffs)
  let x = start
  let ok = true

  for _ in range(max-iters) {
    let fx = _poly-eval-at(coeffs, x)
    if calc.abs(fx) < tol {
      return (root: x, ok: true)
    }
    let dfx = _poly-eval-at(d, x)
    if calc.abs(dfx) < 1e-14 {
      ok = false
      break
    }
    let nx = x - fx / dfx
    if nx < left or nx > right {
      ok = false
      break
    }
    if calc.abs(nx - x) < tol {
      return (root: nx, ok: true)
    }
    x = nx
  }

  (root: x, ok: ok)
}

/// Internal helper `_append-unique-float`.
#let _append-unique-float(values, x, tol: 1e-7) = {
  let exists = values.find(v => calc.abs(v - x) < tol)
  if exists == none { values.push(x) }
  values
}

/// Internal helper `_poly-real-roots`.
#let _poly-real-roots(coeffs) = {
  let c = _trim-float-coeffs(coeffs)
  let deg = c.len() - 1
  if deg <= 0 { return () }

  if deg == 1 {
    let a = c.at(1)
    let b = c.at(0)
    if calc.abs(a) < 1e-14 { return () }
    return ((-b / a),)
  }

  if deg == 2 {
    let a = c.at(2)
    let b = c.at(1)
    let d = c.at(0)
    if calc.abs(a) < 1e-14 { return () }
    let disc = b * b - 4.0 * a * d
    if disc < -1e-12 { return () }
    let s = calc.sqrt(if disc < 0 { 0 } else { disc })
    let roots = ()
    roots = _append-unique-float(roots, (-b + s) / (2.0 * a))
    roots = _append-unique-float(roots, (-b - s) / (2.0 * a))
    return roots
  }

  let deriv = _poly-deriv-coeffs(c)
  let crit = _poly-real-roots(deriv)
  let bound = _poly-cauchy-bound(c)

  let breaks = ()
  breaks.push(-bound)
  for r in crit {
    if r > -bound and r < bound {
      breaks = _append-unique-float(breaks, r)
    }
  }
  breaks.push(bound)

  let roots = ()

  for r in crit {
    if calc.abs(_poly-eval-at(c, r)) < 1e-8 {
      roots = _append-unique-float(roots, r)
    }
  }

  let i = 0
  while i < breaks.len() - 1 {
    let a = breaks.at(i)
    let b = breaks.at(i + 1)
    let fa = _poly-eval-at(c, a)
    let fb = _poly-eval-at(c, b)

    if calc.abs(fa) < 1e-9 {
      roots = _append-unique-float(roots, a)
    }

    if fa * fb < 0 {
      let mid = (a + b) / 2.0
      let newton = _poly-newton-bracketed(c, a, b, mid)
      let root = if newton.ok {
        newton.root
      } else {
        _poly-bisect-root(c, a, b)
      }
      roots = _append-unique-float(roots, root)
    }

    i += 1
  }

  let fend = _poly-eval-at(c, bound)
  if calc.abs(fend) < 1e-9 {
    roots = _append-unique-float(roots, bound)
  }

  roots
}

// --- Complex numeric helpers ---

/// Internal helper `_cx`.
#let _cx(re, im) = (re: re, im: im)
/// Internal helper `_cx-add`.
#let _cx-add(a, b) = (re: a.re + b.re, im: a.im + b.im)
/// Internal helper `_cx-sub`.
#let _cx-sub(a, b) = (re: a.re - b.re, im: a.im - b.im)
/// Internal helper `_cx-mul`.
#let _cx-mul(a, b) = (re: a.re * b.re - a.im * b.im, im: a.re * b.im + a.im * b.re)
/// Internal helper `_cx-scale`.
#let _cx-scale(a, k) = (re: a.re * k, im: a.im * k)
/// Internal helper `_cx-abs2`.
#let _cx-abs2(a) = a.re * a.re + a.im * a.im
/// Internal helper `_cx-abs`.
#let _cx-abs(a) = calc.sqrt(_cx-abs2(a))
/// Internal helper `_cx-div`.
#let _cx-div(a, b) = {
  let den = b.re * b.re + b.im * b.im
  if den < 1e-18 { return none }
  (
    re: (a.re * b.re + a.im * b.im) / den,
    im: (a.im * b.re - a.re * b.im) / den,
  )
}

/// Internal helper `_poly-eval-cx`.
#let _poly-eval-cx(coeffs, z) = {
  let c = _trim-float-coeffs(coeffs)
  let out = _cx(0.0, 0.0)
  let i = c.len() - 1
  while i >= 0 {
    out = _cx-add(_cx-mul(out, z), _cx(c.at(i), 0.0))
    i -= 1
  }
  out
}

/// Internal helper `_poly-complex-roots`.
#let _poly-complex-roots(coeffs, max-iters: 200, tol: 1e-12) = {
  let c0 = _trim-float-coeffs(coeffs)
  let n = c0.len() - 1
  if n <= 0 { return () }

  // Normalize to monic for Durand-Kerner stability.
  let lead = c0.at(n)
  if calc.abs(lead) < 1e-16 { return () }
  let c = c0.map(x => x / lead)

  let radius = 1.0 + c.slice(0, n).fold(0.0, (acc, v) => calc.max(acc, calc.abs(v)))
  let roots = ()
  for k in range(n) {
    let theta = 2.0 * calc.pi * k / n
    roots.push(_cx(radius * calc.cos(theta), radius * calc.sin(theta)))
  }

  for _ in range(max-iters) {
    let max-step = 0.0
    let next = ()

    for i in range(n) {
      let zi = roots.at(i)
      let pz = _poly-eval-cx(c, zi)

      let den = _cx(1.0, 0.0)
      for j in range(n) {
        if i == j { continue }
        den = _cx-mul(den, _cx-sub(zi, roots.at(j)))
      }

      let frac = _cx-div(pz, den)
      if frac == none {
        // tiny denominator: keep current point, try again
        next.push(zi)
        continue
      }

      let zi2 = _cx-sub(zi, frac)
      let step = _cx-abs(_cx-sub(zi2, zi))
      if step > max-step { max-step = step }
      next.push(zi2)
    }

    roots = next
    if max-step < tol { break }
  }

  roots
}

/// Internal helper `_cluster-complex-roots`.
#let _cluster-complex-roots(roots, tol: 1e-6) = {
  let clusters = ()
  for z in roots {
    let found-idx = none
    for i in range(clusters.len()) {
      let c = clusters.at(i)
      let dz = _cx-sub(z, c.center)
      if _cx-abs(dz) < tol {
        found-idx = i
        break
      }
    }

    if found-idx == none {
      clusters.push((center: z, count: 1))
    } else {
      let i = found-idx
      let c = clusters.at(i)
      let cnt = c.count + 1
      let center = _cx(
        (c.center.re * c.count + z.re) / cnt,
        (c.center.im * c.count + z.im) / cnt,
      )
      clusters.at(i) = (center: center, count: cnt)
    }
  }
  clusters
}

/// Internal helper `_num-from-float`.
#let _num-from-float(x) = {
  if calc.abs(x - calc.round(x)) < 1e-10 {
    return num(int(calc.round(x)))
  }
  num(x)
}

/// Internal helper `_complex-to-expr`.
#let _complex-to-expr(z) = {
  let re = if calc.abs(z.re) < 1e-10 { 0.0 } else { z.re }
  let im = if calc.abs(z.im) < 1e-10 { 0.0 } else { z.im }

  if calc.abs(im) < 1e-10 {
    return _num-from-float(re)
  }

  let re-ex = _num-from-float(re)
  let im-ex = _num-from-float(im)
  let imag-ex = simplify(mul(im-ex, const-expr("i")))

  if calc.abs(re) < 1e-10 {
    return imag-ex
  }
  simplify(add(re-ex, imag-ex))
}

/// Internal helper `_quadratic-exact-or-symbolic`.
#let _quadratic-exact-or-symbolic(a, b, c) = {
  // Returns none if exact branch cannot handle and numeric fallback should be used.
  let twoa = rat-mul(rat(2, 1), a)
  if rat-is-zero(twoa) { return none }

  let disc = rat-sub(rat-mul(b, b), rat-mul(rat(4, 1), rat-mul(a, c)))
  let negb = rat-neg(b)

  if disc.n >= 0 {
    let s = rat-sqrt-exact(disc)
    if s == none { return none }
    let r1 = rat-div(rat-add(negb, s), twoa)
    let r2 = rat-div(rat-sub(negb, s), twoa)
    return (
      (expr: _rat-to-root-expr(r1), multiplicity: 1, exact: true, numeric: false, complex: false),
      (expr: _rat-to-root-expr(r2), multiplicity: 1, exact: true, numeric: false, complex: false),
    )
  }

  // Negative discriminant => complex roots.
  let absd = rat-neg(disc)
  let s = rat-sqrt-exact(absd)
  if s == none { return none }

  let re = rat-div(negb, twoa)
  let im = rat-div(s, twoa)
  let z1 = _rat-to-complex-root(re, im)
  let z2 = _rat-to-complex-root(re, rat-neg(im))
  (
    (expr: z1, multiplicity: 1, exact: true, numeric: false, complex: true),
    (expr: z2, multiplicity: 1, exact: true, numeric: false, complex: true),
  )
}

/// Internal helper `_root-rec`.
#let _root-rec(expr, multiplicity: 1, exact: false, numeric: true, complex: false, approx: none) = (
  expr: expr,
  multiplicity: multiplicity,
  exact: exact,
  numeric: numeric,
  complex: complex,
  approx: approx,
)

/// Internal helper `_append-merged-root`.
#let _append-merged-root(roots, root) = {
  let out = ()
  let merged = false
  for r in roots {
    if not merged and expr-eq(r.expr, root.expr) and r.exact == root.exact and r.numeric == root.numeric and r.complex == root.complex {
      out.push(_root-rec(
        r.expr,
        multiplicity: r.multiplicity + root.multiplicity,
        exact: r.exact,
        numeric: r.numeric,
        complex: r.complex,
        approx: r.approx,
      ))
      merged = true
    } else {
      out.push(r)
    }
  }
  if not merged { out.push(root) }
  out
}

/// Internal helper `_lift-biquadratic-exact`.
#let _lift-biquadratic-exact(a, b, c) = {
  // Solve a*y^2 + b*y + c = 0, then map y = x^2.
  let y-roots = _quadratic-exact-or-symbolic(a, b, c)
  if y-roots == none { return none }

  let roots = ()
  for yr in y-roots {
    let y = yr.expr
    let m = yr.multiplicity
    if expr-eq(y, num(0)) {
      roots = _append-merged-root(
        roots,
        _root-rec(num(0), multiplicity: 2 * m, exact: true, numeric: false, complex: false),
      )
      continue
    }

    let sy = simplify(sqrt-of(y))
    roots = _append-merged-root(
      roots,
      _root-rec(
        sy,
        multiplicity: m,
        exact: true,
        numeric: false,
        complex: _is-obviously-complex(sy),
      ),
    )

    let nsy = simplify(neg(sy))
    roots = _append-merged-root(
      roots,
      _root-rec(
        nsy,
        multiplicity: m,
        exact: true,
        numeric: false,
        complex: _is-obviously-complex(nsy),
      ),
    )
  }
  roots
}

/// Internal helper `_build-factor-form`.
#let _build-factor-form(roots, v, lead: num(1)) = {
  if roots.len() == 0 { return lead }

  let x = cvar(v)
  let factors = ()
  for r in roots {
    let base = simplify(sub(x, r.expr))
    if r.multiplicity > 1 {
      factors.push(pow(base, num(r.multiplicity)))
    } else {
      factors.push(base)
    }
  }

  let prod = factors.at(0)
  for i in range(1, factors.len()) {
    // Keep product factored for readability in metadata display.
    prod = mul(prod, factors.at(i))
  }

  if expr-eq(lead, num(1)) {
    prod
  } else {
    mul(lead, prod)
  }
}

/// Internal helper `_unique-root-exprs`.
#let _unique-root-exprs(roots) = {
  let uniq = ()
  for r in roots {
    let hit = uniq.find(u => expr-eq(u, r.expr))
    if hit == none {
      uniq.push(r.expr)
    }
  }
  uniq
}

/// Internal helper `_solve-polynomial-metadata`.
#let _solve-polynomial-metadata(poly-expr, v) = {
  let coeffs = _extract-poly-rat-coeffs(poly-expr, v)
  if coeffs == none {
    return none
  }
  coeffs = _trim-rat-coeffs(coeffs)
  let degree = coeffs.len() - 1

  let lead = rat-to-expr(coeffs.at(coeffs.len() - 1))

  if degree <= 0 {
    return (
      variable: v,
      degree: degree,
      roots: (),
      factor-form: rat-to-expr(coeffs.at(0)),
      lead: lead,
      square-free-gcd: num(1),
      square-free-part: rat-to-expr(coeffs.at(0)),
      has-repeated-roots: false,
      method: "constant",
    )
  }

  let sqf = _rat-poly-squarefree(coeffs, v)
  let gcd-expr = _coeffs-to-expr(sqf.gcd, v)
  let sqf-expr = _coeffs-to-expr(sqf.squarefree, v)
  let has-repeat = sqf.gcd.len() > 1

  // 1) Extract exact rational roots (with multiplicity).
  let remaining = coeffs
  let roots = ()

  // Repeated zero roots.
  let zero-m = 0
  while remaining.len() > 1 and rat-is-zero(remaining.at(0)) {
    zero-m += 1
    remaining = _trim-rat-coeffs(remaining.slice(1))
  }
  if zero-m > 0 {
    roots.push(_root-rec(num(0), multiplicity: zero-m, exact: true, numeric: false, complex: false))
  }

  let guard = 0
  while remaining.len() > 1 and guard < 64 {
    guard += 1

    let ints = _rat-coeffs-to-int-primitive(remaining)
    if ints.len() <= 1 { break }

    let candidates = _rat-candidate-roots(ints)
    let found = false

    for cand in candidates {
      let val = _rat-poly-eval(remaining, cand)
      if rat-is-zero(val) {
        let m = 0
        while remaining.len() > 1 {
          let v0 = _rat-poly-eval(remaining, cand)
          if not rat-is-zero(v0) { break }
          let (q, rem) = _rat-poly-divide-linear(remaining, cand)
          if not rat-is-zero(rem) { break }
          remaining = q
          m += 1
        }

        roots.push(_root-rec(_rat-to-root-expr(cand), multiplicity: m, exact: true, numeric: false, complex: false))
        found = true
        break
      }
    }

    if not found { break }
  }

  remaining = _trim-rat-coeffs(remaining)

  // 2) Remaining tail: exact quadratic when possible, otherwise numeric complex roots.
  let rem-deg = remaining.len() - 1
  if rem-deg == 1 {
    let b = remaining.at(0)
    let a = remaining.at(1)
    if not rat-is-zero(a) {
      let r = rat-div(rat-neg(b), a)
      roots.push(_root-rec(_rat-to-root-expr(r), multiplicity: 1, exact: true, numeric: false, complex: false))
    }
  } else if rem-deg == 2 {
    let c = remaining.at(0)
    let b = remaining.at(1)
    let a = remaining.at(2)
    let exact-q = _quadratic-exact-or-symbolic(a, b, c)
    if exact-q != none {
      for rr in exact-q {
        roots.push(rr)
      }
    } else {
      let floats = _float-from-rat-coeffs(remaining)
      let zs = _poly-complex-roots(floats)
      let clusters = _cluster-complex-roots(zs)
      for cl in clusters {
        let z = cl.center
        let cpx = calc.abs(z.im) > 1e-8
        roots.push(_root-rec(
          _complex-to-expr(z),
          multiplicity: cl.count,
          exact: false,
          numeric: true,
          complex: cpx,
          approx: (re: z.re, im: z.im),
        ))
      }
    }
  } else if rem-deg == 4 {
    // Exact biquadratic path: a*x^4 + b*x^2 + c.
    let c = remaining.at(0)
    let b1 = remaining.at(1)
    let b2 = remaining.at(2)
    let b3 = remaining.at(3)
    let a = remaining.at(4)

    let handled = false
    if rat-is-zero(b1) and rat-is-zero(b3) {
      let lifted = _lift-biquadratic-exact(a, b2, c)
      if lifted != none {
        for rr in lifted {
          roots.push(rr)
        }
        handled = true
      }
    }

    if not handled {
      let floats = _float-from-rat-coeffs(remaining)
      let zs = _poly-complex-roots(floats)
      let clusters = _cluster-complex-roots(zs)
      let refined-real = _poly-real-roots(floats)
      for cl in clusters {
        let z = cl.center
        if calc.abs(z.im) < 1e-4 and refined-real.len() > 0 {
          let best = z.re
          let best-d = 1e99
          for rr in refined-real {
            let d = calc.abs(rr - z.re)
            if d < best-d {
              best-d = d
              best = rr
            }
          }
          if best-d < 0.25 {
            z = (re: best, im: 0.0)
          }
        }
        let cpx = calc.abs(z.im) > 1e-8
        roots.push(_root-rec(
          _complex-to-expr(z),
          multiplicity: cl.count,
          exact: false,
          numeric: true,
          complex: cpx,
          approx: (re: z.re, im: z.im),
        ))
      }
    }
  } else if rem-deg >= 3 {
    let floats = _float-from-rat-coeffs(remaining)
    let zs = _poly-complex-roots(floats)
    let clusters = _cluster-complex-roots(zs)
    let refined-real = _poly-real-roots(floats)
    for cl in clusters {
      let z = cl.center
      if calc.abs(z.im) < 1e-4 and refined-real.len() > 0 {
        let best = z.re
        let best-d = 1e99
        for rr in refined-real {
          let d = calc.abs(rr - z.re)
          if d < best-d {
            best-d = d
            best = rr
          }
        }
        if best-d < 0.25 {
          z = (re: best, im: 0.0)
        }
      }
      let cpx = calc.abs(z.im) > 1e-8
      roots.push(_root-rec(
        _complex-to-expr(z),
        multiplicity: cl.count,
        exact: false,
        numeric: true,
        complex: cpx,
        approx: (re: z.re, im: z.im),
      ))
    }
  }

  // Keep roots in stable canonical order: exact first, then real numeric, then complex numeric.
  let ordered = ()
  let exact-roots = roots.filter(r => r.exact)
  let real-num = roots.filter(r => (not r.exact) and (not r.complex))
  let complex-num = roots.filter(r => (not r.exact) and r.complex)
  ordered = exact-roots + real-num + complex-num

  let factor-form = _build-factor-form(ordered, v, lead: lead)

  (
    variable: v,
    degree: degree,
    roots: ordered,
    factor-form: factor-form,
    lead: lead,
    square-free-gcd: gcd-expr,
    square-free-part: sqf-expr,
    has-repeated-roots: has-repeat,
    method: "rational+numeric-complex",
  )
}

// --- Lightweight linear/quadratic fallback for non-polynomial extraction ---

/// Internal helper `_linear-coeffs`.
#let _linear-coeffs(expr, v) = {
  let e = simplify(expr)

  if is-type(e, "var") and e.name == v {
    return (a: num(1), b: num(0))
  }

  if is-type(e, "num") or is-type(e, "const") {
    return (a: num(0), b: e)
  }

  if is-type(e, "neg") {
    if is-type(e.arg, "var") and e.arg.name == v {
      return (a: num(-1), b: num(0))
    }
    let inner = _linear-coeffs(e.arg, v)
    if inner != none {
      return (a: simplify(neg(inner.a)), b: simplify(neg(inner.b)))
    }
  }

  if is-type(e, "mul") {
    let l = e.args.at(0)
    let r = e.args.at(1)
    if not _contains-var-simple(l, v) and is-type(r, "var") and r.name == v {
      return (a: l, b: num(0))
    }
    if not _contains-var-simple(r, v) and is-type(l, "var") and l.name == v {
      return (a: r, b: num(0))
    }
    if not _contains-var-simple(l, v) and not _contains-var-simple(r, v) {
      return (a: num(0), b: e)
    }
  }

  if is-type(e, "add") {
    let lc = _linear-coeffs(e.args.at(0), v)
    let rc = _linear-coeffs(e.args.at(1), v)
    if lc != none and rc != none {
      return (
        a: simplify(add(lc.a, rc.a)),
        b: simplify(add(lc.b, rc.b)),
      )
    }
  }

  none
}

/// Internal helper `_quadratic-coeffs`.
#let _quadratic-coeffs(expr, v) = {
  let e = simplify(expr)

  if is-type(e, "pow") and is-type(e.base, "var") and e.base.name == v {
    if is-type(e.exp, "num") and e.exp.val == 2 {
      return (a: num(1), b: num(0), c: num(0))
    }
  }

  if is-type(e, "mul") {
    let l = e.args.at(0)
    let r = e.args.at(1)
    if not _contains-var-simple(l, v) and is-type(r, "pow") {
      if is-type(r.base, "var") and r.base.name == v and is-type(r.exp, "num") and r.exp.val == 2 {
        return (a: l, b: num(0), c: num(0))
      }
    }
  }

  if is-type(e, "add") {
    let l = e.args.at(0)
    let r = e.args.at(1)

    let lq = _quadratic-coeffs(l, v)
    let rq = _quadratic-coeffs(r, v)

    if lq != none and rq != none {
      return (
        a: simplify(add(lq.a, rq.a)),
        b: simplify(add(lq.b, rq.b)),
        c: simplify(add(lq.c, rq.c)),
      )
    }

    if lq != none {
      let rl = _linear-coeffs(r, v)
      if rl != none {
        return (
          a: lq.a,
          b: simplify(add(lq.b, rl.a)),
          c: simplify(add(lq.c, rl.b)),
        )
      }
    }
    if rq != none {
      let ll = _linear-coeffs(l, v)
      if ll != none {
        return (
          a: rq.a,
          b: simplify(add(rq.b, ll.a)),
          c: simplify(add(rq.c, ll.b)),
        )
      }
    }
  }

  let lin = _linear-coeffs(e, v)
  if lin != none {
    return (a: num(0), b: lin.a, c: lin.b)
  }

  none
}

// =========================================================================
// Public API
// =========================================================================

/// Solve equation lhs = rhs and return roots only (backward-compatible API).
#let solve(lhs, rhs, v) = {
  _check-free-var(v)
  let lhs = if type(lhs) == int or type(lhs) == float { num(lhs) } else { lhs }
  let rhs = if type(rhs) == int or type(rhs) == float { num(rhs) } else { rhs }
  let combined = simplify(sub(lhs, rhs))

  let meta = _solve-polynomial-metadata(combined, v)
  if meta != none and meta.roots.len() > 0 {
    return _unique-root-exprs(meta.roots)
  }

  // Non-polynomial fallback (linear/quadratic symbolic handling)
  let lin = _linear-coeffs(combined, v)
  if lin != none and not expr-eq(lin.a, num(0)) {
    return (simplify(cdiv(neg(lin.b), lin.a)),)
  }

  let quad = _quadratic-coeffs(combined, v)
  if quad != none and not expr-eq(quad.a, num(0)) {
    let a = quad.a
    let b = quad.b
    let c = quad.c

    let disc = simplify(sub(pow(b, num(2)), mul(num(4), mul(a, c))))
    let neg-b = neg(b)
    let two-a = mul(num(2), a)

    // Complex-safe quadratic branch.
    if is-type(disc, "num") and disc.val < 0 {
      let absd = num(calc.abs(disc.val))
      let imag = simplify(mul(sqrt-of(absd), const-expr("i")))
      let sol1 = simplify(cdiv(add(neg-b, imag), two-a))
      let sol2 = simplify(cdiv(sub(neg-b, imag), two-a))
      return (sol1, sol2)
    }

    let sqrt-disc = pow(disc, cdiv(num(1), num(2)))
    let sol1 = simplify(cdiv(add(neg-b, sqrt-disc), two-a))
    let sol2 = simplify(cdiv(sub(neg-b, sqrt-disc), two-a))
    return (sol1, sol2)
  }

  ()
}

/// Solve polynomial equation and return full metadata.
#let solve-meta(lhs, rhs, v) = {
  _check-free-var(v)
  let lhs = if type(lhs) == int or type(lhs) == float { num(lhs) } else { lhs }
  let rhs = if type(rhs) == int or type(rhs) == float { num(rhs) } else { rhs }
  let combined = simplify(expand(sub(lhs, rhs)))

  let meta = _solve-polynomial-metadata(combined, v)
  if meta != none {
    return meta
  }

  // Fallback metadata for unsupported/non-polynomial forms.
  let roots = solve(lhs, rhs, v).map(r => _root-rec(r, multiplicity: 1, exact: false, numeric: true, complex: false))
  (
    variable: v,
    degree: none,
    roots: roots,
    factor-form: none,
    lead: none,
    square-free-gcd: none,
    square-free-part: none,
    has-repeated-roots: false,
    method: "fallback",
  )
}

/// Factor polynomial expression using metadata roots.
#let factor(expr, v) = {
  _check-free-var(v)
  let poly = simplify(expand(expr))
  let meta = _solve-polynomial-metadata(poly, v)
  if meta == none or meta.factor-form == none { return simplify(expr) }
  meta.factor-form
}
