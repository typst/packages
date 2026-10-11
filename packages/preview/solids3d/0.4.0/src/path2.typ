// path2.typ — helpers for projected 2D Bézier paths (pairs).

#import "vec.typ": clamp, sgn, is-num

#let padd(a, b) = (a.at(0) + b.at(0), a.at(1) + b.at(1))
#let psub(a, b) = (a.at(0) - b.at(0), a.at(1) - b.at(1))
#let pmul(k, a) = (k * a.at(0), k * a.at(1))
#let pdot(a, b) = a.at(0) * b.at(0) + a.at(1) * b.at(1)
#let pcross(a, b) = a.at(0) * b.at(1) - a.at(1) * b.at(0)
#let pabs(a) = calc.sqrt(a.at(0) * a.at(0) + a.at(1) * a.at(1))
#let punit(a) = { let n = pabs(a); if n == 0 { (0.0, 0.0) } else { (a.at(0) / n, a.at(1) / n) } }
#let pinterp(a, b, t) = (a.at(0) + (b.at(0) - a.at(0)) * t, a.at(1) + (b.at(1) - a.at(1)) * t)
// angle of a pair in radians (Asymptote's angle())
#let pangle(a) = if a.at(0) == 0 and a.at(1) == 0 { 0.0 } else { calc.atan2(a.at(0), a.at(1)).rad() }
#let protate(a, ang) = {
  let c = calc.cos(ang)
  let s = calc.sin(ang)
  (c * a.at(0) - s * a.at(1), s * a.at(0) + c * a.at(1))
}

#let length2(p) = if p.cyclic { p.nodes.len() } else { calc.max(p.nodes.len() - 1, 0) }

#let segment2(p, i) = {
  let n = p.nodes.len()
  let i0 = if p.cyclic { calc.rem-euclid(i, n) } else { clamp(i, 0, n - 2) }
  let i1 = if p.cyclic { calc.rem-euclid(i + 1, n) } else { i0 + 1 }
  (p.nodes.at(i0), p.post.at(i0), p.pre.at(i1), p.nodes.at(i1))
}

#let bez2(a, b, c, d, t) = {
  let s = 1 - t
  let k0 = s * s * s
  let k1 = 3 * s * s * t
  let k2 = 3 * s * t * t
  let k3 = t * t * t
  (
    k0 * a.at(0) + k1 * b.at(0) + k2 * c.at(0) + k3 * d.at(0),
    k0 * a.at(1) + k1 * b.at(1) + k2 * c.at(1) + k3 * d.at(1),
  )
}

#let bez2-deriv(a, b, c, d, t) = {
  let s = 1 - t
  let k0 = 3 * s * s
  let k1 = 6 * s * t
  let k2 = 3 * t * t
  (
    k0 * (b.at(0) - a.at(0)) + k1 * (c.at(0) - b.at(0)) + k2 * (d.at(0) - c.at(0)),
    k0 * (b.at(1) - a.at(1)) + k1 * (c.at(1) - b.at(1)) + k2 * (d.at(1) - c.at(1)),
  )
}

#let split-time2(p, t) = {
  let L = length2(p)
  if L == 0 { return (0, 0.0) }
  if p.cyclic {
    let tt = calc.rem-euclid(t, L)
    let i = calc.floor(tt)
    (i, tt - i)
  } else if t <= 0 { (0, 0.0) } else if t >= L { (L - 1, 1.0) } else {
    let i = calc.floor(t)
    (i, t - i)
  }
}

#let point2(p, t) = {
  let n = p.nodes.len()
  if n == 0 { return (0.0, 0.0) }
  if n == 1 { return p.nodes.at(0) }
  let (i, s) = split-time2(p, t)
  let (a, b, c, d) = segment2(p, i)
  bez2(a, b, c, d, s)
}

#let dir2(p, t) = {
  let n = p.nodes.len()
  if n < 2 { return (0.0, 0.0) }
  let (i, s) = split-time2(p, t)
  let (a, b, c, d) = segment2(p, i)
  let v = bez2-deriv(a, b, c, d, s)
  if pabs(v) < 1e-12 {
    v = if s < 0.5 { psub(c, a) } else { psub(d, b) }
    if pabs(v) < 1e-12 { v = psub(d, a) }
  }
  punit(v)
}

// Apply a 2D rotation to every control point.
#let rotate-path2(p, ang) = {
  let c = calc.cos(ang)
  let s = calc.sin(ang)
  let out = (kind: "path", straight: p.straight, cyclic: p.cyclic)
  for key in ("nodes", "pre", "post") {
    let arr = ()
    for z in p.at(key) {
      let (x, y) = z
      arr.push((c * x - s * y, s * x + c * y))
    }
    out.insert(key, arr)
  }
  out
}

// Roots in (0,1) of the derivative of the cubic through y-values.
#let cubic-extrema-times(y0, y1, y2, y3) = {
  // derivative: 3[(y1-y0)(1-t)^2 + 2(y2-y1)(1-t)t + (y3-y2)t^2]
  let a = y1 - y0
  let b = y2 - y1
  let c = y3 - y2
  // quadratic in t: (a - 2b + c) t^2 + 2(b - a) t + a = 0
  let A = a - 2 * b + c
  let B = 2 * (b - a)
  let C = a
  let out = ()
  if calc.abs(A) < 1e-14 {
    if calc.abs(B) > 1e-14 {
      let t = -C / B
      if t > 0 and t < 1 { out.push(t) }
    }
  } else {
    let disc = B * B - 4 * A * C
    if disc >= 0 {
      let sq = calc.sqrt(disc)
      for t in ((-B - sq) / (2 * A), (-B + sq) / (2 * A)) {
        if t > 0 and t < 1 { out.push(t) }
      }
    }
  }
  out
}

// Time of the minimum (want-min) or maximum of coordinate `coord` (0 or 1).
// (Everything inlined: this is the inner loop of the tangent search.)
#let extreme-time2(p, coord, want-min) = {
  let n = p.nodes.len()
  if n == 0 { return 0.0 }
  let sign = if want-min { 1.0 } else { -1.0 }
  let best = sign * p.nodes.at(0).at(coord)
  let best-t = 0.0
  let L = if p.cyclic { n } else { n - 1 }
  for i in range(L) {
    let j = if i + 1 == n { 0 } else { i + 1 }
    let y0 = sign * p.nodes.at(i).at(coord)
    let y1 = sign * p.post.at(i).at(coord)
    let y2 = sign * p.pre.at(j).at(coord)
    let y3 = sign * p.nodes.at(j).at(coord)
    if y3 < best { best = y3; best-t = float(i + 1) }
    if not p.straight.at(i, default: false) {
      // roots of the derivative: A t^2 + B t + C = 0
      let a = y1 - y0
      let b = y2 - y1
      let c = y3 - y2
      let A = a - 2 * b + c
      let B = 2 * (b - a)
      let C = a
      let roots = ()
      if calc.abs(A) < 1e-14 {
        if calc.abs(B) > 1e-14 { roots.push(-C / B) }
      } else {
        let disc = B * B - 4 * A * C
        if disc >= 0 {
          let sq = calc.sqrt(disc)
          roots.push((-B - sq) / (2 * A))
          roots.push((-B + sq) / (2 * A))
        }
      }
      for t in roots {
        if t > 0 and t < 1 {
          let s = 1 - t
          let v = s * s * s * y0 + 3 * s * s * t * y1 + 3 * s * t * t * y2 + t * t * t * y3
          if v < best { best = v; best-t = i + t }
        }
      }
    }
  }
  best-t
}

#let mintimes2(p) = (extreme-time2(p, 0, true), extreme-time2(p, 1, true))
#let maxtimes2(p) = (extreme-time2(p, 0, false), extreme-time2(p, 1, false))

// Bounding box of the control polygon: ((minx, miny), (maxx, maxy)).
#let bbox2(p) = {
  if "bbox" in p { return p.bbox }
  let minx = float.inf
  let miny = float.inf
  let maxx = -float.inf
  let maxy = -float.inf
  for arr in (p.nodes, p.pre, p.post) {
    for z in arr {
      let (x, y) = z
      if x < minx { minx = x }
      if x > maxx { maxx = x }
      if y < miny { miny = y }
      if y > maxy { maxy = y }
    }
  }
  ((minx, miny), (maxx, maxy))
}

// Flatten into a polyline.
#let flatten2(p, n: 8) = {
  let L = length2(p)
  if L == 0 { return p.nodes }
  let pts = ()
  for i in range(L) {
    let (a, b, c, d) = segment2(p, i)
    if p.straight.at(i, default: false) { pts.push(a) } else {
      for k in range(n) { pts.push(bez2(a, b, c, d, k / n)) }
    }
  }
  if not p.cyclic { pts.push(p.nodes.last()) }
  pts
}

// Point-in-polygon (even-odd) on the flattened path.
#let inside2(p, z) = {
  let pts = flatten2(p)
  let n = pts.len()
  if n < 3 { return false }
  let inside = false
  let j = n - 1
  for i in range(n) {
    let (xi, yi) = pts.at(i)
    let (xj, yj) = pts.at(j)
    if (yi > z.at(1)) != (yj > z.at(1)) {
      let x = xi + (z.at(1) - yi) * (xj - xi) / (yj - yi)
      if z.at(0) < x { inside = not inside }
    }
    j = i
  }
  inside
}

#let segments-intersect(a, b, c, d) = {
  let d1 = pcross(psub(d, c), psub(a, c))
  let d2 = pcross(psub(d, c), psub(b, c))
  let d3 = pcross(psub(b, a), psub(c, a))
  let d4 = pcross(psub(b, a), psub(d, a))
  ((d1 > 0 and d2 < 0) or (d1 < 0 and d2 > 0)) and ((d3 > 0 and d4 < 0) or (d3 < 0 and d4 > 0))
}

// Do the two (flattened) paths intersect?
#let intersects2(p, q) = {
  let a = flatten2(p)
  let b = flatten2(q)
  let na = a.len()
  let nb = b.len()
  let la = if p.cyclic { na } else { na - 1 }
  let lb = if q.cyclic { nb } else { nb - 1 }
  for i in range(la) {
    let a0 = a.at(i)
    let a1 = a.at(calc.rem-euclid(i + 1, na))
    for j in range(lb) {
      let b0 = b.at(j)
      let b1 = b.at(calc.rem-euclid(j + 1, nb))
      if segments-intersect(a0, a1, b0, b1) { return true }
    }
  }
  false
}
