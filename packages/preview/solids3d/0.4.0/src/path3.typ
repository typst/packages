// path3.typ — cubic Bézier paths in 3D (Asymptote's path3), including a
// port of the 3D variant of John Hobby's spline algorithm used by Asymptote
// for the `..` connector (three.asy, Bowman & Hammerlindl, TUGboat 29:2).

#import "vec.typ": *

#let n-circle = 400 // Asymptote's nCircle
#let n-graph = 100 // Asymptote's ngraph
#let CCW = true
#let CW = false

// ---------------------------------------------------------------------------
// Bézier helpers
// ---------------------------------------------------------------------------
#let bez(a, b, c, d, t) = {
  let s = 1 - t
  let s2 = s * s
  let t2 = t * t
  let k0 = s2 * s
  let k1 = 3 * s2 * t
  let k2 = 3 * s * t2
  let k3 = t2 * t
  (
    k0 * a.at(0) + k1 * b.at(0) + k2 * c.at(0) + k3 * d.at(0),
    k0 * a.at(1) + k1 * b.at(1) + k2 * c.at(1) + k3 * d.at(1),
    k0 * a.at(2) + k1 * b.at(2) + k2 * c.at(2) + k3 * d.at(2),
  )
}

// Derivative (not normalised) of a cubic Bézier segment.
#let bez-deriv(a, b, c, d, t) = {
  let s = 1 - t
  let k0 = 3 * s * s
  let k1 = 6 * s * t
  let k2 = 3 * t * t
  (
    k0 * (b.at(0) - a.at(0)) + k1 * (c.at(0) - b.at(0)) + k2 * (d.at(0) - c.at(0)),
    k0 * (b.at(1) - a.at(1)) + k1 * (c.at(1) - b.at(1)) + k2 * (d.at(1) - c.at(1)),
    k0 * (b.at(2) - a.at(2)) + k1 * (c.at(2) - b.at(2)) + k2 * (d.at(2) - c.at(2)),
  )
}

// De Casteljau split at t: returns (left, right), each (a, b, c, d).
#let bez-split(a, b, c, d, t) = {
  let ab = interp(a, b, t)
  let bc = interp(b, c, t)
  let cd = interp(c, d, t)
  let abc = interp(ab, bc, t)
  let bcd = interp(bc, cd, t)
  let m = interp(abc, bcd, t)
  ((a, ab, abc, m), (m, bcd, cd, d))
}

// Gauss-Legendre nodes/weights on [0,1] (8 points).
#let gl-nodes = (
  0.019855071751231884, 0.10166676129318664, 0.2372337950418355, 0.4082826787521751,
  0.5917173212478249, 0.7627662049581645, 0.8983332387068134, 0.9801449282487681,
)
#let gl-weights = (
  0.05061426814518813, 0.11119051722668724, 0.15685332293894363, 0.18134189168918098,
  0.18134189168918098, 0.15685332293894363, 0.11119051722668724, 0.05061426814518813,
)

// Arc length of a Bézier segment over [0, t] (8-point Gauss-Legendre,
// inlined).
#let bez-arclength(a, b, c, d, t: 1.0) = {
  let (ax, ay, az) = a
  let (bx, by, bz) = b
  let (cx, cy, cz) = c
  let (dx, dy, dz) = d
  let (p0x, p0y, p0z) = (bx - ax, by - ay, bz - az)
  let (p1x, p1y, p1z) = (cx - bx, cy - by, cz - bz)
  let (p2x, p2y, p2z) = (dx - cx, dy - cy, dz - cz)
  let sum = 0.0
  for i in range(8) {
    let u = gl-nodes.at(i) * t
    let s = 1 - u
    let k0 = 3 * s * s
    let k1 = 6 * s * u
    let k2 = 3 * u * u
    let vx = k0 * p0x + k1 * p1x + k2 * p2x
    let vy = k0 * p0y + k1 * p1y + k2 * p2y
    let vz = k0 * p0z + k1 * p1z + k2 * p2z
    sum += gl-weights.at(i) * calc.sqrt(vx * vx + vy * vy + vz * vz)
  }
  sum * t
}

// ---------------------------------------------------------------------------
// path3 representation
//   (kind: "path3", nodes: (..), pre: (..), post: (..), straight: (..), cyclic: bool)
// Segment i goes from nodes[i] with control post[i] to nodes[i+1] with
// control pre[i+1] (indices modulo n for cyclic paths).
// ---------------------------------------------------------------------------
#let is-path3(p) = type(p) == dictionary and p.at("kind", default: none) == "path3"
#let is-path3-array(x) = type(x) == array and x.len() > 0 and x.all(is-path3)

#let mkpath3(nodes, pre, post, straight, cyclic) = (
  kind: "path3", nodes: nodes, pre: pre, post: post, straight: straight, cyclic: cyclic,
)

#let nullpath3 = mkpath3((), (), (), (), false)

#let size3(p) = p.nodes.len()
#let length3(p) = if p.cyclic { p.nodes.len() } else { calc.max(p.nodes.len() - 1, 0) }
#let cyclic(p) = p.cyclic

// Node index helper
#let node-index(p, i) = {
  let n = p.nodes.len()
  if p.cyclic { calc.rem-euclid(i, n) } else { clamp(i, 0, n - 1) }
}

// Control points (a, b, c, d) of segment i.
#let segment(p, i) = {
  let n = p.nodes.len()
  let i0 = if p.cyclic { calc.rem-euclid(i, n) } else { clamp(i, 0, n - 2) }
  let i1 = if p.cyclic { calc.rem-euclid(i + 1, n) } else { i0 + 1 }
  (p.nodes.at(i0), p.post.at(i0), p.pre.at(i1), p.nodes.at(i1))
}

#let straight(p, i) = p.straight.at(node-index(p, i), default: false)
#let piecewise-straight(p) = p.straight.all(s => s)

// Split a time into (segment index, local parameter).
#let split-time(p, t) = {
  let L = length3(p)
  if L == 0 { return (0, 0.0) }
  if p.cyclic {
    let tt = calc.rem-euclid(t, L)
    let i = calc.floor(tt)
    (i, tt - i)
  } else {
    if t <= 0 { (0, 0.0) } else if t >= L { (L - 1, 1.0) } else {
      let i = calc.floor(t)
      (i, t - i)
    }
  }
}

#let point(p, t) = {
  let n = p.nodes.len()
  if n == 0 { return O }
  if n == 1 { return p.nodes.at(0) }
  let (i, s) = split-time(p, t)
  if s == 0 { return p.nodes.at(node-index(p, i)) }
  if s == 1 { return p.nodes.at(node-index(p, i + 1)) }
  let (a, b, c, d) = segment(p, i)
  bez(a, b, c, d, s)
}

#let precontrol(p, t) = {
  let (i, s) = split-time(p, t)
  if s == 0 { return p.pre.at(node-index(p, i)) }
  let (a, b, c, d) = segment(p, i)
  bez-split(a, b, c, d, s).at(0).at(2)
}

#let postcontrol(p, t) = {
  let (i, s) = split-time(p, t)
  if s == 0 { return p.post.at(node-index(p, i)) }
  let (a, b, c, d) = segment(p, i)
  bez-split(a, b, c, d, s).at(1).at(1)
}

// Unit tangent of segment i at local parameter s (robust to degenerate
// control points).
#let segment-dir(p, i, s) = {
  let (a, b, c, d) = segment(p, i)
  let v = bez-deriv(a, b, c, d, s)
  if vabs2(v) < 1e-24 {
    v = if s < 0.5 { vsub(c, a) } else { vsub(d, b) }
    if vabs2(v) < 1e-24 { v = vsub(d, a) }
  }
  vunit(v)
}

// Unit tangent direction at time t. At a node, the (normalised) average of
// the incoming and outgoing directions is returned, as in Asymptote.
#let dir(p, t) = {
  let n = p.nodes.len()
  if n < 2 { return O }
  let L = length3(p)
  let k = int(calc.round(t))
  if calc.abs(t - k) < 1e-9 and ((k > 0 and k < L) or p.cyclic) {
    let inn = segment-dir(p, k - 1, 1.0)
    let out = segment-dir(p, k, 0.0)
    let v = vunit(vadd(inn, out))
    if vzero(v) { out } else { v }
  } else {
    let (i, s) = split-time(p, t)
    segment-dir(p, i, s)
  }
}

#let reverse(p) = {
  let n = p.nodes.len()
  if n == 0 { return p }
  if p.cyclic {
    // keep node 0 first; new segment i goes from node -i to node -i-1
    let nodes = range(n).map(i => p.nodes.at(calc.rem-euclid(-i, n)))
    let post = range(n).map(i => p.pre.at(calc.rem-euclid(-i, n)))
    let pre = range(n).map(i => p.post.at(calc.rem-euclid(-i, n)))
    let strs = range(n).map(i => p.straight.at(calc.rem-euclid(-i - 1, n), default: false))
    mkpath3(nodes, pre, post, strs, true)
  } else {
    let nodes = p.nodes.rev()
    let post = p.pre.rev()
    let pre = p.post.rev()
    let strs = p.straight.rev()
    mkpath3(nodes, pre, post, strs, false)
  }
}

// Open subpath from time a to time b (reversed if b < a).
#let subpath(p, a, b) = {
  let n = p.nodes.len()
  if n == 0 { return p }
  if a > b { return reverse(subpath(p, b, a)) }
  let L = length3(p)
  if L == 0 { return mkpath3((p.nodes.at(0),), (p.nodes.at(0),), (p.nodes.at(0),), (), false) }
  if not p.cyclic {
    a = clamp(a, 0, L)
    b = clamp(b, 0, L)
  }
  if a == b {
    let v = point(p, a)
    return mkpath3((v,), (v,), (v,), (), false)
  }
  let ia = calc.floor(a)
  let sa = a - ia
  let ib = calc.floor(b)
  let sb = b - ib
  if sb == 0 and ib > ia { ib -= 1; sb = 1.0 }
  let nodes = ()
  let pre = ()
  let post = ()
  let strs = ()
  let n = p.nodes.len()
  for i in range(ia, ib + 1) {
    let i0 = if p.cyclic { calc.rem-euclid(i, n) } else { clamp(i, 0, n - 2) }
    let i1 = if p.cyclic { calc.rem-euclid(i + 1, n) } else { i0 + 1 }
    let A = p.nodes.at(i0)
    let B = p.post.at(i0)
    let C = p.pre.at(i1)
    let D = p.nodes.at(i1)
    let st = p.straight.at(i0, default: false)
    let t0 = if i == ia { sa } else { 0.0 }
    let t1 = if i == ib { sb } else { 1.0 }
    // extract [t0, t1] of the segment (inline De Casteljau)
    for (tt, keep-right) in ((t0, true), (if t0 > 0 { (t1 - t0) / (1 - t0) } else { t1 }, false)) {
      if (keep-right and tt > 0) or (not keep-right and tt < 1) {
        let u = 1 - tt
        let ab = (u * A.at(0) + tt * B.at(0), u * A.at(1) + tt * B.at(1), u * A.at(2) + tt * B.at(2))
        let bc = (u * B.at(0) + tt * C.at(0), u * B.at(1) + tt * C.at(1), u * B.at(2) + tt * C.at(2))
        let cd = (u * C.at(0) + tt * D.at(0), u * C.at(1) + tt * D.at(1), u * C.at(2) + tt * D.at(2))
        let abc = (u * ab.at(0) + tt * bc.at(0), u * ab.at(1) + tt * bc.at(1), u * ab.at(2) + tt * bc.at(2))
        let bcd = (u * bc.at(0) + tt * cd.at(0), u * bc.at(1) + tt * cd.at(1), u * bc.at(2) + tt * cd.at(2))
        let m = (u * abc.at(0) + tt * bcd.at(0), u * abc.at(1) + tt * bcd.at(1), u * abc.at(2) + tt * bcd.at(2))
        if keep-right { A = m; B = bcd; C = cd } else { B = ab; C = abc; D = m }
      }
    }
    if i == ia {
      nodes.push(A)
      pre.push(A)
    }
    post.push(B)
    strs.push(st)
    pre.push(C)
    nodes.push(D)
  }
  post.push(nodes.last())
  mkpath3(nodes, pre, post, strs, false)
}

// Concatenate two open paths (Asymptote's `&`). The last node of p should
// coincide with the first node of q.
#let join(p, q) = {
  if p.nodes.len() == 0 { return q }
  if q.nodes.len() == 0 { return p }
  let nodes = p.nodes + q.nodes.slice(1)
  let pre = p.pre + q.pre.slice(1)
  let post = p.post.slice(0, p.post.len() - 1) + q.post
  let strs = p.straight + q.straight
  mkpath3(nodes, pre, post, strs, false)
}

// Concatenate several paths.
#let join-all(..ps) = ps.pos().fold(nullpath3, join)

// Close an open path (Asymptote's `&cycle`), adding a straight closing
// segment if the endpoints differ.
#let close3(p) = {
  if p.cyclic or p.nodes.len() < 2 { return p }
  let first = p.nodes.first()
  let last = p.nodes.last()
  if vequal(first, last, eps: 1e-12) {
    let nodes = p.nodes.slice(0, -1)
    let post = p.post.slice(0, -1)
    let pre = (p.pre.last(),) + p.pre.slice(1, -1)
    mkpath3(nodes, pre, post, p.straight, true)
  } else {
    let post = p.post.slice(0, -1) + (interp(last, first, 1 / 3),)
    let pre = (interp(last, first, 2 / 3),) + p.pre.slice(1)
    mkpath3(p.nodes, pre, post, p.straight + (true,), true)
  }
}

#let arclength(p) = {
  let L = length3(p)
  let s = 0.0
  for i in range(L) {
    let (a, b, c, d) = segment(p, i)
    s += if straight(p, i) { vabs(vsub(d, a)) } else { bez-arclength(a, b, c, d) }
  }
  s
}

// Time at which the arc length from the start equals s.
#let arctime(p, s) = {
  let L = length3(p)
  if L == 0 { return 0.0 }
  if s <= 0 { return 0.0 }
  let acc = 0.0
  for i in range(L) {
    let (a, b, c, d) = segment(p, i)
    let st = straight(p, i)
    let len = if st { vabs(vsub(d, a)) } else { bez-arclength(a, b, c, d) }
    if acc + len >= s {
      let target = s - acc
      if st { return i + (if len == 0 { 0.0 } else { target / len }) }
      // bisection on the local parameter (inlined Gauss-Legendre)
      let (ax, ay, az) = a
      let (p0x, p0y, p0z) = (b.at(0) - ax, b.at(1) - ay, b.at(2) - az)
      let (p1x, p1y, p1z) = (c.at(0) - b.at(0), c.at(1) - b.at(1), c.at(2) - b.at(2))
      let (p2x, p2y, p2z) = (d.at(0) - c.at(0), d.at(1) - c.at(1), d.at(2) - c.at(2))
      let lo = 0.0
      let hi = 1.0
      for k in range(30) {
        let mid = 0.5 * (lo + hi)
        let sum = 0.0
        for q in range(8) {
          let u = gl-nodes.at(q) * mid
          let s = 1 - u
          let k0 = 3 * s * s
          let k1 = 6 * s * u
          let k2 = 3 * u * u
          let vx = k0 * p0x + k1 * p1x + k2 * p2x
          let vy = k0 * p0y + k1 * p1y + k2 * p2y
          let vz = k0 * p0z + k1 * p1z + k2 * p2z
          sum += gl-weights.at(q) * calc.sqrt(vx * vx + vy * vy + vz * vz)
        }
        if sum * mid < target { lo = mid } else { hi = mid }
      }
      return i + 0.5 * (lo + hi)
    }
    acc += len
  }
  float(L)
}

// Time at relative arc length r in [0,1].
#let reltime(p, r) = arctime(p, r * arclength(p))
#let midpoint(p) = point(p, reltime(p, 0.5))

// Bounding box of the control polygon (a conservative bound of the path).
#let min3(p) = {
  let m = (float.inf, float.inf, float.inf)
  for v in p.nodes { m = vmin(m, v) }
  let n = p.nodes.len()
  let L = length3(p)
  for i in range(L) { m = vmin(m, p.post.at(i)); m = vmin(m, p.pre.at(calc.rem-euclid(i + 1, n))) }
  m
}
#let max3(p) = {
  let m = (-float.inf, -float.inf, -float.inf)
  for v in p.nodes { m = vmax(m, v) }
  let n = p.nodes.len()
  let L = length3(p)
  for i in range(L) { m = vmax(m, p.post.at(i)); m = vmax(m, p.pre.at(calc.rem-euclid(i + 1, n))) }
  m
}

// Apply a 4x4 transform to every control point (inlined for speed: Typst
// memoizes every function call, so hot loops avoid small helper calls).
#let transform-path3(T, p) = {
  let (r0, r1, r2, r3) = T
  let (a0, a1, a2, a3) = r0
  let (b0, b1, b2, b3) = r1
  let (c0, c1, c2, c3) = r2
  let (d0, d1, d2, d3) = r3
  let affine = d0 == 0 and d1 == 0 and d2 == 0 and d3 == 1
  let out = (nodes: (), pre: (), post: ())
  for key in ("nodes", "pre", "post") {
    let arr = ()
    for v in p.at(key) {
      let (x, y, z) = v
      let X = a0 * x + a1 * y + a2 * z + a3
      let Y = b0 * x + b1 * y + b2 * z + b3
      let Z = c0 * x + c1 * y + c2 * z + c3
      if affine { arr.push((X, Y, Z)) } else {
        let w = d0 * x + d1 * y + d2 * z + d3
        if w == 0 { w = 1e-300 }
        arr.push((X / w, Y / w, Z / w))
      }
    }
    out.insert(key, arr)
  }
  mkpath3(out.nodes, out.pre, out.post, p.straight, p.cyclic)
}

// Sample the path into a polyline (n points per segment).
#let flatten3(p, n: 8) = {
  let L = length3(p)
  if L == 0 { return p.nodes }
  let pts = ()
  for i in range(L) {
    let (a, b, c, d) = segment(p, i)
    if straight(p, i) {
      pts.push(a)
    } else {
      for k in range(n) { pts.push(bez(a, b, c, d, k / n)) }
    }
  }
  if not p.cyclic { pts.push(p.nodes.last()) }
  pts
}

// ---------------------------------------------------------------------------
// Hobby's algorithm (3D version, ported from Asymptote's three.asy)
// ---------------------------------------------------------------------------
#let acos1(x) = calc.acos(clamp(x, -1, 1)).rad()

#let hobby-cross(d0, d1, reference) = {
  let n = vcross(d0, d1)
  if vzero(n) { reference } else { n }
}

#let hobby-dir(theta, d0, d1, reference) = {
  let normal = hobby-cross(d0, d1, reference)
  if vzero(normal) { return d1 }
  let axis = if vdot(normal, reference) >= 0 { normal } else { vneg(normal) }
  tvector(rotate3(theta * 1rad, axis), d1)
}

#let hobby-angle(d0, d1, reference) = {
  let theta = acos1(vdot(vunit(d0), vunit(d1)))
  if vdot(hobby-cross(d0, d1, reference), reference) >= 0 { theta } else { -theta }
}

// Solve a[i] x[i-1] + b[i] x[i] + c[i] x[i+1] = f[i].
#let tridiagonal(a, b, c, f) = {
  let n = b.len()
  if n == 0 { return () }
  if n == 1 { return (f.at(0) / b.at(0),) }
  let cp = ()
  let dp = ()
  let denom = b.at(0)
  cp.push(c.at(0) / denom)
  dp.push(f.at(0) / denom)
  for i in range(1, n) {
    denom = b.at(i) - a.at(i) * cp.at(i - 1)
    if denom == 0 { denom = 1e-300 }
    cp.push(if i < n - 1 { c.at(i) / denom } else { 0.0 })
    dp.push((f.at(i) - a.at(i) * dp.at(i - 1)) / denom)
  }
  let x = range(n).map(_ => 0.0)
  x.at(n - 1) = dp.at(n - 1)
  let i = n - 2
  while i >= 0 {
    x.at(i) = dp.at(i) - cp.at(i) * x.at(i + 1)
    i -= 1
  }
  x
}

// Cyclic variant (x[-1] = x[n-1], x[n] = x[0]) via Sherman-Morrison.
#let tridiagonal-cyclic(a, b, c, f) = {
  let n = b.len()
  if n == 1 { return (f.at(0) / (a.at(0) + b.at(0) + c.at(0)),) }
  if n == 2 {
    // rows: b0 x0 + (a0 + c0) x1 = f0 ; (a1 + c1) x0 + b1 x1 = f1
    let p = b.at(0)
    let q = a.at(0) + c.at(0)
    let r = a.at(1) + c.at(1)
    let s = b.at(1)
    let det = p * s - q * r
    if det == 0 { return (0.0, 0.0) }
    return ((f.at(0) * s - q * f.at(1)) / det, (p * f.at(1) - r * f.at(0)) / det)
  }
  let alpha = a.at(0)
  let beta = c.at(n - 1)
  let gamma = -b.at(0)
  let bb = b
  bb.at(0) = b.at(0) - gamma
  bb.at(n - 1) = b.at(n - 1) - alpha * beta / gamma
  let x = tridiagonal(a, bb, c, f)
  let u = range(n).map(_ => 0.0)
  u.at(0) = gamma
  u.at(n - 1) = alpha
  let z = tridiagonal(a, bb, c, u)
  let fact = (x.at(0) + beta * x.at(n - 1) / gamma) / (1 + z.at(0) + beta * z.at(n - 1) / gamma)
  range(n).map(i => x.at(i) - fact * z.at(i))
}

// Hobby's velocity function; returns the relative control distance.
#let relative-distance(theta, phi, t) = {
  let st = calc.sin(theta)
  let ct = calc.cos(theta)
  let sf = calc.sin(phi)
  let cf = calc.cos(phi)
  let sqrt2 = 1.4142135623730951
  let num = 2 + sqrt2 * (st - sf / 16) * (sf - st / 16) * (ct - cf)
  let den = 1 + 0.6180339887498949 * ct + 0.38196601125010515 * cf
  let r = num / den
  if r > 4 { r = 4.0 }
  r / (3 * t)
}

// Control points of a segment given end directions.
#let hobby-controls(v0, v1, d0, d1, tout, tin) = {
  let v = vsub(v1, v0)
  let L = vabs(v)
  let u = vunit(v)
  d0 = vunit(d0)
  d1 = vunit(d1)
  let theta = acos1(vdot(d0, u))
  let phi = acos1(vdot(d1, u))
  if vdot(vcross(d0, v), vcross(v, d1)) < 0 { phi = -phi }
  let c0 = vadd(v0, vmul(L * relative-distance(theta, phi, tout), d0))
  let c1 = vsub(v1, vmul(L * relative-distance(phi, theta, tin), d1))
  (c0, c1)
}

#let hobby-reference(v, n, d0, d1, cyclic) = {
  let m = v.len()
  let at = i => v.at(if cyclic { calc.rem-euclid(i, m) } else { i })
  let V = ()
  for i in range(n - 1) { V.push(vcross(vsub(at(i + 1), at(i)), vsub(at(i + 2), at(i + 1)))) }
  if n > 0 {
    V.push(vcross(d0, vsub(at(1), at(0))))
    V.push(vcross(vsub(at(n), at(n - 1)), d1))
  }
  if V.len() == 0 { return O }
  let mx = V.at(0)
  let M = vabs(mx)
  for vi in V { let a = vabs(vi); if a > M { M = a; mx = vi } }
  let reference = O
  for vi in V {
    let u = vunit(vi)
    reference = vadd(reference, if vdot(u, mx) < 0 { vneg(u) } else { u })
  }
  reference
}

// Solve for the node angles theta (port of three.asy's theta()).
#let hobby-theta(v, alpha, beta, dir0, dirn, g0, gn, reference, cyclic) = {
  let n = alpha.len()
  let m = v.len()
  let at = i => v.at(if cyclic { calc.rem-euclid(i, m) } else { i })
  let l = range(n).map(i => 1 / vabs(vsub(at(i + 1), at(i))))
  let lat = i => l.at(if cyclic { calc.rem-euclid(i, n) } else { i })
  let inn = if cyclic { n } else { n - 1 }
  let psi = range(inn).map(i => hobby-angle(vsub(at(i + 1), at(i)), vsub(at(i + 2), at(i + 1)), reference))
  if not cyclic { psi.push(0.0) }
  let psiat = i => psi.at(if cyclic { calc.rem-euclid(i, n) } else { i })
  let rows = if cyclic { n } else { n + 1 }
  let a = range(rows).map(_ => 0.0)
  let b = range(rows).map(_ => 0.0)
  let c = range(rows).map(_ => 0.0)
  let f = range(rows).map(_ => 0.0)
  let i0 = if cyclic { 0 } else { 1 }
  if not cyclic {
    if vzero(dir0) {
      let a0 = alpha.at(0)
      let b0 = beta.at(0)
      let chi = g0 * calc.pow(b0 / a0, 2)
      a.at(0) = 0.0
      b.at(0) = 3 * a0 - a0 / b0 + chi
      let C = chi * (3 * a0 - 1) + a0 / b0
      c.at(0) = C
      f.at(0) = -C * psi.at(0)
    } else {
      a.at(0) = 0.0
      c.at(0) = 0.0
      b.at(0) = 1.0
      f.at(0) = hobby-angle(vsub(at(1), at(0)), dir0, reference)
    }
    if vzero(dirn) {
      let an = alpha.at(n - 1)
      let bn = beta.at(n - 1)
      let chi = gn * calc.pow(an / bn, 2)
      a.at(n) = chi * (3 * bn - 1) + bn / an
      b.at(n) = 3 * bn - bn / an + chi
      c.at(n) = 0.0
      f.at(n) = 0.0
    } else {
      a.at(n) = 0.0
      c.at(n) = 0.0
      b.at(n) = 1.0
      f.at(n) = hobby-angle(vsub(at(n), at(n - 1)), dirn, reference)
    }
  }
  for i in range(i0, n) {
    let im = if cyclic { calc.rem-euclid(i - 1, n) } else { i - 1 }
    let inn = calc.pow(beta.at(im), 2) * lat(i - 1)
    let A = inn / alpha.at(im)
    a.at(i) = A
    let B = 3 * inn - A
    let out = calc.pow(alpha.at(i), 2) * lat(i)
    let C = out / beta.at(i)
    b.at(i) = B + 3 * out - C
    c.at(i) = C
    f.at(i) = -B * psiat(i - 1) - C * psiat(i)
  }
  if cyclic { tridiagonal-cyclic(a, b, c, f) } else { tridiagonal(a, b, c, f) }
}

// Solve an open run of `..` segments through nodes v (k+1 points) with
// optional end directions d0/d1 (O when free). Returns (posts, pres):
// posts[i] and pres[i] are the two control points of segment i.
#let hobby-open(v, d0, d1, alpha, beta) = {
  let k = v.len() - 1
  if k < 1 { return ((), ()) }
  let reference = hobby-reference(v, k, d0, d1, false)
  let theta = hobby-theta(v, alpha, beta, d0, d1, 1.0, 1.0, reference, false)
  let dirs = range(k + 1).map(_ => O)
  for i in range(1, k) {
    dirs.at(i) = hobby-dir(theta.at(i), vsub(v.at(i), v.at(i - 1)), vsub(v.at(i + 1), v.at(i)), reference)
  }
  dirs.at(0) = if vzero(d0) { hobby-dir(theta.at(0), O, vsub(v.at(1), v.at(0)), reference) } else { vunit(d0) }
  dirs.at(k) = if vzero(d1) { hobby-dir(theta.at(k), O, vsub(v.at(k), v.at(k - 1)), reference) } else { vunit(d1) }
  let posts = ()
  let pres = ()
  for i in range(k) {
    let (c0, c1) = hobby-controls(v.at(i), v.at(i + 1), dirs.at(i), dirs.at(i + 1), alpha.at(i), beta.at(i))
    posts.push(c0)
    pres.push(c1)
  }
  (posts, pres)
}

// Solve a fully cyclic `..` path through nodes v (n points).
#let hobby-cyclic(v, alpha, beta) = {
  let n = v.len()
  if n < 3 {
    // degenerate: straight back and forth
    let posts = range(n).map(i => interp(v.at(i), v.at(calc.rem-euclid(i + 1, n)), 1 / 3))
    let pres = range(n).map(i => interp(v.at(i), v.at(calc.rem-euclid(i + 1, n)), 2 / 3))
    return (posts, pres)
  }
  let reference = hobby-reference(v, n, O, O, true)
  let theta = hobby-theta(v, alpha, beta, O, O, 1.0, 1.0, reference, true)
  let at = i => v.at(calc.rem-euclid(i, n))
  let dirs = range(n).map(i => hobby-dir(theta.at(i), vsub(at(i), at(i - 1)), vsub(at(i + 1), at(i)), reference))
  let posts = ()
  let pres = ()
  for i in range(n) {
    let j = calc.rem-euclid(i + 1, n)
    let (c0, c1) = hobby-controls(v.at(i), v.at(j), dirs.at(i), dirs.at(j), alpha.at(i), beta.at(i))
    posts.push(c0)
    pres.push(c1)
  }
  (posts, pres)
}

// ---------------------------------------------------------------------------
// Guide builder: guide3(A, "--", B, "..", C, "cycle")
// Items: triples (nodes), "--" / ".." (joins), "cycle", and dictionaries:
//   (dir: v)      direction at the preceding node (both incoming and outgoing)
//   (out: v)      outgoing direction at the preceding node
//   (in: v)       incoming direction at the following node
//   (tension: t)  tension of the following segment
//   (controls: (c0, c1)) explicit control points of the following segment
// A default join may be given with join: "--" or "..".
// ---------------------------------------------------------------------------
#let guide3(..items, join: "--") = {
  let nodes = ()
  let joins = () // per segment
  let outs = () // per node
  let ins = () // per node
  let tensions = () // per segment
  let controls = () // per segment
  let cyclic = false
  let pending-join = none
  let pending-in = none
  let pending-tension = none
  let pending-controls = none
  for it in items.pos() {
    if it == "cycle" {
      cyclic = true
      joins.push(if pending-join == none { join } else { pending-join })
      tensions.push(pending-tension)
      controls.push(pending-controls)
      if pending-in != none { ins.at(0) = pending-in }
      pending-join = none
      pending-in = none
      pending-tension = none
      pending-controls = none
      break
    } else if it == "--" or it == ".." {
      pending-join = it
    } else if type(it) == dictionary {
      if "dir" in it { outs.last() = it.dir; ins.last() = it.dir }
      if "out" in it { outs.last() = it.out }
      if "in" in it { pending-in = it.in }
      if "tension" in it { pending-tension = it.tension }
      if "controls" in it { pending-controls = it.controls }
    } else if is-triple(it) {
      if nodes.len() > 0 {
        joins.push(if pending-join == none { join } else { pending-join })
        tensions.push(pending-tension)
        controls.push(pending-controls)
      }
      nodes.push(it.map(float))
      outs.push(none)
      ins.push(pending-in)
      pending-join = none
      pending-in = none
      pending-tension = none
      pending-controls = none
    } else if is-path3(it) {
      // splice an existing path (its first node joins the previous one)
      for (k, v) in it.nodes.enumerate() {
        if nodes.len() > 0 {
          joins.push(if k == 0 { if pending-join == none { join } else { pending-join } } else { "controls" })
          tensions.push(none)
          controls.push(if k == 0 { pending-controls } else { (it.post.at(k - 1), it.pre.at(k)) })
        }
        nodes.push(v)
        outs.push(none)
        ins.push(none)
      }
      pending-join = none
      pending-controls = none
    }
  }
  let n = nodes.len()
  if n == 0 { return nullpath3 }
  if cyclic and n == 1 { cyclic = false }
  let L = if cyclic { n } else { n - 1 }
  let post = nodes
  let pre = nodes
  let strs = range(L).map(_ => false)
  // straight and explicit segments
  for i in range(L) {
    let j = calc.rem-euclid(i + 1, n)
    if controls.at(i) != none {
      post.at(i) = controls.at(i).at(0)
      pre.at(j) = controls.at(i).at(1)
    } else if joins.at(i) == "--" {
      post.at(i) = interp(nodes.at(i), nodes.at(j), 1 / 3)
      pre.at(j) = interp(nodes.at(i), nodes.at(j), 2 / 3)
      strs.at(i) = true
    }
  }
  let is-curved = i => joins.at(i) == ".." and controls.at(i) == none
  let curved = range(L).filter(is-curved)
  if curved.len() > 0 {
    let any-dir = outs.any(d => d != none) or ins.any(d => d != none)
    if cyclic and curved.len() == L and not any-dir {
      let alpha = range(L).map(i => if tensions.at(i) == none { 1.0 } else { float(tensions.at(i)) })
      let (posts, pres) = hobby-cyclic(nodes, alpha, alpha)
      for i in range(L) { post.at(i) = posts.at(i); pre.at(calc.rem-euclid(i + 1, n)) = pres.at(i) }
    } else {
      // Find runs of consecutive curved segments. For cyclic paths start
      // after a non-curved segment (or a node with a direction).
      let start = 0
      if cyclic {
        let found = false
        for i in range(L) { if not is-curved(i) { start = calc.rem-euclid(i + 1, L); found = true; break } }
        if not found {
          for i in range(n) { if outs.at(i) != none or ins.at(i) != none { start = i; break } }
        }
      }
      let i = 0
      while i < L {
        let s = calc.rem-euclid(start + i, L)
        if is-curved(s) {
          // run from segment s
          let k = 0
          while i + k < L and is-curved(calc.rem-euclid(start + i + k, L)) { k += 1 }
          let segs = range(k).map(q => calc.rem-euclid(start + i + q, L))
          let vs = segs.map(q => nodes.at(q)) + (nodes.at(calc.rem-euclid(segs.last() + 1, n)),)
          let first-node = segs.first()
          let last-node = calc.rem-euclid(segs.last() + 1, n)
          let d0 = outs.at(first-node)
          let d1 = ins.at(last-node)
          // In a cyclic path, a node whose other side is curved-and-solved
          // (run wraps) keeps a free end.
          d0 = if d0 == none { O } else { d0 }
          d1 = if d1 == none { O } else { d1 }
          let alpha = segs.map(q => if tensions.at(q) == none { 1.0 } else { float(tensions.at(q)) })
          let (posts, pres) = hobby-open(vs, d0, d1, alpha, alpha)
          for (q, sidx) in segs.enumerate() {
            post.at(sidx) = posts.at(q)
            pre.at(calc.rem-euclid(sidx + 1, n)) = pres.at(q)
          }
          // interior nodes of the run with explicit directions: handled by
          // splitting (a direction at an interior node ends the run)
          i += k
        } else {
          i += 1
        }
      }
    }
  }
  mkpath3(nodes, pre, post, strs, cyclic)
}

// Convenience constructors.
#let line3(..pts, cyclic: false) = {
  let a = pts.pos()
  if a.len() == 1 and type(a.at(0)) == array and not is-triple(a.at(0)) { a = a.at(0) }
  guide3(..a, ..(if cyclic { ("cycle",) } else { () }), join: "--")
}
#let spline3(..pts, cyclic: false) = {
  let a = pts.pos()
  if a.len() == 1 and type(a.at(0)) == array and not is-triple(a.at(0)) { a = a.at(0) }
  guide3(..a, ..(if cyclic { ("cycle",) } else { () }), join: "..")
}

// The nodes of a path (or of an array of paths).
#let nodes3(p) = {
  if is-path3(p) { p.nodes } else if is-triple(p) { (p,) } else if type(p) == array {
    let out = ()
    for q in p { out += nodes3(q) }
    out
  } else { () }
}

// ---------------------------------------------------------------------------
// Arcs and circles (exact cubic approximation, k = 4/3 tan(delta/4))
// ---------------------------------------------------------------------------
// Arc of radius r in the xy-plane around the origin from phi1 to phi2
// (radians) with n segments.
#let planar-arc(r, phi1, phi2, n) = {
  n = calc.max(n, 1)
  let delta = (phi2 - phi1) / n
  let k = 4 / 3 * calc.tan(delta / 4 * 1rad)
  let nodes = ()
  let pre = ()
  let post = ()
  for i in range(n + 1) {
    let phi = phi1 + i * delta
    let c = calc.cos(phi * 1rad)
    let s = calc.sin(phi * 1rad)
    let px = r * c
    let py = r * s
    let tx = -r * s * k
    let ty = r * c * k
    nodes.push((px, py, 0.0))
    post.push((px + tx, py + ty, 0.0))
    pre.push((px - tx, py - ty, 0.0))
  }
  pre.at(0) = nodes.at(0)
  post.at(n) = nodes.at(n)
  mkpath3(nodes, pre, post, range(n).map(_ => false), false)
}

#let make-cyclic-if-full(p, phi1, phi2) = {
  if calc.abs(calc.abs(phi2 - phi1) - 2 * calc.pi) < 1e-9 {
    let n = p.nodes.len() - 1
    mkpath3(p.nodes.slice(0, n), (p.pre.at(n),) + p.pre.slice(1, n), p.post.slice(0, n), p.straight, true)
  } else { p }
}

// Arc centred at c from v1 to v2 (|v1-c| = |v2-c|) about `normal`, with n
// segments (Asymptote's Arc from graph3.asy). `direction` is CCW or CW.
#let Arc3(c, v1, v2, normal: O, direction: CCW, n: n-circle) = {
  let w1 = vsub(v1, c)
  let r = vabs(w1)
  w1 = vunit(w1)
  let w2 = vunit(vsub(v2, c))
  if vzero(normal) {
    normal = vcross(w1, w2)
    if vzero(normal) { panic("explicit normal required for these endpoints") }
  }
  let T = align3(vunit(normal))
  let Tinv = transpose4(T)
  let u1 = tvector(Tinv, w1)
  let u2 = tvector(Tinv, w2)
  let phi1 = calc.atan2(u1.at(0), u1.at(1)).rad()
  let phi2 = calc.atan2(u2.at(0), u2.at(1)).rad()
  if direction {
    if phi1 >= phi2 { phi1 -= 2 * calc.pi }
  } else if phi2 >= phi1 { phi2 -= 2 * calc.pi }
  let p = planar-arc(r, phi1, phi2, n)
  transform-path3(tmul(shift(c), T), p)
}

// Arc centred at c with radius r from dir(theta1,phi1) to dir(theta2,phi2)
// (degrees).
#let Arc3-angles(c, r, theta1, phi1, theta2, phi2, normal: O, direction: auto, n: n-circle) = {
  let d = if direction == auto { theta2 > theta1 or (theta2 == theta1 and phi2 >= phi1) } else { direction }
  Arc3(c, vadd(c, vmul(r, vdir(theta1, phi1))), vadd(c, vmul(r, vdir(theta2, phi2))), normal: normal, direction: d, n: n)
}

// Full circle with n segments (Asymptote's Circle).
#let Circle3(c, r, normal: Z, n: n-circle) = {
  let p = make-cyclic-if-full(planar-arc(r, 0.0, 2 * calc.pi, n), 0.0, 2 * calc.pi)
  transform-path3(tmul(shift(c), align3(vunit(normal))), p)
}

// 4-segment circle and arcs (Asymptote's circle/arc from three.asy).
#let unitcircle3 = make-cyclic-if-full(planar-arc(1.0, 0.0, 2 * calc.pi, 4), 0.0, 2 * calc.pi)
#let circle3(c, r, normal: Z) = {
  let p = if vequal(normal, Z) { unitcircle3 } else { transform-path3(align3(vunit(normal)), unitcircle3) }
  transform-path3(tmul(shift(c), scale3(r)), p)
}
#let arc3(c, v1, v2, normal: O, direction: CCW) = {
  // segments of at most 90 degrees
  let w1 = vsub(v1, c)
  let w2 = vsub(v2, c)
  let nrm = if vzero(normal) { vcross(w1, w2) } else { normal }
  if vzero(nrm) { panic("explicit normal required for these endpoints") }
  let T = align3(vunit(nrm))
  let Tinv = transpose4(T)
  let u1 = tvector(Tinv, vunit(w1))
  let u2 = tvector(Tinv, vunit(w2))
  let phi1 = calc.atan2(u1.at(0), u1.at(1)).rad()
  let phi2 = calc.atan2(u2.at(0), u2.at(1)).rad()
  if direction {
    if phi1 >= phi2 { phi1 -= 2 * calc.pi }
  } else if phi2 >= phi1 { phi2 -= 2 * calc.pi }
  let n = calc.max(1, calc.ceil(calc.abs(phi2 - phi1) / (calc.pi / 2) - 1e-9))
  transform-path3(tmul(shift(c), T), planar-arc(vabs(w1), phi1, phi2, n))
}
#let arc3-angles(c, r, theta1, phi1, theta2, phi2, normal: O, direction: auto) = {
  let d = if direction == auto { theta2 > theta1 or (theta2 == theta1 and phi2 >= phi1) } else { direction }
  arc3(c, vadd(c, vmul(r, vdir(theta1, phi1))), vadd(c, vmul(r, vdir(theta2, phi2))), normal: normal, direction: d)
}

// ---------------------------------------------------------------------------
// Polygons, boxes, planes, graphs
// ---------------------------------------------------------------------------
#let unitsquare3 = line3(O, X, vadd(X, Y), Y, cyclic: true)

// Plane through point o spanned by u and v (a parallelogram).
#let plane(u, v, ..args, o: O) = {
  let a = args.pos()
  if a.len() > 0 { o = a.at(0) }
  line3(o, vadd(o, u), vadd(vadd(o, u), v), vadd(o, v), cyclic: true)
}

// Edges of the box with opposite corners v1, v2 (Asymptote's box()).
#let box3(v1, v2) = {
  let (x1, y1, z1) = v1
  let (x2, y2, z2) = v2
  (
    line3((x1, y1, z1), (x1, y1, z2), (x1, y2, z2), (x1, y2, z1), (x1, y1, z1), (x2, y1, z1), (x2, y1, z2), (x2, y2, z2), (x2, y2, z1), (x2, y1, z1)),
    line3((x2, y2, z1), (x1, y2, z1)),
    line3((x1, y2, z2), (x2, y2, z2)),
    line3((x2, y1, z2), (x1, y1, z2)),
  )
}
#let unitbox = box3(O, (1, 1, 1))

// Graph of a function f: real -> triple over [a, b] with n intervals.
#let graph3(f, a, b, n: n-graph, join: "--") = {
  let pts = range(n + 1).map(i => f(interp(a, b, i / n)))
  guide3(..pts, join: join)
}

// Refine a non-cyclic path so that it approaches its endpoint in
// geometrically spaced steps (three_arrows.asy's approach()).
#let approach(p, n, radix: 3) = {
  let L = length3(p)
  let G = nullpath3
  let tlast = 0.0
  let r = 1 / radix
  for i in range(1, n) {
    let t = L * (1 - calc.pow(r, i))
    G = join(G, subpath(p, tlast, t))
    tlast = t
  }
  join(G, subpath(p, tlast, L))
}
