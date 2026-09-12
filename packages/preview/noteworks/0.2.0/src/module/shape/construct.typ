// =====================================================
// CONSTRUCT - Derived geometry construction operations
// =====================================================

#import "point.typ": is-point, point
#import "line.typ": is-segment, line, linear-direction, ray, segment
#import "core.typ": normalize

// =====================================================
// Point Constructions
// =====================================================

/// Get the midpoint of a segment or between two points
/// Supports: midpoint(segment), midpoint(p1, p2), midpoint(p1, p2, label: "M")
#let midpoint(..args) = {
  let pos = args.pos()
  let named = args.named()
  let label = named.at("label", default: none)

  if pos.len() == 1 {
    // Single argument: segment or array
    let obj = pos.first()
    if is-segment(obj) {
      point(
        (obj.p1.x + obj.p2.x) / 2,
        (obj.p1.y + obj.p2.y) / 2,
        label: label,
      )
    } else if type(obj) == array and obj.len() == 2 {
      let pt1 = obj.at(0)
      let pt2 = obj.at(1)
      point(
        (pt1.x + pt2.x) / 2,
        (pt1.y + pt2.y) / 2,
        label: label,
      )
    } else {
      panic("midpoint: expected segment or array of two points")
    }
  } else if pos.len() == 2 {
    // Two arguments: p1 and p2
    let pt1 = if is-point(pos.at(0)) { pos.at(0) } else { point(pos.at(0).at(0), pos.at(0).at(1)) }
    let pt2 = if is-point(pos.at(1)) { pos.at(1) } else { point(pos.at(1).at(0), pos.at(1).at(1)) }
    point(
      (pt1.x + pt2.x) / 2,
      (pt1.y + pt2.y) / 2,
      label: label,
    )
  } else {
    panic("midpoint: expected 1 or 2 arguments")
  }
}

/// Divide a segment into n equal parts, return array of division points
#let divide-segment(seg, n) = {
  range(1, n).map(i => {
    let t = i / n
    point(
      seg.p1.x + t * (seg.p2.x - seg.p1.x),
      seg.p1.y + t * (seg.p2.y - seg.p1.y),
    )
  })
}

/// Get point at parameter t along a segment (t=0 -> p1, t=1 -> p2)
#let point-on-segment(seg, t) = {
  point(
    seg.p1.x + t * (seg.p2.x - seg.p1.x),
    seg.p1.y + t * (seg.p2.y - seg.p1.y),
  )
}

// =====================================================
// Line Constructions
// =====================================================

/// Create a perpendicular line through a point
///
/// Parameters:
/// - line-obj: The reference line
/// - through: Point the perpendicular passes through
#let perpendicular(line-obj, through) = {
  let pt = if is-point(through) { through } else { point(through.at(0), through.at(1)) }

  let (dx, dy) = linear-direction(line-obj)
  // Perpendicular direction: (-dy, dx)
  let p2 = point(pt.x - dy, pt.y + dx)
  line(pt, p2)
}

/// Create a parallel line through a point
///
/// Parameters:
/// - line-obj: The reference line
/// - through: Point the parallel passes through
#let parallel(line-obj, through) = {
  let pt = if is-point(through) { through } else { point(through.at(0), through.at(1)) }

  let (dx, dy) = linear-direction(line-obj)
  let p2 = point(pt.x + dx, pt.y + dy)
  line(pt, p2)
}

/// Create the perpendicular bisector of a segment
#let perpendicular-bisector(seg) = {
  let mid = midpoint(seg)
  perpendicular(seg, mid)
}

/// Create an angle bisector ray
///
/// Parameters:
/// - p1: First point (one arm of angle)
/// - vertex: The vertex
/// - p2: Second point (other arm)
#let bisector(p1, vertex, p2) = {
  let pt1 = if is-point(p1) { p1 } else { point(p1.at(0), p1.at(1)) }
  let vtx = if is-point(vertex) { vertex } else { point(vertex.at(0), vertex.at(1)) }
  let pt2 = if is-point(p2) { p2 } else { point(p2.at(0), p2.at(1)) }

  // Get normalized direction vectors
  let d1x = pt1.x - vtx.x
  let d1y = pt1.y - vtx.y
  let d2x = pt2.x - vtx.x
  let d2y = pt2.y - vtx.y

  let (n1x, n1y) = normalize(d1x, d1y)
  let (n2x, n2y) = normalize(d2x, d2y)

  // Bisector direction is sum of normalized vectors
  let bx = n1x + n2x
  let by = n1y + n2y

  ray(vtx, point(vtx.x + bx, vtx.y + by))
}

// =====================================================
// Circle Constructions
// =====================================================

#import "circle.typ": circle

/// Create a circle with center and passing through a point
#let circle-through-point(center, through-point) = {
  let c = if is-point(center) { center } else { point(center.at(0), center.at(1)) }
  let p = if is-point(through-point) { through-point } else { point(through-point.at(0), through-point.at(1)) }

  let dx = p.x - c.x
  let dy = p.y - c.y
  let r = calc.sqrt(dx * dx + dy * dy)

  circle(c, r)
}

/// Get tangent line to a circle at a point on the circle
///
/// Parameters:
/// - circ: The circle
/// - at-point: Point on the circle where tangent is drawn
#let tangent-at(circ, at-point) = {
  let p = if is-point(at-point) { at-point } else { point(at-point.at(0), at-point.at(1)) }
  let c = circ.center

  // Radius direction
  let dx = p.x - c.x
  let dy = p.y - c.y

  // Tangent is perpendicular to radius: (-dy, dx)
  let p2 = point(p.x - dy, p.y + dx)
  line(p, p2)
}

/// Get tangent lines from external point to circle
/// Returns array of 0, 1, or 2 tangent lines
#let tangent-from(circ, external-point) = {
  let p = if is-point(external-point) { external-point } else { point(external-point.at(0), external-point.at(1)) }
  let c = circ.center
  let r = circ.radius

  let dx = p.x - c.x
  let dy = p.y - c.y
  let dist = calc.sqrt(dx * dx + dy * dy)

  if dist < r {
    // Point inside circle - no tangents
    ()
  } else if dist == r {
    // Point on circle - one tangent
    (tangent-at(circ, p),)
  } else {
    // Point outside - two tangents
    // Tangent length from p to tangent point
    let tan-len = calc.sqrt(dist * dist - r * r)

    // Angle from center-to-point to tangent point
    let angle-to-tangent = calc.asin(r / dist)
    let base-angle = calc.atan2(dy, dx)

    // Two tangent points
    let angle1 = base-angle + angle-to-tangent
    let angle2 = base-angle - angle-to-tangent

    let t1 = point(c.x + r * calc.cos(angle1 + 90deg), c.y + r * calc.sin(angle1 + 90deg))
    let t2 = point(c.x + r * calc.cos(angle2 - 90deg), c.y + r * calc.sin(angle2 - 90deg))

    (line(p, t1), line(p, t2))
  }
}

// =====================================================
// Transformation Constructions
// =====================================================

/// Reflect a point across a line
#let reflect-point(pt, across-line) = {
  let p = if is-point(pt) { pt } else { point(pt.at(0), pt.at(1)) }
  let l = across-line

  // Line direction
  let (dx, dy) = linear-direction(l)
  let len-sq = dx * dx + dy * dy

  // Vector from line point to p
  let px = p.x - l.p1.x
  let py = p.y - l.p1.y

  // Project onto line
  let dot = px * dx + py * dy
  let proj-x = (dot / len-sq) * dx
  let proj-y = (dot / len-sq) * dy

  // Foot of perpendicular
  let foot-x = l.p1.x + proj-x
  let foot-y = l.p1.y + proj-y

  // Reflected point is 2 * foot - p
  point(2 * foot-x - p.x, 2 * foot-y - p.y)
}

/// Rotate a point around a center by an angle
#let rotate-point(pt, center, angle) = {
  let p = if is-point(pt) { pt } else { point(pt.at(0), pt.at(1)) }
  let c = if is-point(center) { center } else { point(center.at(0), center.at(1)) }

  let dx = p.x - c.x
  let dy = p.y - c.y

  let cos-a = calc.cos(angle)
  let sin-a = calc.sin(angle)

  point(
    c.x + dx * cos-a - dy * sin-a,
    c.y + dx * sin-a + dy * cos-a,
  )
}

/// Translate a point by a vector
#let translate-point(pt, dx, dy) = {
  let p = if is-point(pt) { pt } else { point(pt.at(0), pt.at(1)) }
  point(p.x + dx, p.y + dy)
}

/// Scale a point from a center
#let scale-point(pt, center, factor) = {
  let p = if is-point(pt) { pt } else { point(pt.at(0), pt.at(1)) }
  let c = if is-point(center) { center } else { point(center.at(0), center.at(1)) }

  point(
    c.x + (p.x - c.x) * factor,
    c.y + (p.y - c.y) * factor,
  )
}
