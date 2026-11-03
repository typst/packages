// Numeric evaluation with derivatives, unit inference, polynomials and root finding.
/// ## How it solves
///
/// If the unknown occurs once it is isolated symbolically (with substitution shown). Equations linear in it are solved symbolically too. Polynomials → all real roots (any degree). Anything else → numeric search over ±10⁻¹⁵…10¹⁵ (times the target unit): sign changes are bisected and Newton starts from every local minimum of the absolute value. Systems: equations with a single unknown are solved symbolically first, the rest by damped Newton from 33 starts. Units of unknowns are inferred from the equations; mismatched units stop with an error.
///
/// ## Limits
///
/// Found by the fuzzer (`tests/fuzz.py`: random equations, quantities, options and hostile inputs checked against Python):
///
/// - **Numbers** are 64-bit floats: about 15 significant digits, magnitudes up to 10³⁰⁰. Results that underflow show as 0 (`ln(x) = -800`).
/// - **Isolating** `x^2 = 4` or `sqrt` gives only the positive root, periodic functions only the principal value (`tan(x) = 1` → `atan(1)`). Pass `root:` or `guess:` to use the numeric search, which finds the others.
/// - **Numeric search** can miss roots squeezed between nearby poles, roots of very fast oscillations, and roots outside ±10¹⁵ (scaled by the target unit). In random nonlinear equations this hit about 0.1 %; the result then says "no real solution".
/// - **Systems** are solved numerically from a fixed set of starts; solutions far away from them can be missed. Underdetermined systems (`x + y = 2`, `2x + 2y = 4`) show one arbitrary solution.
/// - **Nesting:** up to about 20 levels of brackets (Typst's function call depth); sums and products of any length are fine.
/// - **Domains:** only real numbers; `(-8)^(1/3)` and `sqrt(-1)` are errors, as is an unknown that cancels out (`x - x`).
/// - **°C** is a temperature difference (no 273.15 offset); temperatures in formulas like `p V = n R T` need K. New base dimensions (bit, €) can't be added.
/// - **Prefixes:** a lone `m` before a unit is metre: `"m s"`, `$"m" Omega$` are m·s and Ω·m; write `"ms"`, `$"m"Omega$` for milli.
/// - **Functions** are expanded where they are used (no recursion); `f(x) = 9` with an existing `f` is an equation, not a new definition.
/// - **Math in solve-block:** every equation with `=` is evaluated, also ones meant as plain text (`$a^2 + b^2 = c^2$` with unknown a, b, c is an error). Put those outside the block or use `equations: false`.

#import "expr.typ": *

// ---------- numeric evaluation with derivatives (dual numbers) ----------
// env: name -> (value, grad | none); grad none means zero. Returns (value, grad) or none on a domain error.
#let _lc(p, g, q: 0, h: none) = if g == none and h == none { none } else if h == none { g.map(x => p * x) } else if g == none { h.map(y => q * y) } else { g.zip(h).map(((x, y)) => p * x + q * y) }
#let _nd(e, env) = {
  let (k, ..a) = e
  let r = if k == "n" { (float(a.first()), none) }
  else if k == "q" { (float(a.first().v), none) }
  else if k == "c" { (if a.first() == "e" { calc.e } else { calc.pi }, none) }
  else if k == "v" {
    let x = env.at(a.first(), default: none)
    if x == none { return none }
    x
  } else {
    let xs = ()
    for t in a.filter(t => type(t) == array) { let y = _nd(t, env); if y == none { return none }; xs.push(y) }
    if k == "-" { let (v, g) = xs.first(); (-v, _lc(-1, g)) }
    else if k == "+" { xs.reduce(((v, g), (w, h)) => (v + w, _lc(1, g, q: 1, h: h))) }
    else if k == "*" { xs.reduce(((v, g), (w, h)) => (v * w, _lc(w, g, q: v, h: h))) }
    else if k == "/" {
      let ((v, g), (w, h)) = xs
      if w == 0 or w * w == 0 { return none }
      (v / w, _lc(1 / w, g, q: -v / (w * w), h: h))
    } else if k == "^" {
      let ((b, g), (x, h)) = xs
      if h == none {
        let xi = calc.abs(x) < 1e9 and calc.round(x) == x
        if b == 0 {
          if x < 0 or (x < 1 and g != none) { return none }
          (if x == 0 { 1.0 } else { 0.0 }, _lc(if x == 1 { 1 } else { 0 }, g))
        } else {
          if b < 0 and not xi { return none }
          if x * calc.ln(calc.abs(b)) > 690 { return none }
          let v = if xi { calc.pow(b, int(x)) } else { calc.pow(b, x) }
          (v, _lc(x * v / b, g))
        }
      } else {
        if b <= 0 or x * calc.ln(b) > 690 { return none }
        let v = calc.exp(x * calc.ln(b))
        (v, _lc(v * x / b, g, q: v * calc.ln(b), h: h))
      }
    } else {
      let f = a.first()
      let (v, g) = xs.first()
      if f == "sqrt" {
        if v < 0 or (v == 0 and g != none) { return none }
        let s = calc.sqrt(v); (s, if v == 0 { none } else { _lc(0.5 / s, g) })
      } else if f == "exp" { if v > 690 { return none }; let y = calc.exp(v); (y, _lc(y, g)) }
      else if f == "ln" { if v <= 0 { return none }; (calc.ln(v), _lc(1 / v, g)) }
      else if f == "log" { if v <= 0 { return none }; (calc.log(v), _lc(1 / (v * calc.ln(10)), g)) }
      else if f == "sin" { (calc.sin(v), _lc(calc.cos(v), g)) }
      else if f == "cos" { (calc.cos(v), _lc(-calc.sin(v), g)) }
      else if f == "tan" { let c = calc.cos(v); if c == 0 { return none }; (calc.tan(v), _lc(1 / (c * c), g)) }
      else if f in ("asin", "acos") {
        if calc.abs(v) > 1 or (calc.abs(v) == 1 and g != none) { return none }
        let y = if f == "asin" { calc.asin(v).rad() } else { calc.acos(v).rad() }
        (y, if calc.abs(v) == 1 { none } else { _lc((if f == "asin" { 1 } else { -1 }) / calc.sqrt(1 - v * v), g) })
      } else if f == "atan" { (calc.atan(v).rad(), _lc(1 / (1 + v * v), g)) }
      else { (calc.abs(v), _lc(if v < 0 { -1 } else { 1 }, g)) }
    }
  }
  if not _ok(r.at(0)) or (r.at(1) != none and r.at(1).any(z => not _ok(z))) { none } else { r }
}
#let _env(d) = d.pairs().filter(p => p.at(0) not in _SP).map(((k, q)) => (k, (float(q.v), none))).to-dict()

// ---------- infer units of the unknowns ----------
// a dimension is (c, a): c + Σ a_j·dim(x_j); none = literal 0 (fits any unit)
#let _dx(e, d, env, xs) = {
  let n = xs.len()
  let K(c) = (c, range(n).map(_ => 0.0))
  let (k, ..a) = e
  if k == "n" { return (if a.first() == 0 { none } else { K(_Z) }, ()) }
  if k == "c" { return (K(_Z), ()) }
  if k == "q" { return (K(a.first().d), ()) }
  if k == "v" {
    let i = xs.position(y => y == a.first())
    if i != none { return ((_Z, range(n).map(j => if j == i { 1.0 } else { 0.0 })), ()) }
    let q = d.at(a.first(), default: none)
    if q == none { return _err("unknown variable '" + a.first() + "'") }
    return (K(q.d), ())
  }
  let sub = a.filter(t => type(t) == array).map(t => _dx(t, d, env, xs))
  let b = _first-err(sub)
  if b != none { return b }
  let cons = sub.map(s => s.at(1)).sum(default: ())
  let ds = sub.map(s => s.at(0))
  let A(x, y, s: 1) = (x.at(0).zip(y.at(0)).map(((p, q)) => p + s * q), x.at(1).zip(y.at(1)).map(((p, q)) => p + s * q))
  let S(x, f) = (x.at(0).map(z => z * f), x.at(1).map(z => z * f))
  let eq(x, y) = if x == none or y == none { () } else { (A(x, y, s: -1),) }
  if k == "-" { (ds.first(), cons) }
  else if k == "+" {
    let nn = ds.filter(x => x != none)
    if nn.len() == 0 { (none, cons) } else { (nn.first(), cons + nn.slice(1).map(x => A(x, nn.first(), s: -1))) }
  }
  else if k == "*" { (if none in ds { none } else { ds.reduce(A) }, cons) }
  else if k == "/" { let (x, y) = ds; (if x == none { none } else if y == none { K(_Z) } else { A(x, y, s: -1) }, cons) }
  else if k == "^" {
    let (b, x) = ds
    if xs.any(v => _has(a.at(1), v)) { (K(_Z), cons + eq(b, K(_Z)) + eq(x, K(_Z))) }
    else {
      let p = _nd(a.at(1), env)
      if p == none { return _err("cannot evaluate an exponent") }
      (if b == none { none } else { S(b, p.at(0)) }, cons + eq(x, K(_Z)))
    }
  } else {
    let (f, _) = a
    let b = ds.first()
    if f == "sqrt" { (if b == none { none } else { S(b, 0.5) }, cons) }
    else if f == "abs" { (b, cons) }
    else { (K(_Z), cons + eq(b, K(_Z))) }
  }
}
// -> (dims per unknown, indices whose unit is not determined)
#let _dims(eqs, d, env, xs) = {
  let n = xs.len()
  let cons = ()
  for (L, R) in eqs {
    let l1 = _dx(L, d, env, xs)
    let r1 = _dx(R, d, env, xs)
    if _E(l1) { return l1 }
    if _E(r1) { return r1 }
    let (l, c1) = l1
    let (r, c2) = r1
    cons += c1 + c2
    if l != none and r != none { cons.push((l.at(0).zip(r.at(0)).map(((p, q)) => p - q), l.at(1).zip(r.at(1)).map(((p, q)) => p - q))) }
  }
  let rows = cons.map(((c, a)) => a + c.map(z => -z))
  let piv = ()
  let r = 0
  for col in range(n) {
    let p = none
    for i in range(r, rows.len()) {
      if calc.abs(rows.at(i).at(col)) > 1e-9 and (p == none or calc.abs(rows.at(i).at(col)) > calc.abs(rows.at(p).at(col))) { p = i }
    }
    if p == none { continue }
    let t = rows.at(p); rows.at(p) = rows.at(r); rows.at(r) = t.map(z => z / t.at(col))
    for i in range(rows.len()) {
      if i != r and rows.at(i).at(col) != 0 {
        let f = rows.at(i).at(col)
        rows.at(i) = rows.at(i).zip(rows.at(r)).map(((x, y)) => x - f * y)
      }
    }
    piv.push((col, r)); r += 1
  }
  for i in range(r, rows.len()) {
    if rows.at(i).slice(n).any(z => calc.abs(z) > 1e-6) { return _err("the units in these equations don't match") }
  }
  let D = range(n).map(_ => _Z)
  for (col, i) in piv { D.at(col) = rows.at(i).slice(n).map(z => calc.round(z, digits: 6)) }
  (D, range(n).filter(j => j not in piv.map(p => p.at(0))))
}

// ---------- polynomials ----------
#let _pa(..ts) = { let ts = ts.pos().filter(t => t != ("n", 0)); if ts.len() == 0 { ("n", 0) } else if ts.len() == 1 { ts.first() } else { ("+", ..ts) } }
#let _pm(a, b) = if a == ("n", 0) or b == ("n", 0) { ("n", 0) } else if a == ("n", 1) { b } else if b == ("n", 1) { a } else { ("*", a, b) }
#let _pmul(p, q) = range(p.len() + q.len() - 1).map(i => _pa(..range(calc.max(0, i - q.len() + 1), calc.min(i, p.len() - 1) + 1).map(j => _pm(p.at(j), q.at(i - j)))))
// expression -> coefficient expressions (ascending powers of x), or none if not a polynomial in x
#let _poly(e, x) = {
  if not _has(e, x) { return (e,) }
  let (k, ..a) = e
  if k == "v" { return (("n", 0), ("n", 1)) }
  if k == "-" { let p = _poly(a.first(), x); return if p == none { none } else { p.map(c => if c == ("n", 0) { c } else { ("-", c) }) } }
  if k == "+" or k == "*" {
    let ps = a.map(t => _poly(t, x))
    if none in ps { return none }
    if k == "*" { return ps.reduce(_pmul) }
    let m = calc.max(..ps.map(p => p.len()))
    return range(m).map(i => _pa(..ps.map(p => p.at(i, default: ("n", 0)))))
  }
  if k == "/" {
    if _has(a.at(1), x) { return none }
    let p = _poly(a.at(0), x)
    return if p == none { none } else { p.map(c => if c == ("n", 0) { c } else { ("/", c, a.at(1)) }) }
  }
  if k == "^" {
    let y = a.at(1)
    if y.at(0) != "n" or y.at(1) < 0 or y.at(1) > 20 or calc.round(y.at(1)) != y.at(1) { return none }
    let p = _poly(a.at(0), x)
    if p == none { return none }
    return range(int(y.at(1))).fold((("n", 1),), (r, _) => _pmul(r, p))
  }
  none
}
// complex helpers
#let _cm(a, b) = (a.at(0) * b.at(0) - a.at(1) * b.at(1), a.at(0) * b.at(1) + a.at(1) * b.at(0))
#let _cs(a, b) = (a.at(0) - b.at(0), a.at(1) - b.at(1))
#let _cabs(a) = calc.sqrt(a.at(0) * a.at(0) + a.at(1) * a.at(1))
#let _cd(a, b) = { let n = b.at(0) * b.at(0) + b.at(1) * b.at(1); ((a.at(0) * b.at(0) + a.at(1) * b.at(1)) / n, (a.at(1) * b.at(0) - a.at(0) * b.at(1)) / n) }
#let _uniq(rs) = {
  let out = ()
  for r in rs.sorted() { if out.len() == 0 or calc.abs(r - out.last()) > 1e-7 * calc.max(calc.abs(r), calc.abs(out.last())) { out.push(r) } }
  out
}
// real roots of Σ c_i x^i (float coefficients, highest ≠ 0), ascending
#let _roots(c) = {
  let z = 0
  while c.at(z) == 0 { z += 1 }
  let c = c.slice(z)
  let n = c.len() - 1
  let rs = if z > 0 { (0.0,) } else { () }
  if n == 1 { rs.push(-c.at(0) / c.at(1)) }
  else if n == 2 {
    let (cc, b, a) = c
    let D = b * b - 4 * a * cc
    if D < 0 and -D <= 1e-12 * b * b { D = 0 }
    if D >= 0 {
      let q = -0.5 * (b + (if b >= 0 { 1 } else { -1 }) * calc.sqrt(D))
      rs += (q / a, cc / q)
    }
  } else if n > 2 {
    // Durand–Kerner on the rescaled monic polynomial (roots of size ~1)
    let R = calc.pow(calc.abs(c.at(0) / c.at(n)), 1 / n)
    let m = range(n + 1).map(i => c.at(i) / c.at(n) * calc.pow(R, i - n))
    let zs = range(n).map(k => { let t = 2 * calc.pi * k / n + 0.4; (calc.cos(t), calc.sin(t)) })
    for it in range(800) {
      let mx = 0
      for k in range(n) {
        let zk = zs.at(k)
        let p = (1.0, 0.0)
        for i in range(n - 1, -1, step: -1) { p = _cm(p, zk); p.at(0) += m.at(i) }
        let den = (1.0, 0.0)
        for j in range(n) { if j != k { den = _cm(den, _cs(zk, zs.at(j))) } }
        if _cabs(den) == 0 { den = (1e-12, 0.0) }
        let dz = _cd(p, den)
        zs.at(k) = _cs(zk, dz)
        mx = calc.max(mx, _cabs(dz))
      }
      if mx < 1e-15 { break }
    }
    let P(y) = range(n + 1).rev().fold((0.0, 0.0), ((v, g), i) => (v * y + m.at(i), g * y + v))
    for (re, im) in zs {
      if calc.abs(im) > 1e-6 * calc.max(_cabs((re, im)), 1e-9) { continue }
      let y = re
      for _ in range(5) { let (v, g) = P(y); if g == 0 { break }; let y2 = y - v / g; if calc.abs(P(y2).at(0)) < calc.abs(v) { y = y2 } else { break } }
      rs.push(y * R)
    }
  }
  _uniq(rs)
}

// ---------- numeric root finding ----------
#let _resid(eqs, env, xs, xv) = { // -> (F, J, S) or none
  let n = xs.len()
  let env = env
  for (j, x) in xs.enumerate() { env.insert(x, (float(xv.at(j)), range(n).map(i => if i == j { 1.0 } else { 0.0 }))) }
  let (F, J, S) = ((), (), ())
  for (L, R) in eqs {
    let l = _nd(L, env)
    let r = _nd(R, env)
    if l == none or r == none { return none }
    let z = range(n).map(_ => 0.0)
    F.push(l.at(0) - r.at(0))
    J.push(_lc(1, if l.at(1) == none { z } else { l.at(1) }, q: -1, h: if r.at(1) == none { z } else { r.at(1) }))
    S.push(calc.abs(l.at(0)) + calc.abs(r.at(0)))
  }
  (F, J, S)
}
#let _conv(F, S) = F.zip(S).all(((f, s)) => calc.abs(f) <= 1e-8 * s)
#let _gauss(A, b) = {
  let n = b.len()
  let M = A.zip(b).map(((r, y)) => r + (y,))
  for c in range(n) {
    let p = range(c, n).sorted(key: r => -calc.abs(M.at(r).at(c))).first()
    if M.at(p).at(c) == 0 { return none }
    let t = M.at(p); M.at(p) = M.at(c); M.at(c) = t
    for r in range(n) {
      if r != c and M.at(r).at(c) != 0 {
        let f = M.at(r).at(c) / M.at(c).at(c)
        M.at(r) = M.at(r).zip(M.at(c)).map(((x, y)) => x - f * y)
      }
    }
  }
  let x = range(n).map(i => M.at(i).at(n) / M.at(i).at(i))
  if x.all(_ok) { x } else { none }
}
// damped Newton from x0 -> solution or none
#let _newton(eqs, env, xs, x0) = {
  let x = x0
  let r = _resid(eqs, env, xs, x)
  if r == none { return none }
  let w = r.at(2).map(s => if s > 0 { 1 / s } else { 1 })
  let N(F) = F.zip(w).map(((f, w)) => calc.pow(f * w, 2)).sum()
  for it in range(40) {
    let (F, J, S) = r
    if N(F) == 0 { break }
    let dx = _gauss(J, F.map(f => -f))
    if dx == none { break }
    let (t, acc) = (1.0, none)
    for _ in range(12) {
      let xn = x.zip(dx).map(((a, b)) => a + t * b)
      let rn = _resid(eqs, env, xs, xn)
      if rn != none and N(rn.at(0)) < N(F) { acc = (xn, rn); break }
      t /= 2
    }
    if acc == none { break }
    let done = x.zip(acc.at(0)).all(((a, b)) => calc.abs(a - b) <= 1e-14 * calc.max(calc.abs(a), calc.abs(b)))
    (x, r) = acc
    if done { break }
  }
  if _conv(r.at(0), r.at(2)) { x } else { none }
}
// all real solutions of one equation in x: scan ±10^-15…10^15, then bisect sign changes
#let _scan(L, R, env, x, s) = {
  let f(t) = { let r = _resid(((L, R),), env, (x,), (t,)); if r == none { none } else { (r.at(0).first(), r.at(2).first()) } }
  let ks = range(-60, 61).map(k => s * calc.pow(10.0, k / 4))
  let pts = ks.rev().map(t => -t) + (0.0,) + ks
  let vs = pts.map(f)
  let rs = ()
  for i in range(pts.len()) {
    let v = vs.at(i)
    if v == none { continue }
    if v.at(0) == 0 { rs.push(pts.at(i)); continue }
    let w = vs.at(i + 1, default: none)
    if w == none or w.at(0) == 0 or (v.at(0) > 0) == (w.at(0) > 0) { continue }
    let (a, b, fa) = (pts.at(i), pts.at(i + 1), v.at(0))
    let ok = true
    for _ in range(200) {
      let m = (a + b) / 2
      if m == a or m == b { break }
      let fm = f(m)
      if fm == none { ok = false; break }
      if fm.at(0) == 0 { (a, b) = (m, m); break }
      if (fm.at(0) > 0) == (fa > 0) { (a, fa) = (m, fm.at(0)) } else { b = m }
    }
    let m = (a + b) / 2
    let fm = f(m)
    if ok and fm != none and calc.abs(fm.at(0)) <= 1e-7 * fm.at(1) { rs.push(m) }
  }
  // roots without a sign change (touching zero, between poles): Newton from local minima of |f|
  for i in range(1, pts.len() - 1) {
    let (u, v, w) = (vs.at(i - 1), vs.at(i), vs.at(i + 1))
    if u == none or v == none or w == none or calc.abs(v.at(0)) > calc.abs(u.at(0)) or calc.abs(v.at(0)) > calc.abs(w.at(0)) { continue }
    let r = _newton(((L, R),), env, (x,), (pts.at(i),))
    if r != none { rs.push(r.first()) }
  }
  _uniq(rs)
}
// several solutions of a system: Newton from deterministic pseudo-random starts
#let _msolve(eqs, env, xs, sc, guess) = {
  let n = xs.len()
  let starts = if guess != none { (guess,) } else {
    let st = (sc,)
    let seed = 20261019
    for i in range(32) {
      let p = ()
      for j in range(n) {
        seed = calc.rem(seed * 1103515245 + 12345, 2147483648)
        let u = seed / 2147483648
        seed = calc.rem(seed * 1103515245 + 12345, 2147483648)
        let sg = if seed / 2147483648 < 0.3 { -1 } else { 1 }
        p.push(sg * sc.at(j) * calc.pow(10.0, 8 * u - 4))
      }
      st.push(p)
    }
    st
  }
  let (sols, idle) = ((), 0)
  for s0 in starts {
    idle += 1
    if sols.len() > 0 and idle > 10 { break }
    let x = _newton(eqs, env, xs, s0)
    if x == none { continue }
    if not sols.any(y => y.zip(x).all(((a, b)) => calc.abs(a - b) <= 1e-6 * calc.max(calc.abs(a), calc.abs(b)) + 1e-300)) { sols.push(x); idle = 0 }
  }
  sols.sorted()
}
