// Plotting with simple-plot.
#import "defined.typ": *
#import "@preview/simple-plot:1.1.0" as _sp

// ---------- plotting (simple-plot) ----------
#let _nice(r) = { let b = calc.pow(10.0, calc.floor(calc.log(r))); for m in (1, 2, 5, 10) { if m * b >= r * (1 - 1e-9) { return m * b } } }
#let _axlabel(n, u, U: _U) = if u == "" { $#n$ } else { $#n thin slash thin #_ushow(u, U: U)$ }
// tick positions + labels with the document's decimal separator
#let _ticks(a, b, st, skip0, cf) = {
  let ps = ()
  let v = calc.ceil(a / st - 1e-9) * st
  while v <= b + st * 1e-9 { if not (skip0 and calc.abs(v) < st * 1e-9) { ps.push(calc.round(v, digits: 12)) }; v += st }
  (ps, ps.map(p => _nc(_fixed(p, 10, false), none, cf)))
}

// bisection on [a, b] where h changes sign (or, with edge: true, where h goes from defined to undefined)
#let _bis(h, a, b, edge: false) = {
  let ha = h(a)
  for _ in range(50) {
    let m = (a + b) / 2
    if m == a or m == b { break }
    let hm = h(m)
    let left = if edge { (hm == none) == (ha == none) } else { hm != none and ha != none and (hm > 0) == (ha > 0) }
    if left { (a, ha) = (m, hm) } else { b = m }
  }
  (a + b) / 2
}
// x positions worth showing: roots, extrema, poles, edges of the domain, intersections -> (points, domain edges)
#let _interesting(cs, env, x, s) = {
  let F(e, t) = { let env = env; env.insert(x, (float(t), (1.0,))); _nd(e, env) }
  let ks = range(-48, 49).map(k => s * calc.pow(10.0, k / 8))
  let ts = ks.rev().map(t => -t) + (0.0,) + ks
  let (pts, edges, xs) = ((), (), ())
  // where h crosses zero: sign changes, refined, and isolated exact zeros (exp underflowing to 0 isn't one)
  let cross(h) = {
    let vs = ts.map(h)
    let r = ()
    for i in range(ts.len()) {
      let u = vs.at(i)
      if u == none { continue }
      if u == 0 { if i > 0 and i < ts.len() - 1 and vs.at(i - 1) not in (none, 0) and vs.at(i + 1) not in (none, 0) { r.push(ts.at(i)) }; continue }
      let w = vs.at(i + 1, default: none)
      if w != none and w != 0 and (u > 0) != (w > 0) { r.push(_bis(h, ts.at(i), ts.at(i + 1))) }
    }
    r
  }
  for e in cs {
    let f(t) = { let r = F(e, t); if r == none { none } else { r.at(0) } }
    let g(t) = { let r = F(e, t); if r == none or r.at(1) == none { none } else { r.at(1).first() } }
    pts += cross(f) + cross(g) // roots and poles, extrema
    for i in range(ts.len() - 1) {
      let (u, w) = (f(ts.at(i)), f(ts.at(i + 1)))
      // overflow (exp of a big number) isn't an edge of the domain
      if (u == none) != (w == none) and calc.abs(if u == none { w } else { u }) < 1e30 { edges.push(_bis(f, ts.at(i), ts.at(i + 1), edge: true)) }
    }
  }
  for (i, a) in cs.enumerate() {
    for b in cs.slice(i + 1) {
      let h(t) = { let (u, w) = (F(a, t), F(b, t)); if u == none or w == none { none } else { u.at(0) - w.at(0) } }
      xs += cross(h)
    }
  }
  (pts + xs + edges, edges, xs)
}
// automatic x range: the cluster of interesting points nearest 0 (periodic curves have them everywhere), with some room
#let _autorange(cs, env, x, s) = {
  let (pts, edges, xs) = _interesting(cs, env, x, s)
  // where curves cross is what the graph is about: only what lies near the crossings
  let pts = if xs.len() == 0 { pts } else { let w = 2 * calc.max(..xs.map(calc.abs)); pts.filter(t => calc.abs(t) <= w) }
  let pts = pts.map(t => if calc.abs(t) < 1e-9 * s { 0.0 } else { t })
  // distances from 0, outward while each is at most 10× the previous, 4 at most (sin has them everywhere)
  let ds = ()
  for a in pts.filter(t => t != 0).map(calc.abs).sorted() {
    if ds.len() > 0 and a <= ds.last() * (1 + 1e-6) { continue }
    if ds.len() >= 4 or (ds.len() > 0 and a > 10 * ds.last()) { break }
    ds.push(a)
  }
  let m = if ds.len() == 0 { 0 } else { ds.last() }
  let core = pts.filter(t => calc.abs(t) <= m * (1 + 1e-6))
  if core.len() == 0 { return (-s, s) }
  let (lo, hi) = (calc.min(..core), calc.max(..core))
  let (a, b) = if lo == hi { let w = if lo == 0 { s } else { calc.abs(lo) }; (lo - w, lo + w) } else { let p = (hi - lo) * 0.2; (lo - p, hi + p) }
  // physical ranges start at 0 when everything interesting is positive and not far from it
  if lo > 0 and lo < 0.5 * (hi - lo) { a = 0.0 }
  if hi < 0 and -hi < 0.5 * (hi - lo) { b = 0.0 }
  // don't run past the edge of the domain (sqrt, ln)
  let ok(t) = cs.any(e => { let env = env; env.insert(x, (float(t), none)); _nd(e, env) != none })
  for t in edges.sorted() { if t <= lo and t > a and not ok(t - (t - a) / 2) { a = t } }
  for t in edges.sorted().rev() { if t >= hi and t < b and not ok(t + (b - t) / 2) { b = t } }
  // round to a tick step, but not past a domain edge
  let st = _nice((b - a) / 5)
  let (a2, b2) = (calc.floor(a / st + 1e-9) * st, calc.ceil(b / st - 1e-9) * st)
  (if ok(a2) or a2 == a { a2 } else { a }, if ok(b2) or b2 == b { b2 } else { b })
}

/// Plots an equation with `simple-plot`: ranges, nice ticks, axis labels and units are picked automatically.
///
/// Every positional string or math is a curve: `y = …` gives one curve (named `y` in the
/// legend) and marks the stored point with guide lines; other equations draw both sides
/// and mark the intersections. `xrange:` / `yrange:` list values that must be visible;
/// without them the x range is picked around the marks, else around the interesting part
/// (roots, extrema, poles, intersections). Marked values are always visible too.
///
/// ```typ
/// #def("R = 50 Ω", "P0 = 2 W")
/// #solve("P0 = U^2/R")
/// #graph("P = U^2/R", x: "U")                                // 0…2·U, the solved point marked
/// #graph("P = U^2/R", x: "R", xrange: ("10 Ω", "1 kΩ"))
/// #graph("cos(w) = w")                                       // range picked, intersection marked
/// #graph("y = x^2", "y = 2x + 3", xrange: (-3, 5))           // several curves
/// #graph("P = U^2/R", x: "R", xrange: (0, "2 R"), mark: ("R", "extrema"))
/// #graph("P = U^2/R", x: "R", ymark: "P0")                  // where P reaches P0
/// ```
///
/// Uses `@preview/simple-plot:1.1.0`. Ticks use the document's decimal separator, axis labels read `U / V`; curves of the same unit share one graph, with a legend.
///
/// **Ranges:** values and expressions in `xrange` / `yrange` must have the axis unit (`$f(20) Omega$` and `"f(20) Ω"` are fine) – `xrange: ("10 Ω", "f(20)")` with a unitless `f(20)` is an error, since it isn't clear what was meant. Without a range: if x is defined, 0…2·x with the solved point marked; else around the marks; else around what's interesting – roots, extrema, poles, edges of the domain (√, ln) and, above all, where curves cross – rounded to nice ticks, starting at 0 when everything interesting is positive. With `ymark`, the y range is around the marked values (steep curves leave the picture). If x has no unit yet, it follows from the curve and the units of the y values (`P = U0^2/R2` with `ymark: "2 W"`: R₂ in Ω).
///
/// **Marks** are always visible – the ranges grow to show them. Combine them in an array, `(auto, "R1")`; `mark: ()` marks nothing.
///
/// **Size:** `width` / `height` are the whole graph, labels included; `auto` makes the plot area 8 × 5 cm. Any other named argument goes straight to simple-plot's `plot` (e.g. `show-grid: false`), other positional ones (series from simple-plot) are added as they are. For full control, plot with simple-plot directly.
///
/// - ..args (str, content, any): The curves (equations or expressions) and options passed on to simple-plot's `plot` (e.g. `show-grid: false`); other positional ones are added as series.
/// - x (auto, str): The x variable. `auto`: the only variable that isn't defined.
/// - xrange (auto, array, str, content, int, float): x values that must be visible: numbers in `xunit` (`(1, 2)`), values (`("10 Ω", "1 kΩ")`) or expressions of defined variables (`(0, "2 R")`, math works too). Two or more give the range from the smallest to the largest; a single one widens the picked range. `auto`: 0…2·x if x is defined, else around the marked x values, else picked from the curves.
/// - yrange (auto, array, str, content, int, float): y values that must be visible, like `xrange` (numbers in `yunit`). Two or more give the exact y range. `auto`: fitted to the curves.
/// - xunit (auto, str, content): Unit of the x axis. `auto`: from the range or the variable.
/// - yunit (auto, str, content): Unit of the y axis. `auto`: SI unit with a fitting prefix.
/// - mark (auto, none, array, str, content, int, float): What to mark, with both coordinates written on the axes: x values like `xrange` (`"R"`, `2`, `"5 V"`; a point with guide lines on every curve, the range grows to show it), `"crossings"`, `"roots"`, `"extrema"` (searched within the range) and `auto`: the solved point or where the two sides cross. An array combines them: `(auto, "R1")`. `()` or `none`: no marks.
/// - xmark (none, array, str, content, int, float): Like `mark`, but only the x value is written on the axis.
/// - ymark (none, array, str, content, int, float): y values to mark, like `yrange`: every point where a curve reaches one, with guide lines; the value is written on the y axis.
/// - samples (int): Number of sample points.
/// - width (auto, length, ratio, relative): Width of the whole graph, labels included: `12cm`, `300pt` or a share like `100%`. `auto`: a plot area of 8 cm.
/// - height (auto, length, ratio, relative): Like `width`; `auto`: a plot area of 5 cm. A share is of the container's height, or of the width when the page grows with its content.
/// - colors (array, color): Colors of the curves, e.g. `(gray, blue, rgb("#f98eff"))`.
/// - digits, separator, form, … (auto): Every option of `solve-config` (except `units`) works here too, for this call only.
/// -> content
#let graph(
  ..args, x: auto, xrange: auto, yrange: auto, xunit: auto, yunit: auto, mark: auto, xmark: (), ymark: (), samples: 400,
  width: auto, height: auto, colors: (blue, red.darken(10%), green.darken(25%), orange.darken(10%)),
  digits: auto, trailing-zeros: auto, separator: auto, grouping: auto, scientific: auto, engineering: auto, multiplication: auto, form: auto,
  max-denominator: auto, fractions: auto, prefixes: auto, show-si: auto, preferred-units: auto, strict: auto, steps: auto, inline-steps: auto,
  layout: auto, implies: auto, approximate: auto, block: auto, max-solutions: auto, defined-style: auto, errors: auto,
) = _mine(context {
  let lc = _check(_given((digits: digits, trailing-zeros: trailing-zeros, separator: separator, grouping: grouping, scientific: scientific, engineering: engineering, multiplication: multiplication, form: form, max-denominator: max-denominator, fractions: fractions, prefixes: prefixes, show-si: show-si, preferred-units: preferred-units, strict: strict, steps: steps, inline-steps: inline-steps, layout: layout, implies: implies, approximate: approximate, block: block, max-solutions: max-solutions, defined-style: defined-style, errors: errors)))
  if _E(lc) { return _errc("graph: " + lc.err, _cf.get(), wide: true) }
  let cf = _cf.get() + lc
  let U = _UT(cf)
  let fail(m) = _errc("graph: " + m, cf, wide: true)
  // types
  let eqs = args.pos().filter(a => type(a) in (str, content))
  if args.pos().any(a => type(a) == array) { return fail("the x range is named: xrange: " + repr(args.pos().find(a => type(a) == array))) }
  let args = arguments(..args.pos().filter(a => type(a) not in (str, content)), ..args.named())
  if eqs.len() == 0 { return fail("nothing to plot – pass an equation like \"P = U^2/R\"") }
  let XV = (str, content, int, float)
  let list(v) = if v == auto or v == none { () } else if type(v) == array { v } else { (v,) }
  let (rng, yrng) = (list(xrange), list(yrange))
  for (n, r) in (xrange: rng, yrange: yrng) { if r.any(v => type(v) not in XV) { return fail(n + ": values to show, like (1, 2), (\"10 Ω\", \"1 kΩ\") or (0, \"2 R\")") } }
  let ymk = list(ymark)
  if ymk.any(v => type(v) not in XV) { return fail("ymark: y values like \"P0\" or 2, or an array of these") }
  // marks: x values, keywords, auto; (item, y labelled): mark writes x and y on the axes, xmark only x
  let KW = ("crossings", "roots", "extrema")
  let ms(v) = if v == none or v == false { () } else if v == true { (auto,) } else if type(v) == array { v } else { (v,) }
  let ents = ms(mark).map(m => (m, true)) + ms(xmark).map(m => (m, false))
  if ents.any(((m, _)) => m != auto and type(m) not in XV) { return fail("mark / xmark: auto, x values like \"R\" or 2, \"crossings\", \"roots\", \"extrema\", or an array of these; () for none") }
  let iskw(m) = type(m) == str and m in KW
  let kws = ents.filter(((m, _)) => iskw(m))
  let autos = ents.filter(((m, _)) => m == auto).map(e => e.at(1))
  let mxs = ents.filter(((m, _)) => m != auto and not iskw(m))
  if x != auto and type(x) != str { return fail("x: a variable name like \"U\", got " + _tn(x)) }
  for (n, v) in (xunit: xunit, yunit: yunit) { if v != auto and type(v) not in (str, content) { return fail(n + ": a unit like \"V\", got " + _tn(v)) } }
  if type(samples) != int or samples < 2 { return fail("samples: an integer ≥ 2") }
  for (n, v) in (width: width, height: height) {
    let ok = if v == auto { true } else if type(v) == length { v.to-absolute() > 0pt } else if type(v) == ratio { v > 0% } else if type(v) == relative { v.ratio >= 0% and v.length.to-absolute() >= -1e9pt } else { false }
    if not ok { return fail(n + ": auto, a length like 8cm or 300pt, or a share like 100%, got " + repr(v) + if type(v) in (int, float) { " – write " + repr(v) + "cm" } else { "" }) }
  }
  let colors = if type(colors) == color { (colors,) } else { colors }
  if type(colors) == content { return fail("colors: square brackets make content – write an array with parentheses: (gray, blue, rgb(\"#f98eff\"))") }
  if type(colors) != array or colors.len() == 0 or colors.any(c => type(c) not in (color, gradient)) { return fail("colors: a color or an array of colors like (gray, blue, rgb(\"#f98eff\"))") }
  let (xunit, yunit) = (xunit, yunit).map(v => if type(v) == content { _str(v) } else { v })
  let b = _first-err((xunit, yunit))
  if b != none { return fail(b.err) }
  for v in (xunit, yunit) { if type(v) == str { let u = _unit(v, U: U); if _E(u) { return fail(u.err) } } }
  let d = _vars-of(_st.get())
  let fns = _st.get().at("#fn", default: (:))
  let env = _env(d)
  let D(e) = _dp(e, none, cf).at(0)
  // each equation: (source, left, right or none)
  let ps = ()
  for q in eqs {
    let s = if type(q) == content and q.func() == math.equation { let m = _str(q, q: true); if _E(m) { m } else { _math-eq(m, d, cf) } } else { _str(q) }
    if _E(s) { return fail(s.err) }
    let sides = s.split("=")
    if sides.len() > 2 { return fail("more than one '=' in '" + s + "'") }
    let L = _parse(sides.at(0), d, f: fns, U: U)
    let R = if sides.len() > 1 { _parse(sides.at(1), d, f: fns, U: U) }
    let b = _first-err((L, R))
    if b != none { return fail(b.err) }
    ps.push((s, L, R))
  }
  let eq = ps.map(p => p.at(0)).join("', '")
  let x = if x != auto { x } else {
    let ys = ps.filter(((_, L, R)) => R != none and L.at(0) == "v").map(p => p.at(1).at(1))
    let u = ps.map(((_, L, R)) => _vars(L) + if R != none { _vars(R) } else { () }).flatten().dedup().filter(n => n not in d and n not in ys)
    if u.len() != 1 { return fail("can't tell the x variable in '" + eq + "', pass x: \"…\"") }
    u.first()
  }
  // curves with their legend labels; pairs whose crossings are marked
  let (curves, labels, pairs) = ((), (), ())
  let ns = ps.filter(((_, L, R)) => R != none and L.at(0) == "v" and L.at(1) != x).map(p => p.at(1).at(1))
  for (_, L, R) in ps {
    if R == none { curves.push(L); labels.push(D(L)) }
    else if L.at(0) == "v" and L.at(1) != x {
      // y = x², y = 2x + 3: the same name twice, so the legend shows the equations
      curves.push(R); labels.push(if ns.filter(n => n == L.at(1)).len() > 1 { $#_name(L.at(1)) = #D(R)$ } else { _name(L.at(1)) })
    }
    else { pairs.push((curves.len(), curves.len() + 1)); curves += (L, R); labels += (D(L), D(R)) }
  }
  if curves.len() == 2 and pairs.len() == 0 { pairs.push((0, 1)) }
  let named = ps.filter(((_, L, R)) => R != none and L.at(0) == "v" and L.at(1) != x).map(p => p.at(1).at(1))
  let yname = if named.len() == ps.len() { named.dedup().join(", ") }
  let (L, R) = (ps.first().at(1), ps.first().at(2))
  // x range and unit
  // x values of range and mark: plain numbers (in xunit, known later) or (v, dims, unit) of a value or expression
  let xv(a) = {
    if type(a) in (int, float) { return float(a) }
    let s = _str(a, q: type(a) == content and a.func() == math.equation)
    if _E(s) { return s }
    // "10" is a plain number like 10: in the axis unit
    if s.trim().match(regex("^[-+−]?\d+(?:[.,]\d+)?(?:[eE][-+]?\d+)?$")) != none { return float(s.trim().replace("−", "-").replace(",", ".")) }
    if _isq(s, U: U) {
      let q = _q(s, U: U)
      if _E(q) { return q }
      let amb = _unames(q.u, U: U).find(n => n in d)
      if amb != none { return _err("'" + amb + "' in '" + s.trim() + "' is both a defined variable and a unit – write [" + s.trim() + "] for the unit, or use * for the variable") }
      return (q.v, q.d, q.u, s.trim())
    }
    let m = _math-src(s, d, cf, bare: true)
    if _E(m) { return m }
    let e = _parse(m, d, f: fns, U: U)
    if _E(e) { return e }
    let r = _ev(e, d)
    if _E(r) { return _err(r.err + " in '" + s.trim() + "'") }
    let a = _auto(r.at(1), U: U)
    (r.at(0), r.at(1), if r.at(1) == _Z { "" } else { _pre(r.at(0) / _unit(a, U: U).at(0), a, cf) }, s.trim())
  }
  // a value whose unit doesn't fit its axis: "'f(20)' is 40 (no unit), but x is in Ω"
  let misfit(v, axis, u) = {
    let (val, dm, vu, src) = v
    let shown = if vu == "" { str(calc.round(val, digits: 4)) + " (no unit)" } else { str(calc.round(val / _unit(vu, U: U).at(0), digits: 4)) + " " + vu }
    "'" + src + "' is " + shown + ", but " + axis + (if u == "" { " has no unit" } else { " is in " + u }) + " – plain numbers count in the axis unit"
  }
  let rvs = rng.map(xv)
  let mvs = mxs.map(e => xv(e.at(0)))
  let mly = mxs.map(e => e.at(1))
  let (yrv, ymv) = (yrng.map(xv), ymk.map(xv))
  let b = _first-err(rvs + mvs + yrv + ymv)
  if b != none { return fail(b.err) }
  let withu = (rvs + mvs).filter(v => type(v) == array and v.at(1) != _Z)
  let xunit = if xunit != auto { xunit } else if x in d { d.at(x).u } else if withu.len() > 0 { withu.first().at(2) } else { "" }
  let (xf, xd) = _unit(xunit, U: U)
  if x in d { xd = d.at(x).d } else if xunit == "" and withu.len() > 0 { xd = withu.first().at(1) }
  // no unit for x yet, but y values have one: x's unit follows from the curve (P = U0²/R2 and P0 in W: R2 in Ω)
  let yu = (yrv + ymv).find(v => type(v) == array and v.at(1) != _Z)
  if xunit == "" and x not in d and withu.len() == 0 and yu != none {
    let r = _dx(curves.first(), d, env, (x,))
    if not _E(r) and r.at(0) != none and r.at(0).at(1).first() != 0 {
      let (c, (k,)) = r.at(0)
      let dm = yu.at(1).zip(c).map(((y, z)) => calc.round((y - z) / k, digits: 6))
      if dm != _Z { xd = dm; xunit = _auto(dm, U: U); xf = _unit(xunit, U: U).at(0) }
    }
  }
  let bad = (rvs + mvs).find(v => type(v) == array and v.at(1) != xd)
  if bad != none { return fail(misfit(bad, x, xunit)) }
  let si(v) = if type(v) == float { v * xf } else { v.at(0) }
  let (rvs, mvs) = (rvs.map(si), mvs.map(si))
  // y unit from the units of the expression
  let dq = d + ((x): (v: xf, d: xd, raw: none, u: xunit, ex: none))
  let yr = _dx(curves.first(), dq, env, ())
  if _E(yr) { return fail(yr.err) }
  let yd = { let r = yr.at(0); if r == none { _Z } else { r.at(0).map(z => calc.round(z, digits: 6)) } }
  for (i, e) in curves.enumerate().slice(1) {
    let r = _dx(e, dq, env, ())
    let di = if _E(r) or r.at(0) == none { none } else { r.at(0).at(0).map(z => calc.round(z, digits: 6)) }
    if di != none and di != yd and yd != _Z { return fail("the curves have different units (" + _auto(yd, U: U) + " and " + (if di == _Z { "1" } else { _auto(di, U: U) }) + ") – plot them separately") }
  }
  let bad = (yrv + ymv).find(v => type(v) == array and v.at(1) != yd)
  if bad != none { return fail(misfit(bad, if yname != none { yname } else { "y" }, if yd == _Z { "" } else { _auto(yd, U: U) })) }
  // plain numbers for y are in yunit, or in the SI unit
  let yb = _unit(if yunit != auto { yunit } else { _auto(yd, U: U) }, U: U).at(0)
  let ysi(v) = if type(v) == float { v * yb } else { v.at(0) }
  let (yrv, ymv) = (yrv.map(ysi), ymv.map(ysi))
  // where the curves reach the y marks: the nearest ones must be visible
  let yneed = ()
  for Y in ymv {
    for e in curves {
      let rs = _scan(e, ("n", Y), env, x, xf).sorted(key: calc.abs)
      if rs.len() > 0 { yneed += rs.filter(t => calc.abs(t) <= 2 * calc.abs(rs.first()) + 1e-9 * xf).slice(0, calc.min(4, rs.len())) }
    }
  }
  let need = mvs + yneed
  let (xa, xb) = if rvs.dedup().len() >= 2 { (calc.min(..rvs), calc.max(..rvs)) } else if x in d {
    let v = d.at(x).v
    if v > 0 { (0.0, 2 * v) } else if v < 0 { (2 * v, 0.0) } else { (-xf, xf) }
  } else if need.len() > 0 {
    // the marks are what's interesting: around them, not back to 0
    let (lo, hi) = (calc.min(..need), calc.max(..need))
    let (a, b) = if lo == hi { let w = if lo == 0 { xf } else { calc.abs(lo) / 2 }; (lo - w, lo + w) } else { let p = (hi - lo) * 0.25; (lo - p, hi + p) }
    let st = _nice((b - a) / 5)
    (calc.floor(a / st + 1e-9) * st, calc.ceil(b / st - 1e-9) * st)
  } else { _autorange(curves, env, x, xf) }
  // a single range value and marked values widen the range; marks get a little room
  for v in rvs { (xa, xb) = (calc.min(xa, v), calc.max(xb, v)) }
  let w = xb - xa
  for v in need { if v < xa { xa = v - 0.05 * w } else if v > xb { xb = v + 0.05 * w } }
  if not (xa < xb) { return fail("the range is empty – give two different x values") }
  let F(e, t) = { let env = env; env.insert(x, (t, none)); let r = _nd(e, env); if r == none { none } else { r.at(0) } }
  let ts = range(samples + 1).map(i => xa + i * (xb - xa) / samples)
  let ys = curves.map(e => ts.map(t => F(e, t)))
  let all = ys.flatten().filter(y => y != none).sorted()
  if all.len() == 0 { return fail("'" + eq + "' can't be evaluated in this range") }
  let (lo, hi) = (all.first(), all.last())
  let (q1, q2) = (all.at(int(all.len() * 0.05)), all.at(int(all.len() * 0.95)))
  if hi - lo > 20 * (q2 - q1) and q2 > q1 { (lo, hi) = (q1 - (q2 - q1) / 2, q2 + (q2 - q1) / 2) } // poles
  // y marks are what's interesting: the y range is around them, steep curves leave the picture
  if ymv.len() > 0 and yrv.dedup().len() < 2 {
    let vs = ymv + yrv
    (lo, hi) = (calc.min(..vs), calc.max(..vs))
    if lo == hi { let w = if lo == 0 { yb } else { calc.abs(lo) }; (lo, hi) = (lo - w, lo + w) } else { let p = (hi - lo) * 0.25; (lo, hi) = (lo - p, hi + p) }
  }
  let yunit = if yunit != auto { yunit } else { let a = _auto(yd, U: U); _pre(calc.max(calc.abs(lo), calc.abs(hi)) / _unit(a, U: U).at(0), a, cf) }
  let yf = _unit(yunit, U: U).at(0)
  // display ranges and ticks
  let (x0, x1) = (xa / xf, xb / xf)
  let (y0, y1) = if yrv.dedup().len() >= 2 { (calc.min(..yrv) / yf, calc.max(..yrv) / yf) } else {
    for v in yrv + ymv { (lo, hi) = (calc.min(lo, v), calc.max(hi, v)) }
    let (y0, y1) = (lo / yf, hi / yf)
    if y0 > 0 and y0 < 0.5 * y1 { y0 = 0 }
    if y1 < 0 and y1 > 0.5 * y0 { y1 = 0 }
    if y0 == y1 { (y0, y1) = (y0 - 1, y1 + 1) }
    let pad = (y1 - y0) * 0.08
    (if y0 == 0 { 0 } else { y0 - pad }, if y1 == 0 { 0 } else { y1 + pad })
  }
  // marked y values beyond an exact y range still show
  for v in ymv { let w = y1 - y0; if v / yf < y0 { y0 = v / yf - 0.05 * w } else if v / yf > y1 { y1 = v / yf + 0.05 * w } }
  let (xs, ys2) = (_nice((x1 - x0) / 5), _nice((y1 - y0) / 5))
  let xc = x0 <= 0 and 0 <= x1
  let yc = y0 <= 0 and 0 <= y1
  let ax = if yc { 0 } else { y0 }
  let xt = _ticks(x0, x1, xs, xc and yc, cf)
  let yt = _ticks(y0, y1, ys2, xc and yc, cf)
  let ay = if xc { 0 } else { x0 }
  // own sampling (finer, split at gaps and poles) drawn as point lines
  let ser = ()
  let used = () // label spots taken, (x, y) in display units
  for (i, e) in curves.enumerate() {
    let runs = ((),)
    for (j, t) in ts.enumerate() {
      let v = ys.at(i).at(j)
      if v == none { if runs.last() != () { runs.push(()) }; continue }
      let p = (t / xf, v / yf, j)
      let q = runs.last().at(-1, default: none)
      if q != none and (q.at(1) > 0) != (p.at(1) > 0) and calc.abs(q.at(1) - p.at(1)) > 2 * (y1 - y0) { runs.push(()) }
      runs.last().push(p)
    }
    let runs = runs.filter(r => r.len() > 1)
    let longest = runs.map(r => r.len()).fold(0, calc.max)
    for r in runs {
      let lab = curves.len() > 1 and r.len() == longest
      // the label goes where this curve is farthest from the others (not at a crossing), away from other labels
      let lp = 0.8
      if lab {
        let (best, bd) = (none, -1)
        for (k, (px, py, j)) in r.enumerate().rev() {
          if k < r.len() * 0.15 or k > r.len() * 0.95 or py < y0 or py > y1 { continue }
          if used.any(((ux, uy)) => calc.abs(ux - px) < 0.2 * (x1 - x0) and calc.abs(uy - py) < 0.15 * (y1 - y0)) { continue }
          let ds = range(curves.len()).filter(c => c != i).map(c => { let w = ys.at(c).at(j); if w == none { 1.0 } else { calc.abs(w / yf - py) / (y1 - y0) } })
          let dd = calc.min(1.0, ..ds)
          if dd > bd + 0.02 { (best, bd) = (k, dd) }
        }
        if best != none { lp = best / (r.len() - 1); used.push((r.at(best).at(0), r.at(best).at(1))) }
      }
      ser.push(_sp.line-plot(r.map(p => p.slice(0, 2)), mark: "none", stroke: colors.at(calc.rem(i, colors.len())) + 1.2pt,
        label: if lab { $#labels.at(i)$ }, label-pos: lp))
    }
  }
  // marks
  let dash = (paint: luma(110), thickness: 0.6pt, dash: "dashed")
  // points (x, y, guides, x labelled, y labelled) in SI; guides: "xy" both guide lines, "x" only the vertical one, "" none
  let pts = ()
  // where h changes sign within the range
  let zeros(h) = {
    let vs = ts.map(h)
    let r = ()
    for i in range(samples) {
      let (u, w) = (vs.at(i), vs.at(i + 1))
      if u == none or w == none { continue }
      if u == 0 { r.push(ts.at(i)) } else if w != 0 and (u > 0) != (w > 0) { r.push(_bis(h, ts.at(i), ts.at(i + 1))) }
    }
    if vs.last() == 0 { r.push(ts.last()) }
    r
  }
  let crossings(prs, ly) = {
    let r = ()
    for (ci, cj) in prs {
      let (A, B) = (curves.at(ci), curves.at(cj))
      r += zeros(t => { let (a, b) = (F(A, t), F(B, t)); if a == none or b == none { none } else { a - b } }).map(t => (t, F(A, t), if ly { "xy" } else { "x" }, true, ly))
    }
    r
  }
  for ly in autos {
    if curves.len() == 1 and yname != none and x in d { mvs.push(d.at(x).v); mly.push(ly) }
    pts += crossings(pairs, ly)
  }
  for (t, ly) in mvs.zip(mly) { for e in curves { pts.push((t, F(e, t), if ly or curves.len() == 1 { "xy" } else { "x" }, true, ly)) } }
  for Y in ymv { for e in curves { pts += zeros(t => { let v = F(e, t); if v == none { none } else { v - Y } }).map(t => (t, Y, "xy", false, true)) } }
  let kw(k) = kws.filter(((m, _)) => m == k).map(e => e.at(1))
  for ly in kw("crossings") { pts += crossings(range(curves.len()).map(i => range(i + 1, curves.len()).map(j => (i, j))).flatten().chunks(2), ly) }
  if kw("roots").len() > 0 { for e in curves { pts += zeros(t => F(e, t)).map(t => (t, 0.0, "", false, false)) } }
  if kw("extrema").len() > 0 {
    for e in curves {
      let g(t) = { let env = env; env.insert(x, (t, (1.0,))); let r = _nd(e, env); if r == none or r.at(1) == none { none } else { r.at(1).first() } }
      pts += zeros(g).map(t => (t, F(e, t), "x", false, false))
    }
  }
  let seen = ()
  let (labx, laby) = ((), ())
  for (t, v, gl, lx, ly) in pts {
    if lx and t / xf >= x0 and t / xf <= x1 and not labx.any(a => calc.abs(a - t / xf) <= 1e-9 * (x1 - x0)) { labx.push(t / xf) }
    if ly and v != none and v / yf >= y0 and v / yf <= y1 and t / xf >= x0 and t / xf <= x1 and not laby.any(a => calc.abs(a - v / yf) <= 1e-9 * (y1 - y0)) { laby.push(v / yf) }
    if v == none { continue }
    let (px, py) = (t / xf, v / yf)
    if px < x0 or px > x1 or py < y0 or py > y1 or seen.any(((a, b)) => calc.abs(a - px) <= 1e-9 * (x1 - x0) and calc.abs(b - py) <= 1e-9 * (y1 - y0)) { continue }
    seen.push((px, py))
    if gl != "" { ser.push(_sp.vline(px, ymin: calc.min(ax, py), ymax: calc.max(ax, py), stroke: dash)) }
    if gl == "xy" { ser.push(_sp.hline(py, xmin: calc.min(ay, px), xmax: calc.max(ay, px), stroke: dash)) }
    ser.push(_sp.scatter(((px, py),), mark-fill: black, mark-stroke: black, mark-size: 0.08))
  }
  // marked values are written on the axes; regular ticks too close to them make room
  let relabel(tk, ls, w) = if ls.len() == 0 { tk } else {
    // mark labels too close to an earlier one are left out
    let ls = ls.fold((), (acc, a) => if acc.any(b => calc.abs(a - b) < 0.06 * w) { acc } else { acc + (a,) })
    let keep = tk.at(0).zip(tk.at(1)).filter(((p, _)) => ls.all(a => calc.abs(a - p) > 0.08 * w))
    let all = (keep + ls.map(a => (a, _nshow((n: a, raw: none), cf).at(0)))).sorted(key: p => p.at(0))
    (all.map(p => p.at(0)), all.map(p => p.at(1)))
  }
  let xt = relabel(xt, labx, x1 - x0)
  let yt = relabel(yt, laby, y1 - y0)
  let o = (
    xmin: x0, xmax: x1, ymin: y0, ymax: y1, width: width, height: height,
    xtick: xt.at(0), xtick-labels: xt.at(1), ytick: yt.at(0), ytick-labels: yt.at(1), show-grid: "major",
    axis-x-pos: if yc { 0 } else { "bottom" }, axis-y-pos: if xc { 0 } else { "left" }, show-origin: xc and yc,
    xlabel: _axlabel(_name(x), xunit, U: U),
    ylabel: _axlabel(if yname != none { named.dedup().map(_name).join($, $) } else if curves.len() == 1 { D(curves.first()) } else { $$ }, yunit, U: U),
  ) + args.named()
  let make(w, h) = _sp.plot(..o + (width: w, height: h), ..ser, ..args.pos())
  // auto: a plot area of 8 × 5 cm; lengths and shares (100%, 50pt) are the whole graph, labels included
  let sized = std.layout(size => {
    let (aw, ah) = (width == auto, height == auto)
    let abs(v, full) = if type(v) == ratio { v * full } else if type(v) == relative { v.ratio * full + v.length.to-absolute() } else { v.to-absolute() }
    if aw and ah { return make(8, 5) }
    // HTML has no width to take a share of: a nominal 16cm, the SVG scales with the page anyway
    let full-w = if calc.abs(size.width.pt()) < 1e6 { size.width } else { 16cm }
    let W = if aw { 8cm } else { abs(width, full-w) }
    // a share of the height: of the container, or of the width when the page grows with its content
    let full-h = if calc.abs(size.height.pt()) < 1e6 { size.height } else { W }
    let H = if ah { 5cm } else { abs(height, full-h) }
    let m = measure(make(W, H))
    let w1 = if aw { W } else { calc.max(W - (m.width - W), 1cm) }
    let h1 = if ah { H } else { calc.max(H - (m.height - H), 1cm) }
    make(w1, h1)
  })
  // HTML has no layout of its own for this: the graph becomes an inline SVG
  if _target() == "html" { _css(); html.elem("div", attrs: (class: "solveng-plot"), html.frame(sized)) } else { align(center, sized) }
})
