// solids.typ — port of Asymptote's solids.asy: surfaces of revolution,
// their skeletons (transverse/longitudinal curves split into visible and
// hidden parts), silhouettes, and the sphere/cylinder/cone constructors.

#import "vec.typ": *
#import "path3.typ": *
#import "path2.typ"
#import "projection.typ": *
#import "surface.typ": nslice, is-revolution, surface-of-revolution, surface-from-patches, patch
#import "geom-transform.typ": geom-transform

#let rev-epsilon = 10 * sqrt-epsilon

// Number of pieces per Bézier segment used when projecting slices for the
// tangent computations (Asymptote uses P.ninterpolate = 16 in perspective;
// 4 is accurate enough and much faster).
#let slice-ninterpolate(P) = if P.infinity { 1 } else { 4 }

// ---------------------------------------------------------------------------
// tangent(p, q, side): try to find a bounding tangent line between two
// projected paths. Returns (ta, tb) or ().
// ---------------------------------------------------------------------------
// Are the two (nearly identical) closed curves nested, i.e. one strictly
// inside the other without crossing? Compares corresponding nodes against
// the local outward normal.
#let nested2(p, q) = {
  let n = calc.min(p.nodes.len(), q.nodes.len())
  if n < 3 or not p.cyclic or not q.cyclic { return false }
  // orientation of p (signed area of the node polygon)
  let area = 0.0
  for i in range(p.nodes.len()) {
    let a = p.nodes.at(i)
    let b = p.nodes.at(calc.rem-euclid(i + 1, p.nodes.len()))
    area += a.at(0) * b.at(1) - b.at(0) * a.at(1)
  }
  let orient = if area >= 0 { 1.0 } else { -1.0 }
  let pos = 0
  let neg = 0
  let scale = 0.0
  for i in range(n) {
    let (ax, ay) = p.nodes.at(i)
    let (bx, by) = q.nodes.at(i)
    // outgoing tangent at node i (post control - node)
    let (px, py) = p.post.at(i)
    let (dx, dy) = (px - ax, py - ay)
    let dn = calc.sqrt(dx * dx + dy * dy)
    if dn == 0 { continue }
    let outward = (orient * dy / dn, -orient * dx / dn)
    let dp = (bx - ax) * outward.at(0) + (by - ay) * outward.at(1)
    let sc = calc.sqrt((bx - ax) * (bx - ax) + (by - ay) * (by - ay))
    if sc > scale { scale = sc }
    if dp > 0 { pos += 1 } else if dp < 0 { neg += 1 }
  }
  if scale == 0 { return false }
  (pos == 0 and neg > 0) or (neg == 0 and pos > 0)
}

#let tangent(p, q, side) = {
  if nested2(p, q) { return () }
  let last-angle = none
  let last = none
  for i in range(100) {
    let ta = path2.extreme-time2(p, 1, side)
    let tb = path2.extreme-time2(q, 1, side)
    let a = path2.point2(p, ta)
    let b = path2.point2(q, tb)
    let ang = path2.pangle(path2.psub(b, a))
    if calc.abs(ang) <= sqrt-epsilon or calc.abs(calc.abs(ang) - calc.pi) <= sqrt-epsilon {
      return (ta, tb)
    }
    last-angle = ang
    last = (ta, tb)
    p = path2.rotate-path2(p, -ang)
    q = path2.rotate-path2(q, -ang)
  }
  if last-angle != none and calc.abs(last-angle) < 1e-4 { last } else { () }
}

// ---------------------------------------------------------------------------
// revolution
// ---------------------------------------------------------------------------
// revolution(g), revolution(g, axis), revolution(c, g, axis)
#let revolution(..args, c: auto, axis: auto, angle1: 0, angle2: 360) = {
  let a = args.pos()
  let cc = if c == auto { O } else { c }
  let ax = if axis == auto { Z } else { axis }
  let g = none
  if a.len() >= 1 and is-triple(a.at(0)) {
    cc = a.at(0)
    g = a.at(1)
    if a.len() >= 3 { ax = a.at(2) }
    if a.len() >= 4 { angle1 = a.at(3) }
    if a.len() >= 5 { angle2 = a.at(4) }
  } else {
    g = a.at(0)
    if a.len() >= 2 { ax = a.at(1) }
    if a.len() >= 3 { angle1 = a.at(2) }
    if a.len() >= 4 { angle2 = a.at(3) }
  }
  if not is-path3(g) { panic("revolution: a path3 generatrix is required") }
  (
    kind: "revolution",
    c: cc.map(float),
    g: g,
    axis: vunit(ax),
    angle1: float(angle1),
    angle2: float(angle2),
    M: max3(g),
    m: min3(g),
  )
}

// Build an approximately rotation-minimizing polygonal tube around a 3D path.
// `width` is the diameter, `n` the number of sides and `samples` the number
// of samples per Bézier segment. The returned value is a surface, so it can
// be passed directly to `draw()`. This is the useful, dependency-free subset
// of Asymptote's `tube`/`tube.asy` convention for helixes, wires and glass
// rods. End caps are omitted by default; pass `caps: true` when they are
// needed. `color` is an optional patch colour.
#let tube3(g, ..args, width: 0.1, n: 12, samples: auto, caps: false, color: none) = {
  let a = args.pos()
  if a.len() >= 1 { width = a.at(0) }
  if a.len() >= 2 { n = a.at(1) }
  if a.len() >= 3 { samples = a.at(2) }
  if not is-path3(g) { panic("tube3: a path3 spine is required") }
  let sides = calc.max(3, int(n))
  let per-segment = if samples == auto { 8 } else { calc.max(1, int(samples)) }
  let spine = flatten3(g, n: per-segment)
  let m = spine.len()
  let cyclic-spine = g.cyclic
  if (cyclic-spine and m < 3) or (not cyclic-spine and m < 2) { return surface-from-patches(()) }
  let radius = 0.5 * float(width)
  if radius <= 0 { return surface-from-patches(()) }

  // Tangents and a transported normal frame. Projecting the previous normal
  // onto the next normal plane avoids the abrupt twisting of Frenet frames at
  // low-curvature or inflection points.
  let frames = ()
  for i in range(m) {
    let previous = if cyclic-spine { spine.at(calc.rem-euclid(i - 1, m)) } else { spine.at(calc.max(0, i - 1)) }
    let following = if cyclic-spine { spine.at(calc.rem-euclid(i + 1, m)) } else { spine.at(calc.min(m - 1, i + 1)) }
    let tangent = vunit(vsub(following, previous))
    let tangent = if vzero(tangent) { vperp(Z) } else { tangent }
    let normal = if frames.len() == 0 { vperp(tangent) } else {
      let old = frames.last().at(0)
      let projected = vsub(old, vmul(vdot(old, tangent), tangent))
      if vabs(projected) < 1e-10 { vperp(tangent) } else { vunit(projected) }
    }
    frames.push((normal, vunit(vcross(tangent, normal))))
  }

  let rings = ()
  for i in range(m) {
    let (normal, binormal) = frames.at(i)
    let ring = ()
    for j in range(sides) {
      let theta = 360 * j / sides * 1deg
      let radial = vadd(vmul(calc.cos(theta), normal), vmul(calc.sin(theta), binormal))
      ring.push(vadd(spine.at(i), vmul(radius, radial)))
    }
    rings.push(ring)
  }

  let patches = ()
  let segments = if cyclic-spine { m } else { m - 1 }
  for i in range(segments) {
    let i1 = if cyclic-spine { calc.rem-euclid(i + 1, m) } else { i + 1 }
    for j in range(sides) {
      let j1 = calc.rem-euclid(j + 1, sides)
      // The order gives an outward normal for a frame with binormal=tangent×normal.
      let boundary = line3(
        rings.at(i).at(j), rings.at(i).at(j1),
        rings.at(i1).at(j1), rings.at(i1).at(j), cyclic: true,
      )
      patches.push(patch(boundary, color: color))
    }
  }
  if caps and not cyclic-spine {
    patches.push(patch(line3(..rings.first(), cyclic: true), color: color))
    patches.push(patch(line3(..rings.last().rev(), cyclic: true), color: color))
  }
  surface-from-patches(patches)
}

#let tube = tube3

#let transform-revolution(T, r) = {
  let trc = tpoint(T, r.c)
  let out = revolution(trc, transform-path3(T, r.g), vsub(tpoint(T, vadd(r.c, r.axis)), trc), r.angle1, r.angle2)
  if "geom" in r {
    let shape = geom-transform(T, r.geom)
    if shape != none { out.geom = shape }
  }
  out
}

// Point of the surface: node i of g rotated by j degrees.
#let vertex(r, i, j) = {
  let v = point(r.g, i)
  let center = vadd(r.c, vmul(vdot(vsub(v, r.c), r.axis), r.axis))
  let perp = vsub(v, center)
  let normal = vcross(r.axis, perp)
  vadd(center, vadd(vmul(calc.cos(j * 1deg), perp), vmul(calc.sin(j * 1deg), normal)))
}

// Transverse slice of the surface at time `position` of g.
#let slice(r, position, n: nslice) = {
  let v = point(r.g, position)
  let center = vadd(r.c, vmul(vdot(vsub(v, r.c), r.axis), r.axis))
  let perp = vsub(v, center)
  if vabs(perp) <= rev-epsilon * calc.max(vabs(r.m), vabs(r.M)) {
    return mkpath3((center,), (center,), (center,), (), false)
  }
  let v1 = vadd(center, tvector(rotate3(r.angle1, r.axis), perp))
  let v2 = vadd(center, tvector(rotate3(r.angle2, r.axis), perp))
  let p = Arc3(center, v1, v2, normal: r.axis, direction: CCW, n: n)
  if calc.rem(r.angle2 - r.angle1, 360) == 0 { close3(p) } else { p }
}

// Direction toward the camera from point c.
#let camera-direction(P, c) = if P.infinity { P.normal } else { vsub(P.camera, c) }

#let empty-curve = (front: (), back: ())

// Add the transverse slice at time t to the skeleton curve s = (front:, back:).
#let transverse-into(r, s, t, n: nslice, P: none) = {
  if P == none { panic("transverse: a projection P is required") }
  let g = r.g
  let S = slice(r, t, n: n)
  let L = length3(g)
  let midtime = 0.5 * L
  let sign = sgn(vdot(r.axis, camera-direction(P, r.c))) * sgn(vdot(r.axis, dir(g, midtime)))
  let eps = rev-epsilon
  if vdot(vsub(r.M, r.m), r.axis) == 0 or (t <= eps and sign < 0) or (t >= L - eps and sign > 0) {
    s.front.push(S)
    return s
  }
  let ni = slice-ninterpolate(P)
  let Sp = slice(r, t + eps, n: n)
  let Sm = slice(r, t - eps, n: n)
  let sp = project-path(P, Sp, ninterpolate: ni)
  let sm = project-path(P, Sm, ninterpolate: ni)
  let t1 = tangent(sp, sm, true)
  let t2 = tangent(sp, sm, false)
  if t1.len() > 1 and t2.len() > 1 {
    let a = t1.at(0) / ni
    let b = t2.at(0) / ni
    let len = length3(S)
    if b < a { let tmp = a; a = b; b = tmp }
    let p1 = subpath(S, a, b)
    let p2 = subpath(S, b, len)
    let P2 = subpath(S, 0, a)
    if not closer(P, midpoint(p2), midpoint(p1)) {
      s.front.push(p1)
      if S.cyclic { s.back.push(join(p2, P2)) } else { s.back.push(p2); s.back.push(P2) }
    } else {
      if S.cyclic { s.front.push(join(p2, P2)) } else { s.front.push(p2); s.front.push(P2) }
      s.back.push(p1)
    }
  } else {
    if (t <= midtime and sign < 0) or (t >= midtime and sign > 0) { s.front.push(S) } else { s.back.push(S) }
  }
  s
}

// Transverse slices: transverse(r, t, P) at time t, or transverse(r, m: k, P)
// for k evenly spaced slices (k = 0: one slice per node of g).
// Returns (front: path3[], back: path3[]).
#let transverse(r, ..args, m: auto, n: nslice, P: none) = {
  let a = args.pos()
  let t = none
  for x in a { if is-projection(x) { P = x } else if is-num(x) { t = x } }
  if t != none {
    return transverse-into(r, empty-curve, t, n: n, P: P)
  }
  let mm = if m == auto { 0 } else { m }
  let s = empty-curve
  let g = r.g
  if mm == 0 {
    for i in range(size3(g)) { s = transverse-into(r, s, float(i), n: n, P: P) }
  } else if mm == 1 {
    s = transverse-into(r, s, reltime(g, 0.5), n: n, P: P)
  } else {
    let factor = 1 / (mm - 1)
    for i in range(mm) { s = transverse-into(r, s, reltime(g, i * factor), n: n, P: P) }
  }
  s
}

// Longitudinal curves (the generatrix rotated to the two silhouette angles),
// each split at the point of maximal distance from the axis.
#let longitudinal(r, ..args, n: nslice, P: none) = {
  for x in args.pos() { if is-projection(x) { P = x } }
  if P == none { panic("longitudinal: a projection P is required") }
  let g = r.g
  let s = empty-curve
  let t = 0
  let d = 0.0
  let N = size3(g)
  for i in range(N) {
    let v = point(g, i)
    let center = vadd(r.c, vmul(vdot(vsub(v, r.c), r.axis), r.axis))
    let rr = vabs(vsub(v, center))
    if rr > d { t = i; d = rr }
  }
  let eps = rev-epsilon
  let ni = slice-ninterpolate(P)
  let S = slice(r, t, n: n)
  let Sm = slice(r, t + eps, n: n)
  let Sp = slice(r, t - eps, n: n)
  let sp = project-path(P, Sp, ninterpolate: ni)
  let sm = project-path(P, Sm, ninterpolate: ni)
  let t1 = tangent(sp, sm, true)
  let t2 = tangent(sp, sm, false)
  let T = transpose4(align3(r.axis))
  let Longitude = v => longitude(tvector(T, vsub(v, r.c)))
  let ref = Longitude(point(g, t))
  let ang = tt => Longitude(point(S, tt / ni)) - ref
  let push = (s, TT) => {
    if TT.len() > 1 {
      let p = transform-path3(rotate3(ang(TT.at(0)), r.c, v: vadd(r.c, r.axis)), g)
      let p1 = subpath(p, 0, t)
      let p2 = subpath(p, t, length3(p))
      if length3(p1) > 0 and (length3(p2) == 0 or not closer(P, midpoint(p2), midpoint(p1))) {
        s.front.push(p1)
        s.back.push(p2)
      } else {
        s.back.push(p1)
        s.front.push(p2)
      }
    }
    s
  }
  s = push(s, t1)
  s = push(s, t2)
  s
}

// Full skeleton: (transverse: (front, back), longitudinal: (front, back)).
#let skeleton(r, ..args, m: 0, n: nslice, P: none) = {
  for x in args.pos() { if is-projection(x) { P = x } else if is-num(x) { m = x } }
  if P == none { panic("skeleton: a projection P is required") }
  (transverse: transverse(r, m: m, n: n, P: P), longitudinal: longitudinal(r, n: n, P: P))
}

// Exact visible contour of a standard torus (axis Z): for every angle around the axis the two points of the
// tube whose normal is perpendicular to the viewing direction are computed (outer and inner branch), and the
// parts hidden behind the torus itself are removed by sampling the sight line against the implicit surface.
#let torus-silhouette(r, P, m) = {
  let info = r.geom
  let (c, R, a) = (info.center, info.major-radius, info.minor-radius)
  let M = calc.max(2 * m, 72)
  let tau = 2 * calc.pi
  let side(th, sgn-in) = {
    let er = (calc.cos(th), calc.sin(th), 0.0)
    let p = vadd(c, vmul(R, er))
    for k in range(3) {
      let d = camera-direction(P, p)
      let ar = vdot(er, d)
      let az = d.at(2)
      let h = calc.max(calc.sqrt(ar * ar + az * az), 1e-12)
      let s0 = if az >= 0 { 1.0 } else { -1.0 }
      let (cp, sp) = (s0 * az / h, -s0 * ar / h)
      let q = if sgn-in { (R - a * cp, -a * sp) } else { (R + a * cp, a * sp) }
      p = vadd(c, vadd(vmul(q.at(0), er), (0.0, 0.0, q.at(1))))
    }
    // visibility: sight line towards the camera against (rho - R)^2 + z^2 = a^2
    let d = vunit(camera-direction(P, p))
    let far = 4 * (R + a)
    let hidden = false
    for j in range(1, 49) {
      let t = 0.06 * a + (far - 0.06 * a) * j / 48 * (if P.infinity { 1.0 } else { calc.min(1.0, vabs(vsub(P.camera, p)) / far * 0.95) })
      let q = vsub(vadd(p, vmul(t, d)), c)
      let rho = calc.sqrt(q.at(0) * q.at(0) + q.at(1) * q.at(1))
      if (rho - R) * (rho - R) + q.at(2) * q.at(2) < a * a * 0.985 { hidden = true; break }
    }
    (p, not hidden)
  }
  let out = ()
  for inner in (false, true) {
    let pts = ()
    for i in range(M) { pts.push(side(tau * i / M, inner)) }
    let visible = pts.map(x => x.at(1))
    if visible.all(v => v) {
      out.push(guide3(..pts.map(x => x.at(0)), "cycle", join: ".."))
    } else {
      // start the scan just after a hidden sample so that runs never wrap around
      let k0 = visible.position(v => not v)
      let order = range(M).map(i => calc.rem(k0 + 1 + i, M))
      let run = ()
      for i in order {
        if visible.at(i) { run.push(pts.at(i).at(0)) } else {
          if run.len() > 1 { out.push(guide3(..run, join: "..")) }
          run = ()
        }
      }
      if run.len() > 1 { out.push(guide3(..run, join: "..")) }
    }
  }
  out
}

// Approximate silhouette based on m evenly spaced transverse slices.
// Returns an array of path3 (must be recomputed if the camera moves).
#let silhouette(r, ..args, m: 64, P: none) = {
  for x in args.pos() { if is-projection(x) { P = x } else if is-num(x) { m = x } }
  if P == none {
    // deferred: evaluated by picture() with its projection
    let mm = m
    return (kind: "deferred", f: PP => silhouette(r, m: mm, P: PP))
  }
  if r.at("geom", default: none) != none and r.geom.at("kind", default: "") == "torus" and calc.abs(vdot(r.axis, Z)) > 0.99999 and vabs(vsub(r.c, r.geom.center)) < 1e-9 {
    return torus-silhouette(r, P, m)
  }
  let g = r.g
  let N = size3(g)
  let M = if m == 0 { N } else { m }
  let factor = if m == 1 { 0 } else { 1 / (m - 1) }
  let n = nslice
  let eps = rev-epsilon
  let ni = slice-ninterpolate(P)
  let G = ()
  let H = ()
  let tfirst = -1.0
  let tlast = 0.0
  let pg = none
  let ph = none
  for i in range(M) {
    let t = if m == 0 { float(i) } else { reltime(g, i * factor) }
    let S = slice(r, t, n: n)
    let Sp = slice(r, t + eps, n: n)
    let Sm = slice(r, t - eps, n: n)
    let sp = project-path(P, Sp, ninterpolate: ni)
    let sm = project-path(P, Sm, ninterpolate: ni)
    let t1 = tangent(sp, sm, true)
    let t2 = tangent(sp, sm, false)
    if t1.len() > 1 and t2.len() > 1 {
      let a = t1.at(0) / ni
      let b = t2.at(0) / ni
      if a != b {
        // keep each branch continuous on the screen (tori: the two tangent points swap sides along the generator)
        let ga = point(S, a)
        let hb = point(S, b)
        let za = project-point(P, ga)
        let zb = project-point(P, hb)
        if pg != none {
          let d1 = path2.pabs(path2.psub(za, pg)) + path2.pabs(path2.psub(zb, ph))
          let d2 = path2.pabs(path2.psub(za, ph)) + path2.pabs(path2.psub(zb, pg))
          if d2 < d1 { (ga, hb) = (hb, ga); (za, zb) = (zb, za) }
        }
        pg = za
        ph = zb
        G.push(ga)
        H.insert(0, hb)
        if tfirst < 0 { tfirst = t }
        tlast = t
      }
    }
  }
  if tfirst < 0 {
    // no silhouette points found (camera along the axis): use the widest slice
    let s = transverse(r, m: 1, n: n, P: P)
    return s.front + s.back
  }
  let L = length3(g)
  let midtime = 0.5 * L
  let sign = sgn(vdot(r.axis, camera-direction(P, r.c))) * sgn(vdot(r.axis, dir(g, midtime)))
  let sfirst = transverse-into(r, empty-curve, tfirst, n: n, P: P)
  let delta = vsub(r.M, r.m)
  let cap = none
  let Gpath = none
  let Hpath = none
  if vdot(delta, r.axis) == 0 or (tfirst <= eps and sign < 0) {
    cap = sfirst.front.at(0)
  } else if sign > 0 {
    if sfirst.front.len() > 0 { Gpath = reverse(sfirst.front.at(0)) }
  } else if sfirst.back.len() > 0 { Gpath = sfirst.back.at(0) }
  let slast = transverse-into(r, empty-curve, tlast, n: n, P: P)
  if vdot(delta, r.axis) == 0 or (tlast >= L - eps and sign > 0) {
    cap = slast.front.at(0)
  } else if sign > 0 {
    if slast.back.len() > 0 { Hpath = reverse(slast.back.at(0)) }
  } else if slast.front.len() > 0 { Hpath = slast.front.at(0) }
  let Gg = guide3(..(if Gpath != none { (Gpath,) } else { () }), ..G, join: "..")
  let Hg = guide3(..(if Hpath != none { (Hpath,) } else { () }), ..H, join: "..")
  if cap == none { (Gg, Hg) } else { (Gg, Hg, cap) }
}

// ---------------------------------------------------------------------------
// Standard solids
// ---------------------------------------------------------------------------
// sphere(r), sphere(c, r), with n Bézier segments in the half circle.
#let sphere(..args, n: nslice, c: auto) = {
  let a = args.pos()
  let (c0, r) = if a.len() == 1 { (O, a.at(0)) } else { (a.at(0), a.at(1)) }
  let c = if c == auto { c0 } else { c }
  if a.len() >= 3 { n = a.at(2) }
  let out = revolution(c, Arc3-angles(c, r, 180 - sqrt-epsilon, 0, sqrt-epsilon, 0, normal: Y, n: n), Z)
  out.geom = (kind: "sphere", center: c.map(float), radius: float(r))
  out
}

// cylinder(r, h), cylinder(c, r, h, axis)
#let cylinder(..args, axis: Z, c: auto) = {
  let a = args.pos()
  let (c0, r, h) = if a.len() == 2 { (O, a.at(0), a.at(1)) } else { (a.at(0), a.at(1), a.at(2)) }
  let c = if c == auto { c0 } else { c }
  if a.len() >= 4 { axis = a.at(3) }
  let C = vadd(c, vmul(r, vperp(axis)))
  let ax = vmul(h, vunit(axis))
  let out = revolution(c, line3(C, vadd(C, ax)), ax)
  out.geom = (kind: "cylinder", radius: float(r), start: c.map(float), end: vadd(c, ax).map(float))
  out
}

// cone(r, h), cone(c, r, h, axis, n)
#let cone(..args, axis: Z, n: nslice, c: auto) = {
  let a = args.pos()
  let (c0, r, h) = if a.len() == 2 { (O, a.at(0), a.at(1)) } else { (a.at(0), a.at(1), a.at(2)) }
  let c = if c == auto { c0 } else { c }
  if a.len() >= 4 { axis = a.at(3) }
  if a.len() >= 5 { n = a.at(4) }
  let ax = vunit(axis)
  let out = revolution(c, approach(line3(vadd(c, vmul(r, vperp(ax))), vadd(c, vmul(h, ax))), n), ax)
  out.geom = (kind: "cone", radius: float(r), base: c.map(float), apex: vadd(c, vmul(h, ax)).map(float))
  out
}

// Torus of major radius R and minor radius a about the z axis.
#let torus(R, a, c: O, n: 16) = {
  let out = revolution(c, transform-path3(shift(vadd(c, vmul(R, X))), Circle3(O, a, normal: Y, n: n)), Z)
  out.geom = (kind: "torus", center: c.map(float), major-radius: float(R), minor-radius: float(a))
  out
}
