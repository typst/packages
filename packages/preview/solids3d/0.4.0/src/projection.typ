// projection.typ — orthographic and perspective projections (three.asy).

#import "vec.typ": *
#import "path3.typ": is-path3, mkpath3, length3, segment, straight, bez-split

#let is-projection(P) = type(P) == dictionary and P.at("kind", default: none) == "projection"

#let make-projection(camera, up, target, infinity, zoom) = {
  let normal = vsub(camera, target)
  let d = vabs(normal)
  (
    kind: "projection",
    camera: camera.map(float),
    up: up.map(float),
    target: target.map(float),
    infinity: infinity,
    zoom: float(zoom),
    normal: vunit(normal),
    vector: normal,
    distance: d,
    modelview: look(camera, up: up, target: target),
    ninterpolate: if infinity { 1 } else { 16 },
  )
}

// orthographic(5, 4, 3) or orthographic((5, 4, 3), up: Z, target: O, zoom: 1)
#let orthographic(..args, camera: none, up: Z, target: O, zoom: 1) = {
  let a = args.pos()
  let cam = if camera != none { camera } else if a.len() == 1 { a.at(0) } else { (a.at(0), a.at(1), a.at(2)) }
  make-projection(cam, up, target, true, zoom)
}

// perspective(5, 4, 2) or perspective((5, 4, 2), up: Z, target: O, zoom: 1)
#let perspective(..args, camera: none, up: Z, target: O, zoom: 1) = {
  let a = args.pos()
  let cam = if camera != none { camera } else if a.len() == 1 { a.at(0) } else { (a.at(0), a.at(1), a.at(2)) }
  if vequal(cam, target) { panic("camera cannot be at target") }
  make-projection(cam, up, target, false, zoom)
}

#let LeftView = orthographic(vneg(X))
#let RightView = orthographic(X)
#let FrontView = orthographic(vneg(Y))
#let BackView = orthographic(Y)
#let BottomView = orthographic(vneg(Z), up: vneg(Y))
#let TopView = orthographic(Z, up: Y)

// Asymptote's default: currentprojection = perspective(5, 4, 2)
#let currentprojection = perspective(5, 4, 2)

// Camera-space coordinates (x right, y up, z toward the viewer).
#let camera-coords(P, v) = tpoint(P.modelview, v)

// Project a triple to a pair (in user units).
#let project-point(P, v) = {
  let (x, y, z) = tpoint(P.modelview, v)
  if P.infinity {
    (x * P.zoom, y * P.zoom)
  } else {
    let depth = -z
    if depth <= 1e-9 { depth = 1e-9 }
    let f = P.distance / depth * P.zoom
    (x * f, y * f)
  }
}

// Larger value = closer to the camera.
#let closeness(P, v) = {
  if P.infinity { vdot(P.normal, v) } else { -vabs(vsub(P.camera, v)) }
}

// Is a closer to the camera than b?
#let closer(P, a, b) = closeness(P, a) > closeness(P, b)

// Depth used to sort patches (Asymptote: dot(P.normal, camera - v)).
#let depth(P, v) = -closeness(P, v)

// Camera position used for depth comparisons (Asymptote's camerafactor
// trick for orthographic projections, given a scene bound).
#let effective-camera(P, m, M) = {
  if P.infinity {
    vadd(P.target, vmul(2 * (vabs(vsub(M, m)) + vabs(vsub(m, P.target))), vunit(P.vector)))
  } else { P.camera }
}

// Project a path3 into a 2D path (same structure with pairs).
// ninterpolate: number of pieces per segment (perspective only).
#let project-path(P, p, ninterpolate: auto) = {
  let ni = if ninterpolate == auto { P.ninterpolate } else { ninterpolate }
  let n = p.nodes.len()
  let L = length3(p)
  if ni <= 1 or L == 0 {
    return (
      kind: "path",
      nodes: p.nodes.map(v => project-point(P, v)),
      pre: p.pre.map(v => project-point(P, v)),
      post: p.post.map(v => project-point(P, v)),
      straight: p.straight,
      cyclic: p.cyclic,
    )
  }
  let (r0, r1, r2, r3) = P.modelview
  let (a0, a1, a2, a3) = r0
  let (b0, b1, b2, b3) = r1
  let (c0, c1, c2, c3) = r2
  let dist = P.distance
  let zoom = P.zoom
  let nodes = ()
  let pre = ()
  let post = ()
  let strs = ()
  let nn = p.nodes.len()
  for i in range(L) {
    let i0 = i
    let i1 = if i + 1 == nn { 0 } else { i + 1 }
    let st = p.straight.at(i, default: false)
    let (A, B, C, D) = (p.nodes.at(i0), p.post.at(i0), p.pre.at(i1), p.nodes.at(i1))
    let k-max = if st { 1 } else { ni }
    for k in range(k-max) {
      // piece k of the segment: split the remainder at 1/(k-max - k)
      let (SA, SB, SC, SD) = (A, B, C, D)
      if k < k-max - 1 {
        let tt = 1 / (k-max - k)
        let u = 1 - tt
        let ab = (u * A.at(0) + tt * B.at(0), u * A.at(1) + tt * B.at(1), u * A.at(2) + tt * B.at(2))
        let bc = (u * B.at(0) + tt * C.at(0), u * B.at(1) + tt * C.at(1), u * B.at(2) + tt * C.at(2))
        let cd = (u * C.at(0) + tt * D.at(0), u * C.at(1) + tt * D.at(1), u * C.at(2) + tt * D.at(2))
        let abc = (u * ab.at(0) + tt * bc.at(0), u * ab.at(1) + tt * bc.at(1), u * ab.at(2) + tt * bc.at(2))
        let bcd = (u * bc.at(0) + tt * cd.at(0), u * bc.at(1) + tt * cd.at(1), u * bc.at(2) + tt * cd.at(2))
        let m = (u * abc.at(0) + tt * bcd.at(0), u * abc.at(1) + tt * bcd.at(1), u * abc.at(2) + tt * bcd.at(2))
        (SA, SB, SC, SD) = (A, ab, abc, m)
        (A, B, C, D) = (m, bcd, cd, D)
      }
      // project the four points
      let proj = ()
      for v in (SA, SB, SC, SD) {
        let (x, y, z) = v
        let X = a0 * x + a1 * y + a2 * z + a3
        let Y = b0 * x + b1 * y + b2 * z + b3
        let depth = -(c0 * x + c1 * y + c2 * z + c3)
        if depth <= 1e-9 { depth = 1e-9 }
        let f = dist / depth * zoom
        proj.push((X * f, Y * f))
      }
      if nodes.len() == 0 {
        nodes.push(proj.at(0))
        pre.push(proj.at(0))
      }
      post.push(proj.at(1))
      pre.push(proj.at(2))
      nodes.push(proj.at(3))
      strs.push(st)
    }
  }
  post.push(nodes.last())
  if p.cyclic {
    // last node coincides with the first
    let m = nodes.len() - 1
    (kind: "path", nodes: nodes.slice(0, m), pre: (pre.at(m),) + pre.slice(1, m), post: post.slice(0, m), straight: strs, cyclic: true)
  } else {
    (kind: "path", nodes: nodes, pre: pre, post: post, straight: strs, cyclic: false)
  }
}

// Generic project: triple or path3 or arrays thereof.
#let project(v, P: currentprojection, ninterpolate: auto) = {
  if is-triple(v) { project-point(P, v) } else if is-path3(v) { project-path(P, v, ninterpolate: ninterpolate) } else if type(v) == array { v.map(x => project(x, P: P, ninterpolate: ninterpolate)) } else { panic("cannot project " + repr(v)) }
}

// Fast projection of a path3 (control points only, no interpolation) that
// also records the 2D bounding box. One function call per path.
#let project-fast(P, p) = {
  let (r0, r1, r2, r3) = P.modelview
  let (a0, a1, a2, a3) = r0
  let (b0, b1, b2, b3) = r1
  let (c0, c1, c2, c3) = r2
  let inf = P.infinity
  let zoom = P.zoom
  let dist = P.distance
  let minx = float.inf
  let miny = float.inf
  let maxx = -float.inf
  let maxy = -float.inf
  let out = (kind: "path", straight: p.straight, cyclic: p.cyclic)
  for key in ("nodes", "pre", "post") {
    let arr = ()
    for v in p.at(key) {
      let (x, y, z) = v
      let X = a0 * x + a1 * y + a2 * z + a3
      let Y = b0 * x + b1 * y + b2 * z + b3
      if not inf {
        let depth = -(c0 * x + c1 * y + c2 * z + c3)
        if depth <= 1e-9 { depth = 1e-9 }
        let f = dist / depth
        X = X * f
        Y = Y * f
      }
      if zoom != 1 { X = X * zoom; Y = Y * zoom }
      if X < minx { minx = X }
      if X > maxx { maxx = X }
      if Y < miny { miny = Y }
      if Y > maxy { maxy = Y }
      arr.push((X, Y))
    }
    out.insert(key, arr)
  }
  out.bbox = ((minx, miny), (maxx, maxy))
  out
}
