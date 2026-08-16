// Shape generators for the scene core: convex hull faces plus parametric solids.
//
// Two return conventions, chosen for what downstream code needs:
//   * `hull-faces` returns geometric *face records* `(plane, vertices)` — the
//     unique bounding planes of a point set with their ordered polygon rings.
//     This is analysis output (planes are useful on their own), not a drawable
//     primitive; feed a record's `vertices` to `scene.face(..)` to draw it.
//   * `uv-sphere` / `cylinder` / `cone` / `prism` return a single `mesh`
//     primitive each (indexed vertices + faces), the compact form the renderer
//     consumes directly.
// Everything here is pure data; no cetz. Math is reused from `linalg.typ`.

#import "linalg.typ": vadd, vsub, vscale, vdot, vcross, vlen, vnorm
#import "scene.typ": mesh, _pt

// --- convex hull ------------------------------------------------------------

/// Whether `pts` genuinely span three dimensions (needed for a bounded
/// polyhedron). False for empty/too-few sets and for all-collinear or all-
/// coplanar sets.
#let _spans-3d(pts) = {
  if pts.len() < 4 { return false }
  let p0 = pts.first()
  let e1 = none
  for p in pts { let d = vsub(p, p0); if vlen(d) > 1e-9 { e1 = d; break } }
  if e1 == none { return false } // all points coincide
  let nrm = none
  for p in pts {
    let c = vcross(e1, vsub(p, p0))
    if vlen(c) > 1e-9 { nrm = vnorm(c); break }
  }
  if nrm == none { return false } // all points collinear
  let d0 = vdot(nrm, p0)
  pts.any(p => calc.abs(vdot(nrm, p) - d0) > 1e-9) // some point off the plane?
}

/// Convex-hull faces of up to ~50 points via unique-plane enumeration.
///
/// Every triple of points defines a candidate plane; it is a hull face iff all
/// other points lie on one side. Duplicate planes are removed, the outward
/// normal is chosen, and each face's coplanar points are returned ordered
/// counter-clockwise about the face centroid.
///
/// Assumes the points are in convex position on their hull faces: a point lying
/// in the interior of a face polygon would be woven into that face's ring.
///
/// Degenerate input — fewer than four points, or all points collinear/coplanar,
/// so no bounded polyhedron exists — returns `none`. (Typst cannot recover from a
/// raised assertion inside a test, so a sentinel is returned for callers to check
/// rather than aborting compilation; see `tests/test-shape.typ`.)
///
/// - points (array): Points to hull (each a 2- or 3-vector).
/// -> array, none
#let hull-faces(points) = {
  let pts = points.map(_pt)
  if not _spans-3d(pts) { return none }
  let n = pts.len()
  let faces = ()
  let seen = ()
  for i in range(n) {
    for j in range(i + 1, n) {
      for k in range(j + 1, n) {
        let nrm = vcross(vsub(pts.at(j), pts.at(i)), vsub(pts.at(k), pts.at(i)))
        if vlen(nrm) < 1e-8 { continue }
        let nrm = vnorm(nrm)
        let d = vdot(nrm, pts.at(i))
        let sides = pts.map(p => vdot(nrm, p) - d)
        if sides.any(s => s > 1e-6) and sides.any(s => s < -1e-6) { continue }
        // orient the normal outward (all points on the -side); `+ 0.0`
        // collapses IEEE signed zero so an axis-aligned face is not counted
        // twice as `(0,0,-1)` and `(-0,-0,-1)`.
        let (nrm, d) = if sides.any(s => s > 1e-6) { (vscale(nrm, -1), -d) } else { (nrm, d) }
        // round first, then collapse: rounding a tiny negative yields -0.0,
        // which would split the key from +0.0
        let key = repr((nrm + (d,)).map(x => calc.round(x, digits: 5) + 0.0))
        if key in seen { continue }
        seen.push(key)
        let fpts = pts.filter(p => calc.abs(vdot(nrm, p) - d) < 1e-6)
        // order the ring counter-clockwise about the centroid
        let c = vscale(fpts.fold((0.0, 0.0, 0.0), vadd), 1 / fpts.len())
        let u = vnorm(vsub(fpts.first(), c))
        let v = vcross(nrm, u)
        let vertices = fpts.sorted(key: p => {
          let r = vsub(p, c)
          calc.atan2(vdot(r, u), vdot(r, v)).rad()
        })
        faces.push((plane: (normal: nrm, offset: d), vertices: vertices))
      }
    }
  }
  faces
}

// --- parametric solids ------------------------------------------------------

/// Merges generator styling: parametric solids default to `stroke: none` so
/// their facet edges do not read as a wireframe; callers can override.
#let _solid-style(style) = {
  let named = style.named()
  if "stroke" not in named { named.insert("stroke", none) }
  named
}

/// An orthonormal basis `(u, v)` spanning the plane perpendicular to `dir`.
#let _frame(dir) = {
  let d = vnorm(dir)
  let ref = if calc.abs(d.at(0)) < 0.9 { (1.0, 0.0, 0.0) } else { (0.0, 1.0, 0.0) }
  let u = vnorm(vcross(d, ref))
  (u, vcross(d, u))
}

/// A point on the circle of radius `r` centred at `base`, in the `(u, v)` plane,
/// at angle `phi`.
#let _ring-pt(base, u, v, r, phi) = vadd(
  base,
  vadd(vscale(u, r * calc.cos(phi)), vscale(v, r * calc.sin(phi))),
)

/// A UV-sphere mesh centred at `center`.
///
/// - center (vector): Centre of the sphere (2- or 3-vector).
/// - r (float): Radius.
/// - segments (int): Meridian subdivisions (longitude).
/// - rings (int): Parallel subdivisions (latitude).
/// - ..style (any): Styling hooks forwarded to the `mesh` primitive.
/// -> dictionary
#let uv-sphere(center, r, segments: 16, rings: 8, ..style) = {
  assert(segments >= 3 and rings >= 2, message: "uv-sphere needs segments >= 3 and rings >= 2")
  let center = _pt(center)
  // The poles are single shared vertices with triangle fans. Emitting a full
  // ring of coincident pole points (the naive grid) makes every pole "quad"
  // degenerate, which flat-shades as a pinwheel artifact around the poles.
  let verts = (vadd(center, (0, 0, r)),)
  for i in range(1, rings) {
    let theta = calc.pi * i / rings
    let (st, ct) = (calc.sin(theta), calc.cos(theta))
    for j in range(segments) {
      let phi = 2 * calc.pi * j / segments
      verts.push(vadd(center, (r * st * calc.cos(phi), r * st * calc.sin(phi), r * ct)))
    }
  }
  verts.push(vadd(center, (0, 0, -r)))
  let ring(i, j) = 1 + (i - 1) * segments + calc.rem(j, segments) // interior ring i in 1..rings-1
  let south = 1 + (rings - 1) * segments
  let faces = ()
  for j in range(segments) { faces.push((0, ring(1, j), ring(1, j + 1))) }
  for i in range(1, rings - 1) {
    for j in range(segments) {
      faces.push((ring(i, j), ring(i, j + 1), ring(i + 1, j + 1), ring(i + 1, j)))
    }
  }
  for j in range(segments) { faces.push((south, ring(rings - 1, j + 1), ring(rings - 1, j))) }
  mesh(verts, faces, .._solid-style(style))
}

/// A cylinder mesh with axis `from` -> `to` and radius `r`.
///
/// - from (vector): Centre of one end cap.
/// - to (vector): Centre of the other end cap.
/// - r (float): Radius.
/// - segments (int): Subdivisions around the axis.
/// - caps (bool): Whether to emit the two end-cap faces.
/// - ..style (any): Styling hooks forwarded to the `mesh` primitive.
/// -> dictionary
#let cylinder(from, to, r, segments: 16, caps: true, ..style) = {
  let (from, to) = (_pt(from), _pt(to))
  let (u, v) = _frame(vsub(to, from))
  let verts = ()
  for base in (from, to) {
    for j in range(segments) {
      verts.push(_ring-pt(base, u, v, r, 2 * calc.pi * j / segments))
    }
  }
  let faces = ()
  for j in range(segments) {
    let (a, b) = (j, calc.rem(j + 1, segments))
    faces.push((a, b, segments + b, segments + a))
  }
  if caps {
    faces.push(range(segments))
    faces.push(range(segments, 2 * segments))
  }
  mesh(verts, faces, .._solid-style(style))
}

/// A cone mesh: base circle of radius `r` at `from`, apex at `to`.
///
/// - from (vector): Centre of the base circle.
/// - to (vector): Apex point.
/// - r (float): Base radius.
/// - segments (int): Subdivisions around the base.
/// - cap (bool): Whether to emit the base face.
/// - ..style (any): Styling hooks forwarded to the `mesh` primitive.
/// -> dictionary
#let cone(from, to, r, segments: 16, cap: true, ..style) = {
  let (from, to) = (_pt(from), _pt(to))
  let (u, v) = _frame(vsub(to, from))
  let verts = ()
  for j in range(segments) {
    verts.push(_ring-pt(from, u, v, r, 2 * calc.pi * j / segments))
  }
  verts.push(to) // apex at index `segments`
  let faces = ()
  for j in range(segments) {
    faces.push((j, calc.rem(j + 1, segments), segments))
  }
  if cap { faces.push(range(segments)) }
  mesh(verts, faces, .._solid-style(style))
}

/// A prism/extrusion mesh: the polygon `base` swept by the vector `extent`.
///
/// - base (array): Ordered polygon vertices (each a 2- or 3-vector).
/// - extent (vector): Sweep vector added to `base` to make the top ring.
/// - caps (bool): Whether to emit the bottom and top polygon faces.
/// - ..style (any): Styling hooks forwarded to the `mesh` primitive.
/// -> dictionary
#let prism(base, extent, caps: true, ..style) = {
  let base = base.map(_pt)
  let extent = _pt(extent)
  let n = base.len()
  let verts = base + base.map(p => vadd(p, extent))
  let faces = ()
  for j in range(n) {
    let (a, b) = (j, calc.rem(j + 1, n))
    faces.push((a, b, n + b, n + a))
  }
  if caps {
    faces.push(range(n))
    faces.push(range(n, 2 * n))
  }
  mesh(verts, faces, .._solid-style(style))
}
