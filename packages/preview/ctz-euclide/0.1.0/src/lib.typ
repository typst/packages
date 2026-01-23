// ctz-euclide/src/lib.typ
// Main entry point for ctz-euclide Typst package
//
// A port of the LaTeX tkz-euclide package for Euclidean geometry
// Uses cetz as the drawing backend

#import "@preview/cetz:0.4.2" as cetz

#import "util.typ"
#import "point.typ"
#import "intersection.typ"
#import "triangle.typ"
#import "transform.typ"
#import "draw.typ"
#import "drawing.typ"
#import "circle.typ"

/// Package version
#let _version = (0, 1, 0)

// Re-export cetz canvas for convenience
#let _canvas = cetz.canvas

/// Internal key for storing points in shared-state
#let _points-key = "ctz-points"
/// Internal key for storing named lines in shared-state
#let _lines-key = "ctz-lines"
/// Internal key for storing named circles in shared-state
#let _circles-key = "ctz-circles"
/// Internal key for storing named polygons in shared-state
#let _polygons-key = "ctz-polygons"

/// Get all stored points from context
#let _get-points(ctx) = {
  ctx.shared-state.at(_points-key, default: (:))
}

/// Store points in context
#let _set-points(ctx, points) = {
  ctx.shared-state.insert(_points-key, points)
  ctx
}

/// Get all stored lines from context
#let _get-lines(ctx) = {
  ctx.shared-state.at(_lines-key, default: (:))
}

/// Store lines in context
#let _set-lines(ctx, lines) = {
  ctx.shared-state.insert(_lines-key, lines)
  ctx
}

/// Get all stored circles from context
#let _get-circles(ctx) = {
  ctx.shared-state.at(_circles-key, default: (:))
}

/// Store circles in context
#let _set-circles(ctx, circles) = {
  ctx.shared-state.insert(_circles-key, circles)
  ctx
}

/// Get all stored polygons from context
#let _get-polygons(ctx) = {
  ctx.shared-state.at(_polygons-key, default: (:))
}

/// Store polygons in context
#let _set-polygons(ctx, polygons) = {
  ctx.shared-state.insert(_polygons-key, polygons)
  ctx
}

/// Get the object type for a given name
/// Returns "point", "line", "circle", "polygon", or none
#let _get-object-type(ctx, name) = {
  let found-types = ()

  if name in _get-points(ctx) {
    found-types.push("point")
  }
  if name in _get-lines(ctx) {
    found-types.push("line")
  }
  if name in _get-circles(ctx) {
    found-types.push("circle")
  }
  if name in _get-polygons(ctx) {
    found-types.push("polygon")
  }

  if found-types.len() == 0 {
    return none
  } else if found-types.len() > 1 {
    panic("Ambiguous object '" + name + "' exists as both " + found-types.at(0) + " and " + found-types.at(1) + ". Use unique names.")
  } else {
    return found-types.at(0)
  }
}

/// Custom coordinate resolver - accepts both "A" and "ctz:A" syntax
#let _ctz-coordinate-resolver(ctx, c) = {
  if type(c) == str {
    let points = _get-points(ctx)
    // Try with "ctz:" prefix first
    if c.starts-with("ctz:") {
      let name = c.slice(4)
      if name in points {
        return points.at(name)
      }
    }
    // Try direct name lookup (e.g., "A" instead of "ctz:A")
    if c in points {
      return points.at(c)
    }
  }
  c
}

/// Initialize ctz-euclide in a cetz canvas
/// Must be called at the start of canvas body
#let _init() = {
  cetz.draw.set-ctx(ctx => {
    // Initialize shared state for point storage
    if _points-key not in ctx.shared-state {
      ctx.shared-state.insert(_points-key, (:))
    }
    if _lines-key not in ctx.shared-state {
      ctx.shared-state.insert(_lines-key, (:))
    }
    if _circles-key not in ctx.shared-state {
      ctx.shared-state.insert(_circles-key, (:))
    }
    if _polygons-key not in ctx.shared-state {
      ctx.shared-state.insert(_polygons-key, (:))
    }
    // Register coordinate resolver if not already done
    if type(ctx.resolve-coordinate) != array {
      ctx.resolve-coordinate = ()
    }
    if _ctz-coordinate-resolver not in ctx.resolve-coordinate {
      ctx.resolve-coordinate.push(_ctz-coordinate-resolver)
    }
    ctx
  })
}

/// Resolve a point reference to coordinates (internal helper)
#let _resolve-point(ctx, p) = {
  if type(p) == str {
    // Check if it's a ctz point name
    let points = _get-points(ctx)
    if p in points {
      return points.at(p)
    }
    // Try to strip "ctz:" prefix
    if p.starts-with("ctz:") {
      let name = p.slice(4)
      if name in points {
        return points.at(name)
      }
    }
    // Fall back to cetz coordinate resolution
    let (_, _pt) = cetz.coordinate.resolve(ctx, p)
    return _pt
  } else if type(p) == array {
    if p.len() >= 2 and p.len() <= 3 and p.all(x => type(x) in (int, float)) {
      return if p.len() == 2 { (p.at(0), p.at(1), 0) } else { p }
    }
    let (_, _pt) = cetz.coordinate.resolve(ctx, p)
    return _pt
  } else if type(p) == dictionary {
    let (_, _pt) = cetz.coordinate.resolve(ctx, p)
    return _pt
  }
  panic("Cannot resolve point: " + repr(p))
}

/// Helper to convert point name to ctz: coordinate (or pass through raw coordinates)
#let _pt(name) = {
  if type(name) == str {
    "ctz:" + name
  } else {
    // Raw coordinate tuple - pass through
    name
  }
}

/// Define multiple points at once
#let _pts(..points) = {
  let pairs = if points.named() != (:) {
    points.named().pairs()
  } else {
    let pos = points.pos()
    assert(calc.rem(pos.len(), 2) == 0,
      message: "ctz-pts requires name-coordinate pairs")
    range(0, pos.len(), step: 2).map(i => (pos.at(i), pos.at(i + 1)))
  }

  (ctx => {
    for (name, coord) in pairs {
      let _pt = if type(coord) == array and coord.len() >= 2 and coord.len() <= 3 and coord.all(x => type(x) in (int, float, length)) {
        let resolve-num(v) = if type(v) == length { v / 1cm } else { v }
        let x = resolve-num(coord.at(0))
        let y = resolve-num(coord.at(1))
        let z = if coord.len() > 2 { resolve-num(coord.at(2)) } else { 0 }
        (x, y, z)
      } else {
        let (ctx2, resolved) = cetz.coordinate.resolve(ctx, coord)
        ctx = ctx2
        resolved
      }

      let stored = _get-points(ctx)
      stored.insert(name, _pt)
      ctx = _set-points(ctx, stored)
    }
    (ctx: ctx)
  },)
}

/// Parse line specification (name or pair of points)
#let _parse-line(ctx, line-spec) = {
  if type(line-spec) == str {
    let lines = _get-lines(ctx)
    if line-spec in lines {
      return lines.at(line-spec)
    }
    panic("Line '" + line-spec + "' not found")
  } else if type(line-spec) == array and line-spec.len() == 2 {
    let p1 = _resolve-point(ctx, line-spec.at(0))
    let p2 = _resolve-point(ctx, line-spec.at(1))
    return (p1, p2)
  }
  panic("Invalid line specification: " + repr(line-spec))
}

/// Line-line intersection
#let _ll(name, line1, line2, ray: true) = {
  (ctx => {
    let (p1, p2) = _parse-line(ctx, line1)
    let (p3, p4) = _parse-line(ctx, line2)

    let result = intersection.line-line-raw(p1, p2, p3, p4, ray: ray)
    assert(result != none, message: "Lines are parallel, no intersection found")

    let points = _get-points(ctx)
    points.insert(name, result)
    ctx = _set-points(ctx, points)

    (ctx: ctx)
  },)
}

/// Parse circle specification
#let _parse-circle(ctx, circle-spec) = {
  if type(circle-spec) == str {
    let circles = _get-circles(ctx)
    if circle-spec in circles {
      let c = circles.at(circle-spec)
      return (c.center, c.radius)
    }
    panic("Circle '" + circle-spec + "' not found")
  } else if type(circle-spec) == dictionary {
    let center = _resolve-point(ctx, circle-spec.center)
    let radius = if "radius" in circle-spec {
      if type(circle-spec.radius) == length { circle-spec.radius / 1cm } else { circle-spec.radius }
    } else if "through" in circle-spec {
      let _pt = _resolve-point(ctx, circle-spec.through)
      util.dist(center, _pt)
    } else {
      panic("Circle needs radius or through point")
    }
    (center, radius)
  } else if type(circle-spec) == array and circle-spec.len() == 2 {
    let center = _resolve-point(ctx, circle-spec.at(0))
    let _pt = _resolve-point(ctx, circle-spec.at(1))
    (center, util.dist(center, _pt))
  } else {
    panic("Invalid circle specification: " + repr(circle-spec))
  }
}

/// Line-circle intersection
#let _lc(result-names, line, circle-spec, near: none) = {
  (ctx => {
    let (la, lb) = _parse-line(ctx, line)
    let (center, radius) = _parse-circle(ctx, circle-spec)

    let results = intersection.line-circle-raw(la, lb, center, radius)

    if near != none and results.len() > 1 {
      let near-pt = _resolve-point(ctx, near)
      results = results.sorted(key: _pt => util.dist-sq(near-pt, _pt))
    }

    let names = if type(result-names) == str { (result-names,) } else { result-names }
    let points = _get-points(ctx)
    for (i, _pt-name) in names.enumerate() {
      if i < results.len() {
        points.insert(_pt-name, results.at(i))
      }
    }
    ctx = _set-points(ctx, points)

    (ctx: ctx)
  },)
}

/// Circle-circle intersection
#let _cc(result-names, circle1, circle2) = {
  (ctx => {
    let (c0, r0) = _parse-circle(ctx, circle1)
    let (c1, r1) = _parse-circle(ctx, circle2)

    let results = intersection.circle-circle-raw(c0, r0, c1, r1)

    let names = if type(result-names) == str { (result-names,) } else { result-names }
    let points = _get-points(ctx)
    for (i, _pt-name) in names.enumerate() {
      if i < results.len() {
        points.insert(_pt-name, results.at(i))
      }
    }
    ctx = _set-points(ctx, points)

    (ctx: ctx)
  },)
}

/// Define a named line from two points
#let _def-line-name(name, a, b) = {
  (ctx => {
    let p1 = _resolve-point(ctx, a)
    let p2 = _resolve-point(ctx, b)
    let lines = _get-lines(ctx)
    lines.insert(name, (p1, p2))
    ctx = _set-lines(ctx, lines)
    (ctx: ctx)
  },)
}

/// Define a named circle by center and radius/through point
#let _def-circle(name, center, radius: auto, through: none) = {
  (ctx => {
    let c = _resolve-point(ctx, center)
    let r = if radius != auto {
      if type(radius) == length { radius / 1cm } else { radius }
    } else if through != none {
      let p = _resolve-point(ctx, through)
      util.dist(c, p)
    } else {
      panic("Circle needs radius or through point")
    }

    let circles = _get-circles(ctx)
    circles.insert(name, (center: c, radius: r))
    ctx = _set-circles(ctx, circles)
    (ctx: ctx)
  },)
}

/// Define a named polygon from ordered points
#let _def-polygon(name, ..points) = {
  let pts = points.pos()
  if pts.len() < 3 {
    panic("Polygon needs at least three points")
  }
  (ctx => {
    let polygons = _get-polygons(ctx)
    polygons.insert(name, pts)
    ctx = _set-polygons(ctx, polygons)
    (ctx: ctx)
  },)
}

/// Triangle centroid
#let _centroid(name, a, b, c) = {
  (ctx => {
    let pa = _resolve-point(ctx, a)
    let pb = _resolve-point(ctx, b)
    let pc = _resolve-point(ctx, c)
    let center = triangle.centroid-raw(pa, pb, pc)

    let points = _get-points(ctx)
    points.insert(name, center)
    ctx = _set-points(ctx, points)
    (ctx: ctx)
  },)
}

/// Triangle circumcenter
#let _circumcenter(name, a, b, c) = {
  (ctx => {
    let pa = _resolve-point(ctx, a)
    let pb = _resolve-point(ctx, b)
    let pc = _resolve-point(ctx, c)
    let center = triangle.circumcenter-raw(pa, pb, pc)

    let points = _get-points(ctx)
    points.insert(name, center)
    ctx = _set-points(ctx, points)
    (ctx: ctx)
  },)
}

/// Triangle incenter
#let _incenter(name, a, b, c) = {
  (ctx => {
    let pa = _resolve-point(ctx, a)
    let pb = _resolve-point(ctx, b)
    let pc = _resolve-point(ctx, c)
    let center = triangle.incenter-raw(pa, pb, pc)

    let points = _get-points(ctx)
    points.insert(name, center)
    ctx = _set-points(ctx, points)
    (ctx: ctx)
  },)
}

/// Triangle orthocenter
#let _orthocenter(name, a, b, c) = {
  (ctx => {
    let pa = _resolve-point(ctx, a)
    let pb = _resolve-point(ctx, b)
    let pc = _resolve-point(ctx, c)
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
#let _euler(name, a, b, c) = {
  (ctx => {
    let pa = _resolve-point(ctx, a)
    let pb = _resolve-point(ctx, b)
    let pc = _resolve-point(ctx, c)
    let center = triangle.euler-center-raw(pa, pb, pc)
    let points = _get-points(ctx)
    points.insert(name, center)
    ctx = _set-points(ctx, points)
    (ctx: ctx)
  },)
}

/// Lemoine point (symmedian point)
#let _lemoine(name, a, b, c) = {
  (ctx => {
    let pa = _resolve-point(ctx, a)
    let pb = _resolve-point(ctx, b)
    let pc = _resolve-point(ctx, c)
    let center = triangle.lemoine-raw(pa, pb, pc)
    let points = _get-points(ctx)
    points.insert(name, center)
    ctx = _set-points(ctx, points)
    (ctx: ctx)
  },)
}

/// Nagel point
#let _nagel(name, a, b, c) = {
  (ctx => {
    let pa = _resolve-point(ctx, a)
    let pb = _resolve-point(ctx, b)
    let pc = _resolve-point(ctx, c)
    let center = triangle.nagel-raw(pa, pb, pc)
    let points = _get-points(ctx)
    points.insert(name, center)
    ctx = _set-points(ctx, points)
    (ctx: ctx)
  },)
}

/// Gergonne point
#let _gergonne(name, a, b, c) = {
  (ctx => {
    let pa = _resolve-point(ctx, a)
    let pb = _resolve-point(ctx, b)
    let pc = _resolve-point(ctx, c)
    let center = triangle.gergonne-raw(pa, pb, pc)
    let points = _get-points(ctx)
    points.insert(name, center)
    ctx = _set-points(ctx, points)
    (ctx: ctx)
  },)
}

/// Spieker center
#let _spieker(name, a, b, c) = {
  (ctx => {
    let pa = _resolve-point(ctx, a)
    let pb = _resolve-point(ctx, b)
    let pc = _resolve-point(ctx, c)
    let center = triangle.spieker-raw(pa, pb, pc)
    let points = _get-points(ctx)
    points.insert(name, center)
    ctx = _set-points(ctx, points)
    (ctx: ctx)
  },)
}

/// Feuerbach point
#let _feuerbach(name, a, b, c) = {
  (ctx => {
    let pa = _resolve-point(ctx, a)
    let pb = _resolve-point(ctx, b)
    let pc = _resolve-point(ctx, c)
    let center = triangle.feuerbach-raw(pa, pb, pc)
    let points = _get-points(ctx)
    points.insert(name, center)
    ctx = _set-points(ctx, points)
    (ctx: ctx)
  },)
}

/// Mittenpunkt
#let _mittenpunkt(name, a, b, c) = {
  (ctx => {
    let pa = _resolve-point(ctx, a)
    let pb = _resolve-point(ctx, b)
    let pc = _resolve-point(ctx, c)
    let center = triangle.mittenpunkt-raw(pa, pb, pc)
    let points = _get-points(ctx)
    points.insert(name, center)
    ctx = _set-points(ctx, points)
    (ctx: ctx)
  },)
}

/// Excenter (opposite to specified vertex)
#let _excenter(name, a, b, c, vertex: "a") = {
  (ctx => {
    let pa = _resolve-point(ctx, a)
    let pb = _resolve-point(ctx, b)
    let pc = _resolve-point(ctx, c)
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
#let _medial(name-a, name-b, name-c, a, b, c) = {
  (ctx => {
    let pa = _resolve-point(ctx, a)
    let pb = _resolve-point(ctx, b)
    let pc = _resolve-point(ctx, c)
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
#let _orthic(name-a, name-b, name-c, a, b, c) = {
  (ctx => {
    let pa = _resolve-point(ctx, a)
    let pb = _resolve-point(ctx, b)
    let pc = _resolve-point(ctx, c)
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
#let _intouch(name-a, name-b, name-c, a, b, c) = {
  (ctx => {
    let pa = _resolve-point(ctx, a)
    let pb = _resolve-point(ctx, b)
    let pc = _resolve-point(ctx, c)
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
#let _midpoint(name, a, b) = {
  (ctx => {
    let pa = _resolve-point(ctx, a)
    let pb = _resolve-point(ctx, b)
    let mid = util.midpoint(pa, pb)
    let points = _get-points(ctx)
    points.insert(name, mid)
    ctx = _set-points(ctx, points)
    (ctx: ctx)
  },)
}

/// Define equilateral triangle third point
#let _equilateral(name, a, b) = {
  (ctx => {
    let pa = _resolve-point(ctx, a)
    let pb = _resolve-point(ctx, b)
    let pc = util.equilateral-point(pa, pb)
    let points = _get-points(ctx)
    points.insert(name, pc)
    ctx = _set-points(ctx, points)
    (ctx: ctx)
  },)
}

/// Define square third and fourth points
#let _square(name-c, name-d, a, b) = {
  (ctx => {
    let pa = _resolve-point(ctx, a)
    let pb = _resolve-point(ctx, b)
    let (pc, pd) = util.square-points(pa, pb)
    let points = _get-points(ctx)
    points.insert(name-c, pc)
    points.insert(name-d, pd)
    ctx = _set-points(ctx, points)
    (ctx: ctx)
  },)
}

/// Define golden ratio point
#let _golden(name, a, b) = {
  (ctx => {
    let pa = _resolve-point(ctx, a)
    let pb = _resolve-point(ctx, b)
    let pc = util.golden-ratio-point(pa, pb)
    let points = _get-points(ctx)
    points.insert(name, pc)
    ctx = _set-points(ctx, points)
    (ctx: ctx)
  },)
}

/// Define Thales triangle (right triangle inscribed in circle)
/// Creates three points where the right angle is at name-c
#let _thales-triangle(name-a, name-b, name-c, center, radius, base-angle: 0, orientation: "left") = {
  (ctx => {
    // Resolve center
    let c = _resolve-point(ctx, center)
    let r = if type(radius) == length {
      radius / 1cm
    } else {
      radius
    }

    // Calculate angles for three vertices
    let angle-a = base-angle
    let angle-b = base-angle + 180
    let angle-c = if orientation == "left" {
      base-angle + 90
    } else {
      base-angle - 90
    }

    // Calculate point positions using point-on-circle from transform.typ
    let pa = transform.point-on-circle-raw(c, r, angle-a)
    let pb = transform.point-on-circle-raw(c, r, angle-b)
    let pc = transform.point-on-circle-raw(c, r, angle-c)

    // Store all three points
    let points = _get-points(ctx)
    points.insert(name-a, pa)
    points.insert(name-b, pb)
    points.insert(name-c, pc)
    ctx = _set-points(ctx, points)

    (ctx: ctx)
  },)
}

/// Define barycentric point
#let _barycentric(name, a, b, c, wa, wb, wc) = {
  (ctx => {
    let pa = _resolve-point(ctx, a)
    let pb = _resolve-point(ctx, b)
    let pc = _resolve-point(ctx, c)
    let result = util.barycentric-point(pa, pb, pc, wa, wb, wc)
    let points = _get-points(ctx)
    points.insert(name, result)
    ctx = _set-points(ctx, points)
    (ctx: ctx)
  },)
}

/// Define point on circle at angle
#let _point-on-circle(name, center, radius, angle-deg) = {
  (ctx => {
    let c = _resolve-point(ctx, center)
    let r = if type(radius) == length { radius / 1cm } else { radius }
    let result = util.point-on-circle(c, r, angle-deg)
    let points = _get-points(ctx)
    points.insert(name, result)
    ctx = _set-points(ctx, points)
    (ctx: ctx)
  },)
}

/// Define regular polygon vertices
#let _regular-polygon(..args) = {
  let pos = args.pos()
  if pos.len() < 3 {
    panic("Regular polygon needs names, center, and first vertex")
  }
  let name = none
  let names = none
  let center = none
  let first-vertex = none
  if type(pos.at(0)) == str {
    if pos.len() < 4 {
      panic("Regular polygon needs name, names, center, and first vertex")
    }
    name = pos.at(0)
    names = pos.at(1)
    center = pos.at(2)
    first-vertex = pos.at(3)
  } else {
    names = pos.at(0)
    center = pos.at(1)
    first-vertex = pos.at(2)
  }
  (ctx => {
    let c = _resolve-point(ctx, center)
    let fv = _resolve-point(ctx, first-vertex)
    let n = names.len()
    let vertices = util.regular-polygon-vertices(c, fv, n)
    let points = _get-points(ctx)
    for (i, vname) in names.enumerate() {
      points.insert(vname, vertices.at(i))
    }
    ctx = _set-points(ctx, points)
    if name != none {
      let polygons = _get-polygons(ctx)
      polygons.insert(name, names)
      ctx = _set-polygons(ctx, polygons)
    }
    (ctx: ctx)
  },)
}

/// Define linear combination point: P = A + k*(B-A)
#let _linear(name, a, b, k) = {
  (ctx => {
    let pa = _resolve-point(ctx, a)
    let pb = _resolve-point(ctx, b)
    let result = util.linear-point(pa, pb, k)
    let points = _get-points(ctx)
    points.insert(name, result)
    ctx = _set-points(ctx, points)
    (ctx: ctx)
  },)
}

/// Define central symmetry point
#let _symmetry(name, source, center) = {
  (ctx => {
    let p = _resolve-point(ctx, source)
    let c = _resolve-point(ctx, center)
    let result = util.central-symmetry(p, c)
    let points = _get-points(ctx)
    points.insert(name, result)
    ctx = _set-points(ctx, points)
    (ctx: ctx)
  },)
}

/// Define inversion of point/object through a circle (polymorphic)
#let _inversion(name, source, center, radius) = {
  (ctx => {
    let c = _resolve-point(ctx, center)
    let r = if type(radius) == length { radius / 1cm } else { radius }

    // Detect source object type
    let obj-type = _get-object-type(ctx, source)

    if obj-type == none {
      // Treat as a point
      let p = _resolve-point(ctx, source)
      let result = util.circle-inversion(p, c, r)
      let points = _get-points(ctx)
      points.insert(name, result)
      ctx = _set-points(ctx, points)
    } else if obj-type == "point" {
      let p = _resolve-point(ctx, source)
      let result = util.circle-inversion(p, c, r)
      let points = _get-points(ctx)
      points.insert(name, result)
      ctx = _set-points(ctx, points)
    } else if obj-type == "line" {
      let lines = _get-lines(ctx)
      let (p1, p2) = lines.at(source)
      let foot = util.project-point-on-line(c, p1, p2)
      let dist-to-line = util.dist(c, foot)

      if util.approx-zero(dist-to-line) {
        // Line through inversion center -> invariant
        lines.insert(name, (p1, p2))
        ctx = _set-lines(ctx, lines)
      } else {
        // Inversion of a line not through center is a circle through center
        let foot-inv = util.circle-inversion(foot, c, r)
        let mid = util.midpoint(c, foot-inv)
        let rad = util.dist(c, foot-inv) / 2
        let circles = _get-circles(ctx)
        circles.insert(name, (center: mid, radius: rad))
        ctx = _set-circles(ctx, circles)
      }
    } else if obj-type == "circle" {
      let circles = _get-circles(ctx)
      let circ = circles.at(source)
      let d = util.dist(c, circ.center)

      if util.approx-eq(d, circ.radius, epsilon: util.eps) {
        // Circle through inversion center -> line
        let dx = circ.center.at(0) - c.at(0)
        let dy = circ.center.at(1) - c.at(1)
        let far = (
          c.at(0) + 2 * dx,
          c.at(1) + 2 * dy,
          circ.center.at(2, default: 0),
        )
        let p0 = util.circle-inversion(far, c, r)
        let p1 = (p0.at(0) - dy, p0.at(1) + dx, p0.at(2, default: 0))
        let p2 = (p0.at(0) + dy, p0.at(1) - dx, p0.at(2, default: 0))
        let lines = _get-lines(ctx)
        lines.insert(name, (p1, p2))
        ctx = _set-lines(ctx, lines)
      } else {
        // Circle not through center -> circle
        let denom = d * d - circ.radius * circ.radius
        let factor = (r * r) / denom
        let new-center = (
          c.at(0) + factor * (circ.center.at(0) - c.at(0)),
          c.at(1) + factor * (circ.center.at(1) - c.at(1)),
          circ.center.at(2, default: 0),
        )
        let new-radius = calc.abs(factor) * circ.radius
        circles.insert(name, (center: new-center, radius: new-radius))
        ctx = _set-circles(ctx, circles)
      }
    } else if obj-type == "polygon" {
      let polygons = _get-polygons(ctx)
      let vertex-names = polygons.at(source)
      let points = _get-points(ctx)

      for vname in vertex-names {
        if vname not in points {
          panic("Cannot invert polygon '" + source + "': vertex point '" + vname + "' not found. All vertex points must be explicitly defined.")
        }
        let pt = points.at(vname)
        let inv-pt = util.circle-inversion(pt, c, r)
        points.insert(vname, inv-pt)
      }
      ctx = _set-points(ctx, points)
      polygons.insert(name, vertex-names)
      ctx = _set-polygons(ctx, polygons)
    }

    (ctx: ctx)
  },)
}

// =============================================================================
// TANGENT DEFINITIONS
// =============================================================================

/// Define tangent points from external point to circle
#let _tangent-from(name1, name2, external-point, center, radius) = {
  (ctx => {
    let p = _resolve-point(ctx, external-point)
    let c = _resolve-point(ctx, center)
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
#let _tangent-at(name1, name2, point-on-circle, center) = {
  (ctx => {
    let p = _resolve-point(ctx, point-on-circle)
    let c = _resolve-point(ctx, center)
    let (t1, t2) = circle.tangent-at-point-raw(p, c)
    let points = _get-points(ctx)
    points.insert(name1, t1)
    points.insert(name2, t2)
    ctx = _set-points(ctx, points)
    (ctx: ctx)
  },)
}

/// Define radical axis of two circles
#let _radical-axis(name1, name2, center1, radius1, center2, radius2) = {
  (ctx => {
    let c1 = _resolve-point(ctx, center1)
    let c2 = _resolve-point(ctx, center2)
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

/// Define point/object by rotation around a center (polymorphic)
#let _rotation(name, source, center, angle-deg) = {
  (ctx => {
    let center-pt = _resolve-point(ctx, center)

    // Detect source object type
    let obj-type = _get-object-type(ctx, source)

    if obj-type == none {
      // Try to resolve as a point reference (not in storage)
      let src = _resolve-point(ctx, source)
      let result = transform.rotation-raw(src, center-pt, angle-deg)
      let points = _get-points(ctx)
      points.insert(name, result)
      ctx = _set-points(ctx, points)
    } else if obj-type == "point" {
      // Rotate point
      let src = _resolve-point(ctx, source)
      let result = transform.rotation-raw(src, center-pt, angle-deg)
      let points = _get-points(ctx)
      points.insert(name, result)
      ctx = _set-points(ctx, points)
    } else if obj-type == "line" {
      // Rotate line (rotate both endpoints)
      let lines = _get-lines(ctx)
      let (p1, p2) = lines.at(source)
      let new-p1 = transform.rotation-raw(p1, center-pt, angle-deg)
      let new-p2 = transform.rotation-raw(p2, center-pt, angle-deg)
      lines.insert(name, (new-p1, new-p2))
      ctx = _set-lines(ctx, lines)
    } else if obj-type == "circle" {
      // Rotate circle (rotate center, keep radius)
      let circles = _get-circles(ctx)
      let c = circles.at(source)
      let new-center = transform.rotation-raw(c.center, center-pt, angle-deg)
      circles.insert(name, (center: new-center, radius: c.radius))
      ctx = _set-circles(ctx, circles)
    } else if obj-type == "polygon" {
      // Rotate polygon by rotating all vertex points
      let polygons = _get-polygons(ctx)
      let vertex-names = polygons.at(source)
      let points = _get-points(ctx)

      // Rotate each vertex point in place
      for vname in vertex-names {
        if vname not in points {
          panic("Cannot rotate polygon '" + source + "': vertex point '" + vname + "' not found. All vertex points must be explicitly defined.")
        }
        let pt = points.at(vname)
        let rotated-pt = transform.rotation-raw(pt, center-pt, angle-deg)
        points.insert(vname, rotated-pt)
      }
      ctx = _set-points(ctx, points)

      // Store rotated polygon with same vertex names
      polygons.insert(name, vertex-names)
      ctx = _set-polygons(ctx, polygons)
    }

    (ctx: ctx)
  },)
}

/// Define point by reflection across a line
#let _reflect(name, source, line-a, line-b) = {
  (ctx => {
    let src = _resolve-point(ctx, source)
    let la = _resolve-point(ctx, line-a)
    let lb = _resolve-point(ctx, line-b)
    let result = transform.reflection-raw(src, la, lb)

    let points = _get-points(ctx)
    points.insert(name, result)
    ctx = _set-points(ctx, points)
    (ctx: ctx)
  },)
}

/// Define point by translation
#let _translate(name, source, vector) = {
  (ctx => {
    let src = _resolve-point(ctx, source)
    let vec = if type(vector) == array {
      (vector.at(0), vector.at(1), 0)
    } else {
      let v1 = _resolve-point(ctx, vector.at(0))
      let v2 = _resolve-point(ctx, vector.at(1))
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
#let _homothety(name, source, center, factor) = {
  (ctx => {
    let src = _resolve-point(ctx, source)
    let ctr = _resolve-point(ctx, center)
    let result = transform.homothety-raw(src, ctr, factor)

    let points = _get-points(ctx)
    points.insert(name, result)
    ctx = _set-points(ctx, points)
    (ctx: ctx)
  },)
}

/// Define point by projection onto line
#let _project(name, source, line-a, line-b) = {
  (ctx => {
    let src = _resolve-point(ctx, source)
    let la = _resolve-point(ctx, line-a)
    let lb = _resolve-point(ctx, line-b)
    let result = transform.projection-raw(src, la, lb)

    let points = _get-points(ctx)
    points.insert(name, result)
    ctx = _set-points(ctx, points)
    (ctx: ctx)
  },)
}

/// Duplicate any geometric object
#let _duplicate(target-name, source-name, points: auto) = {
  (ctx => {
    let obj-type = _get-object-type(ctx, source-name)

    if obj-type == none {
      panic("Object '" + source-name + "' not found. Cannot duplicate.")
    } else if obj-type == "point" {
      // Duplicate point
      let pt = _resolve-point(ctx, source-name)
      let point-dict = _get-points(ctx)
      point-dict.insert(target-name, pt)
      ctx = _set-points(ctx, point-dict)
    } else if obj-type == "line" {
      // Duplicate line
      let lines = _get-lines(ctx)
      let (p1, p2) = lines.at(source-name)
      lines.insert(target-name, (p1, p2))
      ctx = _set-lines(ctx, lines)
    } else if obj-type == "circle" {
      // Duplicate circle
      let circles = _get-circles(ctx)
      let c = circles.at(source-name)
      circles.insert(target-name, (center: c.center, radius: c.radius))
      ctx = _set-circles(ctx, circles)
    } else if obj-type == "polygon" {
      // Duplicate polygon - requires explicit point names
      let polygons = _get-polygons(ctx)
      let source-points = polygons.at(source-name)

      if points == auto {
        panic("For polygon duplication, must provide explicit point names: points: (\"A2\", \"B2\", ...)")
      }

      if points.len() != source-points.len() {
        panic("Point count mismatch: source polygon has " + str(source-points.len()) + " vertices, but " + str(points.len()) + " names provided.")
      }

      // Copy each vertex with new name
      let point-dict = _get-points(ctx)
      for (i, old-name) in source-points.enumerate() {
        let pt = _resolve-point(ctx, old-name)
        let new-name = points.at(i)
        point-dict.insert(new-name, pt)
      }
      ctx = _set-points(ctx, point-dict)

      // Store new polygon with new point names
      polygons.insert(target-name, points)
      ctx = _set-polygons(ctx, polygons)
    }

    (ctx: ctx)
  },)
}

/// Global point style state key
#let _point-style-key = "ctz-point-style"

/// Set up default point style
#let _set-up-point(style-spec) = {
  cetz.draw.set-ctx(ctx => {
    ctx.shared-state.insert(_point-style-key, style-spec)
    ctx
  })
}

/// Get current point style
#let _get-point-style(ctx) = {
  ctx.shared-state.at(_point-style-key, default: draw.default-point-style)
}

/// Define a line by geometric construction (perpendicular, parallel, bisector, etc.)
#let _def-line(name1, name2, construction) = {
  (ctx => {
    let result = if construction.type == "perpendicular" {
      // Perpendicular to line through point
      let la = _resolve-point(ctx, construction.line.at(0))
      let lb = _resolve-point(ctx, construction.line.at(1))
      let through = _resolve-point(ctx, construction.through)
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
      let la = _resolve-point(ctx, construction.line.at(0))
      let lb = _resolve-point(ctx, construction.line.at(1))
      let through = _resolve-point(ctx, construction.through)
      let dx = lb.at(0) - la.at(0)
      let dy = lb.at(1) - la.at(1)
      let p1 = (through.at(0) - dx, through.at(1) - dy, 0)
      let p2 = (through.at(0) + dx, through.at(1) + dy, 0)
      (p1, p2)
    } else if construction.type == "bisector" {
      // Angle bisector: vertex is middle point
      let pa = _resolve-point(ctx, construction.points.at(0))
      let vertex = _resolve-point(ctx, construction.points.at(1))
      let pc = _resolve-point(ctx, construction.points.at(2))
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
      let pa = _resolve-point(ctx, construction.segment.at(0))
      let pb = _resolve-point(ctx, construction.segment.at(1))
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

// Line construction helpers
#let _perp(name1, name2, line, through) = _def-line(name1, name2, (type: "perpendicular", line: line, through: through))
#let _para(name1, name2, line, through) = _def-line(name1, name2, (type: "parallel", line: line, through: through))
#let _bisect(name1, name2, a, vertex, c) = _def-line(name1, name2, (type: "bisector", points: (a, vertex, c)))
#let _mediator(name1, name2, a, b) = _def-line(name1, name2, (type: "mediator", segment: (a, b)))

// =============================================================================
// DRAWING FUNCTIONS
// =============================================================================

/// Draw a polyline or named line (direct CeTZ wrapper)
#let _draw-line(..args) = {
  let pos = args.pos()
  let named = args.named()
  if pos.len() == 1 and type(pos.at(0)) == str {
    let name = pos.at(0)
    cetz.draw.get-ctx(ctx => {
      let lines = _get-lines(ctx)
      if name in lines {
        let (p1, p2) = lines.at(name)
        cetz.draw.line(p1, p2, ..named)
      } else {
        panic("Line '" + name + "' not found")
      }
    })
  } else {
    cetz.draw.line(..pos, ..named)
  }
}

/// Set point/label styling
#let _style(..style-args) = drawing.set-style(cetz.draw, ..style-args)

/// Draw points
#let _points(..names) = drawing.draw-points-styled(cetz.draw, _pt, ..names)

/// Draw labels
#let _labels(..args) = drawing.label-points-styled(cetz.draw, _pt, ..args)

/// Draw angle
#let _angle(vertex, a, b, ..opts) = drawing.mark-angle(cetz.draw, cetz.angle, _pt(vertex), _pt(a), _pt(b), ..opts)

/// Draw polygon
#let _polygon(..args) = {
  let pos = args.pos()
  let named = args.named()
  if pos.len() == 1 and type(pos.at(0)) == str {
    let name = pos.at(0)
    cetz.draw.get-ctx(ctx => {
      let polygons = _get-polygons(ctx)
      if name in polygons {
        let pts = polygons.at(name)
        drawing.draw-polygon(cetz.draw, _pt, ..pts, ..named)
      } else {
        panic("Polygon '" + name + "' not found")
      }
    })
  } else {
    drawing.draw-polygon(cetz.draw, _pt, ..pos, ..named)
  }
}

/// Draw a regular polygon by passing its vertex names
#let _draw-regular-polygon(names, ..opts) = {
  if names.len() < 3 {
    panic("Regular polygon needs at least three vertices")
  }
  let named = opts.named()
  let mark = named.at("mark", default: none)
  let mark-opts = named.at("mark-opts", default: (:))
  let draw-opts = (:)
  for (k, v) in named {
    if k not in ("mark", "mark-opts") {
      draw-opts.insert(k, v)
    }
  }

  _polygon(..names, ..draw-opts)

  if mark != none {
    let n = names.len()
    for i in range(n) {
      let a = names.at(i)
      let b = names.at(calc.rem(i + 1, n))
      drawing.mark-segment(cetz.draw, _pt, a, b, mark: mark, ..mark-opts)
    }
  }
}

/// Fill polygon
#let _fill-polygon(..args) = {
  let pos = args.pos()
  let named = args.named()
  if pos.len() == 1 and type(pos.at(0)) == str {
    let name = pos.at(0)
    cetz.draw.get-ctx(ctx => {
      let polygons = _get-polygons(ctx)
      if name in polygons {
        let pts = polygons.at(name)
        drawing.fill-polygon(cetz.draw, _pt, ..pts, ..named)
      } else {
        panic("Polygon '" + name + "' not found")
      }
    })
  } else {
    drawing.fill-polygon(cetz.draw, _pt, ..pos, ..named)
  }
}

/// Fill a regular polygon by passing its vertex names
#let _fill-regular-polygon(names, ..opts) = {
  if names.len() < 3 {
    panic("Regular polygon needs at least three vertices")
  }
  _fill-polygon(..names, ..opts)
}

/// Parse a TikZ-like path spec (e.g., "A--B->C|-|D")
#let _parse-path-spec(spec) = {
  let s = spec.trim()
  let points = ()
  let connectors = ()
  let label-placements = (:)
  let point-style-overrides = (:)
  let ops = ("<->", "|-|", "|->", "<-|", "->", "<-", "--")

  let trim-left(s) = {
    while s.len() > 0 and s.slice(0, 1).trim() == "" {
      s = s.slice(1)
    }
    s
  }

  s = trim-left(s)
  while s.len() > 0 {
    let i = 0
    let depth = 0
    while i < s.len() and (depth > 0 or s.slice(i, i + 1) not in ("-", "<", ">", "|")) {
      let ch = s.slice(i, i + 1)
      if ch == "{" { depth += 1 }
      else if ch == "}" { depth -= 1 }
      i += 1
    }
    if depth != 0 {
      panic("Unbalanced label braces in path spec: " + spec)
    }
    if i == 0 {
      panic("Expected point name in path spec: " + spec)
    }
    let token = s.slice(0, i).trim()
    if token == "" {
      panic("Empty point name in path spec: " + spec)
    }
    let name = token
    if "{" in token {
      let start = none
      for j in range(token.len()) {
        if token.slice(j, j + 1) == "{" {
          start = j
          break
        }
      }
      if start == none {
        panic("Invalid label placement in path spec: " + spec)
      }
      let end = token.len() - 1
      if not token.ends-with("}") {
        panic("Invalid label placement in path spec: " + spec)
      }
      name = token.slice(0, start).trim()
      let spec = token.slice(start + 1, end).trim()
      if name == "" {
        panic("Empty point name in path spec: " + spec)
      }
      if spec != "" {
        let pos = none
        let style = none
        let parts = spec.split(",")
        for part in parts {
          let item = part.trim()
          if item == "" { continue }
          if ":" in item {
            let key = item.split(":").at(0).trim()
            let val = item.split(":").at(1).trim()
            if val.starts-with("\"") and val.ends-with("\"") and val.len() >= 2 {
              val = val.slice(1, val.len() - 1)
            }
            if key == "pos" {
              pos = val
            } else if key == "style" or key == "point" {
              style = if val == "none" { none } else { val }
            }
          } else {
            pos = item
          }
        }
        if pos != none and pos != "" {
          label-placements.insert(name, pos)
        }
        if style != none {
          point-style-overrides.insert(name, style)
        }
      }
    }
    points.push(name)
    s = trim-left(s.slice(i))
    if s.len() == 0 { break }

    let connector = none
    for op in ops {
      if s.starts-with(op) {
        connector = op
        s = s.slice(op.len())
        break
      }
    }
    if connector == none {
      panic("Expected connector in path spec: " + spec)
    }
    connectors.push(connector)
    s = trim-left(s)
  }

  if points.len() != connectors.len() + 1 {
    panic("Invalid path spec: " + spec)
  }

  (points: points, connectors: connectors, label-placements: label-placements, point-style-overrides: point-style-overrides)
}

/// Draw a path with per-segment arrows using a TikZ-like string
#let _path(spec, ..opts) = {
  if type(spec) != str {
    panic("ctz-draw-path expects a string like \"A--B->C|-|D\"")
  }
  let parsed = _parse-path-spec(spec)
  let points = parsed.points
  let connectors = parsed.connectors
  let named = opts.named()
  let draw-points = named.at("points", default: true)
  let draw-labels = named.at("labels", default: true)
  let default-label-pos = named.at("label-pos", default: "below")
  let label-overrides = named.at("label-overrides", default: (:))
  let point-style = named.at("point-style", default: auto)
  let point-color = named.at("point-color", default: black)
  let style = (:)
  for (k, v) in named {
    if k not in ("points", "labels", "label-pos", "label-overrides", "point-style", "point-color") {
      style.insert(k, v)
    }
  }

  for i in range(points.len() - 1) {
    let arrows = connectors.at(i)
    if arrows == "--" {
      arrows = none
    }
    drawing.draw-segment(cetz.draw, _pt, points.at(i), points.at(i + 1), arrows: arrows, ..style)
  }

  if draw-points {
    let connectors-len = connectors.len()
    for i in range(points.len()) {
      let name = points.at(i)
      let has-bar = false
      if i > 0 {
        let prev = connectors.at(i - 1)
        let prev-end = if prev in ("|-|", "<-|") { "|" } else { none }
        if prev-end == "|" { has-bar = true }
      }
      if i < connectors-len {
        let next = connectors.at(i)
        let next-start = if next in ("|-|", "|->") { "|" } else { none }
        if next-start == "|" { has-bar = true }
      }

      let default-style = if has-bar { none } else { "cross" }
      let final-style = if point-style == auto { default-style } else { point-style }
      if name in parsed.point-style-overrides {
        final-style = parsed.point-style-overrides.at(name)
      }

      if final-style != none {
        drawing.draw-point(cetz.draw, _pt(name), style: final-style, color: point-color)
      }
    }
  }

  if draw-labels {
    let placements = (:)
    for name in points {
      placements.insert(name, default-label-pos)
    }
    for (k, v) in parsed.label-placements {
      placements.insert(k, v)
    }
    for (k, v) in label-overrides {
      placements.insert(k, v)
    }
    drawing.label-points-styled(cetz.draw, _pt, ..points, ..placements)
  }
}

/// Draw segment
#let _segment(a, b, ..opts) = drawing.draw-segment(cetz.draw, _pt, a, b, ..opts)

/// Draw measurement segment
#let _measure-segment(a, b, ..opts) = drawing.draw-measure-segment(cetz.draw, _pt, a, b, ..opts)

/// Draw line with extension
#let _line-add(a, b, ..opts) = drawing.draw-line-add(cetz.draw, _pt, a, b, ..opts)

/// Draw arc through points
#let _arc(center, start, end, ..opts) = drawing.draw-arc-through(cetz.draw, _pt, center, start, end, ..opts)

/// Draw arc with radius
#let _arc-r(center, radius, start-angle, end-angle, ..opts) = drawing.draw-arc-r(cetz.draw, center, radius, start-angle, end-angle, ..opts)

/// Draw circle with radius
#let _circle-r(center, radius, ..opts) = drawing.draw-circle-r(cetz.draw, center, radius, ..opts)

/// Draw circle through point
#let _circle-through(center, through, ..opts) = drawing.draw-circle-through(cetz.draw, _pt, center, through, ..opts)

/// Draw circle with diameter
#let _circle-diameter(a, b, ..opts) = drawing.draw-circle-diameter(cetz.draw, _pt, a, b, ..opts)

/// Draw a named circle
#let _draw-circle(name, ..opts) = {
  cetz.draw.get-ctx(ctx => {
    let circles = _get-circles(ctx)
    if name in circles {
      let c = circles.at(name)
      drawing.draw-circle-r(cetz.draw, c.center, c.radius, ..opts)
    } else {
      panic("Circle '" + name + "' not found")
    }
  })
}

/// Draw circumcircle
#let _circumcircle(a, b, c, ..opts) = drawing.draw-circumcircle(cetz.draw, _pt, a, b, c, ..opts)

/// Draw incircle
#let _incircle(a, b, c, ..opts) = drawing.draw-incircle(cetz.draw, _pt, a, b, c, ..opts)

/// Draw semicircle
#let _semicircle(a, b, ..opts) = drawing.draw-semicircle(cetz.draw, _pt, a, b, ..opts)

/// Fully polymorphic draw function - draws named objects or unnamed constructs
///
/// Named objects:
///   ctz-draw("C1", stroke: blue)
///
/// Unnamed constructs via named parameters:
///   ctz-draw(path: "A--B--C", stroke: black)
///   ctz-draw(line: ("A", "B", "C"), stroke: red)
///   ctz-draw(points: ("A", "B", "C"))                              // Draw multiple points
///   ctz-draw(points: ("A", "B", "C"), labels: true)               // Draw points with labels
///   ctz-draw(points: ("A", "B", "C"), labels: (A: "top"))        // Custom label positions
///   ctz-draw(circle-through: ("O", "A"), stroke: blue)
///   ctz-draw(circle-r: ((0, 0), 2), stroke: green)
///   ctz-draw(circle-diameter: ("A", "B"), stroke: purple)
///   ctz-draw(circumcircle: ("A", "B", "C"), stroke: blue)
///   ctz-draw(incircle: ("A", "B", "C"), stroke: red)
///   ctz-draw(arc: (center: "O", start: "A", end: "B"), stroke: black)
///   ctz-draw(arc-r: ((0, 0), 2, 0, 90), stroke: black)
///   ctz-draw(semicircle: ("A", "B"), stroke: blue)
///   ctz-draw(segment: ("A", "B"), stroke: black)
#let _polymorphic-draw(..args) = {
  let pos = args.pos()
  let named = args.named()

  // Case 1: Named object (first positional arg is string)
  if pos.len() > 0 and type(pos.at(0)) == str {
    let name = pos.at(0)
    cetz.draw.get-ctx(ctx => {
      let obj-type = _get-object-type(ctx, name)

      if obj-type == none {
        panic("Object '" + name + "' not found. No point, line, circle, or polygon with this name exists.")
      } else if obj-type == "circle" {
        _draw-circle(name, ..named)
      } else if obj-type == "line" {
        _draw-line(name, ..named)
      } else if obj-type == "polygon" {
        _polygon(name, ..named)
      } else if obj-type == "point" {
        _points(name, ..named)
      }
    })
  }
  // Case 2: Unnamed construct via named parameter
  else if "path" in named {
    let path-spec = named.path
    let other-opts = (:)
    for (k, v) in named {
      if k != "path" {
        other-opts.insert(k, v)
      }
    }
    _path(path-spec, ..other-opts)
  }
  else if "line" in named {
    let line-points = named.line
    let other-opts = (:)
    for (k, v) in named {
      if k != "line" {
        other-opts.insert(k, v)
      }
    }
    // Use draw-polygon with close: false for polylines through named points
    other-opts.insert("close", false)
    drawing.draw-polygon(cetz.draw, _pt, ..line-points, ..other-opts)
  }
  else if "points" in named {
    let point-names = named.points
    let labels-spec = named.at("labels", default: false)

    // Ensure point-names is an array
    if type(point-names) != array {
      point-names = (point-names,)
    }

    // Draw the points
    _points(..point-names)

    // Draw labels if requested
    if labels-spec != false {
      if labels-spec == true {
        // Draw all labels with default positioning
        _labels(..point-names)
      } else if type(labels-spec) == dictionary {
        // Draw labels with custom positioning
        _labels(..point-names, ..labels-spec)
      }
    }
  }
  else if "labels" in named {
    // Standalone labels (without points parameter)
    let labels-spec = named.labels

    if type(labels-spec) == array {
      // Array with point names and options
      _labels(..labels-spec)
    } else if type(labels-spec) == dictionary {
      // Dictionary with only options (assumes points were drawn separately)
      // Extract point names from dictionary keys
      let point-names = ()
      let options = (:)
      for (k, v) in labels-spec {
        if type(k) == str and k.len() <= 5 {  // Likely a point name
          options.insert(k, v)
          if k not in point-names {
            point-names.push(k)
          }
        }
      }
      if point-names.len() > 0 {
        _labels(..point-names, ..options)
      }
    }
  }
  else if "circle-through" in named {
    let pts = named.at("circle-through")
    let other-opts = (:)
    for (k, v) in named {
      if k != "circle-through" {
        other-opts.insert(k, v)
      }
    }
    _circle-through(pts.at(0), pts.at(1), ..other-opts)
  }
  else if "circle-r" in named {
    let spec = named.at("circle-r")
    let other-opts = (:)
    for (k, v) in named {
      if k != "circle-r" {
        other-opts.insert(k, v)
      }
    }
    _circle-r(spec.at(0), spec.at(1), ..other-opts)
  }
  else if "circle-diameter" in named {
    let pts = named.at("circle-diameter")
    let other-opts = (:)
    for (k, v) in named {
      if k != "circle-diameter" {
        other-opts.insert(k, v)
      }
    }
    _circle-diameter(pts.at(0), pts.at(1), ..other-opts)
  }
  else if "circumcircle" in named {
    let pts = named.circumcircle
    let other-opts = (:)
    for (k, v) in named {
      if k != "circumcircle" {
        other-opts.insert(k, v)
      }
    }
    _circumcircle(pts.at(0), pts.at(1), pts.at(2), ..other-opts)
  }
  else if "incircle" in named {
    let pts = named.incircle
    let other-opts = (:)
    for (k, v) in named {
      if k != "incircle" {
        other-opts.insert(k, v)
      }
    }
    _incircle(pts.at(0), pts.at(1), pts.at(2), ..other-opts)
  }
  else if "arc" in named {
    let spec = named.arc
    let other-opts = (:)
    for (k, v) in named {
      if k != "arc" {
        other-opts.insert(k, v)
      }
    }
    _arc(spec.center, spec.start, spec.end, ..other-opts)
  }
  else if "arc-r" in named {
    let spec = named.at("arc-r")
    let other-opts = (:)
    for (k, v) in named {
      if k != "arc-r" {
        other-opts.insert(k, v)
      }
    }
    _arc-r(spec.at(0), spec.at(1), spec.at(2), spec.at(3), ..other-opts)
  }
  else if "semicircle" in named {
    let pts = named.semicircle
    let other-opts = (:)
    for (k, v) in named {
      if k != "semicircle" {
        other-opts.insert(k, v)
      }
    }
    _semicircle(pts.at(0), pts.at(1), ..other-opts)
  }
  else if "segment" in named {
    let pts = named.segment
    let other-opts = (:)
    for (k, v) in named {
      if k != "segment" {
        other-opts.insert(k, v)
      }
    }
    _segment(pts.at(0), pts.at(1), ..other-opts)
  }
  else {
    panic("ctz-draw() requires either a named object (string) or a type parameter (path:, line:, circle-through:, etc.)")
  }
}

/// Draw sector
#let _sector(center, start, end, ..opts) = drawing.draw-sector(cetz.draw, _pt, center, start, end, ..opts)

/// Mark segment
#let _mark-segment(a, b, ..opts) = drawing.mark-segment(cetz.draw, _pt, a, b, ..opts)

/// Mark right angle
#let _mark-right-angle(a, vertex, c, ..opts) = drawing.mark-right-angle(cetz.draw, _pt, a, vertex, c, ..opts)

/// Fill angle
#let _fill-angle(vertex, a, c, ..opts) = drawing.fill-angle(cetz.draw, cetz.angle, _pt, vertex, a, c, ..opts)

/// Label segment
#let _label-segment(a, b, ..opts) = drawing.label-segment(cetz.draw, _pt, a, b, ..opts)

/// Label angle
#let _label-angle(vertex, a, c, ..opts) = drawing.label-angle-at(cetz.draw, _pt, vertex, a, c, ..opts)

/// Label a named circle
#let _label-circle(name, label, pos: "above", dist: 0.2, offset: (0, 0)) = {
  cetz.draw.get-ctx(ctx => {
    let circles = _get-circles(ctx)
    if name in circles {
      let c = circles.at(name)
      let base = draw.anchor-offset(pos, c.radius + dist)
      let label-pos = (
        c.center.at(0) + base.at(0) + offset.at(0),
        c.center.at(1) + base.at(1) + offset.at(1),
        c.center.at(2, default: 0),
      )
      let anchor = draw.ctz-pos-to-anchor(pos)
      cetz.draw.content(label-pos, label, anchor: anchor)
    } else {
      panic("Circle '" + name + "' not found")
    }
  })
}

/// Label a named polygon
#let _label-polygon(name, label, pos: "center", dist: 0.2, offset: (0, 0)) = {
  cetz.draw.get-ctx(ctx => {
    let polygons = _get-polygons(ctx)
    if name in polygons {
      let pts = polygons.at(name).map(p => _resolve-point(ctx, p))
      if pts.len() == 0 {
        return
      }
      let sum = (0, 0, 0)
      for p in pts {
        sum = (sum.at(0) + p.at(0), sum.at(1) + p.at(1), sum.at(2) + p.at(2, default: 0))
      }
      let center = (sum.at(0) / pts.len(), sum.at(1) / pts.len(), sum.at(2) / pts.len())

      let base = if pos == "center" or pos == "centroid" { (0, 0) } else { draw.anchor-offset(pos, dist) }
      let anchor = if pos == "center" or pos == "centroid" { "center" } else { draw.ctz-pos-to-anchor(pos) }
      let label-pos = (
        center.at(0) + base.at(0) + offset.at(0),
        center.at(1) + base.at(1) + offset.at(1),
        center.at(2, default: 0),
      )
      cetz.draw.content(label-pos, label, anchor: anchor)
    } else {
      panic("Polygon '" + name + "' not found")
    }
  })
}

// =============================================================================
// CALCULATIONS (return values via context)
// =============================================================================

#let _calc-length(a, b) = (ctx => {
  let pa = _resolve-point(ctx, a)
  let pb = _resolve-point(ctx, b)
  (ctx: ctx, value: util.dist(pa, pb))
},)

#let _calc-angle(a, b, c) = (ctx => {
  let pa = _resolve-point(ctx, a)
  let pb = _resolve-point(ctx, b)
  let pc = _resolve-point(ctx, c)
  (ctx: ctx, value: util.angle-at-vertex(pa, pb, pc))
},)

#let _calc-area(a, b, c) = (ctx => {
  let pa = _resolve-point(ctx, a)
  let pb = _resolve-point(ctx, b)
  let pc = _resolve-point(ctx, c)
  (ctx: ctx, value: util.triangle-area(pa, pb, pc))
},)

#let _calc-slope(a, b) = (ctx => {
  let pa = _resolve-point(ctx, a)
  let pb = _resolve-point(ctx, b)
  (ctx: ctx, value: util.slope-angle(pa, pb))
},)

#let _calc-ratio(a, b, c) = (ctx => {
  let pa = _resolve-point(ctx, a)
  let pb = _resolve-point(ctx, b)
  let pc = _resolve-point(ctx, c)
  (ctx: ctx, value: util.ratio(pa, pb, pc))
},)

// =============================================================================
// GRID AND AXES
// =============================================================================

#let _grid(..opts) = drawing.draw-grid(cetz.draw, ..opts)
#let _axes(..opts) = drawing.draw-axes(cetz.draw, ..opts)
#let _axis-x(..opts) = drawing.draw-axis-x(cetz.draw, ..opts)
#let _axis-y(..opts) = drawing.draw-axis-y(cetz.draw, ..opts)
#let _hline(y, ..opts) = drawing.draw-hline(cetz.draw, y, ..opts)
#let _vline(x, ..opts) = drawing.draw-vline(cetz.draw, x, ..opts)
#let _draw-text(x, y, content, ..opts) = drawing.draw-text(cetz.draw, x, y, content, ..opts)

// =============================================================================
// CLIPPING
// =============================================================================

/// Set global clip region
#let _set-clip(xmin, ymin, xmax, ymax) = drawing.set-clip-region(cetz.draw, xmin, ymin, xmax, ymax)

/// Clear global clip region
#let _clear-clip() = drawing.clear-clip-region(cetz.draw)

/// Show clip boundary
#let _show-clip(stroke: gray + 0.5pt) = drawing.draw-global-clip-boundary(cetz.draw, stroke: stroke)

/// Draw line with global clip
#let _ctz-line(a, b, add: (10, 10), stroke: black) = drawing.draw-line-global-clip(cetz.draw, _pt, a, b, add: add, stroke: stroke)

/// Draw segment with global clip
#let _seg(a, b, stroke: black) = drawing.draw-segment-global-clip(cetz.draw, _pt, a, b, stroke: stroke)

/// Draw clipped line (manual bounds)
#let _clipped-line(p1, p2, xmin, ymin, xmax, ymax, stroke: black) = drawing.draw-clipped-line(cetz.draw, p1, p2, xmin, ymin, xmax, ymax, stroke: stroke)

/// Draw clipped line with extension (manual bounds)
#let _clipped-line-add(a, b, xmin, ymin, xmax, ymax, add: (10, 10), stroke: black) = drawing.draw-clipped-line-add(cetz.draw, _pt, a, b, xmin, ymin, xmax, ymax, add: add, stroke: stroke)

/// Draw clip boundary
#let _clip-boundary(xmin, ymin, xmax, ymax, stroke: black + 0.5pt) = drawing.draw-clip-boundary(cetz.draw, xmin, ymin, xmax, ymax, stroke: stroke)

/// Raw clipping algorithm
#let _clip-line-to-rect = drawing.clip-line-to-rect

// =============================================================================
// RAW ALGORITHMS (no context needed)
// =============================================================================

#let _algorithms = (
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
)

// Re-export utility functions
#let _midpoint-raw = util.midpoint
#let _dist = util.dist
#let _angle-to = util.angle-to
#let _project-point-on-line = util.project-point-on-line
#let _rotate-point = util.rotate-point

// =============================================================================
// PUBLIC API (ctz- prefix)
// =============================================================================

/// Package version
#let ctz-version = _version

/// CeTZ canvas alias
#let ctz-canvas = _canvas

/// Initialize ctz-euclide (call at start of canvas body)
#let ctz-init() = _init()

/// Helper to convert point name to ctz: coordinate
#let ctz-pt(name) = _pt(name)

// Point definitions
#let ctz-def-points(..points) = _pts(..points)
#let ctz-pts(..points) = ctz-def-points(..points)
#let ctz-def-line(name, a, b) = _def-line-name(name, a, b)
#let ctz-def-circle(name, center, radius: auto, through: none) = _def-circle(name, center, radius: radius, through: through)
#let ctz-def-polygon(name, ..points) = _def-polygon(name, ..points)

// Intersections
#let ctz-def-ll(name, l1, l2, ray: true) = _ll(name, l1, l2, ray: ray)
#let ctz-def-lc(result-names, line, circle-spec, near: none) = _lc(result-names, line, circle-spec, near: near)
#let ctz-def-cc(result-names, circle1, circle2) = _cc(result-names, circle1, circle2)

// Triangle centers
#let ctz-def-centroid(name, a, b, c) = _centroid(name, a, b, c)
#let ctz-def-circumcenter(name, a, b, c) = _circumcenter(name, a, b, c)
#let ctz-def-incenter(name, a, b, c) = _incenter(name, a, b, c)
#let ctz-def-orthocenter(name, a, b, c) = _orthocenter(name, a, b, c)
#let ctz-def-euler(name, a, b, c) = _euler(name, a, b, c)
#let ctz-def-lemoine(name, a, b, c) = _lemoine(name, a, b, c)
#let ctz-def-nagel(name, a, b, c) = _nagel(name, a, b, c)
#let ctz-def-gergonne(name, a, b, c) = _gergonne(name, a, b, c)
#let ctz-def-spieker(name, a, b, c) = _spieker(name, a, b, c)
#let ctz-def-feuerbach(name, a, b, c) = _feuerbach(name, a, b, c)
#let ctz-def-mittenpunkt(name, a, b, c) = _mittenpunkt(name, a, b, c)
#let ctz-def-excenter(name, a, b, c, vertex: "A") = _excenter(name, a, b, c, vertex: vertex)

// Special triangles
#let ctz-def-medial-triangle(name-a, name-b, name-c, a, b, c) = _medial(name-a, name-b, name-c, a, b, c)
#let ctz-def-orthic-triangle(name-a, name-b, name-c, a, b, c) = _orthic(name-a, name-b, name-c, a, b, c)
#let ctz-def-intouch-triangle(name-a, name-b, name-c, a, b, c) = _intouch(name-a, name-b, name-c, a, b, c)
#let ctz-def-thales-triangle(name-a, name-b, name-c, center, radius, base-angle: 0, orientation: "left") = _thales-triangle(name-a, name-b, name-c, center, radius, base-angle: base-angle, orientation: orientation)

// Point constructions
#let ctz-def-midpoint(name, a, b) = _midpoint(name, a, b)
#let ctz-def-equilateral(name, a, b) = _equilateral(name, a, b)
#let ctz-def-square(name-c, name-d, a, b) = _square(name-c, name-d, a, b)
#let ctz-def-golden(name, a, b, inside: true) = _golden(name, a, b, inside: inside)
#let ctz-def-barycentric(name, a, b, c, x, y, z) = _barycentric(name, a, b, c, x, y, z)
#let ctz-def-point-on-circle(name, center, radius, angle-deg) = _point-on-circle(name, center, radius, angle-deg)
#let ctz-def-regular-polygon(..args) = _regular-polygon(..args)
#let ctz-def-linear(name, a, b, k) = _linear(name, a, b, k)
#let ctz-def-symmetry(name, source, center) = _symmetry(name, source, center)
#let ctz-def-inversion(name, source, center, radius) = _inversion(name, source, center, radius)
#let ctz-def-tangent-from(name1, name2, point, center, radius) = _tangent-from(name1, name2, point, center, radius)
#let ctz-def-tangent-at(name1, name2, point-on-circle, center) = _tangent-at(name1, name2, point-on-circle, center)
#let ctz-def-radical-axis(name1, name2, circle1, circle2) = _radical-axis(name1, name2, circle1, circle2)

// Transformations
#let ctz-def-rotation(name, source, center, angle-deg) = _rotation(name, source, center, angle-deg)
#let ctz-def-reflect(name, source, p1, p2) = _reflect(name, source, p1, p2)
#let ctz-def-translate(name, source, vector) = _translate(name, source, vector)
#let ctz-def-homothety(name, source, center, k) = _homothety(name, source, center, k)
#let ctz-def-project(name, source, p1, p2) = _project(name, source, p1, p2)
#let ctz-duplicate(target-name, source-name, points: auto) = _duplicate(target-name, source-name, points: points)

// Line construction helpers
#let ctz-def-perp(name1, name2, line, through) = _perp(name1, name2, line, through)
#let ctz-def-para(name1, name2, line, through) = _para(name1, name2, line, through)
#let ctz-def-bisect(name1, name2, a, vertex, c) = _bisect(name1, name2, a, vertex, c)
#let ctz-def-mediator(name1, name2, a, b) = _mediator(name1, name2, a, b)

// Drawing functions
#let ctz-style(..style-args) = _style(..style-args)
#let ctz-draw(..args) = _polymorphic-draw(..args)
#let ctz-draw-line(..args) = _draw-line(..args)
#let ctz-draw-points(..names) = _points(..names)
#let ctz-points(..names) = ctz-draw-points(..names)
#let ctz-draw-labels(..args) = _labels(..args)
#let ctz-draw-angle(vertex, a, b, ..opts) = _angle(vertex, a, b, ..opts)
#let ctz-draw-polygon(..args) = _polygon(..args)
#let ctz-draw-fill-polygon(..args) = _fill-polygon(..args)
#let ctz-draw-regular-polygon(names, ..opts) = _draw-regular-polygon(names, ..opts)
#let ctz-draw-fill-regular-polygon(names, ..opts) = _fill-regular-polygon(names, ..opts)
#let ctz-draw-path(spec, ..opts) = _path(spec, ..opts)
#let ctz-draw-segment(a, b, ..opts) = _segment(a, b, ..opts)
#let ctz-draw-measure-segment(a, b, ..opts) = _measure-segment(a, b, ..opts)
#let ctz-draw-line-add(a, b, ..opts) = _line-add(a, b, ..opts)
#let ctz-draw-arc(center, start, end, ..opts) = _arc(center, start, end, ..opts)
#let ctz-draw-arc-r(center, radius, start-angle, end-angle, ..opts) = _arc-r(center, radius, start-angle, end-angle, ..opts)
#let ctz-draw-circle-r(center, radius, ..opts) = _circle-r(center, radius, ..opts)
#let ctz-draw-circle-through(center, through, ..opts) = _circle-through(center, through, ..opts)
#let ctz-draw-circle-diameter(a, b, ..opts) = _circle-diameter(a, b, ..opts)
#let ctz-draw-circle(name, ..opts) = _draw-circle(name, ..opts)
#let ctz-draw-circumcircle(a, b, c, ..opts) = _circumcircle(a, b, c, ..opts)
#let ctz-draw-incircle(a, b, c, ..opts) = _incircle(a, b, c, ..opts)
#let ctz-draw-semicircle(a, b, ..opts) = _semicircle(a, b, ..opts)
#let ctz-draw-sector(center, start, end, ..opts) = _sector(center, start, end, ..opts)
#let ctz-draw-mark-segment(a, b, ..opts) = _mark-segment(a, b, ..opts)
#let ctz-draw-mark-right-angle(a, vertex, c, ..opts) = _mark-right-angle(a, vertex, c, ..opts)
#let ctz-draw-fill-angle(vertex, a, c, ..opts) = _fill-angle(vertex, a, c, ..opts)
#let ctz-draw-label-segment(a, b, ..opts) = _label-segment(a, b, ..opts)
#let ctz-draw-label-angle(vertex, a, c, ..opts) = _label-angle(vertex, a, c, ..opts)
#let ctz-label-circle(name, label, pos: "above", dist: 0.2, offset: (0, 0)) = _label-circle(name, label, pos: pos, dist: dist, offset: offset)
#let ctz-label-polygon(name, label, pos: "center", dist: 0.2, offset: (0, 0)) = _label-polygon(name, label, pos: pos, dist: dist, offset: offset)

// Calculations (return values via context)
#let ctz-calc-length(a, b) = _calc-length(a, b)
#let ctz-calc-angle(a, b, c) = _calc-angle(a, b, c)
#let ctz-calc-area(a, b, c) = _calc-area(a, b, c)
#let ctz-calc-slope(a, b) = _calc-slope(a, b)
#let ctz-calc-ratio(a, b, c) = _calc-ratio(a, b, c)

// Grid and axes
#let ctz-draw-grid(..opts) = _grid(..opts)
#let ctz-draw-axes(..opts) = _axes(..opts)
#let ctz-draw-axis-x(..opts) = _axis-x(..opts)
#let ctz-draw-axis-y(..opts) = _axis-y(..opts)
#let ctz-draw-hline(y, ..opts) = _hline(y, ..opts)
#let ctz-draw-vline(x, ..opts) = _vline(x, ..opts)
#let ctz-draw-text(x, y, content, ..opts) = _draw-text(x, y, content, ..opts)

// Clipping
#let ctz-set-clip(xmin, ymin, xmax, ymax) = _set-clip(xmin, ymin, xmax, ymax)
#let ctz-clear-clip() = _clear-clip()
#let ctz-show-clip(stroke: gray + 0.5pt) = _show-clip(stroke: stroke)
#let ctz-draw-line-global-clip(a, b, add: (10, 10), stroke: black) = _ctz-line(a, b, add: add, stroke: stroke)
#let ctz-draw-seg-global-clip(a, b, stroke: black) = _seg(a, b, stroke: stroke)
#let ctz-draw-clipped-line(p1, p2, xmin, ymin, xmax, ymax, stroke: black) = _clipped-line(p1, p2, xmin, ymin, xmax, ymax, stroke: stroke)
#let ctz-draw-clipped-line-add(a, b, xmin, ymin, xmax, ymax, add: (10, 10), stroke: black) = _clipped-line-add(a, b, xmin, ymin, xmax, ymax, add: add, stroke: stroke)
#let ctz-draw-clip-boundary(xmin, ymin, xmax, ymax, stroke: black + 0.5pt) = _clip-boundary(xmin, ymin, xmax, ymax, stroke: stroke)
#let ctz-clip-line-to-rect = _clip-line-to-rect

// Raw algorithms (no context needed)
#let ctz-algorithms = _algorithms

// Utility re-exports
#let ctz-midpoint-raw = _midpoint-raw
#let ctz-dist = _dist
#let ctz-angle-to = _angle-to
#let ctz-project-point-on-line = _project-point-on-line
#let ctz-rotate-point = _rotate-point
