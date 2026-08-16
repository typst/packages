// Painter's-algorithm renderer: depth-sort scene primitives, then paint them
// back-to-front with CeTZ. Generalised from the validated crystal renderer
// (gradient-shaded sphere balls, translucent faces) with two changes: styling
// comes from a theme dict instead of hardcoded atom colours, and mesh/`face`
// polygons are flat-shaded from a single world light direction.
//
// Two CeTZ 0.5.2 gotchas from that reference renderer are honoured here:
//   * `import cetz.draw: *` re-exports names like `scale`/`project` that would
//     shadow parameters and our camera projection. All geometry is therefore
//     computed in pure helpers BEFORE the wildcard import, and the drawing loop
//     touches only cetz's `line`/`circle`/`content`.
//   * colour mixing must weight explicitly, `color.mix((white, 25%), (col, 75%))`,
//     not `white.mix((col, 75%))` (which renormalises to a much paler tone).
//     `_sphere-fill` is the guarded, pure helper carrying that weighting.

#import "@preview/cetz:0.5.2"
#import "camera.typ": project, project-scale
#import "linalg.typ": vadd, vsub, vscale, vdot, vcross, vlen
#import "style.typ": default-theme, resolve-style, face-brightness
#import "anchors.typ": resolve-scene

// --- sphere shading ---------------------------------------------------------

/// The body tint of a shaded sphere of base colour `col`: the documented
/// mid-tone `color.mix((white, 25%), (col, 75%))` (crystal-renderer parity
/// pixel-compares against it). This is the pure, testable
/// guard against the `white.mix(..)` mis-weighting (see the module header); it
/// is the mid stop of `_sphere-gradient`.
///
/// - col (color): The sphere's base colour.
/// -> color
#let _sphere-fill(col) = color.mix((white, 25%), (col, 75%))

/// Radial "3D ball" gradient for a sphere of base colour `col`. With
/// `specular: true` (the default): a tight near-white specular core fading
/// through the classic highlight and the `_sphere-fill` body tint to a
/// darkened rim. `specular: false` reproduces the pre-specular four-stop
/// gradient exactly (the classic look, selectable per sphere or per theme via
/// the `specular` style hook). The sphere's thin outline is separate: the
/// theme's `stroke-width`/`stroke-darken` hooks on the drawn circle.
///
/// - col (color): The sphere's base colour.
/// - specular (bool): Add the specular highlight stop (default) or keep the
///   classic gradient.
/// -> gradient
#let _sphere-gradient(col, specular: true) = if specular {
  gradient.radial(
    (color.mix((white, 92%), (col, 8%)), 0%),
    (color.mix((white, 70%), (col, 30%)), 12%),
    (_sphere-fill(col), 30%),
    (col, 58%),
    (col.darken(35%), 100%),
    center: (35%, 30%),
    radius: 110%,
  )
} else {
  gradient.radial(
    (color.mix((white, 70%), (col, 30%)), 0%),
    (_sphere-fill(col), 25%),
    (col, 55%),
    (col.darken(30%), 100%),
    center: (35%, 30%),
    radius: 110%,
  )
}

// --- depth sorting (pure) ---------------------------------------------------

/// Midpoint of two points.
#let _mid(a, b) = vscale(vadd(a, b), 0.5)

/// Centroid of a point array.
#let _centroid(pts) = vscale(pts.fold((0.0, 0.0, 0.0), vadd), 1 / pts.len())

/// The 3D point whose camera depth is a primitive's depth key.
#let _depth-point(p) = {
  let k = p.kind
  if k == "sphere" { p.center }
  else if k == "seg" or k == "edge" { _mid(p.a, p.b) }
  else if k == "arrow" { _mid(p.from, p.to) }
  else if k == "face" { _centroid(p.pts) }
  else { p.center } // unreachable: labels/meshes handled before this
}

// Geometry support points used by the opt-in back/front depth policies.
#let _depth-support(p) = {
  let k = p.kind
  if k == "sphere" { (p.center,) }
  else if k == "seg" or k == "edge" { (p.a, p.b) }
  else if k == "arrow" { (p.from, p.to) }
  else if k == "face" { p.pts }
  else { (p.at,) }
}

// Scalar painter key for one already-exploded primitive. `center` is the
// historical centre/midpoint/centroid rule; back/front anchor at the farthest
// or nearest support point when intersecting geometry needs a conservative
// draw order (notably coordination faces meeting opaque ligand spheres).
#let _primitive-depth(p, camera) = {
  let key = p.at("depth-key", default: "center")
  assert(
    key in ("center", "back", "front"),
    message: "depth-key must be \"center\", \"back\", or \"front\"; got " + repr(key),
  )
  if p.kind == "label" { return 1e9 }
  if key == "center" { return project(camera, _depth-point(p)).depth }
  let depths = _depth-support(p).map(q => project(camera, q).depth)
  if key == "back" { calc.min(..depths) } else { calc.max(..depths) }
}

/// Explodes any `mesh` primitive into one `face` primitive per mesh face,
/// carrying the mesh's styling hooks. Non-mesh primitives pass through. This
/// lets a mesh's near and far faces sort independently in `sort-prims`.
#let _explode(prims) = {
  let out = ()
  for p in prims {
    if p.kind == "mesh" {
      let hooks = (:)
      for (kk, vv) in p {
        if kk not in ("kind", "vertices", "faces") { hooks.insert(kk, vv) }
      }
      let mesh-center = _centroid(p.vertices)
      for f in p.faces {
        out.push((
          kind: "face",
          pts: f.map(i => p.vertices.at(i)),
          mesh-face: true,
          mesh-center: mesh-center,
          ..hooks,
        ))
      }
    } else {
      out.push(p)
    }
  }
  out
}

// Unit camera direction in which projected depth increases (toward the viewer).
#let _camera-depth-direction(camera) = if camera.mode == "2d" {
  (0.0, 0.0, 1.0)
} else {
  let az = camera.azimuth
  let el = camera.elevation
  (-calc.sin(az) * calc.cos(el), calc.cos(az) * calc.cos(el), calc.sin(el))
}

// A stable non-degenerate normal for a polygon, or `none` when its vertices are
// collinear. Mesh normals are oriented away from the mesh centroid so culling
// remains correct even when a generator's cap winding is inconsistent.
#let _face-normal(p) = {
  if p.pts.len() < 3 { return none }
  let origin = p.pts.first()
  let normal = none
  for i in range(1, p.pts.len() - 1) {
    let e1 = vsub(p.pts.at(i), origin)
    let e2 = vsub(p.pts.at(i + 1), origin)
    let n = vcross(e1, e2)
    let area-scale = vlen(e1) * vlen(e2)
    if area-scale > 0 and vlen(n) > 1e-12 * area-scale { normal = n; break }
  }
  if normal == none { return none }
  let mesh-center = p.at("mesh-center", default: none)
  if mesh-center != none and vdot(normal, vsub(_centroid(p.pts), mesh-center)) < 0 {
    normal = vscale(normal, -1)
  }
  normal
}

// `true` for a face whose outward normal points away from the viewer, `false`
// for a viewer-facing face, and `none` for an edge-on/degenerate face.
#let _face-is-rear(p, camera) = {
  let n = _face-normal(p)
  if n == none { return none }
  let facing = vdot(n, _camera-depth-direction(camera))
  let eps = 1e-12 * vlen(n)
  if calc.abs(facing) <= eps { none } else { facing < 0 }
}

/// Explodes meshes and applies their camera-aware face-visibility policy.
///
/// Opaque mesh faces cull rear faces by default. Translucent meshes and bare
/// faces retain both sides; retained rear faces are tagged for quiet strokes.
#let _prepare-faces(prims, camera, theme: default-theme) = {
  let out = ()
  for p in _explode(prims) {
    if p.kind != "face" {
      out.push(p)
      continue
    }
    let st = resolve-style(theme, p)
    let opaque = st.at("fill-opacity", default: 0%) == 0%
    let adaptive = p.at("mesh-face", default: false) and opaque
    let cull = st.at("cull", default: if adaptive { "back" } else { none })
    assert(
      cull in (none, "back", "front"),
      message: "face cull must be none, \"back\", or \"front\"; got " + repr(cull),
    )
    let rear = _face-is-rear(p, camera)
    let drop = rear != none and (
      (cull == "back" and rear) or (cull == "front" and not rear)
    )
    if not drop {
      let q = p
      // Bare faces have no inherent outward-winding contract, so their default
      // appearance must not depend on vertex order. Rear styling is automatic
      // for meshes and opt-in for a bare face through `hidden-stroke`.
      if rear == true and (p.at("mesh-face", default: false) or "hidden-stroke" in st) {
        q.insert("rear-face", true)
      }
      out.push(q)
    }
  }
  out
}

// The interval in [0, 1] where a quadratic `a t^2 + b t + c` is <= 0.
// The quadratics used below are squared distances minus a radius squared, so
// `a` is non-negative and their sublevel set is either empty or one interval.
#let _quadratic-interval(a, b, c) = {
  if a == 0 {
    if c <= 0 { (0.0, 1.0) } else { none }
  } else {
    let disc = b * b - 4 * a * c
    if disc <= 0 { none } else {
      let root = calc.sqrt(disc)
      let lo = calc.max(0.0, (-b - root) / (2 * a))
      let hi = calc.min(1.0, (-b + root) / (2 * a))
      if hi > lo { (lo, hi) } else { none }
    }
  }
}

// Restrict an interval to the half-line where h(t) = h0 + dh*t is in front
// of (`front: true`) or behind (`front: false`) the sphere centre plane.
#let _depth-half(interval, h0, dh, front: false) = {
  if interval == none { return none }
  let (lo, hi) = interval
  if dh == 0 {
    let keep = if front { h0 >= 0 } else { h0 <= 0 }
    if keep { interval } else { none }
  } else {
    let cross = -h0 / dh
    if front {
      if dh > 0 { lo = calc.max(lo, cross) }
      else { hi = calc.min(hi, cross) }
    } else {
      if dh > 0 { hi = calc.min(hi, cross) }
      else { lo = calc.max(lo, cross) }
    }
    if hi > lo { (lo, hi) } else { none }
  }
}

// Parameter intervals of line a--b hidden by an opaque sphere under an
// orthographic camera. Behind the centre plane, the whole projected disk hides
// the line. In front of that plane, only the part inside the actual sphere is
// hidden; a line nearer than the sphere's front surface remains visible.
// Under a perspective camera the projected disk uses the depth-scaled radius
// (via _projected-sphere); the front-hemisphere refinement mixes screen units
// with view depth and is exact for orthographic, approximate (conservative)
// for mild perspective.
#let _projected-sphere(sp, camera) = {
  let p = project(camera, sp.center)
  // Screen-space occluder disk. Under perspective a sphere's silhouette radius
  // depends on its depth; project-scale is exactly 1.0 for orthographic/2d.
  (sx: p.sx, sy: p.sy, depth: p.depth, r: sp.r * project-scale(camera, p.depth))
}

#let _overlap1(a0, a1, b0, b1) = calc.min(a0, a1) <= calc.max(b0, b1) and calc.max(a0, a1) >= calc.min(b0, b1)

#let _line-bbox-overlaps-disk(pa, pb, sp) = {
  _overlap1(pa.sx, pb.sx, sp.sx - sp.r, sp.sx + sp.r) and _overlap1(pa.sy, pb.sy, sp.sy - sp.r, sp.sy + sp.r)
}

#let _line-sphere-occlusion(pa, pb, sp) = {
  let (qx, qy) = (pa.sx - sp.sx, pa.sy - sp.sy)
  let (dx, dy) = (pb.sx - pa.sx, pb.sy - pa.sy)
  let h0 = pa.depth - sp.depth
  let dh = pb.depth - pa.depth
  let aa = dx * dx + dy * dy
  let bb = 2 * (qx * dx + qy * dy)
  let cc = qx * qx + qy * qy - sp.r * sp.r
  let disk = _quadratic-interval(aa, bb, cc)
  let ball = _quadratic-interval(
    aa + dh * dh,
    bb + 2 * h0 * dh,
    cc + h0 * h0,
  )
  let hidden = ()
  let rear = _depth-half(disk, h0, dh)
  let front = _depth-half(ball, h0, dh, front: true)
  if rear != none { hidden.push(rear) }
  if front != none { hidden.push(front) }
  (hidden: hidden, disk: disk)
}

#let _merge-intervals(intervals) = {
  // These are dimensionless line parameters, so this tolerance is independent
  // of the scene's world-unit scale.
  let eps = 1e-12
  let merged = ()
  for cur in intervals.sorted(key: x => x.at(0)) {
    if merged.len() == 0 {
      merged.push(cur)
    } else {
      let prev = merged.last()
      if cur.at(0) <= prev.at(1) + eps {
        merged = merged.slice(0, merged.len() - 1)
        merged.push((prev.at(0), calc.max(prev.at(1), cur.at(1))))
      } else {
        merged.push(cur)
      }
    }
  }
  merged
}

#let _lerp-point(a, b, t) = vadd(vscale(a, 1 - t), vscale(b, t))

#let _cross2(a, b) = a.at(0) * b.at(1) - a.at(1) * b.at(0)

#let _point-in-polygon(q, pts) = {
  let inside = false
  let j = pts.len() - 1
  for i in range(pts.len()) {
    let pi = pts.at(i)
    let pj = pts.at(j)
    let crosses = (pi.at(1) > q.at(1)) != (pj.at(1) > q.at(1))
    if crosses {
      let numerator = (pj.at(0) - pi.at(0)) * (q.at(1) - pi.at(1))
      let x = numerator / (pj.at(1) - pi.at(1)) + pi.at(0)
      if q.at(0) < x { inside = not inside }
    }
    j = i
  }
  inside
}

// Cached projected/planar data for one face. Non-planar and edge-on polygons
// return `none`: they still draw, but cannot be exact line occluders.
#let _face-occluder(p, camera, theme) = {
  let normal = _face-normal(p)
  if normal == none { return none }
  let origin = p.pts.first()
  let scale = 0.0
  for q in p.pts { scale = calc.max(scale, vlen(vsub(q, origin))) }
  let planar-eps = 1e-8 * vlen(normal) * scale
  if p.pts.any(q => calc.abs(vdot(normal, vsub(q, origin))) > planar-eps) {
    return none
  }
  let view-dot = vdot(normal, _camera-depth-direction(camera))
  if calc.abs(view-dot) <= 1e-12 * vlen(normal) { return none }
  let screen = p.pts.map(q => {
    let s = project(camera, q)
    (s.sx, s.sy)
  })
  let xs = screen.map(q => q.at(0))
  let ys = screen.map(q => q.at(1))
  let st = resolve-style(theme, p)
  (
    origin: origin,
    normal: normal,
    view-dot: view-dot,
    scale: scale,
    screen: screen,
    bounds: (calc.min(..xs), calc.min(..ys), calc.max(..xs), calc.max(..ys)),
    opaque: st.at("fill-opacity", default: 0%) == 0%,
  )
}

#let _line-bbox-overlaps-face(pa, pb, face) = {
  let b = face.bounds
  _overlap1(pa.sx, pb.sx, b.at(0), b.at(2)) and _overlap1(pa.sy, pb.sy, b.at(1), b.at(3))
}

// Projected polygon cuts plus the intervals an opaque face hides. Translucent
// faces contribute cuts only, improving fragment depth keys without erasing data.
#let _line-face-interaction(a, b, pa, pb, face) = {
  let param-eps = 1e-12
  let p0 = (pa.sx, pa.sy)
  let d = (pb.sx - pa.sx, pb.sy - pa.sy)
  let dlen = calc.sqrt(d.at(0) * d.at(0) + d.at(1) * d.at(1))
  let cuts = (0.0, 1.0)
  for i in range(face.screen.len()) {
    let q0 = face.screen.at(i)
    let q1 = face.screen.at(calc.rem(i + 1, face.screen.len()))
    let e = (q1.at(0) - q0.at(0), q1.at(1) - q0.at(1))
    let rel = (q0.at(0) - p0.at(0), q0.at(1) - p0.at(1))
    let den = _cross2(d, e)
    let elen = calc.sqrt(e.at(0) * e.at(0) + e.at(1) * e.at(1))
    if dlen > 0 and elen > 0 and calc.abs(den) > 1e-12 * dlen * elen {
      let t = _cross2(rel, e) / den
      let u = _cross2(rel, d) / den
      if t > param-eps and t < 1 - param-eps and u >= -param-eps and u <= 1 + param-eps {
        cuts.push(t)
      }
    }
  }
  let s0 = vdot(face.normal, vsub(a, face.origin))
  let s1 = vdot(face.normal, vsub(b, face.origin))
  if s0 * s1 < 0 {
    let t = s0 / (s0 - s1)
    if t > param-eps and t < 1 - param-eps { cuts.push(t) }
  }
  cuts = cuts.sorted()
  let unique = ()
  for t in cuts {
    if unique.len() == 0 or t - unique.last() > param-eps { unique.push(t) }
  }
  let hidden = ()
  if face.opaque {
    for i in range(unique.len() - 1) {
      let lo = unique.at(i)
      let hi = unique.at(i + 1)
      let mid = (lo + hi) / 2
      let q = (p0.at(0) + d.at(0) * mid, p0.at(1) + d.at(1) * mid)
      if _point-in-polygon(q, face.screen) {
        let world = _lerp-point(a, b, mid)
        let toward-viewer = -vdot(face.normal, vsub(world, face.origin)) / face.view-dot
        let depth-eps = 1e-12 * calc.max(vlen(vsub(b, a)), face.scale)
        if toward-viewer > depth-eps { hidden.push((lo, hi)) }
      }
    }
  }
  (cuts: unique, hidden: hidden)
}

#let _line-points(p) = if p.kind == "arrow" { (p.from, p.to) } else { (p.a, p.b) }

#let _line-fragment(p, a, b, interval, eps) = {
  let q = p
  if p.kind == "arrow" {
    q.insert("from", _lerp-point(a, b, interval.at(0)))
    q.insert("to", _lerp-point(a, b, interval.at(1)))
    q.insert("draw-head", interval.at(1) >= 1 - eps)
  } else {
    q.insert("a", _lerp-point(a, b, interval.at(0)))
    q.insert("b", _lerp-point(a, b, interval.at(1)))
  }
  q
}

/// Splits line primitives into portions visible around opaque spheres/faces.
///
/// This is deliberately separate from `sort-prims`: the public helper remains
/// a sorting-only operation, while the render path can assign a correct depth
/// key to every visible line fragment. Line styles are preserved; only the
/// terminal surviving arrow fragment keeps its head.
#let _clip-lines(prims, camera, theme: default-theme) = {
  let eps = 1e-12 // dimensionless parameter-space tolerance
  let prims = _prepare-faces(prims, camera, theme: theme)
  let spheres = prims.filter(p => p.kind == "sphere").map(p => _projected-sphere(p, camera))
  let faces = prims.filter(p => p.kind == "face")
    .map(p => _face-occluder(p, camera, theme)).filter(p => p != none)
  let out = ()
  for p in prims {
    if p.kind in ("seg", "edge", "arrow") {
      let (a, b) = _line-points(p)
      let pa = project(camera, a)
      let pb = project(camera, b)
      let hidden = ()
      let cuts = (0.0, 1.0)
      for sp in spheres {
        if not _line-bbox-overlaps-disk(pa, pb, sp) { continue }
        let occ = _line-sphere-occlusion(pa, pb, sp)
        hidden += occ.hidden
        // Split even a fully visible line where it enters/leaves the projected
        // disk. That gives the overlapping foreground piece its own depth key
        // instead of letting a distant, non-overlapping tail drag its midpoint
        // behind the sphere.
        if occ.disk != none { cuts += (occ.disk.at(0), occ.disk.at(1)) }
      }
      for face in faces {
        if not _line-bbox-overlaps-face(pa, pb, face) { continue }
        let hit = _line-face-interaction(a, b, pa, pb, face)
        cuts += hit.cuts
        hidden += hit.hidden
      }
      let merged = _merge-intervals(hidden)
      for iv in merged {
        cuts += (iv.at(0), iv.at(1))
      }
      cuts = cuts.sorted()
      let unique = ()
      for t in cuts {
        if unique.len() == 0 or t - unique.last() > eps { unique.push(t) }
      }
      let visible = ()
      let hidden-index = 0
      for i in range(unique.len() - 1) {
        let iv = (unique.at(i), unique.at(i + 1))
        let mid = (iv.at(0) + iv.at(1)) / 2
        while hidden-index < merged.len() and merged.at(hidden-index).at(1) <= mid {
          hidden-index += 1
        }
        let is-hidden = if hidden-index < merged.len() {
          let h = merged.at(hidden-index)
          mid > h.at(0) and mid < h.at(1)
        } else { false }
        if iv.at(1) - iv.at(0) > eps and not is-hidden { visible.push(iv) }
      }
      for iv in visible {
        out.push(_line-fragment(p, a, b, iv, eps))
      }
    } else {
      out.push(p)
    }
  }
  out
}

/// Depth-sorts scene primitives back-to-front for painter's-algorithm drawing.
///
/// Pure — no cetz. By default each primitive gets a scalar depth key from
/// `camera`: spheres use their centre, seg/edge/arrow their midpoint, faces
/// their centroid, and labels a huge constant so they always paint last (on
/// top). A primitive can opt into `depth-key: "back"` or `"front"` to use its
/// farthest or nearest support point instead.
/// Meshes are first exploded into per-face `face` primitives, each keyed by its
/// own centroid, so a single mesh's faces sort independently. Depth grows toward
/// the viewer, so ascending order is far-to-near.
///
/// - prims (array): Scene primitives (as from `build-scene(..).prims`).
/// - camera (camera): The camera to key depths through.
/// -> array
#let sort-prims(prims, camera) = {
  let keyed = _explode(prims).map(p => {
    (..p, depth: _primitive-depth(p, camera))
  })
  keyed.sorted(key: p => p.depth)
}

// --- pure draw-record preparation -------------------------------------------

/// Projects a 3D point to canvas coordinates: screen position times `unit`.
#let _screen(camera, unit, p) = {
  let q = project(camera, p)
  (q.sx * unit, q.sy * unit)
}

#let _quiet-paint(paint) = if type(paint) == color {
  paint.lighten(22%).transparentize(48%)
} else { paint }

#let _quiet-stroke(stroke) = {
  if stroke == none { return none }
  if type(stroke) == color { return _quiet-paint(stroke) }
  if type(stroke) == dictionary {
    let q = stroke
    if "paint" in q { q.insert("paint", _quiet-paint(q.paint)) }
    return q
  }
  stroke
}

/// Turns one depth-sorted primitive into a plain-data draw record (screen
/// coordinates, resolved colours and thicknesses). No cetz here, so the drawing
/// loop can run entirely on cetz names without shadowing our projection.
#let _record(camera, unit, theme, p) = {
  let st = resolve-style(theme, p)
  let k = p.kind
  if k == "sphere" {
    let q = project(camera, p.center)
    (
      kind: k,
      pos: (q.sx * unit, q.sy * unit),
      radius: p.r * project-scale(camera, q.depth) * unit,
      color: st.color,
      specular: st.at("specular", default: true),
      stroke: (paint: st.color.darken(st.stroke-darken), thickness: st.stroke-width),
    )
  } else if k == "seg" {
    (
      kind: k,
      a: _screen(camera, unit, p.a),
      b: _screen(camera, unit, p.b),
      stroke: (
        paint: st.color,
        thickness: st.w * project-scale(camera, project(camera, _mid(p.a, p.b)).depth) * unit * 1cm,
        cap: "round",
      ),
    )
  } else if k == "edge" {
    (
      kind: k,
      a: _screen(camera, unit, p.a),
      b: _screen(camera, unit, p.b),
      stroke: (paint: st.color, thickness: st.width, dash: st.at("dash", default: "solid")),
    )
  } else if k == "arrow" {
    let wsc = project-scale(camera, project(camera, _mid(p.from, p.to)).depth)
    (
      kind: k,
      a: _screen(camera, unit, p.from),
      b: _screen(camera, unit, p.to),
      stroke: (paint: st.color, thickness: st.w * wsc * unit * 1cm, cap: "round"),
      mark: if p.at("draw-head", default: true) {
        (end: st.head, fill: st.color, scale: st.head-scale * st.w * wsc * unit)
      } else { none },
    )
  } else if k == "face" {
    let b = if st.at("shade", default: true) { face-brightness(p.pts, theme.light) } else { 1.0 }
    let fill = st.color.darken((1.0 - b) * 100%)
    let op = st.at("fill-opacity", default: 0%)
    if op != 0% { fill = fill.transparentize(op) }
    let stroke = st.at(
      "stroke",
      default: (paint: st.color.darken(st.stroke-darken), thickness: st.stroke-width),
    )
    if p.at("rear-face", default: false) and (op != 0% or "hidden-stroke" in st) {
      stroke = st.at("hidden-stroke", default: _quiet-stroke(stroke))
    }
    (
      kind: k,
      pts: p.pts.map(q => _screen(camera, unit, q)),
      fill: fill,
      // an explicit `stroke` hook (e.g. `none` from the solid generators)
      // overrides the theme-derived facet stroke
      stroke: stroke,
    )
  } else if k == "label" {
    (
      kind: k,
      pos: _screen(camera, unit, p.at),
      body: text(size: st.size, fill: st.color, weight: st.weight, p.text),
      anchor: st.at("text-anchor", default: none),
    )
  } else {
    panic("unknown primitive kind: " + k)
  }
}

// --- cetz emission ----------------------------------------------------------

/// Raw cetz draw commands for `scene`, depth-sorted and painted back-to-front,
/// for composition inside an existing `cetz.canvas`.
///
/// Coordinates are the camera's screen projection times `unit` (canvas units per
/// scene unit). Spheres are gradient-shaded balls (with perspective-scaled radii
/// when applicable); segments are round-capped strokes; edges thin
/// neutral lines; arrows strokes with a scaled head; faces flat-shaded, possibly
/// translucent, filled polygons; labels content drawn last.
///
/// The screen-space bounding box `(x0, y0, x1, y1)` of a scene's AABB: the span
/// of the eight AABB corners' projected `(sx, sy)`. Placement of annotations
/// (triad bottom-left, legend/colorbar on the right) is derived from this.
#let _projected-screen-bbox(camera, bbox) = {
  let (mn, mx) = (bbox.min, bbox.max)
  let xs = ()
  let ys = ()
  for x in (mn.at(0), mx.at(0)) {
    for y in (mn.at(1), mx.at(1)) {
      for z in (mn.at(2), mx.at(2)) {
        let q = project(camera, (x, y, z))
        xs.push(q.sx)
        ys.push(q.sy)
      }
    }
  }
  (calc.min(..xs), calc.min(..ys), calc.max(..xs), calc.max(..ys))
}

/// - scene (dictionary): A scene `(prims, bbox)` from `build-scene`.
/// - camera (camera): The camera to project through.
/// - theme (dictionary): A theme (see `default-theme`).
/// - unit (float): Canvas units per scene unit.
/// - axes (none, dictionary): `(vectors:, names?:)` — an axes triad placed
///   bottom-left of the projected bbox (see `annotate.axes-triad`).
/// - legend (none, array): `(label, color)` entries placed to the right (see
///   `annotate.legend`).
/// - colorbar (none, dictionary): `(colormap:, range:)` placed on the right,
///   spanning the scene height (see `annotate.colorbar`).
/// - register-anchors (bool): Export logical object anchors to the surrounding
///   CeTZ canvas. Disable when no later CeTZ command needs them.
/// - engine (str): `"typst"` (default) or the bundled `"wasm"` geometry backend.
/// - engine-cull (none, dictionary): Optional WASM-side culling policy used by
///   higher-level packages.
/// -> content
#let scene-group(
  scene,
  camera,
  theme: default-theme,
  unit: 1,
  axes: none,
  legend: none,
  colorbar: none,
  register-anchors: true,
  engine: "typst",
  engine-cull: none,
) = {
  assert(
    engine in ("typst", "wasm"),
    message: "scenery: engine must be \"typst\" or \"wasm\", got " + repr(engine),
  )
  let scene = resolve-scene(scene, camera)
  // All geometry resolved to plain data before the wildcard import, so the loop
  // below cannot be tripped by cetz re-exporting `project`/`scale`.
  //
  // `engine: "wasm"` (opt-in) delegates only the depth-sort + line-clipping to
  // the scenery-engine WASM plugin; the `import` is scoped to this branch so the
  // default pure-Typst path never loads the blob. Styling stays Typst-side:
  // `engine-sort` returns draw-ordered geometry records keyed back to the
  // original styled primitives, so `_record` reassembles colour/gradient/theme
  // by primitive exactly as the pure path does.
  let ordered = if engine == "wasm" {
    import "engine.typ": engine-sort
    engine-sort(
      _prepare-faces(scene.prims, camera, theme: theme),
      camera,
      theme: theme,
      cull: engine-cull,
    )
  } else {
    sort-prims(_clip-lines(scene.prims, camera, theme: theme), camera)
  }
  let records = ordered.map(p => _record(camera, unit, theme, p))
  // Annotation placement, in canvas coords (screen projection times `unit`).
  let sb = _projected-screen-bbox(camera, scene.bbox)
  let (x0, y0, x1, y1) = (sb.at(0) * unit, sb.at(1) * unit, sb.at(2) * unit, sb.at(3) * unit)
  import cetz.draw: *
  // Register one anchor-only CeTZ group per logical scenery object. Geometry is
  // still emitted anonymously below because depth clipping can split one object
  // into multiple draw records.
  if register-anchors {
    for (object-name, object-anchors) in scene.anchors {
      group(name: object-name, {
        for (anchor-name, point) in object-anchors {
          anchor(anchor-name, _screen(camera, unit, point))
        }
      })
    }
  }
  for r in records {
    if r.kind == "sphere" {
      circle(r.pos, radius: r.radius, fill: _sphere-gradient(r.color, specular: r.specular), stroke: r.stroke)
    } else if r.kind == "seg" or r.kind == "edge" {
      line(r.a, r.b, stroke: r.stroke)
    } else if r.kind == "arrow" {
      line(r.a, r.b, stroke: r.stroke, mark: r.mark)
    } else if r.kind == "face" {
      line(..r.pts, close: true, fill: r.fill, stroke: r.stroke)
    } else if r.kind == "label" {
      content(r.pos, r.body, anchor: r.anchor)
    }
  }
  // Annotation furniture, drawn on top of the scene. Deferred import breaks the
  // render <-> annotate reference cycle (annotate reuses `_sphere-gradient`).
  if axes != none or legend != none or colorbar != none {
    import "annotate.typ": axes-triad as _triad-cmd, legend as _legend-cmd, colorbar as _colorbar-cmd
    if axes != none {
      _triad-cmd(
        camera,
        axes.vectors,
        names: axes.at("names", default: ("x", "y", "z")),
        origin: (x0 - 0.5, y0 - 0.5),
      )
    }
    if legend != none {
      _legend-cmd(legend, origin: (x1 + 0.7, y1))
    }
    if colorbar != none {
      let cx = x1 + (if legend != none { 2.4 } else { 0.7 })
      _colorbar-cmd(colorbar.colormap, colorbar.range, origin: (cx, y0), height: y1 - y0)
    }
  }
}

// --- top-level canvas -------------------------------------------------------

/// The projected screen-space width of a scene's bounding box: the span of the
/// eight AABB corners' `sx` after projection.
#let _projected-width(camera, bbox) = {
  let (mn, mx) = (bbox.min, bbox.max)
  let xs = ()
  for x in (mn.at(0), mx.at(0)) {
    for y in (mn.at(1), mx.at(1)) {
      for z in (mn.at(2), mx.at(2)) {
        xs.push(project(camera, (x, y, z)).sx)
      }
    }
  }
  calc.max(..xs) - calc.min(..xs)
}

/// Renders a scene to Typst content: a `cetz.canvas` (length 1cm) scaled so the
/// scene's projected bounding-box width equals `width`.
///
/// - scene (dictionary): A scene `(prims, bbox)` from `build-scene`.
/// - camera (camera): The camera to project through.
/// - width (length): Target on-page width of the scene's bounding box.
/// - theme (dictionary): A theme (see `default-theme`).
/// - axes (none, dictionary): `(vectors:, names?:)` axes-triad spec, placed
///   bottom-left (see `scene-group`).
/// - legend (none, array): `(label, color)` legend entries, placed right.
/// - colorbar (none, dictionary): `(colormap:, range:)` colorbar spec, placed
///   right.
/// - engine (str): `"typst"` (default) or the bundled `"wasm"` geometry backend.
/// - engine-cull (none, dictionary): Optional WASM-side culling policy used by
///   higher-level packages.
/// -> content
#let render-scene(
  scene,
  camera,
  width: 8cm,
  theme: default-theme,
  axes: none,
  legend: none,
  colorbar: none,
  engine: "typst",
  engine-cull: none,
) = {
  let scene = resolve-scene(scene, camera)
  let w = _projected-width(camera, scene.bbox)
  let unit = if w > 0 { (width / 1cm) / w } else { 1.0 }
  cetz.canvas(length: 1cm, scene-group(
    scene,
    camera,
    theme: theme,
    unit: unit,
    axes: axes,
    legend: legend,
    colorbar: colorbar,
    register-anchors: false,
    engine: engine,
    engine-cull: engine-cull,
  ))
}
