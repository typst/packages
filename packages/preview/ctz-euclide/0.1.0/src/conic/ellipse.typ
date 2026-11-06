// ctz-euclide/src/conic/ellipse.typ
// Ellipse-related conic functions

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

/// Perpendicular 2D vector (uses util.perpendicular)
#let _perp2(v) = util.perpendicular(v)

/// Dot product (2D)
#let _dot2(a, b) = a.at(0) * b.at(0) + a.at(1) * b.at(1)

/// Rotate a 2D vector by angle
#let _rotate2(v, angle) = {
  let ang = util.to-angle(angle)
  let c = calc.cos(ang)
  let s = calc.sin(ang)
  (v.at(0) * c - v.at(1) * s, v.at(0) * s + v.at(1) * c)
}

// =============================================================================
// ELLIPSE FUNCTIONS
// =============================================================================

/// Point on ellipse for parameter angle t
#let ellipse-point-raw(center, rx, ry, angle: 0deg, t: 0deg) = {
  util.assert-positive(rx, name: "rx (x-radius)")
  util.assert-positive(ry, name: "ry (y-radius)")
  let tt = util.to-angle(t)
  let x = rx * calc.cos(tt)
  let y = ry * calc.sin(tt)
  let rot = _rotate2((x, y), angle)
  (center.at(0) + rot.at(0), center.at(1) + rot.at(1), center.at(2, default: 0))
}

/// Foci of an ellipse
/// Returns (F1, F2)
#let ellipse-foci-raw(center, rx, ry, angle: 0deg) = {
  let a = if rx >= ry { rx } else { ry }
  let b = if rx >= ry { ry } else { rx }
  let c = calc.sqrt(calc.max(0, a * a - b * b))
  let local1 = if rx >= ry { (c, 0) } else { (0, c) }
  let local2 = if rx >= ry { (-c, 0) } else { (0, -c) }
  let rot1 = _rotate2(local1, angle)
  let rot2 = _rotate2(local2, angle)
  (
    (center.at(0) + rot1.at(0), center.at(1) + rot1.at(1), center.at(2, default: 0)),
    (center.at(0) + rot2.at(0), center.at(1) + rot2.at(1), center.at(2, default: 0)),
  )
}

/// Point on ellipse for a direction from center
/// If from-center is true, theta is the ray direction angle
#let ellipse-angpoint-raw(center, rx, ry, angle: 0deg, theta: 0deg, from-center: false) = {
  if not from-center {
    return ellipse-point-raw(center, rx, ry, angle: angle, t: theta)
  }
  let th = util.to-angle(theta)
  let dir = (calc.cos(th), calc.sin(th))
  let local = _rotate2(dir, -util.to-angle(angle))
  let denom = (local.at(0) * local.at(0)) / (rx * rx) + (local.at(1) * local.at(1)) / (ry * ry)
  if denom <= util.eps { return center }
  let s = 1 / calc.sqrt(denom)
  let local-pt = (local.at(0) * s, local.at(1) * s)
  let world = _rotate2(local-pt, angle)
  (center.at(0) + world.at(0), center.at(1) + world.at(1), center.at(2, default: 0))
}

/// Relative point on ellipse (0..1 maps to 0..360deg)
#let ellipse-relpoint-raw(center, rx, ry, t, angle: 0deg) = {
  let tt = t * 360deg
  ellipse-point-raw(center, rx, ry, angle: angle, t: tt)
}

/// Tangent line at ellipse parameter t
/// Returns (p1, p2, pt)
#let ellipse-tangent-raw(center, rx, ry, angle: 0deg, t: 0deg, length: auto) = {
  let pt = ellipse-point-raw(center, rx, ry, angle: angle, t: t)
  let tt = util.to-angle(t)
  let dir = (-rx * calc.sin(tt), ry * calc.cos(tt))
  let dir-rot = _rotate2(dir, angle)
  let udir = _unit2(dir-rot)
  let len = if length == auto { calc.max(rx, ry) } else { length }
  let p1 = (pt.at(0) - udir.at(0) * len, pt.at(1) - udir.at(1) * len, pt.at(2))
  let p2 = (pt.at(0) + udir.at(0) * len, pt.at(1) + udir.at(1) * len, pt.at(2))
  (p1, p2, pt)
}

/// Project a point onto an ellipse along the ray from the center
/// Returns the intersection point on the ellipse in the direction of `point`.
#let ellipse-project-point-raw(center, rx, ry, angle: 0deg, point) = {
  let dx = point.at(0) - center.at(0)
  let dy = point.at(1) - center.at(1)
  if calc.abs(dx) < util.eps and calc.abs(dy) < util.eps {
    return center
  }
  let theta = calc.atan2(dy, dx)
  ellipse-angpoint-raw(center, rx, ry, angle: angle, theta: theta, from-center: true)
}

/// Tangents from an external point to the ellipse
/// Returns ( (p1, p2, tpt), ... )
#let ellipse-tangents-from-point-raw(center, rx, ry, angle: 0deg, external, length: auto) = {
  let rel = (external.at(0) - center.at(0), external.at(1) - center.at(1))
  let local = _rotate2(rel, -util.to-angle(angle))
  let x0 = local.at(0)
  let y0 = local.at(1)
  let A = x0 / rx
  let B = y0 / ry
  let R = calc.sqrt(A * A + B * B)

  if R < 1 - util.eps-geometric {
    return ()
  }

  let phi = calc.atan2(B, A)
  let acos-arg = util.clamp(1 / calc.max(R, 1), -1, 1)
  let alpha = calc.acos(acos-arg)

  let ts = if R < 1 + util.eps-geometric {
    (phi,)
  } else {
    (phi + alpha, phi - alpha)
  }

  let results = ()
  for t in ts {
    let tpt = ellipse-point-raw(center, rx, ry, angle: angle, t: t)
    let dir = (tpt.at(0) - external.at(0), tpt.at(1) - external.at(1))
    let udir = _unit2(dir)
    let len = if length == auto { calc.max(rx, ry) * 2 } else { length }
    let p1 = (external.at(0) - udir.at(0) * len, external.at(1) - udir.at(1) * len, external.at(2, default: 0))
    let p2 = (tpt.at(0) + udir.at(0) * len, tpt.at(1) + udir.at(1) * len, tpt.at(2, default: 0))
    results.push((p1, p2, tpt))
  }

  results
}

/// Tangent from an external point, selecting the contact closest to a target point
/// Returns (p1, p2, tpt) or none
#let ellipse-tangent-from-point-towards-raw(center, rx, ry, angle: 0deg, external, target, length: auto) = {
  let tangents = ellipse-tangents-from-point-raw(center, rx, ry, angle: angle, external, length: length)
  if tangents.len() == 0 { return none }
  let best = none
  let bestd = 1e9
  for t in tangents {
    let tp = t.at(2)
    let d = util.dist(tp, target)
    if d < bestd {
      bestd = d
      best = t
    }
  }
  best
}

/// Intersections between an ellipse and a circle
/// Returns a list of points (up to 4)
#let ellipse-circle-intersections-raw(center, rx, ry, angle: 0deg, circle-center, r, steps: 360) = {
  let f = t => {
    let p = ellipse-point-raw(center, rx, ry, angle: angle, t: t)
    let dx = p.at(0) - circle-center.at(0)
    let dy = p.at(1) - circle-center.at(1)
    dx * dx + dy * dy - r * r
  }

  let pts = ()
  let prev-t = 0deg
  let prev-f = f(prev-t)
  for i in range(1, steps + 1) {
    let t = i * 360deg / steps
    let cur-f = f(t)
    if calc.abs(cur-f) < util.eps-geometric {
      pts.push(ellipse-point-raw(center, rx, ry, angle: angle, t: t))
    } else if prev-f * cur-f < 0 {
      // Bisection to refine root
      let a = prev-t
      let b = t
      let fa = prev-f
      let fb = cur-f
      for _i in range(0, 30) {
        let m = (a + b) / 2
        let fm = f(m)
        if fa * fm <= 0 {
          b = m
          fb = fm
        } else {
          a = m
          fa = fm
        }
      }
      pts.push(ellipse-point-raw(center, rx, ry, angle: angle, t: (a + b) / 2))
    }
    prev-t = t
    prev-f = cur-f
  }

  // Deduplicate close points
  let out = ()
  for p in pts {
    let unique = true
    for q in out {
      if util.dist(p, q) < util.eps-visual { unique = false }
    }
    if unique { out.push(p) }
  }
  out
}

/// Sample points on an ellipse
/// - center: (x, y, z)
/// - rx, ry: radii
/// - angle: rotation angle (deg)
/// - steps: number of segments
#let ellipse-points-raw(center, rx, ry, angle: 0deg, steps: 120) = {
  let pts = ()
  let rot = util.to-angle(angle)
  for i in range(0, steps + 1) {
    let t = i * 360deg / steps
    let x = rx * calc.cos(t)
    let y = ry * calc.sin(t)
    let p = (center.at(0) + x, center.at(1) + y, center.at(2, default: 0))
    if rot != 0deg {
      p = util.rotate-point(p, center, rot)
    }
    pts.push(p)
  }
  pts
}
