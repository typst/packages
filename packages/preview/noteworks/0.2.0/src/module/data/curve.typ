// =====================================================
// CURVE - Interpolation curves (linear and spline)
// =====================================================
// Create curves through points using various interpolation methods

/// Helper: Convert Catmull-Rom control points to Cubic Bezier control points
#let catmull-to-bezier(p0, p1, p2, p3, tension: 0.5) = {
  // Extract coordinates
  let get-coords(p) = if type(p) == dictionary { (p.x, p.y) } else { (p.at(0), p.at(1)) }
  let (x0, y0) = get-coords(p0)
  let (x1, y1) = get-coords(p1)
  let (x2, y2) = get-coords(p2)
  let (x3, y3) = get-coords(p3)

  // Calculate derivatives (tangents)
  let factor = (1.0 - tension) / 2.0
  let m1x = (x2 - x0) * factor
  let m1y = (y2 - y0) * factor
  let m2x = (x3 - x1) * factor
  let m2y = (y3 - y1) * factor

  // Bezier control points
  let c1x = x1 + m1x / 3.0
  let c1y = y1 + m1y / 3.0
  let c2x = x2 - m2x / 3.0
  let c2y = y2 - m2y / 3.0

  ((c1x, c1y), (c2x, c2y))
}

/// Create a curve through points
/// Without tension: piecewise linear (polyline)
/// With tension: spline interpolation
///
/// Parameters:
/// - ..points: Points to connect (can be (x,y) tuples or point objects)
///             Also accepts a single array of points
/// - label: Optional label for legend
/// - style: Optional style overrides (stroke color, thickness)
/// - tension: If provided, uses spline interpolation (0.0 = smooth, 1.0 = tight)
#let curve-through(..args) = {
  let named = args.named()
  let pos = args.pos()

  // Handle both curve-through(p1, p2, p3) and curve-through((p1, p2, p3))
  let pts = if pos.len() == 1 and type(pos.first()) == array {
    // Single array argument containing all points
    pos.first()
  } else {
    pos
  }

  let tension = named.at("tension", default: none)

  // If tension is provided, use spline interpolation
  if tension != none and pts.len() >= 2 {
    let segments = ()
    let coords = pts.map(p => if type(p) == dictionary { (p.x, p.y) } else { (p.at(0), p.at(1)) })

    // Duplicate endpoints for open spline
    let ext-pts = (coords.first(),) + coords + (coords.last(),)

    for i in range(coords.len() - 1) {
      let p0 = ext-pts.at(i)
      let p1 = ext-pts.at(i + 1)
      let p2 = ext-pts.at(i + 2)
      let p3 = ext-pts.at(i + 3)

      let (c1, c2) = catmull-to-bezier(p0, p1, p2, p3, tension: tension)
      segments.push((p1, c1, c2, p2))
    }

    (
      type: "curve",
      points: pts,
      segments: segments,
      interpolation: "spline",
      label: named.at("label", default: none),
      style: named.at("style", default: auto),
    )
  } else {
    (
      type: "curve",
      points: pts,
      interpolation: "linear",
      label: named.at("label", default: none),
      style: named.at("style", default: auto),
    )
  }
}

/// Create a smooth curve through points (cubic spline interpolation)
///
/// Parameters:
/// - ..points: Points to connect (can be (x,y) tuples or point objects)
///             Also accepts a single array of points
/// - label: Optional label for legend
/// - style: Optional style overrides (stroke color, thickness)
/// - tension: Spline tension (0.0 = smooth, 1.0 = tight, default: 0.0)
#let smooth-curve(..args) = {
  let named = args.named()
  let pos = args.pos()

  // Handle both smooth-curve(p1, p2, p3) and smooth-curve((p1, p2, p3))
  let pts = if pos.len() == 1 and type(pos.first()) == array {
    pos.first()
  } else {
    pos
  }

  let tension = named.at("tension", default: 0.0)
  let segments = ()

  if pts.len() >= 2 {
    let coords = pts.map(p => if type(p) == dictionary { (p.x, p.y) } else { (p.at(0), p.at(1)) })

    // Duplicate endpoints for open spline
    let ext-pts = (coords.first(),) + coords + (coords.last(),)

    for i in range(coords.len() - 1) {
      let p0 = ext-pts.at(i)
      let p1 = ext-pts.at(i + 1)
      let p2 = ext-pts.at(i + 2)
      let p3 = ext-pts.at(i + 3)

      let (c1, c2) = catmull-to-bezier(p0, p1, p2, p3, tension: tension)
      segments.push((p1, c1, c2, p2))
    }
  }

  (
    type: "curve",
    points: pts,
    segments: segments,
    interpolation: "spline",
    label: named.at("label", default: none),
    style: named.at("style", default: auto),
  )
}

/// Check if object is a curve
#let is-curve(obj) = {
  type(obj) == dictionary and obj.at("type", default: none) == "curve"
}
