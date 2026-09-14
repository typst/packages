// ctz-euclide/src/conic/parabola.typ
// Parabola-related conic functions

#import "../util.typ"

// =============================================================================
// INTERNAL HELPERS
// =============================================================================

/// Normalize a 2D vector
#let _unit2(v) = {
  let len = calc.sqrt(v.at(0) * v.at(0) + v.at(1) * v.at(1))
  if len < util.eps {
    return (0, 0)
  }
  (v.at(0) / len, v.at(1) / len)
}

/// Perpendicular 2D vector
#let _perp2(v) = util.perpendicular(v)

/// Dot product (2D)
#let _dot2(a, b) = a.at(0) * b.at(0) + a.at(1) * b.at(1)

// =============================================================================
// PARABOLA FUNCTIONS
// =============================================================================

/// Sample points on a parabola defined by focus and directrix line
/// - focus: (x, y, z)
/// - directrix-a, directrix-b: two points on the directrix
/// - extent: half-width along directrix direction
/// - steps: number of segments
#let parabola-points-focus-directrix-raw(focus, directrix-a, directrix-b, extent: auto, steps: 120) = {
  let foot = util.project-point-on-line(focus, directrix-a, directrix-b)
  let d = util.dist(focus, foot)
  if d < util.eps {
    return ()
  }

  let u = _unit2((focus.at(0) - foot.at(0), focus.at(1) - foot.at(1)))
  let v = _perp2(u)
  let ext = if extent == auto { d * 3 } else { extent }

  let pts = ()
  for i in range(0, steps + 1) {
    let t = -ext + (2 * ext) * i / steps
    let x = (t * t + d * d) / (2 * d)
    let px = foot.at(0) + u.at(0) * x + v.at(0) * t
    let py = foot.at(1) + u.at(1) * x + v.at(1) * t
    pts.push((px, py, focus.at(2, default: 0)))
  }
  pts
}

/// Parabola points from focus, p, angle (Asymptote-like)
/// p: distance from vertex to focus
/// angle: opening direction
#let parabola-points-from-focus-raw(focus, p, angle: 0deg, extent: auto, steps: 120) = {
  let ang = util.to-angle(angle)
  let ax = (calc.cos(ang), calc.sin(ang))
  let perp = _perp2(ax)

  // Vertex and directrix (distance p behind focus, then another p to directrix)
  let V = (focus.at(0) - p * ax.at(0), focus.at(1) - p * ax.at(1))
  let D0 = (focus.at(0) - 2 * p * ax.at(0), focus.at(1) - 2 * p * ax.at(1))
  let D1 = (D0.at(0) - 10 * perp.at(0), D0.at(1) - 10 * perp.at(1))
  let D2 = (D0.at(0) + 10 * perp.at(0), D0.at(1) + 10 * perp.at(1))

  parabola-points-focus-directrix-raw(focus, D1, D2, extent: extent, steps: steps)
}

/// Directrix endpoints and vertex for a parabola (focus, p, angle)
/// Returns (D1, D2, V)
#let parabola-directrix-raw(focus, p, angle: 0deg) = {
  let ang = util.to-angle(angle)
  let ax = (calc.cos(ang), calc.sin(ang))
  let perp = _perp2(ax)
  let V = (focus.at(0) - p * ax.at(0), focus.at(1) - p * ax.at(1))
  let D0 = (focus.at(0) - 2 * p * ax.at(0), focus.at(1) - 2 * p * ax.at(1))
  let D1 = (D0.at(0) - 10 * perp.at(0), D0.at(1) - 10 * perp.at(1))
  let D2 = (D0.at(0) + 10 * perp.at(0), D0.at(1) + 10 * perp.at(1))
  (D1, D2, V)
}

/// Internal parabola frame (foot, u, v, d)
#let _parabola-frame-raw(focus, directrix-a, directrix-b) = {
  let foot = util.project-point-on-line(focus, directrix-a, directrix-b)
  let d = util.dist(focus, foot)
  if d < util.eps {
    return none
  }
  let u = _unit2((focus.at(0) - foot.at(0), focus.at(1) - foot.at(1)))
  let v = _perp2(u)
  (foot, u, v, d)
}

/// Point on parabola (focus/directrix) for parameter t (along directrix direction)
#let parabola-point-raw(focus, directrix-a, directrix-b, t) = {
  let frame = _parabola-frame-raw(focus, directrix-a, directrix-b)
  if frame == none { return none }
  let (foot, u, v, d) = frame
  let x = (t * t + d * d) / (2 * d)
  let px = foot.at(0) + u.at(0) * x + v.at(0) * t
  let py = foot.at(1) + u.at(1) * x + v.at(1) * t
  (px, py, focus.at(2, default: 0))
}

/// Tangent at parameter t on parabola
/// Returns (p1, p2, pt)
#let parabola-tangent-raw(focus, directrix-a, directrix-b, t, length: auto) = {
  let frame = _parabola-frame-raw(focus, directrix-a, directrix-b)
  if frame == none { return none }
  let (foot, u, v, d) = frame
  let pt = parabola-point-raw(focus, directrix-a, directrix-b, t)
  let dir = (u.at(0) * (t / d) + v.at(0), u.at(1) * (t / d) + v.at(1))
  let udir = _unit2(dir)
  let len = if length == auto { d * 2 } else { length }
  let p1 = (pt.at(0) - udir.at(0) * len, pt.at(1) - udir.at(1) * len, pt.at(2))
  let p2 = (pt.at(0) + udir.at(0) * len, pt.at(1) + udir.at(1) * len, pt.at(2))
  (p1, p2, pt)
}

/// Tangents from an external point to the parabola (focus/directrix)
/// Returns ( (p1, p2, tpt), ... )
#let parabola-tangents-from-point-raw(focus, directrix-a, directrix-b, external, length: auto) = {
  let frame = _parabola-frame-raw(focus, directrix-a, directrix-b)
  if frame == none { return () }
  let (foot, u, v, d) = frame

  let rel = (external.at(0) - foot.at(0), external.at(1) - foot.at(1))
  let x0 = _dot2(rel, u)
  let y0 = _dot2(rel, v)

  let A = (-2 * x0 + d)
  let B = 2 * y0
  let C = -d

  let slopes = ()
  if calc.abs(A) < util.eps {
    if calc.abs(B) < util.eps {
      slopes = ()
    } else {
      slopes = (-C / B,)
    }
  } else {
    let disc = B * B - 4 * A * C
    if disc >= 0 {
      let root = calc.sqrt(disc)
      slopes = ((-B + root) / (2 * A), (-B - root) / (2 * A))
    }
  }

  let results = ()
  for m in slopes {
    let b = y0 - m * x0
    let tpt = if calc.abs(m) < util.eps and calc.abs(b) < util.eps {
      // Vertex tangent
      let x = d / 2
      let y = 0
      let px = foot.at(0) + u.at(0) * x + v.at(0) * y
      let py = foot.at(1) + u.at(1) * x + v.at(1) * y
      (px, py, external.at(2, default: 0))
    } else {
      let x = (d - m * b) / (m * m)
      let y = m * x + b
      let px = foot.at(0) + u.at(0) * x + v.at(0) * y
      let py = foot.at(1) + u.at(1) * x + v.at(1) * y
      (px, py, external.at(2, default: 0))
    }

    // Direction from external point to tangent point
    let dir = (tpt.at(0) - external.at(0), tpt.at(1) - external.at(1))
    let udir = _unit2(dir)
    let len = if length == auto { d * 2 } else { length }

    // Line passes through both external and tpt, extend in both directions
    let p1 = (external.at(0) - udir.at(0) * len, external.at(1) - udir.at(1) * len, external.at(2, default: 0))
    let p2 = (tpt.at(0) + udir.at(0) * len, tpt.at(1) + udir.at(1) * len, tpt.at(2, default: 0))

    results.push((p1, p2, tpt))
  }

  results
}
