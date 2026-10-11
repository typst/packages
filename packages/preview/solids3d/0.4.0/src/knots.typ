// knots.typ — knots and links in 3D, drawn with the *real* depth order, by nibart.
//
// A 3D curve is sampled, projected, smoothed into a Hobby spline (nibart) and its crossings are found
// (nibart). At every crossing the depth of the two passages tells which strand is over: the under-strand is
// interrupted (style "gap": the classic knot diagram) or the over-strand is redrawn on top ("weave").
// Every strand is a shaded tube: outline, shadow side, body and highlight, all pen strokes of nibart.

#import "@preview/nibart:0.3.0" as nib
#import "projection.typ": project-point, closeness
#import "nibridge.typ": items-paths
#import "pens.typ": *
#import "vec.typ": *

// ── classic curves: functions t ∈ [0, 1) → (x, y, z) ────────────────────────────────
#let _tau = 2 * calc.pi
/// Trefoil knot (3₁), about 4 units wide.
#let trefoil(scale: 1.0) = t => {
  let a = _tau * t
  (scale * (calc.sin(a) + 2 * calc.sin(2 * a)), scale * (calc.cos(a) - 2 * calc.cos(2 * a)), -scale * calc.sin(3 * a))
}
/// Figure-eight knot (4₁).
#let figure-eight(scale: 1.0) = t => {
  let a = _tau * t
  let r = 2 + calc.cos(2 * a)
  (scale * r * calc.cos(3 * a) * 0.8, scale * r * calc.sin(3 * a) * 0.8, scale * 1.4 * calc.sin(4 * a))
}
/// Torus knot T(p, q) on a torus of radii `R` (centre circle) and `r` (tube).
#let torus-knot(p, q, R: 2.0, r: 0.9) = t => {
  let a = _tau * t
  let k = R + r * calc.cos(q * a)
  (k * calc.cos(p * a), k * calc.sin(p * a), r * calc.sin(q * a))
}
/// Hopf link: two linked circles.
#let hopf-link(R: 1.0) = (
  t => (R * calc.cos(_tau * t) - R / 2, R * calc.sin(_tau * t), 0.0),
  t => (R * calc.cos(_tau * t) + R / 2, 0.0, R * calc.sin(_tau * t)),
)
/// Borromean rings: three ellipses, no two linked, yet inseparable.
#let borromean(a: 2.0, b: 1.2) = (
  t => (a * calc.cos(_tau * t), b * calc.sin(_tau * t), 0.0),
  t => (0.0, a * calc.cos(_tau * t), b * calc.sin(_tau * t)),
  t => (b * calc.sin(_tau * t), 0.0, a * calc.cos(_tau * t)),
)

#let _mix(a, b, t) = color.mix((a, (1 - t) * 100%), (b, t * 100%))

// layers of a shaded tube along `piece`
#let _tube(piece, w, ol, base, dark, lite, ink, lv) = {
  let (lx, ly) = lv
  let items = ()
  if ol > 0pt { items += nib.stroke-items(piece, pen: nib.pencircle(w + 2 * ol), fill: ink, tol: 0.02pt) }
  items += nib.stroke-items(piece, pen: nib.pencircle(w), fill: dark, tol: 0.02pt)
  items += nib.stroke-items(nib.shifted(piece, lx * 0.14 * w, ly * 0.14 * w), pen: nib.pencircle(0.72 * w), fill: base, tol: 0.02pt)
  if lite != none { items += nib.stroke-items(nib.shifted(piece, lx * 0.2 * w, ly * 0.2 * w), pen: nib.pencircle(0.2 * w), fill: lite, tol: 0.02pt) }
  items
}

/// Knots and links of 3D curves. `strands`: functions `t => (x, y, z)` on [0, 1) (closed curves) or arrays of
/// points; see `trefoil`, `torus-knot`, `hopf-link`, `borromean`…
/// - `width`: tube diameter on paper (length). `samples`: points per strand. `colors`: one colour per strand.
/// - `style`: `"gap"` (the under-strand is interrupted) or `"weave"` (continuous tubes, the over-strand redrawn).
/// - `gap`: clearance of a gap; `outline`: outline width (auto: 14 % of the width).
#let knot3(..strands, samples: 120, width: 7pt, colors: auto, style: "gap", gap: auto, outline: auto, ink: auto, flips: ()) = {
  assert(style in ("gap", "weave"), message: "knot3: style must be \"gap\" or \"weave\"")
  let S = ()
  for s in strands.pos() { if type(s) == array and s.len() > 0 and type(s.first()) == function { S += s } else { S.push(s) } }
  let pts = S.map(s => if type(s) == function { range(samples).map(i => s(i / samples).map(float)) } else { s.map(v => v.map(float)) })
  ((cmd: "knot3", pts: pts, width: width, colors: colors, style: style, gap: gap, outline: outline, ink: ink, flips: flips),)
}

#let _default-colors = (rgb("#c0392b"), rgb("#2c6fbb"), rgb("#d9a521"), rgb("#2e8b57"), rgb("#7a4fa0"))

// the primitives of a knot command, in user units. `eng`: engraving style (paper tubes, ink shadow side).
#let knot-prims(c, P, s0, lv, eng: none) = {
  let w = c.width.pt()
  let ol = if c.outline == auto { 0.14 * w } else { c.outline.pt() }
  let ink = if c.ink != auto { c.ink } else if eng != none { eng.ink } else { rgb("#1d1a24") }
  let cols = if eng != none { (eng.paper,) } else if c.colors == auto { _default-colors } else { c.colors }
  let n = c.pts.len()
  // projected, smoothed strands and the depth of their samples
  let paths = ()
  let cl = ()
  for s in c.pts {
    let z = s.map(v => project-point(P, v))
    paths.push(nib.mp-path-pts(z.map(q => (q.at(0) * s0, q.at(1) * s0)), cycle: true))
    cl.push(s.map(v => closeness(P, v)))
  }
  let depth-at = (i, t) => {
    let m = cl.at(i).len()
    let k = calc.rem-euclid(int(calc.floor(t)), m)
    let f = t - calc.floor(t)
    cl.at(i).at(k) * (1 - f) + cl.at(i).at(calc.rem-euclid(k + 1, m)) * f
  }
  // crossings and who is over
  let xs = nib.crossings(paths)
  let info = ()
  for (k, x) in xs.enumerate() {
    let (ia, ta) = x.a
    let (ib, tb) = x.b
    let a-over = depth-at(ia, ta) > depth-at(ib, tb)
    if (k + 1) in c.flips { a-over = not a-over }
    let da = nib.direction-of(paths.at(ia), ta)
    let db = nib.direction-of(paths.at(ib), tb)
    let sn = calc.max(calc.abs(da.at(0) * db.at(1) - da.at(1) * db.at(0)), 0.3)
    info.push((over: if a-over { x.a } else { x.b }, under: if a-over { x.b } else { x.a }, sn: sn))
  }
  let g = if c.gap == auto { 0.3 * w } else { c.gap.pt() }
  let color-of = i => cols.at(calc.rem(i, cols.len()))
  let layers = (p, i) => {
    let base = color-of(i)
    let dark = if eng != none { ink } else { _mix(base, black, 0.5) }
    let lite = if eng != none { none } else { _mix(base, white, 0.65) }
    _tube(p, w * 1pt, ol * 1pt, base, dark, lite, ink, lv)
  }
  let items = ()
  if c.style == "gap" {
    for (i, s) in paths.enumerate() {
      let times = ()
      let halves = ()
      for inf in info {
        if inf.under.at(0) == i {
          times.push(inf.under.at(1))
          halves.push(((w + 2 * ol) / 2 + g) / inf.sn * 1pt)
        }
      }
      let pieces = if times.len() == 0 { (s,) } else { nib.gap-at(s, times, halves) }
      for piece in pieces { items += layers(piece, i) }
    }
  } else {
    for (i, s) in paths.enumerate() { items += layers(s, i) }
    for inf in info {
      let (i, t) = inf.over
      let s = paths.at(i)
      let L = nib.arclength(s).pt()
      let sc = nib.arclength(nib.subpath(s, 0, t)).pt()
      let R = ((w + 2 * ol) / 2 + 0.5) / inf.sn + 0.15 * w
      // staggered extents: each layer stops inside the paint of the next one, so that the redrawn piece
      // melts into the continuous tube below it (no visible seam)
      let R2 = R + 0.6 * w + ol
      let R3 = R2 + 0.75 * w
      let R4 = R3 + 0.5 * w
      let piece = r => nib.subpath(s, if sc - r < 0 { nib.arctime(s, calc.max(sc - r + L, 0.0)) - s.segs.len() } else { nib.arctime(s, sc - r) },
        if sc + r > L { nib.arctime(s, calc.min(sc + r - L, L)) + s.segs.len() } else { nib.arctime(s, sc + r) })
      let base = color-of(i)
      let dark = if eng != none { ink } else { _mix(base, black, 0.5) }
      let lite = if eng != none { none } else { _mix(base, white, 0.65) }
      let (lx, ly) = lv
      items += nib.stroke-items(piece(R), pen: nib.pencircle((w + 2 * ol) * 1pt), fill: ink, tol: 0.02pt)
      items += nib.stroke-items(piece(R2), pen: nib.pencircle(w * 1pt), fill: dark, tol: 0.02pt)
      let p3 = piece(R3)
      items += nib.stroke-items(nib.shifted(p3, lx * 0.14 * w * 1pt, ly * 0.14 * w * 1pt), pen: nib.pencircle(0.72 * w * 1pt), fill: base, tol: 0.02pt)
      if lite != none { items += nib.stroke-items(nib.shifted(piece(R4), lx * 0.2 * w * 1pt, ly * 0.2 * w * 1pt), pen: nib.pencircle(0.2 * w * 1pt), fill: lite, tol: 0.02pt) }
    }
  }
  let prims = ()
  for it in items {
    if it.at("kind", default: none) != "shape" { continue }
    let ps = items-paths((it,), s0)
    if ps.len() == 0 { continue }
    let xs2 = ()
    let ys2 = ()
    for p in ps { for z in p.nodes { xs2.push(z.at(0)); ys2.push(z.at(1)) } }
    prims.push((type: "ink", paths: ps, paint: it.fill, alpha: 1.0, bb: ((calc.min(..xs2), calc.min(..ys2)), (calc.max(..xs2), calc.max(..ys2)))))
  }
  prims
}
