// vec.typ — triples (3D vectors) and 4x4 affine transforms.
// Port of the relevant parts of Asymptote's three.asy / plain_prethree.asy.

#let O = (0.0, 0.0, 0.0)
#let X = (1.0, 0.0, 0.0)
#let Y = (0.0, 1.0, 0.0)
#let Z = (0.0, 0.0, 1.0)

#let real-epsilon = 2.220446049250313e-16
#let sqrt-epsilon = 1.4901161193847656e-08

#let is-num(x) = type(x) == int or type(x) == float
#let is-triple(v) = type(v) == array and v.len() == 3 and is-num(v.at(0)) and is-num(v.at(1)) and is-num(v.at(2))
#let is-pair(v) = type(v) == array and v.len() == 2 and is-num(v.at(0)) and is-num(v.at(1))

#let vadd(a, b) = (a.at(0) + b.at(0), a.at(1) + b.at(1), a.at(2) + b.at(2))
#let vsub(a, b) = (a.at(0) - b.at(0), a.at(1) - b.at(1), a.at(2) - b.at(2))
#let vmul(k, v) = (k * v.at(0), k * v.at(1), k * v.at(2))
#let vneg(v) = (-v.at(0), -v.at(1), -v.at(2))
#let vdot(a, b) = a.at(0) * b.at(0) + a.at(1) * b.at(1) + a.at(2) * b.at(2)
#let vcross(a, b) = (
  a.at(1) * b.at(2) - a.at(2) * b.at(1),
  a.at(2) * b.at(0) - a.at(0) * b.at(2),
  a.at(0) * b.at(1) - a.at(1) * b.at(0),
)
#let vabs2(v) = v.at(0) * v.at(0) + v.at(1) * v.at(1) + v.at(2) * v.at(2)
#let vabs(v) = calc.sqrt(vabs2(v))
#let vunit(v) = {
  let n = vabs(v)
  if n == 0 { O } else { (v.at(0) / n, v.at(1) / n, v.at(2) / n) }
}
#let vsum(..vs) = vs.pos().fold(O, vadd)
#let vequal(a, b, eps: 0) = calc.abs(a.at(0) - b.at(0)) <= eps and calc.abs(a.at(1) - b.at(1)) <= eps and calc.abs(a.at(2) - b.at(2)) <= eps
#let vzero(v) = v.at(0) == 0 and v.at(1) == 0 and v.at(2) == 0

// Linear interpolation, works on numbers, pairs and triples.
#let interp(a, b, t) = {
  if is-num(a) { a + (b - a) * t } else { a.zip(b).map(((x, y)) => x + (y - x) * t) }
}

// Component-wise min / max of two triples.
#let vmin(a, b) = (calc.min(a.at(0), b.at(0)), calc.min(a.at(1), b.at(1)), calc.min(a.at(2), b.at(2)))
#let vmax(a, b) = (calc.max(a.at(0), b.at(0)), calc.max(a.at(1), b.at(1)), calc.max(a.at(2), b.at(2)))

// Orthogonal projection of u onto v.
#let vproject(u, v) = {
  let w = vunit(v)
  vmul(vdot(u, w), w)
}

// A unit vector perpendicular to v (Asymptote's perp).
#let vperp(v) = {
  let u = vcross(v, Y)
  let norm = sqrt-epsilon * vabs(v)
  if vabs(u) > norm { return vunit(u) }
  u = vcross(v, Z)
  if vabs(u) > norm { vunit(u) } else { X }
}

#let sgn(x) = if x > 0 { 1 } else if x < 0 { -1 } else { 0 }
#let clamp(x, lo, hi) = calc.max(lo, calc.min(hi, x))

// Spherical coordinates (degrees): colatitude theta measured from Z,
// longitude phi measured from X in the xy-plane (Asymptote's dir(theta,phi)).
#let vdir(theta, phi) = {
  let t = theta * 1deg
  let p = phi * 1deg
  (calc.sin(t) * calc.cos(p), calc.sin(t) * calc.sin(p), calc.cos(t))
}
#let expi(theta, phi) = (calc.sin(theta) * calc.cos(phi), calc.sin(theta) * calc.sin(phi), calc.cos(theta))
#let colatitude(v) = {
  let n = vabs(v)
  if n == 0 { 0.0 } else { calc.acos(clamp(v.at(2) / n, -1, 1)).deg() }
}
#let latitude(v) = 90.0 - colatitude(v)
#let longitude(v) = {
  if v.at(0) == 0 and v.at(1) == 0 { 0.0 } else { calc.atan2(v.at(0), v.at(1)).deg() }
}

// Angle between two vectors in degrees.
#let vangle(a, b) = {
  let d = vdot(vunit(a), vunit(b))
  calc.acos(clamp(d, -1, 1)).deg()
}

// ---------------------------------------------------------------------------
// 4x4 transforms (row-major nested arrays), acting on homogeneous columns.
// ---------------------------------------------------------------------------

#let identity4 = ((1.0, 0.0, 0.0, 0.0), (0.0, 1.0, 0.0, 0.0), (0.0, 0.0, 1.0, 0.0), (0.0, 0.0, 0.0, 1.0))

#let is-transform(T) = type(T) == array and T.len() == 4 and type(T.at(0)) == array and T.at(0).len() == 4

#let tmul(A, B) = {
  range(4).map(i => range(4).map(j => {
    let ai = A.at(i)
    ai.at(0) * B.at(0).at(j) + ai.at(1) * B.at(1).at(j) + ai.at(2) * B.at(2).at(j) + ai.at(3) * B.at(3).at(j)
  }))
}

// Compose transforms: compose(A, B, C) == A*B*C (C applied first).
#let compose(..Ts) = Ts.pos().fold(identity4, tmul)

// Apply a transform to a point (with homogeneous division).
#let tpoint(T, p) = {
  let (x, y, z) = p
  let r0 = T.at(0)
  let r1 = T.at(1)
  let r2 = T.at(2)
  let r3 = T.at(3)
  let w = r3.at(0) * x + r3.at(1) * y + r3.at(2) * z + r3.at(3)
  let X = r0.at(0) * x + r0.at(1) * y + r0.at(2) * z + r0.at(3)
  let Y = r1.at(0) * x + r1.at(1) * y + r1.at(2) * z + r1.at(3)
  let Z = r2.at(0) * x + r2.at(1) * y + r2.at(2) * z + r2.at(3)
  if w == 1 or w == 0 { (X, Y, Z) } else { (X / w, Y / w, Z / w) }
}

// Apply only the linear part (for direction vectors).
#let tvector(T, v) = {
  let (x, y, z) = v
  (
    T.at(0).at(0) * x + T.at(0).at(1) * y + T.at(0).at(2) * z,
    T.at(1).at(0) * x + T.at(1).at(1) * y + T.at(1).at(2) * z,
    T.at(2).at(0) * x + T.at(2).at(1) * y + T.at(2).at(2) * z,
  )
}

#let transpose4(T) = range(4).map(i => range(4).map(j => T.at(j).at(i)))

// Strip the translation part.
#let shiftless(T) = (
  (T.at(0).at(0), T.at(0).at(1), T.at(0).at(2), 0.0),
  (T.at(1).at(0), T.at(1).at(1), T.at(1).at(2), 0.0),
  (T.at(2).at(0), T.at(2).at(1), T.at(2).at(2), 0.0),
  (0.0, 0.0, 0.0, 1.0),
)

// General 4x4 inverse (Gauss-Jordan). Returns none if singular.
#let inverse4(T) = {
  let a = range(4).map(i => T.at(i).map(float) + range(4).map(j => if i == j { 1.0 } else { 0.0 }))
  let singular = false
  for c in range(4) {
    // pivot
    let piv = c
    for r in range(c + 1, 4) { if calc.abs(a.at(r).at(c)) > calc.abs(a.at(piv).at(c)) { piv = r } }
    if calc.abs(a.at(piv).at(c)) < 1e-300 { singular = true; break }
    if piv != c { let tmp = a.at(c); a.at(c) = a.at(piv); a.at(piv) = tmp }
    let p = a.at(c).at(c)
    a.at(c) = a.at(c).map(x => x / p)
    for r in range(4) {
      if r != c {
        let f = a.at(r).at(c)
        if f != 0 { a.at(r) = a.at(r).zip(a.at(c)).map(((x, y)) => x - f * y) }
      }
    }
  }
  if singular { none } else { a.map(row => row.slice(4)) }
}

// Inverse-transpose of the linear part, for transforming normals.
#let normal-transform(T) = {
  let inv = inverse4(shiftless(T))
  if inv == none { identity4 } else { transpose4(inv) }
}

#let shift(..args) = {
  let a = args.pos()
  let (x, y, z) = if a.len() == 1 { a.at(0) } else { a }
  ((1.0, 0.0, 0.0, float(x)), (0.0, 1.0, 0.0, float(y)), (0.0, 0.0, 1.0, float(z)), (0.0, 0.0, 0.0, 1.0))
}

#let scale3(x, y: auto, z: auto) = {
  let sy = if y == auto { x } else { y }
  let sz = if z == auto { x } else { z }
  ((float(x), 0.0, 0.0, 0.0), (0.0, float(sy), 0.0, 0.0), (0.0, 0.0, float(sz), 0.0), (0.0, 0.0, 0.0, 1.0))
}
#let xscale3(x) = scale3(x, y: 1, z: 1)
#let yscale3(y) = scale3(1, y: y, z: 1)
#let zscale3(z) = scale3(1, y: 1, z: z)
#let diagonal4(a, b, c, d) = ((float(a), 0.0, 0.0, 0.0), (0.0, float(b), 0.0, 0.0), (0.0, 0.0, float(c), 0.0), (0.0, 0.0, 0.0, float(d)))

// Rotation by `angle` (degrees, or a Typst angle) about the axis `u`
// through the origin, or about the line u--v when v is given.
#let rotate3(a, u, v: none) = {
  let ang = if type(a) == angle { a } else { a * 1deg }
  if v != none {
    let axis = vsub(v, u)
    return tmul(shift(u), tmul(rotate3(ang, axis), shift(vneg(u))))
  }
  if vzero(u) { panic("cannot rotate about the zero vector") }
  let (x, y, z) = vunit(u)
  let s = calc.sin(ang)
  let c = calc.cos(ang)
  let t = 1 - c
  (
    (t * x * x + c, t * x * y - s * z, t * x * z + s * y, 0.0),
    (t * x * y + s * z, t * y * y + c, t * y * z - s * x, 0.0),
    (t * x * z - s * y, t * y * z + s * x, t * z * z + c, 0.0),
    (0.0, 0.0, 0.0, 1.0),
  )
}

// Reflection about the plane through u, v and w.
#let reflect3(u, v, w) = {
  let n = vunit(vcross(vsub(v, u), vsub(w, u)))
  if vzero(n) { panic("points determining reflection plane cannot be colinear") }
  let (nx, ny, nz) = n
  let R = (
    (1 - 2 * nx * nx, -2 * nx * ny, -2 * nx * nz, 0.0),
    (-2 * nx * ny, 1 - 2 * ny * ny, -2 * ny * nz, 0.0),
    (-2 * nx * nz, -2 * ny * nz, 1 - 2 * nz * nz, 0.0),
    (0.0, 0.0, 0.0, 1.0),
  )
  tmul(shift(u), tmul(R, shift(vneg(u))))
}

// Rotation mapping Z onto the unit vector u (Asymptote's align(triple)).
#let align3(u) = {
  let (a, b, c) = vunit(u)
  let d = a * a + b * b
  if d != 0 {
    d = calc.sqrt(d)
    let e = 1 / d
    (
      (-b * e, -a * c * e, a, 0.0),
      (a * e, -b * c * e, b, 0.0),
      (0.0, d, c, 0.0),
      (0.0, 0.0, 0.0, 1.0),
    )
  } else if c >= 0 { identity4 } else { diagonal4(1, -1, -1, 1) }
}

// Modelview transform of a camera at `eye` looking at `target` with `up`
// (based on gluLookAt; Asymptote's look()).
#let look(eye, up: Z, target: O) = {
  let f = vunit(vsub(target, eye))
  if vzero(f) { f = vneg(Z) }
  let s = vcross(f, up)
  s = if not vzero(s) { vunit(s) } else { vperp(f) }
  let u = vcross(s, f)
  let M = (
    (s.at(0), s.at(1), s.at(2), 0.0),
    (u.at(0), u.at(1), u.at(2), 0.0),
    (-f.at(0), -f.at(1), -f.at(2), 0.0),
    (0.0, 0.0, 0.0, 1.0),
  )
  tmul(M, shift(vneg(eye)))
}
