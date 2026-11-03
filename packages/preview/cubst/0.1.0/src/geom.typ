// Vector geometry shared by the puzzle models, the move engine and the
// renderers. Points are plain arrays: (x, y, z) in 3D, (x, y) in 2D.
//
// World frame: x to the right (L→R), y up (D→U), z towards the viewer (B→F).

// --- 3D ----------------------------------------------------------------------

#let add(a, b) = a.zip(b).map(((x, y)) => x + y)
#let sub(a, b) = a.zip(b).map(((x, y)) => x - y)
#let scale(a, k) = a.map(x => x * k)
#let dot(a, b) = a.zip(b).map(((x, y)) => x * y).sum()
#let cross(a, b) = (
  a.at(1) * b.at(2) - a.at(2) * b.at(1),
  a.at(2) * b.at(0) - a.at(0) * b.at(2),
  a.at(0) * b.at(1) - a.at(1) * b.at(0),
)
#let norm(a) = calc.sqrt(dot(a, a))
#let unit(a) = scale(a, 1 / norm(a))
#let centroid(pts) = scale(pts.slice(1).fold(pts.at(0), add), 1 / pts.len())

/// Rotate `p` about the unit `axis` by `angle` (right-hand rule: a positive
/// angle is counter-clockwise when looking from the tip of the axis).
#let rotate(p, axis, angle) = {
  let c = calc.cos(angle)
  let s = calc.sin(angle)
  add(add(scale(p, c), scale(cross(axis, p), s)), scale(axis, dot(axis, p) * (1 - c)))
}

/// A string key for a point, robust to floating-point noise; used to find
/// which sticker a rotated sticker lands on.
#let key(p) = p.map(x => str(calc.round(x, digits: 3) + 0.0)).join(",")

/// Remove the component of `v` along the unit normal `n`.
#let project-onto-plane(v, n) = sub(v, scale(n, dot(v, n)))

/// A 2D frame on a face, used to draw it head-on: `u` points right and `v`
/// points *down* the picture, so that `up-hint` ends up at the top.
#let frame(center, normal, up-hint) = {
  let up = unit(project-onto-plane(up-hint, normal))
  (center: center, normal: normal, u: cross(up, normal), v: scale(up, -1))
}
#let to-local(fr, p) = {
  let d = sub(p, fr.center)
  (dot(d, fr.u), dot(d, fr.v))
}
#let from-local(fr, q) = add(fr.center, add(scale(fr.u, q.at(0)), scale(fr.v, q.at(1))))

// --- 2D ----------------------------------------------------------------------

#let rot2(q, a) = (
  q.at(0) * calc.cos(a) - q.at(1) * calc.sin(a),
  q.at(0) * calc.sin(a) + q.at(1) * calc.cos(a),
)
#let add2(a, b) = (a.at(0) + b.at(0), a.at(1) + b.at(1))
#let sub2(a, b) = (a.at(0) - b.at(0), a.at(1) - b.at(1))
#let scale2(a, k) = (a.at(0) * k, a.at(1) * k)
#let dot2(a, b) = a.at(0) * b.at(0) + a.at(1) * b.at(1)
#let norm2(a) = calc.sqrt(dot2(a, a))
#let unit2(a) = scale2(a, 1 / norm2(a))
#let centroid2(pts) = scale2(pts.slice(1).fold(pts.at(0), add2), 1 / pts.len())
/// Angle of `q` measured clockwise from the top of the picture (y down), in
/// [-1deg, 359deg) so that a point straight up never lands on the wrap-around.
#let clock-angle(q) = {
  let a = calc.atan2(-q.at(1), q.at(0))
  if a < -1deg { a + 360deg } else { a }
}

/// Keep the part of a convex polygon where `a·x + b·y <= c` (Sutherland–Hodgman).
#let clip(poly, a, b, c) = {
  let out = ()
  let n = poly.len()
  for i in range(n) {
    let p = poly.at(i)
    let q = poly.at(calc.rem(i + 1, n))
    let fp = a * p.at(0) + b * p.at(1) - c
    let fq = a * q.at(0) + b * q.at(1) - c
    if fp <= 1e-9 { out.push(p) }
    if (fp < -1e-9 and fq > 1e-9) or (fp > 1e-9 and fq < -1e-9) {
      let t = fp / (fp - fq)
      out.push((p.at(0) + t * (q.at(0) - p.at(0)), p.at(1) + t * (q.at(1) - p.at(1))))
    }
  }
  out
}

/// Shrink a convex polygon about its centroid so that every edge moves
/// inwards by `gap / 2` (used to show the body colour between stickers).
#let inset(poly, gap) = {
  if gap <= 0 { return poly }
  let g = centroid2(poly)
  let n = poly.len()
  // smallest distance from the centroid to an edge
  let r = range(n).map(i => {
    let p = poly.at(i)
    let q = poly.at(calc.rem(i + 1, n))
    let e = sub2(q, p)
    calc.abs(e.at(0) * (g.at(1) - p.at(1)) - e.at(1) * (g.at(0) - p.at(0))) / norm2(e)
  }).fold(1e9, calc.min)
  let f = calc.max(0, 1 - gap / 2 / r)
  poly.map(p => add2(g, scale2(sub2(p, g), f)))
}

#let bbox(points) = (
  min: (points.map(p => p.at(0)).fold(1e9, calc.min), points.map(p => p.at(1)).fold(1e9, calc.min)),
  max: (points.map(p => p.at(0)).fold(-1e9, calc.max), points.map(p => p.at(1)).fold(-1e9, calc.max)),
)

/// True for an axis-aligned rectangle (lets the renderer use `rect`, which
/// supports `radius`, instead of `polygon`).
#let is-axis-rect(poly) = {
  if poly.len() != 4 { return false }
  let xs = poly.map(p => calc.round(p.at(0), digits: 6)).dedup()
  let ys = poly.map(p => calc.round(p.at(1), digits: 6)).dedup()
  xs.len() == 2 and ys.len() == 2
}
