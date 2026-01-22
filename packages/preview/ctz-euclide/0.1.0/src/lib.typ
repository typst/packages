// ctz-euclide/src/lib.typ
// Main entry point for ctz-euclide Typst package
//
// A port of the LaTeX tkz-euclide package for Euclidean geometry
// Uses cetz as the drawing backend

#import "util.typ"
#import "point.typ"
#import "intersection.typ"
#import "triangle.typ"
#import "transform.typ"
#import "draw.typ"
#import "drawing.typ"
#import "circle.typ"

/// Package version
#let version = (0, 1, 0)

/// Internal key for storing points in shared-state
#let _points-key = "tkz-points"

/// Get all stored points from context
#let _get-points(ctx) = {
  ctx.shared-state.at(_points-key, default: (:))
}

/// Store points in context
#let _set-points(ctx, points) = {
  ctx.shared-state.insert(_points-key, points)
  ctx
}

/// Custom coordinate resolver - accepts both "A" and "tkz:A" syntax
#let tkz-coordinate-resolver(ctx, c) = {
  if type(c) == str {
    let points = _get-points(ctx)
    // Try with "tkz:" prefix first
    if c.starts-with("tkz:") {
      let name = c.slice(4)
      if name in points {
        return points.at(name)
      }
    }
    // Try direct name lookup (e.g., "A" instead of "tkz:A")
    if c in points {
      return points.at(c)
    }
  }
  c
}

/// Initialize ctz-euclide in a cetz canvas
/// Must be called at the start of canvas body
#let init(cetz-draw) = {
  cetz-draw.set-ctx(ctx => {
    // Initialize shared state for point storage
    if _points-key not in ctx.shared-state {
      ctx.shared-state.insert(_points-key, (:))
    }
    // Register coordinate resolver if not already done
    if type(ctx.resolve-coordinate) != array {
      ctx.resolve-coordinate = ()
    }
    if tkz-coordinate-resolver not in ctx.resolve-coordinate {
      ctx.resolve-coordinate.push(tkz-coordinate-resolver)
    }
    ctx
  })
}

/// Resolve a point reference to coordinates (internal helper)
#let _resolve-point(ctx, p, cetz-coordinate) = {
  if type(p) == str {
    // Check if it's a tkz point name
    let points = _get-points(ctx)
    if p in points {
      return points.at(p)
    }
    // Try to strip "tkz:" prefix
    if p.starts-with("tkz:") {
      let name = p.slice(4)
      if name in points {
        return points.at(name)
      }
    }
    // Fall back to cetz coordinate resolution
    let (_, pt) = cetz-coordinate.resolve(ctx, p)
    return pt
  } else if type(p) == array {
    if p.len() >= 2 and p.len() <= 3 and p.all(x => type(x) in (int, float)) {
      return if p.len() == 2 { (p.at(0), p.at(1), 0) } else { p }
    }
    let (_, pt) = cetz-coordinate.resolve(ctx, p)
    return pt
  } else if type(p) == dictionary {
    let (_, pt) = cetz-coordinate.resolve(ctx, p)
    return pt
  }
  panic("Cannot resolve point: " + repr(p))
}

/// Define multiple points at once
#let def-points(cetz-coordinate, ..points) = {
  let pairs = if points.named() != (:) {
    points.named().pairs()
  } else {
    let pos = points.pos()
    assert(calc.rem(pos.len(), 2) == 0,
      message: "tkz-def-points requires name-coordinate pairs")
    range(0, pos.len(), step: 2).map(i => (pos.at(i), pos.at(i + 1)))
  }

  (ctx => {
    for (name, coord) in pairs {
      let pt = if type(coord) == array and coord.len() >= 2 and coord.len() <= 3 and coord.all(x => type(x) in (int, float, length)) {
        let resolve-num(v) = if type(v) == length { v / 1cm } else { v }
        let x = resolve-num(coord.at(0))
        let y = resolve-num(coord.at(1))
        let z = if coord.len() > 2 { resolve-num(coord.at(2)) } else { 0 }
        (x, y, z)
      } else {
        let (ctx2, resolved) = cetz-coordinate.resolve(ctx, coord)
        ctx = ctx2
        resolved
      }

      let stored = _get-points(ctx)
      stored.insert(name, pt)
      ctx = _set-points(ctx, stored)
    }
    (ctx: ctx)
  },)
}

/// Line-line intersection
#let inter-ll(name, line1, line2, ray: true, cetz-coordinate) = {
  (ctx => {
    let p1 = _resolve-point(ctx, line1.at(0), cetz-coordinate)
    let p2 = _resolve-point(ctx, line1.at(1), cetz-coordinate)
    let p3 = _resolve-point(ctx, line2.at(0), cetz-coordinate)
    let p4 = _resolve-point(ctx, line2.at(1), cetz-coordinate)

    let result = intersection.line-line-raw(p1, p2, p3, p4, ray: ray)
    assert(result != none, message: "Lines are parallel, no intersection found")

    let points = _get-points(ctx)
    points.insert(name, result)
    ctx = _set-points(ctx, points)

    (ctx: ctx)
  },)
}

/// Parse circle specification
#let _parse-circle(ctx, circle-spec, cetz-coordinate) = {
  if type(circle-spec) == dictionary {
    let center = _resolve-point(ctx, circle-spec.center, cetz-coordinate)
    let radius = if "radius" in circle-spec {
      if type(circle-spec.radius) == length { circle-spec.radius / 1cm } else { circle-spec.radius }
    } else if "through" in circle-spec {
      let pt = _resolve-point(ctx, circle-spec.through, cetz-coordinate)
      util.dist(center, pt)
    } else {
      panic("Circle needs radius or through point")
    }
    (center, radius)
  } else if type(circle-spec) == array and circle-spec.len() == 2 {
    let center = _resolve-point(ctx, circle-spec.at(0), cetz-coordinate)
    let pt = _resolve-point(ctx, circle-spec.at(1), cetz-coordinate)
    (center, util.dist(center, pt))
  } else {
    panic("Invalid circle specification: " + repr(circle-spec))
  }
}

/// Line-circle intersection
#let inter-lc(result-names, line, circle, near: none, cetz-coordinate) = {
  (ctx => {
    let la = _resolve-point(ctx, line.at(0), cetz-coordinate)
    let lb = _resolve-point(ctx, line.at(1), cetz-coordinate)
    let (center, radius) = _parse-circle(ctx, circle, cetz-coordinate)

    let results = intersection.line-circle-raw(la, lb, center, radius)

    if near != none and results.len() > 1 {
      let near-pt = _resolve-point(ctx, near, cetz-coordinate)
      results = results.sorted(key: pt => util.dist-sq(near-pt, pt))
    }

    let names = if type(result-names) == str { (result-names,) } else { result-names }
    let points = _get-points(ctx)
    for (i, pt-name) in names.enumerate() {
      if i < results.len() {
        points.insert(pt-name, results.at(i))
      }
    }
    ctx = _set-points(ctx, points)

    (ctx: ctx)
  },)
}

/// Circle-circle intersection
#let inter-cc(result-names, circle1, circle2, cetz-coordinate) = {
  (ctx => {
    let (c0, r0) = _parse-circle(ctx, circle1, cetz-coordinate)
    let (c1, r1) = _parse-circle(ctx, circle2, cetz-coordinate)

    let results = intersection.circle-circle-raw(c0, r0, c1, r1)

    let names = if type(result-names) == str { (result-names,) } else { result-names }
    let points = _get-points(ctx)
    for (i, pt-name) in names.enumerate() {
      if i < results.len() {
        points.insert(pt-name, results.at(i))
      }
    }
    ctx = _set-points(ctx, points)

    (ctx: ctx)
  },)
}

/// Triangle centroid
#let centroid(name, a, b, c, cetz-coordinate) = {
  (ctx => {
    let pa = _resolve-point(ctx, a, cetz-coordinate)
    let pb = _resolve-point(ctx, b, cetz-coordinate)
    let pc = _resolve-point(ctx, c, cetz-coordinate)
    let center = triangle.centroid-raw(pa, pb, pc)

    let points = _get-points(ctx)
    points.insert(name, center)
    ctx = _set-points(ctx, points)
    (ctx: ctx)
  },)
}

/// Triangle circumcenter
#let circumcenter(name, a, b, c, cetz-coordinate) = {
  (ctx => {
    let pa = _resolve-point(ctx, a, cetz-coordinate)
    let pb = _resolve-point(ctx, b, cetz-coordinate)
    let pc = _resolve-point(ctx, c, cetz-coordinate)
    let center = triangle.circumcenter-raw(pa, pb, pc)

    let points = _get-points(ctx)
    points.insert(name, center)
    ctx = _set-points(ctx, points)
    (ctx: ctx)
  },)
}

/// Triangle incenter
#let incenter(name, a, b, c, cetz-coordinate) = {
  (ctx => {
    let pa = _resolve-point(ctx, a, cetz-coordinate)
    let pb = _resolve-point(ctx, b, cetz-coordinate)
    let pc = _resolve-point(ctx, c, cetz-coordinate)
    let center = triangle.incenter-raw(pa, pb, pc)

    let points = _get-points(ctx)
    points.insert(name, center)
    ctx = _set-points(ctx, points)
    (ctx: ctx)
  },)
}

/// Triangle orthocenter
#let orthocenter(name, a, b, c, cetz-coordinate) = {
  (ctx => {
    let pa = _resolve-point(ctx, a, cetz-coordinate)
    let pb = _resolve-point(ctx, b, cetz-coordinate)
    let pc = _resolve-point(ctx, c, cetz-coordinate)
    let center = triangle.orthocenter-raw(pa, pb, pc)

    let points = _get-points(ctx)
    points.insert(name, center)
    ctx = _set-points(ctx, points)
    (ctx: ctx)
  },)
}

// =============================================================================
// ADDITIONAL TRIANGLE CENTERS
// =============================================================================

/// Nine-point (Euler) circle center
#let euler-center(name, a, b, c, cetz-coordinate) = {
  (ctx => {
    let pa = _resolve-point(ctx, a, cetz-coordinate)
    let pb = _resolve-point(ctx, b, cetz-coordinate)
    let pc = _resolve-point(ctx, c, cetz-coordinate)
    let center = triangle.euler-center-raw(pa, pb, pc)
    let points = _get-points(ctx)
    points.insert(name, center)
    ctx = _set-points(ctx, points)
    (ctx: ctx)
  },)
}

/// Lemoine point (symmedian point)
#let lemoine(name, a, b, c, cetz-coordinate) = {
  (ctx => {
    let pa = _resolve-point(ctx, a, cetz-coordinate)
    let pb = _resolve-point(ctx, b, cetz-coordinate)
    let pc = _resolve-point(ctx, c, cetz-coordinate)
    let center = triangle.lemoine-raw(pa, pb, pc)
    let points = _get-points(ctx)
    points.insert(name, center)
    ctx = _set-points(ctx, points)
    (ctx: ctx)
  },)
}

/// Nagel point
#let nagel(name, a, b, c, cetz-coordinate) = {
  (ctx => {
    let pa = _resolve-point(ctx, a, cetz-coordinate)
    let pb = _resolve-point(ctx, b, cetz-coordinate)
    let pc = _resolve-point(ctx, c, cetz-coordinate)
    let center = triangle.nagel-raw(pa, pb, pc)
    let points = _get-points(ctx)
    points.insert(name, center)
    ctx = _set-points(ctx, points)
    (ctx: ctx)
  },)
}

/// Gergonne point
#let gergonne(name, a, b, c, cetz-coordinate) = {
  (ctx => {
    let pa = _resolve-point(ctx, a, cetz-coordinate)
    let pb = _resolve-point(ctx, b, cetz-coordinate)
    let pc = _resolve-point(ctx, c, cetz-coordinate)
    let center = triangle.gergonne-raw(pa, pb, pc)
    let points = _get-points(ctx)
    points.insert(name, center)
    ctx = _set-points(ctx, points)
    (ctx: ctx)
  },)
}

/// Spieker center
#let spieker(name, a, b, c, cetz-coordinate) = {
  (ctx => {
    let pa = _resolve-point(ctx, a, cetz-coordinate)
    let pb = _resolve-point(ctx, b, cetz-coordinate)
    let pc = _resolve-point(ctx, c, cetz-coordinate)
    let center = triangle.spieker-raw(pa, pb, pc)
    let points = _get-points(ctx)
    points.insert(name, center)
    ctx = _set-points(ctx, points)
    (ctx: ctx)
  },)
}

/// Feuerbach point
#let feuerbach(name, a, b, c, cetz-coordinate) = {
  (ctx => {
    let pa = _resolve-point(ctx, a, cetz-coordinate)
    let pb = _resolve-point(ctx, b, cetz-coordinate)
    let pc = _resolve-point(ctx, c, cetz-coordinate)
    let center = triangle.feuerbach-raw(pa, pb, pc)
    let points = _get-points(ctx)
    points.insert(name, center)
    ctx = _set-points(ctx, points)
    (ctx: ctx)
  },)
}

/// Mittenpunkt
#let mittenpunkt(name, a, b, c, cetz-coordinate) = {
  (ctx => {
    let pa = _resolve-point(ctx, a, cetz-coordinate)
    let pb = _resolve-point(ctx, b, cetz-coordinate)
    let pc = _resolve-point(ctx, c, cetz-coordinate)
    let center = triangle.mittenpunkt-raw(pa, pb, pc)
    let points = _get-points(ctx)
    points.insert(name, center)
    ctx = _set-points(ctx, points)
    (ctx: ctx)
  },)
}

/// Excenter (opposite to specified vertex)
#let excenter(name, a, b, c, vertex: "a", cetz-coordinate) = {
  (ctx => {
    let pa = _resolve-point(ctx, a, cetz-coordinate)
    let pb = _resolve-point(ctx, b, cetz-coordinate)
    let pc = _resolve-point(ctx, c, cetz-coordinate)
    let center = triangle.excenter-raw(pa, pb, pc, vertex: vertex)
    let points = _get-points(ctx)
    points.insert(name, center)
    ctx = _set-points(ctx, points)
    (ctx: ctx)
  },)
}

// =============================================================================
// SPECIAL TRIANGLES
// =============================================================================

/// Define medial triangle vertices
#let medial-triangle(name-a, name-b, name-c, a, b, c, cetz-coordinate) = {
  (ctx => {
    let pa = _resolve-point(ctx, a, cetz-coordinate)
    let pb = _resolve-point(ctx, b, cetz-coordinate)
    let pc = _resolve-point(ctx, c, cetz-coordinate)
    let (ma, mb, mc) = triangle.medial-triangle-raw(pa, pb, pc)
    let points = _get-points(ctx)
    points.insert(name-a, ma)
    points.insert(name-b, mb)
    points.insert(name-c, mc)
    ctx = _set-points(ctx, points)
    (ctx: ctx)
  },)
}

/// Define orthic triangle vertices
#let orthic-triangle(name-a, name-b, name-c, a, b, c, cetz-coordinate) = {
  (ctx => {
    let pa = _resolve-point(ctx, a, cetz-coordinate)
    let pb = _resolve-point(ctx, b, cetz-coordinate)
    let pc = _resolve-point(ctx, c, cetz-coordinate)
    let (ha, hb, hc) = triangle.orthic-triangle-raw(pa, pb, pc)
    let points = _get-points(ctx)
    points.insert(name-a, ha)
    points.insert(name-b, hb)
    points.insert(name-c, hc)
    ctx = _set-points(ctx, points)
    (ctx: ctx)
  },)
}

/// Define intouch triangle vertices
#let intouch-triangle(name-a, name-b, name-c, a, b, c, cetz-coordinate) = {
  (ctx => {
    let pa = _resolve-point(ctx, a, cetz-coordinate)
    let pb = _resolve-point(ctx, b, cetz-coordinate)
    let pc = _resolve-point(ctx, c, cetz-coordinate)
    let (ta, tb, tc) = triangle.intouch-triangle-raw(pa, pb, pc)
    let points = _get-points(ctx)
    points.insert(name-a, ta)
    points.insert(name-b, tb)
    points.insert(name-c, tc)
    ctx = _set-points(ctx, points)
    (ctx: ctx)
  },)
}

// =============================================================================
// POINT CONSTRUCTIONS
// =============================================================================

/// Define midpoint of segment AB
#let def-midpoint(name, a, b, cetz-coordinate) = {
  (ctx => {
    let pa = _resolve-point(ctx, a, cetz-coordinate)
    let pb = _resolve-point(ctx, b, cetz-coordinate)
    let mid = util.midpoint(pa, pb)
    let points = _get-points(ctx)
    points.insert(name, mid)
    ctx = _set-points(ctx, points)
    (ctx: ctx)
  },)
}

/// Define equilateral triangle third point
#let def-equilateral(name, a, b, cetz-coordinate) = {
  (ctx => {
    let pa = _resolve-point(ctx, a, cetz-coordinate)
    let pb = _resolve-point(ctx, b, cetz-coordinate)
    let pc = util.equilateral-point(pa, pb)
    let points = _get-points(ctx)
    points.insert(name, pc)
    ctx = _set-points(ctx, points)
    (ctx: ctx)
  },)
}

/// Define square third and fourth points
#let def-square(name-c, name-d, a, b, cetz-coordinate) = {
  (ctx => {
    let pa = _resolve-point(ctx, a, cetz-coordinate)
    let pb = _resolve-point(ctx, b, cetz-coordinate)
    let (pc, pd) = util.square-points(pa, pb)
    let points = _get-points(ctx)
    points.insert(name-c, pc)
    points.insert(name-d, pd)
    ctx = _set-points(ctx, points)
    (ctx: ctx)
  },)
}

/// Define golden ratio point
#let def-golden-ratio(name, a, b, cetz-coordinate) = {
  (ctx => {
    let pa = _resolve-point(ctx, a, cetz-coordinate)
    let pb = _resolve-point(ctx, b, cetz-coordinate)
    let pc = util.golden-ratio-point(pa, pb)
    let points = _get-points(ctx)
    points.insert(name, pc)
    ctx = _set-points(ctx, points)
    (ctx: ctx)
  },)
}

/// Define barycentric point
#let def-barycentric(name, a, b, c, wa, wb, wc, cetz-coordinate) = {
  (ctx => {
    let pa = _resolve-point(ctx, a, cetz-coordinate)
    let pb = _resolve-point(ctx, b, cetz-coordinate)
    let pc = _resolve-point(ctx, c, cetz-coordinate)
    let result = util.barycentric-point(pa, pb, pc, wa, wb, wc)
    let points = _get-points(ctx)
    points.insert(name, result)
    ctx = _set-points(ctx, points)
    (ctx: ctx)
  },)
}

/// Define point on circle at angle
#let def-point-on-circle(name, center, radius, angle-deg, cetz-coordinate) = {
  (ctx => {
    let c = _resolve-point(ctx, center, cetz-coordinate)
    let r = if type(radius) == length { radius / 1cm } else { radius }
    let result = util.point-on-circle(c, r, angle-deg)
    let points = _get-points(ctx)
    points.insert(name, result)
    ctx = _set-points(ctx, points)
    (ctx: ctx)
  },)
}

/// Define regular polygon vertices
#let def-regular-polygon(names, center, first-vertex, cetz-coordinate) = {
  (ctx => {
    let c = _resolve-point(ctx, center, cetz-coordinate)
    let fv = _resolve-point(ctx, first-vertex, cetz-coordinate)
    let n = names.len()
    let vertices = util.regular-polygon-vertices(c, fv, n)
    let points = _get-points(ctx)
    for (i, name) in names.enumerate() {
      points.insert(name, vertices.at(i))
    }
    ctx = _set-points(ctx, points)
    (ctx: ctx)
  },)
}

/// Define linear combination point: P = A + k*(B-A)
#let def-linear(name, a, b, k, cetz-coordinate) = {
  (ctx => {
    let pa = _resolve-point(ctx, a, cetz-coordinate)
    let pb = _resolve-point(ctx, b, cetz-coordinate)
    let result = util.linear-point(pa, pb, k)
    let points = _get-points(ctx)
    points.insert(name, result)
    ctx = _set-points(ctx, points)
    (ctx: ctx)
  },)
}

/// Define central symmetry point
#let def-symmetry(name, source, center, cetz-coordinate) = {
  (ctx => {
    let p = _resolve-point(ctx, source, cetz-coordinate)
    let c = _resolve-point(ctx, center, cetz-coordinate)
    let result = util.central-symmetry(p, c)
    let points = _get-points(ctx)
    points.insert(name, result)
    ctx = _set-points(ctx, points)
    (ctx: ctx)
  },)
}

/// Define circle inversion point
#let def-inversion(name, source, center, radius, cetz-coordinate) = {
  (ctx => {
    let p = _resolve-point(ctx, source, cetz-coordinate)
    let c = _resolve-point(ctx, center, cetz-coordinate)
    let r = if type(radius) == length { radius / 1cm } else { radius }
    let result = util.circle-inversion(p, c, r)
    let points = _get-points(ctx)
    points.insert(name, result)
    ctx = _set-points(ctx, points)
    (ctx: ctx)
  },)
}

// =============================================================================
// TANGENT DEFINITIONS
// =============================================================================

/// Define tangent points from external point to circle
#let def-tangent-from(name1, name2, external-point, center, radius, cetz-coordinate) = {
  (ctx => {
    let p = _resolve-point(ctx, external-point, cetz-coordinate)
    let c = _resolve-point(ctx, center, cetz-coordinate)
    let r = if type(radius) == length { radius / 1cm } else { radius }
    let tangents = circle.tangent-from-point-raw(p, c, r)
    let points = _get-points(ctx)
    if tangents.len() >= 1 { points.insert(name1, tangents.at(0)) }
    if tangents.len() >= 2 { points.insert(name2, tangents.at(1)) }
    ctx = _set-points(ctx, points)
    (ctx: ctx)
  },)
}

/// Define tangent line at point on circle
#let def-tangent-at(name1, name2, point-on-circle, center, cetz-coordinate) = {
  (ctx => {
    let p = _resolve-point(ctx, point-on-circle, cetz-coordinate)
    let c = _resolve-point(ctx, center, cetz-coordinate)
    let (t1, t2) = circle.tangent-at-point-raw(p, c)
    let points = _get-points(ctx)
    points.insert(name1, t1)
    points.insert(name2, t2)
    ctx = _set-points(ctx, points)
    (ctx: ctx)
  },)
}

/// Define radical axis of two circles
#let def-radical-axis(name1, name2, center1, radius1, center2, radius2, cetz-coordinate) = {
  (ctx => {
    let c1 = _resolve-point(ctx, center1, cetz-coordinate)
    let c2 = _resolve-point(ctx, center2, cetz-coordinate)
    let r1 = if type(radius1) == length { radius1 / 1cm } else { radius1 }
    let r2 = if type(radius2) == length { radius2 / 1cm } else { radius2 }
    let result = circle.radical-axis-raw(c1, r1, c2, r2)
    if result != none {
      let (p1, p2) = result
      let points = _get-points(ctx)
      points.insert(name1, p1)
      points.insert(name2, p2)
      ctx = _set-points(ctx, points)
    }
    (ctx: ctx)
  },)
}

/// Define point by rotation around a center
#let def-point-by-rotation(name, source, center, angle-deg, cetz-coordinate) = {
  (ctx => {
    let src = _resolve-point(ctx, source, cetz-coordinate)
    let ctr = _resolve-point(ctx, center, cetz-coordinate)
    let result = transform.rotation-raw(src, ctr, angle-deg)

    let points = _get-points(ctx)
    points.insert(name, result)
    ctx = _set-points(ctx, points)
    (ctx: ctx)
  },)
}

/// Define point by reflection across a line
#let def-point-by-reflection(name, source, line-a, line-b, cetz-coordinate) = {
  (ctx => {
    let src = _resolve-point(ctx, source, cetz-coordinate)
    let la = _resolve-point(ctx, line-a, cetz-coordinate)
    let lb = _resolve-point(ctx, line-b, cetz-coordinate)
    let result = transform.reflection-raw(src, la, lb)

    let points = _get-points(ctx)
    points.insert(name, result)
    ctx = _set-points(ctx, points)
    (ctx: ctx)
  },)
}

/// Define point by translation
#let def-point-by-translation(name, source, vector, cetz-coordinate) = {
  (ctx => {
    let src = _resolve-point(ctx, source, cetz-coordinate)
    let vec = if type(vector) == array {
      (vector.at(0), vector.at(1), 0)
    } else {
      let v1 = _resolve-point(ctx, vector.at(0), cetz-coordinate)
      let v2 = _resolve-point(ctx, vector.at(1), cetz-coordinate)
      (v2.at(0) - v1.at(0), v2.at(1) - v1.at(1), 0)
    }
    let result = transform.translation-raw(src, vec)

    let points = _get-points(ctx)
    points.insert(name, result)
    ctx = _set-points(ctx, points)
    (ctx: ctx)
  },)
}

/// Define point by homothety (scaling from center)
#let def-point-by-homothety(name, source, center, factor, cetz-coordinate) = {
  (ctx => {
    let src = _resolve-point(ctx, source, cetz-coordinate)
    let ctr = _resolve-point(ctx, center, cetz-coordinate)
    let result = transform.homothety-raw(src, ctr, factor)

    let points = _get-points(ctx)
    points.insert(name, result)
    ctx = _set-points(ctx, points)
    (ctx: ctx)
  },)
}

/// Define point by projection onto line
#let def-point-by-projection(name, source, line-a, line-b, cetz-coordinate) = {
  (ctx => {
    let src = _resolve-point(ctx, source, cetz-coordinate)
    let la = _resolve-point(ctx, line-a, cetz-coordinate)
    let lb = _resolve-point(ctx, line-b, cetz-coordinate)
    let result = transform.projection-raw(src, la, lb)

    let points = _get-points(ctx)
    points.insert(name, result)
    ctx = _set-points(ctx, points)
    (ctx: ctx)
  },)
}

/// Global point style state key
#let _point-style-key = "tkz-point-style"

/// Set up default point style
#let set-up-point(style, cetz-draw) = {
  cetz-draw.set-ctx(ctx => {
    ctx.shared-state.insert(_point-style-key, style)
    ctx
  })
}

/// Get current point style
#let _get-point-style(ctx) = {
  ctx.shared-state.at(_point-style-key, default: draw.default-point-style)
}

/// Define a line by geometric construction (perpendicular, parallel, bisector, etc.)
#let def-line(name1, name2, construction, cetz-coordinate) = {
  (ctx => {
    let result = if construction.type == "perpendicular" {
      // Perpendicular to line through point
      let la = _resolve-point(ctx, construction.line.at(0), cetz-coordinate)
      let lb = _resolve-point(ctx, construction.line.at(1), cetz-coordinate)
      let through = _resolve-point(ctx, construction.through, cetz-coordinate)
      let foot = util.project-point-on-line(through, la, lb)
      // Line from through point, perpendicular to la-lb
      let dx = lb.at(0) - la.at(0)
      let dy = lb.at(1) - la.at(1)
      // Perpendicular direction
      let p1 = (through.at(0) - dy, through.at(1) + dx, 0)
      let p2 = (through.at(0) + dy, through.at(1) - dx, 0)
      (p1, p2)
    } else if construction.type == "parallel" {
      // Parallel to line through point
      let la = _resolve-point(ctx, construction.line.at(0), cetz-coordinate)
      let lb = _resolve-point(ctx, construction.line.at(1), cetz-coordinate)
      let through = _resolve-point(ctx, construction.through, cetz-coordinate)
      let dx = lb.at(0) - la.at(0)
      let dy = lb.at(1) - la.at(1)
      let p1 = (through.at(0) - dx, through.at(1) - dy, 0)
      let p2 = (through.at(0) + dx, through.at(1) + dy, 0)
      (p1, p2)
    } else if construction.type == "bisector" {
      // Angle bisector: vertex is middle point
      let pa = _resolve-point(ctx, construction.points.at(0), cetz-coordinate)
      let vertex = _resolve-point(ctx, construction.points.at(1), cetz-coordinate)
      let pc = _resolve-point(ctx, construction.points.at(2), cetz-coordinate)
      let bisector-pt = util.angle-bisector-point(pa, vertex, pc)

      // Extend the bisector both ways so it is visible across the figure
      let dir-x = bisector-pt.at(0) - vertex.at(0)
      let dir-y = bisector-pt.at(1) - vertex.at(1)
      let dir-len = calc.sqrt(dir-x * dir-x + dir-y * dir-y)
      let dir = if util.approx-zero(dir-len) { (1, 0) } else { (dir-x / dir-len, dir-y / dir-len) }

      let span = calc.max(util.dist(vertex, pa), util.dist(vertex, pc), 1) * 2.5
      let p1 = (vertex.at(0) - dir.at(0) * span, vertex.at(1) - dir.at(1) * span, vertex.at(2, default: 0))
      let p2 = (vertex.at(0) + dir.at(0) * span, vertex.at(1) + dir.at(1) * span, vertex.at(2, default: 0))
      (p1, p2)
    } else if construction.type == "mediator" {
      // Perpendicular bisector of segment
      let pa = _resolve-point(ctx, construction.segment.at(0), cetz-coordinate)
      let pb = _resolve-point(ctx, construction.segment.at(1), cetz-coordinate)
      let (p1, p2, mid) = util.perpendicular-bisector(pa, pb)
      (p1, p2)
    } else {
      panic("Unknown line construction type: " + construction.type)
    }

    let points = _get-points(ctx)
    points.insert(name1, result.at(0))
    points.insert(name2, result.at(1))
    ctx = _set-points(ctx, points)
    (ctx: ctx)
  },)
}

/// Create wrapper functions that have cetz modules pre-bound
#let create-api(cetz) = {
  let cetz-coordinate = cetz.coordinate
  let cetz-draw-module = cetz.draw

  // Helper to convert point name to tkz: coordinate
  let pt(name) = "tkz:" + name

  (
    init: () => init(cetz.draw),

    // Point definition
    pts: (..args) => def-points(cetz-coordinate, ..args),

    // Point name helper - converts "A" to "tkz:A"
    pt: pt,

    // Transformations
    rotate: (name, source, center, angle) => def-point-by-rotation(name, source, center, angle, cetz-coordinate),
    reflect: (name, source, line-a, line-b) => def-point-by-reflection(name, source, line-a, line-b, cetz-coordinate),
    translate: (name, source, vector) => def-point-by-translation(name, source, vector, cetz-coordinate),
    scale: (name, source, center, factor) => def-point-by-homothety(name, source, center, factor, cetz-coordinate),
    project: (name, source, line-a, line-b) => def-point-by-projection(name, source, line-a, line-b, cetz-coordinate),
    symmetry: (name, source, center) => def-symmetry(name, source, center, cetz-coordinate),
    inversion: (name, source, center, radius) => def-inversion(name, source, center, radius, cetz-coordinate),

    // Line constructions
    perp: (name1, name2, line, through) => def-line(name1, name2, (type: "perpendicular", line: line, through: through), cetz-coordinate),
    para: (name1, name2, line, through) => def-line(name1, name2, (type: "parallel", line: line, through: through), cetz-coordinate),
    bisect: (name1, name2, a, vertex, c) => def-line(name1, name2, (type: "bisector", points: (a, vertex, c)), cetz-coordinate),
    mediator: (name1, name2, a, b) => def-line(name1, name2, (type: "mediator", segment: (a, b)), cetz-coordinate),

    // Intersections
    ll: (name, line1, line2, ray: true) => inter-ll(name, line1, line2, ray: ray, cetz-coordinate),
    lc: (result-names, line, circle, near: none) => inter-lc(result-names, line, circle, near: near, cetz-coordinate),
    cc: (result-names, circle1, circle2) => inter-cc(result-names, circle1, circle2, cetz-coordinate),

    // Triangle centers - basic
    centroid: (name, a, b, c) => centroid(name, a, b, c, cetz-coordinate),
    circumcenter: (name, a, b, c) => circumcenter(name, a, b, c, cetz-coordinate),
    incenter: (name, a, b, c) => incenter(name, a, b, c, cetz-coordinate),
    orthocenter: (name, a, b, c) => orthocenter(name, a, b, c, cetz-coordinate),

    // Triangle centers - extended
    euler: (name, a, b, c) => euler-center(name, a, b, c, cetz-coordinate),
    lemoine: (name, a, b, c) => lemoine(name, a, b, c, cetz-coordinate),
    nagel: (name, a, b, c) => nagel(name, a, b, c, cetz-coordinate),
    gergonne: (name, a, b, c) => gergonne(name, a, b, c, cetz-coordinate),
    spieker: (name, a, b, c) => spieker(name, a, b, c, cetz-coordinate),
    feuerbach: (name, a, b, c) => feuerbach(name, a, b, c, cetz-coordinate),
    mittenpunkt: (name, a, b, c) => mittenpunkt(name, a, b, c, cetz-coordinate),
    excenter: (name, a, b, c, vertex: "a") => excenter(name, a, b, c, vertex: vertex, cetz-coordinate),

    // Special triangles
    medial: (na, nb, nc, a, b, c) => medial-triangle(na, nb, nc, a, b, c, cetz-coordinate),
    orthic: (na, nb, nc, a, b, c) => orthic-triangle(na, nb, nc, a, b, c, cetz-coordinate),
    intouch: (na, nb, nc, a, b, c) => intouch-triangle(na, nb, nc, a, b, c, cetz-coordinate),

    // Point constructions
    midpoint: (name, a, b) => def-midpoint(name, a, b, cetz-coordinate),
    equilateral: (name, a, b) => def-equilateral(name, a, b, cetz-coordinate),
    square: (nc, nd, a, b) => def-square(nc, nd, a, b, cetz-coordinate),
    golden: (name, a, b) => def-golden-ratio(name, a, b, cetz-coordinate),
    barycentric: (name, a, b, c, wa, wb, wc) => def-barycentric(name, a, b, c, wa, wb, wc, cetz-coordinate),
    "point-on-circle": (name, center, radius, angle) => def-point-on-circle(name, center, radius, angle, cetz-coordinate),
    "regular-polygon": (names, center, first) => def-regular-polygon(names, center, first, cetz-coordinate),
    linear: (name, a, b, k) => def-linear(name, a, b, k, cetz-coordinate),

    // Tangent constructions
    "tangent-from": (n1, n2, ext, center, radius) => def-tangent-from(n1, n2, ext, center, radius, cetz-coordinate),
    "tangent-at": (n1, n2, pt, center) => def-tangent-at(n1, n2, pt, center, cetz-coordinate),
    "radical-axis": (n1, n2, c1, r1, c2, r2) => def-radical-axis(n1, n2, c1, r1, c2, r2, cetz-coordinate),

    // Point styling
    set-up-point: (style) => set-up-point(style, cetz-draw-module),

    // Drawing - basic
    style: (..style) => drawing.set-style(cetz-draw-module, ..style),
    points: (..names) => drawing.draw-points-styled(cetz-draw-module, pt, ..names),
    labels: (..args) => drawing.label-points-styled(cetz-draw-module, pt, ..args),
    angle: (vertex, a, b, ..opts) => drawing.mark-angle(cetz-draw-module, cetz.angle, pt(vertex), pt(a), pt(b), ..opts),

    // Drawing - polygons and segments
    polygon: (..args) => drawing.draw-polygon(cetz-draw-module, pt, ..args),
    "fill-polygon": (..args) => drawing.fill-polygon(cetz-draw-module, pt, ..args),
    segment: (a, b, ..opts) => drawing.draw-segment(cetz-draw-module, pt, a, b, ..opts),
    "line-add": (a, b, ..opts) => drawing.draw-line-add(cetz-draw-module, pt, a, b, ..opts),

    // Drawing - arcs and circles
    arc: (center, start, end, ..opts) => drawing.draw-arc-through(cetz-draw-module, pt, center, start, end, ..opts),
    "arc-r": (center, radius, start-angle, end-angle, ..opts) => drawing.draw-arc-r(cetz-draw-module, center, radius, start-angle, end-angle, ..opts),
    "circle-r": (center, radius, ..opts) => drawing.draw-circle-r(cetz-draw-module, center, radius, ..opts),
    "circle-through": (center, through, ..opts) => drawing.draw-circle-through(cetz-draw-module, pt, center, through, ..opts),
    "circle-diameter": (a, b, ..opts) => drawing.draw-circle-diameter(cetz-draw-module, pt, a, b, ..opts),
    circumcircle: (a, b, c, ..opts) => drawing.draw-circumcircle(cetz-draw-module, pt, a, b, c, ..opts),
    incircle: (a, b, c, ..opts) => drawing.draw-incircle(cetz-draw-module, pt, a, b, c, ..opts),
    semicircle: (a, b, ..opts) => drawing.draw-semicircle(cetz-draw-module, pt, a, b, ..opts),
    sector: (center, start, end, ..opts) => drawing.draw-sector(cetz-draw-module, pt, center, start, end, ..opts),

    // Marking
    "mark-segment": (a, b, ..opts) => drawing.mark-segment(cetz-draw-module, pt, a, b, ..opts),
    "mark-right-angle": (a, vertex, c, ..opts) => drawing.mark-right-angle(cetz-draw-module, pt, a, vertex, c, ..opts),
    "fill-angle": (vertex, a, c, ..opts) => drawing.fill-angle(cetz-draw-module, cetz.angle, pt, vertex, a, c, ..opts),
    "label-segment": (a, b, ..opts) => drawing.label-segment(cetz-draw-module, pt, a, b, ..opts),
    "label-angle": (vertex, a, c, ..opts) => drawing.label-angle-at(cetz-draw-module, pt, vertex, a, c, ..opts),

    // Calculations (return values, not ctx operations)
    calc: (
      length: (a, b) => (ctx => {
        let pa = _resolve-point(ctx, a, cetz-coordinate)
        let pb = _resolve-point(ctx, b, cetz-coordinate)
        (ctx: ctx, value: util.dist(pa, pb))
      },),
      angle: (a, b, c) => (ctx => {
        let pa = _resolve-point(ctx, a, cetz-coordinate)
        let pb = _resolve-point(ctx, b, cetz-coordinate)
        let pc = _resolve-point(ctx, c, cetz-coordinate)
        (ctx: ctx, value: util.angle-at-vertex(pa, pb, pc))
      },),
      area: (a, b, c) => (ctx => {
        let pa = _resolve-point(ctx, a, cetz-coordinate)
        let pb = _resolve-point(ctx, b, cetz-coordinate)
        let pc = _resolve-point(ctx, c, cetz-coordinate)
        (ctx: ctx, value: util.triangle-area(pa, pb, pc))
      },),
      slope: (a, b) => (ctx => {
        let pa = _resolve-point(ctx, a, cetz-coordinate)
        let pb = _resolve-point(ctx, b, cetz-coordinate)
        (ctx: ctx, value: util.slope-angle(pa, pb))
      },),
      ratio: (a, b, c) => (ctx => {
        let pa = _resolve-point(ctx, a, cetz-coordinate)
        let pb = _resolve-point(ctx, b, cetz-coordinate)
        let pc = _resolve-point(ctx, c, cetz-coordinate)
        (ctx: ctx, value: util.ratio(pa, pb, pc))
      },),
    ),

    // Grid and Axes
    grid: (..opts) => drawing.draw-grid(cetz-draw-module, ..opts),
    axes: (..opts) => drawing.draw-axes(cetz-draw-module, ..opts),
    "axis-x": (..opts) => drawing.draw-axis-x(cetz-draw-module, ..opts),
    "axis-y": (..opts) => drawing.draw-axis-y(cetz-draw-module, ..opts),
    hline: (y, ..opts) => drawing.draw-hline(cetz-draw-module, y, ..opts),
    vline: (x, ..opts) => drawing.draw-vline(cetz-draw-module, x, ..opts),
    text: (x, y, content, ..opts) => drawing.draw-text(cetz-draw-module, x, y, content, ..opts),

    // Global clipping - set once, apply to all lines
    "set-clip": (xmin, ymin, xmax, ymax) => drawing.set-clip-region(cetz-draw-module, xmin, ymin, xmax, ymax),
    "clear-clip": () => drawing.clear-clip-region(cetz-draw-module),
    "show-clip": (stroke: gray + 0.5pt) => drawing.draw-global-clip-boundary(cetz-draw-module, stroke: stroke),
    // Lines that automatically use global clip if set
    "line": (a, b, add: (10, 10), stroke: black) => drawing.draw-line-global-clip(cetz-draw-module, pt, a, b, add: add, stroke: stroke),
    "seg": (a, b, stroke: black) => drawing.draw-segment-global-clip(cetz-draw-module, pt, a, b, stroke: stroke),

    // Manual clipping - specify bounds per line
    "clipped-line": (p1, p2, xmin, ymin, xmax, ymax, stroke: black) => drawing.draw-clipped-line(cetz-draw-module, p1, p2, xmin, ymin, xmax, ymax, stroke: stroke),
    "clipped-line-add": (a, b, xmin, ymin, xmax, ymax, add: (10, 10), stroke: black) => drawing.draw-clipped-line-add(cetz-draw-module, pt, a, b, xmin, ymin, xmax, ymax, add: add, stroke: stroke),
    "clip-boundary": (xmin, ymin, xmax, ymax, stroke: black + 0.5pt) => drawing.draw-clip-boundary(cetz-draw-module, xmin, ymin, xmax, ymax, stroke: stroke),
    // Raw clipping algorithm
    "clip-line-to-rect": drawing.clip-line-to-rect,

    // Raw algorithms
    raw: (
      // Intersections
      line-line: intersection.line-line-raw,
      line-circle: intersection.line-circle-raw,
      circle-circle: intersection.circle-circle-raw,
      // Triangle centers
      centroid: triangle.centroid-raw,
      circumcenter: triangle.circumcenter-raw,
      incenter: triangle.incenter-raw,
      orthocenter: triangle.orthocenter-raw,
      inradius: triangle.inradius-raw,
      circumradius: triangle.circumradius-raw,
      euler-center: triangle.euler-center-raw,
      euler-radius: triangle.euler-radius-raw,
      lemoine: triangle.lemoine-raw,
      nagel: triangle.nagel-raw,
      gergonne: triangle.gergonne-raw,
      spieker: triangle.spieker-raw,
      feuerbach: triangle.feuerbach-raw,
      mittenpunkt: triangle.mittenpunkt-raw,
      excenter: triangle.excenter-raw,
      exradius: triangle.exradius-raw,
      // Special triangles
      medial-triangle: triangle.medial-triangle-raw,
      orthic-triangle: triangle.orthic-triangle-raw,
      intouch-triangle: triangle.intouch-triangle-raw,
      excentral-triangle: triangle.excentral-triangle-raw,
      tangential-triangle: triangle.tangential-triangle-raw,
      // Transformations
      rotation: transform.rotation-raw,
      reflection: transform.reflection-raw,
      translation: transform.translation-raw,
      homothety: transform.homothety-raw,
      projection: transform.projection-raw,
      point-on-circle: transform.point-on-circle-raw,
      // Circle definitions
      circle-through: circle.circle-through-raw,
      circle-diameter: circle.circle-diameter-raw,
      circle-circum: circle.circle-circum-raw,
      circle-in: circle.circle-in-raw,
      circle-ex: circle.circle-ex-raw,
      circle-euler: circle.circle-euler-raw,
      tangent-from: circle.tangent-from-point-raw,
      tangent-at: circle.tangent-at-point-raw,
      radical-axis: circle.radical-axis-raw,
      apollonius: circle.apollonius-circle-raw,
      // Utility calculations
      midpoint: util.midpoint,
      dist: util.dist,
      angle-at-vertex: util.angle-at-vertex,
      slope-angle: util.slope-angle,
      triangle-area: util.triangle-area,
      polygon-area: util.polygon-area,
      equilateral-point: util.equilateral-point,
      square-points: util.square-points,
      golden-ratio-point: util.golden-ratio-point,
      barycentric-point: util.barycentric-point,
      regular-polygon-vertices: util.regular-polygon-vertices,
      central-symmetry: util.central-symmetry,
      circle-inversion: util.circle-inversion,
    ),

    // Utility functions
    util: util,

    // Drawing helpers
    draw: draw,
    drawing: drawing,
    circle: circle,
    triangle: triangle,
  )
}

// Re-export utility functions
#let midpoint = util.midpoint
#let dist = util.dist
#let angle-to = util.angle-to
#let project-point-on-line = util.project-point-on-line
#let rotate-point = util.rotate-point
