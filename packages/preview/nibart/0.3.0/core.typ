// nib — a MetaPost-like approach to running a pen (elliptical, polygonal, variable) along a path. Typst >= 0.15.
//
// The heavy lifting (Hobby's algorithm, pen envelopes, intersections, arc length…) is done by a small
// Rust/WebAssembly plugin (nib.wasm). This file provides the Typst API.
//
// Conventions: mathematical axes (y points UP, angles are counter-clockwise) as in MetaPost;
// every position/size you pass or receive is a Typst length (plain numbers in path specs mean pt).

/// Package version.
#let nib-version = "0.3.0"

#let _plugin = plugin("nibart.wasm")
#let _call(f, data) = json(f(bytes(json.encode(data))))
#let _pt(x) = if type(x) == length { x.pt() } else if type(x) == int or type(x) == float { float(x) } else { panic("nib: expected a length, got " + repr(x)) }
#let _rad(a) = if type(a) == angle { a.rad() } else { float(a) * calc.pi / 180 }

// ───────────────────────────────────────────────────────────────── paths
/// Path from a MetaPost-style specification: `"(0,0)..(10,5){up}..tension 1.5..(20,0)--cycle"`.
/// Numbers are multiplied by `unit` (default 1pt). Syntax: `..`  `...`  `--`  `{up|down|left|right|dir θ|x,y|curl c}`,
/// `tension a [and b]`, `controls P [and Q]`, `cycle`. Returns an opaque path (Bézier segments).
#let mp-path(spec, unit: 1pt) = {
  let r = _call(_plugin.parse_path, (spec: spec, unit: _pt(unit)))
  r
}
/// Smooth (Hobby) path through a list of points `((x, y), …)` given as lengths.
#let mp-path-pts(pts, cycle: false, tension: 1, curl: none) = {
  let s = pts.map(p => "(" + str(_pt(p.at(0))) + "," + str(_pt(p.at(1))) + ")")
  let join = if tension == 1 { ".." } else { "..tension " + str(tension) + ".." }
  let sp = s.join(join)
  if curl != none { sp = "{curl " + str(curl) + "}" + s.first() + join + s.slice(1).join(join) }
  if cycle { sp += join + "cycle" }
  mp-path(sp)
}
#let _op(p, op, args: (), other: none) = {
  let d = (path: p, op: op, args: args)
  if other != none { d.insert("other", other) }
  _call(_plugin.path_op, d)
}
/// Number of Bézier segments of a path.
#let path-length(p) = p.segs.len()
#let _pl(pt) = (pt.at(0) * 1pt, pt.at(1) * 1pt)
/// Point at time `t` (t = segment index + fraction, like MetaPost's `point t of p`).
#let point-of(p, t) = _pl(_op(p, "point", args: (t,)))
/// Tangent vector at time `t` (not normalised, in pt).
#let direction-of(p, t) = _op(p, "direction", args: (t,))
/// Angle of the tangent at time `t`.
#let direction-angle(p, t) = { let d = direction-of(p, t); calc.atan2(d.at(0), d.at(1)) }
/// Sub-path between times `t0` and `t1` (wraps around on cyclic paths; negative times allowed).
#let subpath(p, t0, t1) = _op(p, "subpath", args: (t0, t1))
/// The same path, traversed backwards.
#let reverse(p) = _op(p, "reverse")
/// Total arc length of a path (as a length).
#let arclength(p) = _op(p, "arclength") * 1pt
/// Time `t` at which the path has covered arc length `len` (like `arctime len of p`).
#let arctime(p, len) = _op(p, "arctime", args: (_pt(len),))
/// Bounding box of a path: `(x0:, y0:, x1:, y1:)`.
#let path-bbox(p) = { let b = _op(p, "bbox"); (x0: b.at(0) * 1pt, y0: b.at(1) * 1pt, x1: b.at(2) * 1pt, y1: b.at(3) * 1pt) }
/// (temps, distance) du point du chemin le plus proche de `pos`.
#let closest-time(p, pos) = { let r = _op(p, "closest", args: (_pt(pos.at(0)), _pt(pos.at(1)))); (r.at(0), r.at(1) * 1pt) }
/// All pairs `(ta, tb)` where the two paths cross, sorted by `ta`.
#let intersection-times(a, b) = _op(a, "intersections", other: b)
/// Premier point d'intersection (ou none).
#let intersection-point(a, b) = { let r = intersection-times(a, b); if r.len() == 0 { none } else { point-of(a, r.first().at(0)) } }
/// Mark an open path as cyclic (closing it with a straight join).
#let path-close(p) = (segs: p.segs, cycle: true)

// ── affine transformations (MetaPost's `shifted`, `scaled`, `rotated`, `slanted`, `xscaled`, `yscaled`, `transformed`)
#let _xf(p, a, b, c, d, e, f) = {
  let m(x, y) = (a * x + c * y + e, b * x + d * y + f)
  (segs: p.segs.map(s => {
    let q0 = m(s.at(0), s.at(1)); let q1 = m(s.at(2), s.at(3)); let q2 = m(s.at(4), s.at(5)); let q3 = m(s.at(6), s.at(7))
    (q0.at(0), q0.at(1), q1.at(0), q1.at(1), q2.at(0), q2.at(1), q3.at(0), q3.at(1))
  }), cycle: p.cycle)
}
/// Translate a path by `(dx, dy)`.
#let shifted(p, dx, dy) = _xf(p, 1, 0, 0, 1, _pt(dx), _pt(dy))
/// Scale a path by `s` about the origin.
#let scaled(p, s) = _xf(p, s, 0, 0, s, 0, 0)
/// Scale x by `s`.
#let xscaled(p, s) = _xf(p, s, 0, 0, 1, 0, 0)
/// Scale y by `s`.
#let yscaled(p, s) = _xf(p, 1, 0, 0, s, 0, 0)
/// Shear: x += s·y.
#let slanted(p, s) = _xf(p, 1, 0, s, 1, 0, 0)
/// Rotate a path by `a` (counter-clockwise) about `about` (default: the origin).
#let rotated(p, a, about: (0pt, 0pt)) = {
  let t = _rad(a); let (c, s) = (calc.cos(t), calc.sin(t))
  let (ox, oy) = (_pt(about.at(0)), _pt(about.at(1)))
  _xf(p, c, s, -s, c, ox - c * ox + s * oy, oy - s * ox - c * oy)
}
/// General affine map `(x, y) ↦ (a·x + c·y + e, b·x + d·y + f)`.
#let transformed(p, a, b, c, d, e: 0pt, f: 0pt) = _xf(p, a, b, c, d, _pt(e), _pt(f))
#let reflected(p, angle: 90deg) = { // reflection across the line through the origin at `angle`
  let t = 2 * _rad(angle); _xf(p, calc.cos(t), calc.sin(t), calc.sin(t), -calc.cos(t), 0, 0) }

// ───────────────────────────────────────────────────────────────── pens
/// Elliptical pen: `w` = full width (along the axis rotated by `angle`), `h` = full height.
/// `angle`: orientation of the w axis (counter-clockwise), like `pencircle xscaled w yscaled h rotated angle`.
#let penellipse(w, h, angle: 0deg) = (kind: "ellipse", w: _pt(w), h: _pt(h), angle: _rad(angle))
/// Circular pen of diameter `d`.
#let pencircle(d) = penellipse(d, d)
/// Broad-edged calligraphic pen: a flattened ellipse, `w` = nib width, `t` = thickness, `angle` = slant.
#let broadnib(w, t: auto, angle: 30deg) = penellipse(w, if t == auto { w / 5 } else { t }, angle: angle)
/// Convex polygonal pen (points as lengths, around the origin).
#let penpoly(pts) = (kind: "poly", pts: pts.map(p => (_pt(p.at(0)), _pt(p.at(1)))))
/// Square pen of side `s`, rotated by `angle`.
#let pensquare(s, angle: 0deg) = {
  let h = _pt(s) / 2; let t = _rad(angle); let (c, sn) = (calc.cos(t), calc.sin(t))
  (kind: "poly", pts: ((-h, -h), (h, -h), (h, h), (-h, h)).map(q => (c * q.at(0) - sn * q.at(1), sn * q.at(0) + c * q.at(1))))
}
/// Razor pen: a segment of length `len` at `angle`.
#let penrazor(len, angle: 0deg) = {
  let h = _pt(len) / 2; let t = _rad(angle)
  (kind: "poly", pts: ((-h * calc.cos(t), -h * calc.sin(t)), (h * calc.cos(t), h * calc.sin(t))))
}

// ───────────────────────────────────────────────────────────────── drawable objects
#let _shape(contours, bbox, fill, stroke: none) = (kind: "shape", contours: contours, bbox: bbox, fill: fill, stroke: stroke)

/// Closed contour of a path, as drawing commands.
#let _path-contour(p) = {
  let cmds = ((0, p.segs.first().at(0), p.segs.first().at(1)),)
  for s in p.segs { cmds.push((2, s.at(2), s.at(3), s.at(4), s.at(5), s.at(6), s.at(7))) }
  cmds
}

/// Draw path `p` with a pen (like `pickup pen; draw p;`). Returns a fillable shape.
///  - `pen`   : fixed pen (penellipse, broadnib, pencircle, penpoly, pensquare, penrazor)
///  - `pens`  : variable pen: array `((w, h, angle), …)` (one per path node) or a function `i => (w, h, angle)`
///  - `tol`   : geometric tolerance · `fit`: fit Béziers to the outline of variable/polygonal pens · `outline`: Typst stroke around the shape
///  - `exact` : force the sweep-by-union of convex hulls (instead of the exact envelope)
#let draw(p, pen: none, pens: none, fill: black, tol: 0.01pt, fit: true, exact: false, outline: none) = {
  let req = (path: p, opts: (tol: _pt(tol), fit: fit, exact: exact))
  if pens != none {
    let n = if p.cycle { p.segs.len() } else { p.segs.len() + 1 }
    let arr = if type(pens) == function { range(n).map(i => pens(i)) } else { pens }
    if arr.len() != n { panic("nib: `pens` must contain " + str(n) + " pens (one per node), got " + str(arr.len())) }
    req.insert("pens", arr.map(q => (_pt(q.at(0)), _pt(q.at(1)), _rad(q.at(2)))))
  } else {
    if pen == none { panic("nib: draw needs `pen` or `pens`") }
    req.insert("pen", pen)
  }
  let r = _call(_plugin.nib_stroke, req)
  _shape(r.contours, r.bbox, fill, stroke: outline)
}
/// Fill the area of a closed path (like `fill p;`).
#let mp-fill(p, fill: black) = {
  let b = _op(p, "bbox")
  _shape((_path-contour(p),), b, fill)
}
/// A round or elliptical dot (like `drawdot`).
#let mp-dot(pos, pen: pencircle(2pt), fill: black) = {
  let q = mp-path("(" + str(_pt(pos.at(0))) + "," + str(_pt(pos.at(1))) + ")")
  draw(q, pen: pen, fill: fill)
}
/// A Typst label placed at `pos` (lengths), aligned by `align` (like `label.top`).
#let mp-label(body, pos, align: center + horizon) = (kind: "label", body: body, pos: pos, align: align)
/// Draw the path skeleton with a Typst `stroke` (handy to inspect control points).
#let mp-skeleton(p, stroke: 0.4pt + red) = (kind: "skeleton", path: p, stroke: stroke)
/// Group several objects.
#let mp-group(..items) = (kind: "group", items: items.pos())

#let _flatten(items) = {
  let out = ()
  for it in items {
    if type(it) == array { out += _flatten(it) }
    else if type(it) == dictionary and it.at("kind", default: none) == "group" { out += _flatten(it.items) }
    else if it != none { out.push(it) }
  }
  out
}

#let _curve-of(sh, x0, y1) = {
  // local coordinates: origin at the top-left of the box (y flipped)
  let cv(cmds) = {
    let comps = ()
    for c in cmds {
      let X(i) = (c.at(i) - x0) * 1pt
      let Y(i) = (y1 - c.at(i + 1)) * 1pt
      if c.at(0) == 0 { comps.push(curve.move((X(1), Y(1)))) }
      else if c.at(0) == 1 { comps.push(curve.line((X(1), Y(1)))) }
      else { comps.push(curve.cubic((X(1), Y(1)), (X(3), Y(3)), (X(5), Y(5)))) }
    }
    comps.push(curve.close(mode: "straight"))
    comps
  }
  let comps = sh.contours.map(cv).flatten()
  curve(fill: sh.fill, fill-rule: "non-zero", stroke: sh.at("stroke", default: none), ..comps)
}

#let _bbox-all(items) = {
  let b = none
  for it in items {
    let bb = if it.kind == "shape" { it.bbox } else if it.kind == "skeleton" { _op(it.path, "bbox") } else { none }
    if bb == none { continue }
    if b == none { b = bb }
    else { b = (calc.min(b.at(0), bb.at(0)), calc.min(b.at(1), bb.at(1)), calc.max(b.at(2), bb.at(2)), calc.max(b.at(3), bb.at(3))) }
  }
  b
}

/// Figure (like `beginfig … endfig`). Objects live in a y-up frame whose origin sits at `origin` from the
/// bottom-left corner. With `width`/`height` = `auto` the box fits its content (+ `pad`). `grid`, `frame`, `clip` are optional.
/// `baseline`: `auto` → the y = 0 line is the text baseline (when inside the box).
#let mp-fig(..items, width: auto, height: auto, origin: (0pt, 0pt), pad: 1pt, baseline: auto, grid: none, frame: none, clip: false) = {
  let its = _flatten(items.pos())
  let bb = _bbox-all(its)
  let (ox, oy) = (origin.at(0), origin.at(1))
  let (w, h) = (width, height)
  if width == auto or height == auto {
    if bb == none { bb = (0, 0, 0, 0) }
    if width == auto { w = (bb.at(2) - bb.at(0)) * 1pt + 2 * pad; ox = pad - bb.at(0) * 1pt }
    if height == auto { h = (bb.at(3) - bb.at(1)) * 1pt + 2 * pad; oy = pad - bb.at(1) * 1pt }
  }
  let bl = if baseline == auto { if oy >= 0pt and oy <= h { oy } else { 0pt } } else { baseline }
  box(width: w, height: h, baseline: bl, stroke: frame, clip: clip, {
    if grid != none {
      let step = grid
      let i0 = -calc.floor(ox / step); let i1 = calc.floor((w - ox) / step)
      let j0 = -calc.floor(oy / step); let j1 = calc.floor((h - oy) / step)
      for i in range(i0, i1 + 1) { place(bottom + left, dx: ox + i * step, line(start: (0pt, 0pt), end: (0pt, -h), stroke: 0.25pt + luma(200))) }
      for j in range(j0, j1 + 1) { place(bottom + left, dy: -(oy + j * step), line(length: w, stroke: 0.25pt + luma(200))) }
    }
    for it in its {
      if it.kind == "shape" {
        let (x0, y0, x1, y1) = it.bbox
        place(bottom + left, dx: ox + x0 * 1pt, dy: -(oy + y0 * 1pt), _curve-of(it, x0, y1))
      } else if it.kind == "label" {
        let al = it.align
        let fx = if al.x == left { 0 } else if al.x == right { 1 } else { 0.5 }
        let fy = if al.y == top { 1 } else if al.y == bottom { 0 } else { 0.5 }
        context {
          let sz = measure(it.body)
          place(bottom + left, dx: ox + it.pos.at(0) - sz.width * fx, dy: -(oy + it.pos.at(1) - sz.height * fy), it.body)
        }
      } else if it.kind == "skeleton" {
        let p = it.path
        let (b0, b1, b2, b3) = _op(p, "bbox")
        let comps = (curve.move(((p.segs.first().at(0) - b0) * 1pt, (b3 - p.segs.first().at(1)) * 1pt)),)
        for s in p.segs { comps.push(curve.cubic(((s.at(2) - b0) * 1pt, (b3 - s.at(3)) * 1pt), ((s.at(4) - b0) * 1pt, (b3 - s.at(5)) * 1pt), ((s.at(6) - b0) * 1pt, (b3 - s.at(7)) * 1pt))) }
        if p.cycle { comps.push(curve.close(mode: "straight")) }
        place(bottom + left, dx: ox + b0 * 1pt, dy: -(oy + b1 * 1pt), curve(stroke: it.stroke, ..comps))
      }
    }
  })
}

// ═════════════════════════════════════════════════════════════════ calligraphic strokes (v0.2)
// Length-based input, pen driven by arc length, `follow`, irregular dashes, `pressure`,
// stacking (`layered`), outline and construction view. Re-implemented here from the behaviour described by
// the `nibst` project (B. Auguie, MPL-2.0) — no code from that project is used.

// ── paths from points (Typst lengths; y up, like everywhere in nib)
#let _pp(q) = (_pt(q.at(0)), _pt(q.at(1)))
#let _seg8(a, b, c, d) = { let (a, b, c, d) = (a, b, c, d).map(_pp); (a.at(0), a.at(1), b.at(0), b.at(1), c.at(0), c.at(1), d.at(0), d.at(1)) }
/// One cubic Bézier segment.
#let cubic(a, b, c, d) = (segs: (_seg8(a, b, c, d),), cycle: false)
/// One straight segment.
#let straight(a, b) = {
  let (p, q) = (_pp(a), _pp(b))
  let l(u) = (p.at(0) + (q.at(0) - p.at(0)) * u, p.at(1) + (q.at(1) - p.at(1)) * u)
  (segs: ((p.at(0), p.at(1), l(1 / 3).at(0), l(1 / 3).at(1), l(2 / 3).at(0), l(2 / 3).at(1), q.at(0), q.at(1)),), cycle: false)
}
/// Concatenate two open paths (the end of `a` is assumed to equal the start of `b`).
#let path-join(a, b) = (segs: a.segs + b.segs, cycle: false)
/// Concatenate a list of paths (optionally closing the result).
#let path-join-all(parts, cycle: false) = (segs: parts.map(q => q.segs).fold((), (a, b) => a + b), cycle: cycle)
#let polyline(pts, cycle: false) = {
  let ps = if cycle { pts + (pts.first(),) } else { pts }
  path-join-all(ps.windows(2).map(w => straight(w.first(), w.last())), cycle: cycle)
}
/// List of cubics `((p0, c1, c2, p3), …)`. With `y-down: true` coordinates follow Typst's convention (y down):
/// the path is flipped and pen angles are mirrored, to reproduce a drawing written for `nibst`.
#let cubics(segments, cycle: false, y-down: false) = {
  let segs = segments.map(s => { let t = _seg8(..s); if y-down { (t.at(0), -t.at(1), t.at(2), -t.at(3), t.at(4), -t.at(5), t.at(6), -t.at(7)) } else { t } })
  (segs: segs, cycle: cycle, ydown: y-down)
}

// ── calligraphic pen (optionally varying along the path)
#let _ratio(v) = if type(v) == ratio { v / 100% } else { float(v) }
/// `nibpen(width:, thinness:, angle:, follow:)` or, with stops `(at: 0%|1cm, width:, thinness:, minor-width:, angle:)`,
/// linear interpolation between stops. `follow: true`: the angle is relative to the path tangent.
#let nibpen(..stops, width: 1pt, thinness: 25%, minor-width: none, angle: 30deg, follow: false) = {
  let mk(st) = {
    let w = st.at("width", default: width)
    let mw = st.at("minor-width", default: minor-width)
    let h = if mw == none { w * _ratio(st.at("thinness", default: thinness)) } else { mw }
    (pos: st.at("at", default: 0%), w: _pt(w), h: _pt(h), a: _rad(st.at("angle", default: angle)))
  }
  let sts = if stops.pos().len() == 0 { ((at: 0%),) } else { stops.pos() }
  (kind: "varpen", follow: follow, stops: sts.map(mk))
}
/// Dash pattern: alternating dash/gap lengths; `jitter` = random variation (seeded by `seed`).
#let dashes(..lengths, offset: 0pt, jitter: 0pt, seed: 0) = (lengths: lengths.pos().map(_pt), offset: _pt(offset), jitter: _pt(jitter), seed: seed)
/// Break up the thin parts of a stroke (intermittent pressure): below `minimum-width`, gaps appear.
#let pressure(minimum-width: 0.2pt, period: 2pt, seed: 0) = (min: _pt(minimum-width), period: _pt(period), seed: seed)

#let _lcg(s) = calc.rem(s * 1664525 + 1013904223, 4294967296)
#let _unit(s) = s / 4294967296
#let _clip01(x) = calc.min(1.0, calc.max(0.0, x))

/// Pen parameters (w, h, angle) at arc length `s` (pt).
#let _pen-at(stops, s, L) = {
  let ps = stops.map(st => if type(st.pos) == ratio { st.pos / 100% * L } else { _pt(st.pos) })
  let k = stops.len()
  if s <= ps.first() or k == 1 { return (stops.first().w, stops.first().h, stops.first().a) }
  if s >= ps.last() { return (stops.last().w, stops.last().h, stops.last().a) }
  let i = 0
  while i + 2 < k and ps.at(i + 1) < s { i += 1 }
  let (s0, s1) = (ps.at(i), ps.at(i + 1))
  let u = if s1 > s0 { (s - s0) / (s1 - s0) } else { 1.0 }
  let (a, b) = (stops.at(i), stops.at(i + 1))
  (a.w + (b.w - a.w) * u, a.h + (b.h - a.h) * u, a.a + (b.a - a.a) * u)
}

#let _intersect(A, B) = {
  let out = ()
  let (i, j) = (0, 0)
  while i < A.len() and j < B.len() {
    let lo = calc.max(A.at(i).at(0), B.at(j).at(0))
    let hi = calc.min(A.at(i).at(1), B.at(j).at(1))
    if hi > lo { out.push((lo, hi)) }
    if A.at(i).at(1) < B.at(j).at(1) { i += 1 } else { j += 1 }
  }
  out
}

#let _dash-intervals(d, L) = {
  let n = d.lengths.len()
  let st = _lcg(d.seed * 7919 + 17)
  let out = ()
  let pos = -calc.rem(d.offset, d.lengths.sum())
  let k = 0
  while pos < L and k < 100000 {
    st = _lcg(st)
    let len = d.lengths.at(calc.rem(k, n))
    if d.jitter > 0 { len = calc.max(0.05 * len, len + d.jitter * (2 * _unit(st) - 1)) }
    if calc.even(k) {
      let (a, b) = (calc.max(0.0, pos), calc.min(L, pos + len))
      if b > a { out.push((a, b)) }
    }
    pos += len
    k += 1
  }
  out
}

#let _pressure-intervals(pr, stops, L) = {
  let cells = calc.ceil(L / pr.period)
  let st = _lcg(pr.seed * 104729 + 31)
  let keep = ()
  for c in range(cells) {
    st = _lcg(st)
    let (a, b) = (c * pr.period, calc.min(L, (c + 1) * pr.period))
    let (_, h, _) = _pen-at(stops, (a + b) / 2, L)
    let gap = _clip01(1 - h / pr.min)
    if _unit(st) >= gap {
      if keep.len() > 0 and keep.last().at(1) >= a - 1e-9 { keep.last().at(1) = b } else { keep.push((a, b)) }
    }
  }
  keep
}

#let _ellipse-contour(cx, cy, a, b, ang) = {
  let m = 32
  let cmds = ()
  for i in range(m) {
    let t = 2 * calc.pi * i / m
    let (ex, ey) = (a * calc.cos(t), b * calc.sin(t))
    let x = cx + ex * calc.cos(ang) - ey * calc.sin(ang)
    let y = cy + ex * calc.sin(ang) + ey * calc.cos(ang)
    cmds.push((if i == 0 { 0 } else { 1 }, x, y))
  }
  cmds
}

#let _contours-bbox(cs) = {
  let pts = cs.flatten().chunks(3).map(c => (c.at(1), c.at(2)))
  (calc.min(..pts.map(q => q.at(0))), calc.min(..pts.map(q => q.at(1))), calc.max(..pts.map(q => q.at(0))), calc.max(..pts.map(q => q.at(1))))
}

/// Drawable objects of a calligraphic stroke (pass them to `mp-fig`).
/// - `pen`: `nibpen(...)`, `penellipse/pencircle/broadnib/...`; `pens:` (one pen per node, legacy mode) is still accepted.
/// - `follow`: angle relative to the tangent (overrides `nibpen(follow:)`); `refine`: subdivision (auto = 4 when the pen varies).
/// - `dash`, `pressure`: see `dashes`, `pressure`.
/// - `overlap: "union"` (default) or `"layered"` (pieces of length `layer` stacked; useful with a translucent fill + `outline`).
/// - `outline`: a Typst `stroke` around the shape; `debug`: skeleton and pen outlines.
#let stroke-items(p, pen: none, pens: none, fill: black, dash: none, pressure: none, follow: auto, refine: auto,
    overlap: "union", layer: 4pt, outline: none, tol: 0.01pt, exact: false, fit: true, debug: false) = {
  assert(overlap in ("union", "layered"), message: "nib: overlap must be \"union\" or \"layered\"")
  let sgn = if p.at("ydown", default: false) { -1 } else { 1 }
  if pens != none or (type(pen) == dictionary and pen.kind in ("ellipse", "poly")) {
    if dash == none and pressure == none and overlap == "union" and not debug {
      return (draw(p, pen: pen, pens: pens, fill: fill, tol: tol, exact: exact, fit: fit, outline: outline),)
    }
  }
  // variable pen: list of stops
  let vp = if pens != none { panic("nib: `pens` cannot be combined with dash/pressure/layered/debug") } else if pen.kind == "varpen" { pen } else if pen.kind == "ellipse" {
    (kind: "varpen", follow: false, stops: ((pos: 0%, w: pen.w, h: pen.h, a: pen.angle),))
  } else { panic("nib: dash/pressure/layered/debug need an elliptical pen") }
  let fol = if follow == auto { vp.follow } else { follow }
  let stops = vp.stops.map(st => (pos: st.pos, w: st.w, h: st.h, a: st.a * sgn))
  let simple = stops.len() == 1 and not fol and dash == none and pressure == none and overlap == "union" and not debug
  if simple {
    let st = stops.first()
    return (draw(p, pen: penellipse(st.w * 1pt, st.h * 1pt, angle: st.a * 1rad), fill: fill, tol: tol, exact: exact, fit: fit, outline: outline),)
  }
  let k = if refine == auto { if stops.len() > 1 or fol { 4 } else { 1 } } else { refine }
  let p2 = if k > 1 { _op(p, "refine", args: (k,)) } else { p }
  let prof = _op(p2, "profile")
  let L = prof.len.last()
  let cyc = p2.cycle
  // arc-length intervals to draw
  let ivs = none
  if dash != none { ivs = _dash-intervals(dash, L) }
  if pressure != none {
    let pr = _pressure-intervals(pressure, stops, L)
    ivs = if ivs == none { pr } else { _intersect(ivs, pr) }
  }
  if overlap == "layered" {
    let lay = _pt(layer)
    let base = if ivs == none { ((0.0, L),) } else { ivs }
    let cut = ()
    for (a, b) in base {
      let m = calc.max(1, calc.ceil((b - a) / lay))
      for i in range(m) { cut.push((a + (b - a) * i / m, a + (b - a) * (i + 1) / m)) }
    }
    ivs = cut
  }
  // pieces: (path, arc length at nodes, tangent at nodes)
  let pcs = if ivs == none {
    let nn = if cyc { p2.segs.len() } else { p2.segs.len() + 1 }
    ((path: p2, s: prof.len.slice(0, nn), ang: prof.ang.slice(0, nn)),)
  } else {
    if ivs.len() == 0 { () } else { _op(p2, "pieces", args: ivs.flatten()) }
  }
  let reqs = ()
  for pc in pcs {
    let prev = none
    let arr = ()
    for (i, s) in pc.s.enumerate() {
      if pc.path.at("cycle", default: false) and i >= pc.path.segs.len() { continue }
      let (w, h, a) = _pen-at(stops, s, L)
      if fol { a += pc.ang.at(i) }
      if prev != none { a = a - calc.pi * calc.round((a - prev) / calc.pi) }
      prev = a
      arr.push((w, h, a))
    }
    reqs.push((path: pc.path, pens: arr, opts: (tol: _pt(tol), fit: fit, exact: false)))
  }
  let shapes = if reqs.len() == 0 { () } else { _call(_plugin.nib_stroke_many, (items: reqs)) }
  let items = ()
  if overlap == "layered" {
    for sh in shapes { items.push(_shape(sh.contours, sh.bbox, fill, stroke: outline)) }
  } else if shapes.len() > 0 {
    let cs = shapes.map(sh => sh.contours).fold((), (a, b) => a + b)
    let bb = (calc.min(..shapes.map(sh => sh.bbox.at(0))), calc.min(..shapes.map(sh => sh.bbox.at(1))), calc.max(..shapes.map(sh => sh.bbox.at(2))), calc.max(..shapes.map(sh => sh.bbox.at(3))))
    items.push(_shape(cs, bb, fill, stroke: outline))
  }
  if debug {
    items.push(mp-skeleton(p, stroke: 0.45pt + rgb("#b3261e")))
    let n2 = p2.segs.len()
    let stepn = calc.max(1, calc.ceil(n2 / 40))
    let cs = ()
    for i in range(0, n2 + 1, step: stepn) {
      let j = calc.min(i, n2 - 1)
      let (x, y) = if i < n2 { (p2.segs.at(i).at(0), p2.segs.at(i).at(1)) } else { (p2.segs.last().at(6), p2.segs.last().at(7)) }
      let (w, h, a) = _pen-at(stops, prof.len.at(i), L)
      if fol { a += prof.ang.at(i) }
      cs.push(_ellipse-contour(x, y, w / 2, h / 2, a))
    }
    items.push(_shape(cs, _contours-bbox(cs), none, stroke: (paint: rgb("#176b87"), thickness: 0.45pt)))
  }
  items
}

/// Like `stroke-items` but returns a box directly (an `mp-fig` fitted to the content + `pad`).
#let nib-stroke(p, pad: 1pt, ..args) = mp-fig(..stroke-items(p, ..args), pad: pad)
