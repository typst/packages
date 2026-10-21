#import "geometry.typ": _hypot, _vadd, _vscale, _vsub

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

// A cubic segment, kept as plain points so that it can also be walked
// backwards -- the inside of a filled outline is traced counter-clockwise.
#let _cubic(from, c1, c2, to) = (from: from, c1: c1, c2: c2, to: to)
#let _emit(segs) = segs.map(s => curve.cubic(s.c1, s.c2, s.to))
#let _emit-rev(segs) = segs.rev().map(s => curve.cubic(s.c2, s.c1, s.from))

#let _angle-of(center, p) = {
  let d = _vsub(p, center)
  calc.atan2(d.at(0) / 1pt, d.at(1) / 1pt)
}

// One rounded, optionally-smoothed corner, split in two at `split` so that
// per-side strokes can be drawn: `rect` splits its outline in the middle of
// each corner, and each of the three outlines a stroked shape needs (outer
// edge, stroke center, inner edge) has its own split point.
//
// Returns the corner's `start` (on the previous side), `mid` (the split point)
// and `end` (on the next side), plus `first` (start to mid), `second` (mid to
// end) and `full` (start to end in a single arc, which is what `rect` spends
// on a corner it does not have to split).
#let _piece(corner, pt, r, params, split: auto) = {
  let (edge-in, edge-out, base0, base1) = _corner-geom.at(corner)
  if r <= 0pt {
    // No arc: `rect` collapses the corner onto a single point, which for a
    // negative radius is pulled slightly inside the corner along both edges.
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
  let angle-mid = if split == auto { (angle0 + angle1) / 2 } else {
    // Bring the requested angle into this corner's branch, then keep it
    // inside whatever is left of the arc after smoothing trimmed it.
    let s = _angle-of(center, split)
    while s < base0 { s += 360deg }
    while s > base1 { s -= 360deg }
    calc.max(angle0, calc.min(angle1, s))
  }

  let on-arc(angle) = (
    center.at(0) + r * calc.cos(angle),
    center.at(1) + r * calc.sin(angle),
  )

  // Typst's curve has no arc primitive, so each arc is approximated with a
  // single cubic via the standard 4/3*tan(theta/4) handle-length construction
  // -- the same one `rect` uses, so the two agree segment for segment.
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
  let arc-p0 = on-arc(angle0)
  let arc-p1 = on-arc(angle1)
  let end = _vadd(pt, _vscale(edge-out, p))

  let lead-in = _cubic(
    start,
    _vadd(start, _vscale(neg-edge-in, a)),
    _vadd(start, _vscale(neg-edge-in, a + b)),
    arc-p0,
  )
  let lead-out = _cubic(
    arc-p1,
    _vadd(_vadd(arc-p1, _vscale(neg-edge-in, d)), _vscale(edge-out, c)),
    _vadd(_vadd(arc-p1, _vscale(neg-edge-in, d)), _vscale(edge-out, b + c)),
    end,
  )

  (
    pt: pt,
    arc: true,
    start: start,
    mid: on-arc(angle-mid),
    end: end,
    full: (lead-in, arc-seg(angle0, angle1), lead-out),
    first: (lead-in, arc-seg(angle0, angle-mid)),
    second: (arc-seg(angle-mid, angle1), lead-out),
  )
}

// A single cubic through the arc from `start` to `end` around `center`, for
// round caps -- `rect` draws those from a deliberately off-center point, so
// the construction has to be the center-based one rather than the angular one.
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

// The unit vector 90 degrees counter-clockwise from `from` -> `to`, unitless
// so that it can be scaled by a length.
#let _line-normal(from, to) = {
  let d = _vsub(to, from)
  let h = _hypot(d) / 1pt
  if h == 0 { (0, 0) } else { (d.at(1) / 1pt / h, -(d.at(0) / 1pt) / h) }
}

// `rect` nudges a round cap's center off the chord by a single *raw* unit,
// which is 1/127 of a point -- just far enough to stop the arc degenerating
// into a straight line, and small enough that the cap stays a half circle.
#let _cap-nudge = 1pt / 127
