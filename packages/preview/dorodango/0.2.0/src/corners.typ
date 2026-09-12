#import "geometry.typ": _hypot, _vadd, _vscale, _vsub

// The four corners clockwise, and for each the side and corner reached by
// stepping one place clockwise (`cw`) or counter-clockwise (`ccw`).
#let _corner-order = ("top-left", "top-right", "bottom-right", "bottom-left")
#let _next-cw = (
  top-left: "top-right",
  top-right: "bottom-right",
  bottom-right: "bottom-left",
  bottom-left: "top-left",
)
#let _next-ccw = (
  top-left: "bottom-left",
  top-right: "top-left",
  bottom-right: "top-right",
  bottom-left: "bottom-right",
)
#let _side-cw = (
  top-left: "top",
  top-right: "right",
  bottom-right: "bottom",
  bottom-left: "left",
)
#let _side-ccw = (
  top-left: "left",
  top-right: "top",
  bottom-right: "right",
  bottom-left: "bottom",
)

// Unit vectors along the two edges at each corner (`edge-in` from the previous
// side, `edge-out` toward the next) and the arc's angular span.
#let _corner-geom = (
  top-left: (edge-in: (0, 1), edge-out: (1, 0), base0: 180deg, base1: 270deg),
  top-right: (edge-in: (-1, 0), edge-out: (0, 1), base0: -90deg, base1: 0deg),
  bottom-right: (
    edge-in: (0, -1),
    edge-out: (-1, 0),
    base0: 0deg,
    base1: 90deg,
  ),
  bottom-left: (
    edge-in: (1, 0),
    edge-out: (0, -1),
    base0: 90deg,
    base1: 180deg,
  ),
)

// Per-corner straight-edge budget for rounding and smoothing. Adjacent corners
// split each side by radius, taking the smaller share. Larger radii go first.
#let _budgets(radii, side-lens) = {
  let budget = (
    top-left: -1pt,
    top-right: -1pt,
    bottom-right: -1pt,
    bottom-left: -1pt,
  )
  for corner in _corner-order.sorted(key: c => -radii.at(c)) {
    let r = radii.at(corner)
    // The two sides this corner shares, each with the corner at its far end.
    let vals = (
      (_side-cw.at(corner), _next-cw.at(corner)),
      (_side-ccw.at(corner), _next-ccw.at(corner)),
    ).map(pair => {
      let (side, adj-corner) = pair
      let ar = radii.at(adj-corner)
      if r <= 0pt and ar <= 0pt { 0pt } else {
        let side-len = side-lens.at(side)
        let adj-budget = budget.at(adj-corner)
        if adj-budget >= 0pt { side-len - adj-budget } else {
          (r / (r + ar)) * side-len
        }
      }
    })
    budget.at(corner) = calc.min(..vals)
  }
  budget
}

// Figma's "Corner Smoothing": a, b, c, d are Bezier handle lengths for the
// lead-in/lead-out cubics, and arc-measure is what survives of the circular
// arc (90deg at smoothing 0, 0deg at smoothing 1).
// https://www.figma.com/blog/desperately-seeking-squircles/
#let _corner-params(r, s, budget, preserve-smoothing) = {
  if r <= 0pt {
    (
      a: 0pt,
      b: 0pt,
      c: 0pt,
      d: 0pt,
      p: 0pt,
      angle-alpha: 45deg,
    )
  } else {
    let p = (1 + s) * r
    // With `false`, clamp `s` to the budget, so further increases may have no
    // effect. With `true`, shorten over-budget a/b handles to preserve smoothing.
    if not preserve-smoothing {
      s = calc.min(s, budget / r - 1)
      p = calc.min(p, budget)
    }
    let arc-measure = 90deg * (1 - s)
    let arc-len = calc.sin(arc-measure / 2) * r * calc.sqrt(2)
    let angle-alpha = (90deg - arc-measure) / 2
    let p3-p4 = r * calc.tan(angle-alpha / 2)
    let angle-beta = 45deg * s
    let c = p3-p4 * calc.cos(angle-beta)
    let d = c * calc.tan(angle-beta)
    let b = (p - arc-len - c - d) / 3
    let a = 2 * b
    if preserve-smoothing and p > budget {
      let p1-p3-max = budget - d - arc-len - c
      let min-a = p1-p3-max / 6
      let max-b = p1-p3-max - min-a
      b = calc.min(b, max-b)
      a = p1-p3-max - b
      p = budget
    }
    (
      a: a,
      b: b,
      c: c,
      d: d,
      p: p,
      angle-alpha: angle-alpha,
    )
  }
}

// Plain points rather than `curve.cubic`, so a segment can also be walked
// backwards, which the inside of a filled outline needs.
#let _cubic(from, c1, c2, to) = (from: from, c1: c1, c2: c2, to: to)
#let _emit(segs) = segs.map(s => curve.cubic(s.c1, s.c2, s.to))
#let _emit-rev(segs) = segs.rev().map(s => curve.cubic(s.c2, s.c1, s.from))

#let _angle-of(center, p) = {
  let d = _vsub(p, center)
  calc.atan2(d.at(0) / 1pt, d.at(1) / 1pt)
}

// Builds a rounded, optionally-smoothed corner. `rect` splits outer, middle,
// and inner outlines at distinct midpoints. Returns `start`, `mid`, `end`,
// `first`, `second`, and `full`. With `split: none`, only `full` is built.
#let _piece(corner, pt, r, params, split: none) = {
  let (edge-in, edge-out, base0, base1) = _corner-geom.at(corner)
  if r <= 0pt {
    // `rect` collapses the corner onto a single point, pulled slightly inside
    // along both edges when the radius is negative.
    return (
      pt: pt,
      arc: false,
      start: _vadd(pt, _vscale(edge-in, r)),
      mid: pt,
      end: _vadd(pt, _vscale(edge-out, r)),
      full: (),
      first: (),
      second: (),
    )
  }

  let (a, b, c, d, p, angle-alpha) = params
  let center = _vadd(pt, _vscale(_vadd(edge-in, edge-out), r))
  let neg-edge-in = _vscale(edge-in, -1)

  let angle0 = base0 + angle-alpha
  let angle1 = base1 - angle-alpha

  let on-arc(angle) = (
    center.at(0) + r * calc.cos(angle),
    center.at(1) + r * calc.sin(angle),
  )

  // Typst's curve has no arc primitive, so each arc becomes one cubic via the
  // standard 4/3*tan(theta/4) construction. `rect` does the same, so the two
  // agree segment for segment.
  let arc-seg(from, to) = {
    let kappa = 4.0 / 3.0 * calc.tan((to - from) / 4)
    let tangent(angle) = (-calc.sin(angle), calc.cos(angle))
    _cubic(
      on-arc(from),
      _vadd(on-arc(from), _vscale(tangent(from), kappa * r)),
      _vadd(on-arc(to), _vscale(tangent(to), -kappa * r)),
      on-arc(to),
    )
  }

  let start = _vadd(pt, _vscale(edge-in, p))
  let arc-p1 = on-arc(angle1)
  let end = _vadd(pt, _vscale(edge-out, p))

  let lead-in = _cubic(
    start,
    _vadd(start, _vscale(neg-edge-in, a)),
    _vadd(start, _vscale(neg-edge-in, a + b)),
    on-arc(angle0),
  )
  let lead-out = _cubic(
    arc-p1,
    _vadd(_vadd(arc-p1, _vscale(neg-edge-in, d)), _vscale(edge-out, c)),
    _vadd(_vadd(arc-p1, _vscale(neg-edge-in, d)), _vscale(edge-out, b + c)),
    end,
  )

  let base = (
    pt: pt,
    arc: true,
    start: start,
    end: end,
    full: (lead-in, arc-seg(angle0, angle1), lead-out),
  )
  if split == none {
    return (..base, mid: pt, first: (), second: ())
  }

  // Bring the requested angle into this corner's branch, then keep it inside
  // whatever is left of the arc after smoothing trimmed it.
  let angle-mid = {
    let s = _angle-of(center, split)
    while s < base0 { s += 360deg }
    while s > base1 { s -= 360deg }
    calc.max(angle0, calc.min(angle1, s))
  }

  (
    ..base,
    mid: on-arc(angle-mid),
    first: (lead-in, arc-seg(angle0, angle-mid)),
    second: (arc-seg(angle-mid, angle1), lead-out),
  )
}

// One cubic through the arc from `start` to `end` around `center`. Round caps
// come from a deliberately off-center point, so this construction is
// center-based rather than angular.
#let _arc-through(start, center, end) = {
  let a = _vsub(start, center)
  let b = _vsub(end, center)
  let ax = a.at(0) / 1pt
  let ay = a.at(1) / 1pt
  let bx = b.at(0) / 1pt
  let by = b.at(1) / 1pt
  let q1 = ax * ax + ay * ay
  let q2 = q1 + ax * bx + ay * by
  let denom = ax * by - ay * bx
  if denom == 0 { return curve.line(end) }
  let k2 = 4.0 / 3.0 * (calc.sqrt(calc.max(0.0, 2 * q1 * q2)) - q2) / denom
  curve.cubic(
    (
      center.at(0) + a.at(0) - k2 * a.at(1),
      center.at(1) + a.at(1) + k2 * a.at(0),
    ),
    (
      center.at(0) + b.at(0) + k2 * b.at(1),
      center.at(1) + b.at(1) - k2 * b.at(0),
    ),
    end,
  )
}

// Unit vector 90 degrees counter-clockwise from `from` -> `to`. Unitless so it
// can be scaled by a length.
#let _line-normal(from, to) = {
  let d = _vsub(to, from)
  let h = _hypot(d) / 1pt
  if h == 0 { (0, 0) } else { (d.at(1) / 1pt / h, -(d.at(0) / 1pt) / h) }
}

// `rect` nudges a round cap's center off the chord by one *raw* unit, 1/127 of
// a point, just enough to keep the arc from collapsing to a line.
#let _cap-nudge = 1pt / 127
