// ctz-euclide/src/draw.typ
// Drawing functions for points, angles, arcs, labels

#import "util.typ"

// =============================================================================
// STYLE CONFIGURATION
// =============================================================================
// Modify these values to customize the default appearance of all drawings.
// Users can change these at the top of their document after importing.

/// Default stroke width for point markers (crosses, plus signs, etc.)
#let default-point-stroke-width = 0.9pt

/// Default stroke width for tick marks on segments and arcs
#let default-mark-stroke-width = 1pt

/// Default point size in canvas units (for ctz-draw points)
#let default-point-size = 0.07

/// Default point size in pt (for path markers)
#let default-point-size-pt = 2pt

/// Default smaller point size in pt (for dots, circles, squares)
#let default-point-size-small-pt = 1.5pt

/// Default color for points and marks
#let default-point-color = black

/// Default color for lines and segments
#let default-line-color = black

/// Default color for construction marks (tick marks, arc marks)
#let default-mark-color = black

/// Default point shape ("cross", "dot", "circle", "plus", "square", "diamond", "triangle")
#let default-point-shape = "cross"

// =============================================================================
// MAIN LEVÉE (HAND-DRAWN STYLE)
// =============================================================================

/// Enable hand-drawn/sketchy style globally
#let default-main-levee = false

/// Roughness amount (0 = smooth, higher = more rough). Typical range: 0.5 to 2.0
#let default-main-levee-roughness = 1.0

/// Seed for reproducible randomness (use same seed for consistent sketchy look)
#let default-main-levee-seed = 42

/// Number of segments per unit length for sketchy lines
#let default-main-levee-segments = 3

/// Hash function for deterministic pseudo-random numbers
#let _hash(seed, index) = {
  let h = calc.sin(seed * 12.9898 + index * 78.233) * 43758.5453
  calc.rem(calc.abs(h), 1.0)
}

/// Apply main-levée perturbation to a point
/// Returns a slightly offset point based on roughness and seed
#let perturb-point(pt, roughness: 1.0, seed: 42, index: 0) = {
  if roughness == 0 { return pt }

  let r1 = _hash(seed, index * 2)
  let r2 = _hash(seed, index * 2 + 1)

  // Scale perturbation by roughness (in canvas units)
  let scale = roughness * 0.025
  let dx = (r1 - 0.5) * 2 * scale
  let dy = (r2 - 0.5) * 2 * scale

  (pt.at(0) + dx, pt.at(1) + dy)
}

/// Generate sketchy line points between two points
#let sketchy-line-points(p1, p2, roughness: 1.0, seed: 42, base-index: 0) = {
  if roughness == 0 { return (p1, p2) }

  let dx = p2.at(0) - p1.at(0)
  let dy = p2.at(1) - p1.at(1)
  let len = calc.sqrt(dx * dx + dy * dy)

  // More segments for longer lines
  let segments = calc.max(2, int(len * default-main-levee-segments))

  let points = ()
  for i in range(segments + 1) {
    let t = i / segments
    let x = p1.at(0) + t * dx
    let y = p1.at(1) + t * dy

    // Less perturbation at endpoints
    let r = if i == 0 or i == segments { roughness * 0.2 } else { roughness }
    let pt = perturb-point((x, y), roughness: r, seed: seed, index: base-index + i)
    points.push(pt)
  }
  points
}

/// Generate sketchy circle points
#let sketchy-circle-points(center, radius, roughness: 1.0, seed: 42, steps: 36) = {
  let points = ()
  for i in range(steps) {
    let angle = i / steps * 2 * calc.pi
    let r = radius
    if roughness > 0 {
      // Vary the radius slightly
      let r-var = _hash(seed, i) * roughness * 0.04 * radius
      r = radius + (r-var - roughness * 0.02 * radius)
    }
    let x = center.at(0) + r * calc.cos(angle)
    let y = center.at(1) + r * calc.sin(angle)
    let pt = if roughness > 0 {
      perturb-point((x, y), roughness: roughness * 0.5, seed: seed, index: i + steps)
    } else { (x, y) }
    points.push(pt)
  }
  // Close the circle
  points.push(points.at(0))
  points
}

/// Generate sketchy arc points
#let sketchy-arc-points(center, radius, start-angle, end-angle, roughness: 1.0, seed: 42, steps: 24) = {
  let points = ()
  let angle-span = end-angle - start-angle
  for i in range(steps + 1) {
    let t = i / steps
    let angle = start-angle + t * angle-span
    let r = radius
    if roughness > 0 {
      let r-var = _hash(seed, i) * roughness * 0.04 * radius
      r = radius + (r-var - roughness * 0.02 * radius)
    }
    let x = center.at(0) + r * calc.cos(angle)
    let y = center.at(1) + r * calc.sin(angle)
    let pt = if roughness > 0 {
      perturb-point((x, y), roughness: roughness * 0.5, seed: seed, index: i)
    } else { (x, y) }
    points.push(pt)
  }
  points
}

/// Generate sketchy polygon points (perturb each vertex)
#let sketchy-polygon-points(vertices, roughness: 1.0, seed: 42) = {
  if roughness == 0 { return vertices }

  let points = ()
  for (i, v) in vertices.enumerate() {
    points.push(perturb-point(v, roughness: roughness * 0.7, seed: seed, index: i))
  }
  points
}

/// Generate sketchy ellipse points
#let sketchy-ellipse-points(center, rx, ry, angle: 0deg, roughness: 1.0, seed: 42, steps: 36) = {
  let points = ()
  let cos-a = calc.cos(angle)
  let sin-a = calc.sin(angle)

  for i in range(steps) {
    let t = i / steps * 2 * calc.pi
    let ex = rx * calc.cos(t)
    let ey = ry * calc.sin(t)

    // Rotate
    let x = center.at(0) + ex * cos-a - ey * sin-a
    let y = center.at(1) + ex * sin-a + ey * cos-a

    if roughness > 0 {
      // Vary slightly
      let pt = perturb-point((x, y), roughness: roughness * 0.5, seed: seed, index: i)
      points.push(pt)
    } else {
      points.push((x, y))
    }
  }
  // Close
  points.push(points.at(0))
  points
}

// =============================================================================
// POINT SHAPES
// =============================================================================

/// Point shape styles
#let point-shapes = (
  dot: "dot",
  cross: "cross",
  plus: "plus",
  circle: "circle",
  square: "square",
  diamond: "diamond",
  triangle: "triangle",
)

/// Default point style (canvas units)
/// Used by draw-points-styled via global style
#let default-point-style = (
  shape: default-point-shape,
  size: default-point-size,
  fill: default-point-color,
  stroke: default-point-color,
  stroke-width: default-point-stroke-width,
)

/// Draw a single point with given style
/// Returns cetz draw commands
#let draw-point(pos, style: (:)) = {
  let s = default-point-style
  for (k, v) in style {
    s.insert(k, v)
  }

  let x = pos.at(0)
  let y = pos.at(1)
  let sz = s.size
  let sw = s.at("stroke-width", default: default-point-stroke-width)

  if s.shape == "dot" {
    // Filled circle
    ((
      type: "circle",
      center: (x, y),
      radius: sz,
      fill: s.fill,
      stroke: none,
    ),)
  } else if s.shape == "circle" {
    // Open circle
    ((
      type: "circle",
      center: (x, y),
      radius: sz,
      fill: white,
      stroke: s.stroke + sw,
    ),)
  } else if s.shape == "cross" {
    // X mark
    (
      (
        type: "line",
        points: ((x - sz, y - sz), (x + sz, y + sz)),
        stroke: s.stroke + sw,
      ),
      (
        type: "line",
        points: ((x - sz, y + sz), (x + sz, y - sz)),
        stroke: s.stroke + sw,
      ),
    )
  } else if s.shape == "plus" {
    // + mark
    (
      (
        type: "line",
        points: ((x - sz, y), (x + sz, y)),
        stroke: s.stroke + sw,
      ),
      (
        type: "line",
        points: ((x, y - sz), (x, y + sz)),
        stroke: s.stroke + sw,
      ),
    )
  } else if s.shape == "square" {
    ((
      type: "rect",
      corner1: (x - sz, y - sz),
      corner2: (x + sz, y + sz),
      fill: s.fill,
      stroke: none,
    ),)
  } else if s.shape == "diamond" {
    ((
      type: "polygon",
      points: ((x, y + sz), (x + sz, y), (x, y - sz), (x - sz, y)),
      fill: s.fill,
      stroke: none,
    ),)
  } else if s.shape == "triangle" {
    ((
      type: "polygon",
      points: ((x, y + sz), (x + sz * 0.866, y - sz * 0.5), (x - sz * 0.866, y - sz * 0.5)),
      fill: s.fill,
      stroke: none,
    ),)
  } else {
    // Default to dot
    ((
      type: "circle",
      center: (x, y),
      radius: sz,
      fill: s.fill,
      stroke: none,
    ),)
  }
}

/// Calculate angle bisector direction for labeling
#let angle-bisector-direction(a, vertex, b) = {
  // Vectors from vertex to a and b
  let va-x = a.at(0) - vertex.at(0)
  let va-y = a.at(1) - vertex.at(1)
  let vb-x = b.at(0) - vertex.at(0)
  let vb-y = b.at(1) - vertex.at(1)

  // Normalize
  let va-len = calc.sqrt(va-x * va-x + va-y * va-y)
  let vb-len = calc.sqrt(vb-x * vb-x + vb-y * vb-y)

  if va-len < 1e-9 or vb-len < 1e-9 {
    return (1, 0)
  }

  va-x = va-x / va-len
  va-y = va-y / va-len
  vb-x = vb-x / vb-len
  vb-y = vb-y / vb-len

  // Bisector is sum of unit vectors
  let bx = va-x + vb-x
  let by = va-y + vb-y
  let b-len = calc.sqrt(bx * bx + by * by)

  if b-len < 1e-9 {
    // Vectors are opposite, perpendicular bisector
    return (-va-y, va-x)
  }

  (bx / b-len, by / b-len)
}

/// Calculate the angle in degrees from vertex, going from ray to a to ray to b (counterclockwise)
#let calc-angle-deg(a, vertex, b) = {
  let angle-a = calc.atan2(a.at(1) - vertex.at(1), a.at(0) - vertex.at(0))
  let angle-b = calc.atan2(b.at(1) - vertex.at(1), b.at(0) - vertex.at(0))

  let diff = angle-b - angle-a
  // Normalize to [0, 360)
  if diff < 0deg {
    diff = diff + 360deg
  }
  diff
}

/// Calculate midpoint of arc
#let arc-midpoint(center, radius, start-angle, end-angle) = {
  let mid-angle = (start-angle + end-angle) / 2
  let mid-rad = mid-angle * calc.pi / 180
  (
    center.at(0) + radius * calc.cos(mid-rad),
    center.at(1) + radius * calc.sin(mid-rad),
    center.at(2, default: 0),
  )
}

/// Position for label based on anchor string
#let anchor-offset(anchor, distance) = {
  let offsets = (
    "north": (0, distance),
    "south": (0, -distance),
    "east": (distance, 0),
    "west": (-distance, 0),
    "north-east": (distance * 0.707, distance * 0.707),
    "north-west": (-distance * 0.707, distance * 0.707),
    "south-east": (distance * 0.707, -distance * 0.707),
    "south-west": (-distance * 0.707, -distance * 0.707),
    "above": (0, distance),
    "below": (0, -distance),
    "left": (-distance, 0),
    "right": (distance, 0),
    "above left": (-distance * 0.707, distance * 0.707),
    "above right": (distance * 0.707, distance * 0.707),
    "below left": (-distance * 0.707, -distance * 0.707),
    "below right": (distance * 0.707, -distance * 0.707),
  )
  offsets.at(anchor, default: (0, distance))
}

/// Convert ctz position to cetz anchor
#let ctz-pos-to-anchor(pos) = {
  let mapping = (
    "above": "south",
    "below": "north",
    "left": "east",
    "right": "west",
    "above left": "south-east",
    "above right": "south-west",
    "below left": "north-east",
    "below right": "north-west",
  )
  mapping.at(pos, default: pos)
}

/// Calculate point on arc at given parameter t (0 to 1)
#let arc-point(center, radius, start-angle-deg, end-angle-deg, t) = {
  let angle-deg = start-angle-deg + t * (end-angle-deg - start-angle-deg)
  let angle-rad = angle-deg * calc.pi / 180
  (
    center.at(0) + radius * calc.cos(angle-rad),
    center.at(1) + radius * calc.sin(angle-rad),
    center.at(2, default: 0),
  )
}

/// Calculate angle from center to point (in degrees)
#let angle-of-point(center, point) = {
  let dx = point.at(0) - center.at(0)
  let dy = point.at(1) - center.at(1)
  let rad = calc.atan2(dy, dx)
  // Convert to degrees, atan2 returns radians in typst
  if type(rad) == angle {
    if rad < 0deg { rad + 360deg } else { rad }
  } else {
    let deg = rad * 180 / calc.pi
    if deg < 0 { deg + 360 } else { deg }
  }
}

/// Generate tick mark on arc
/// Returns line endpoints for a tick mark perpendicular to arc
#let arc-tick-mark(center, radius, angle-deg, tick-size: 0.15) = {
  let angle-rad = angle-deg * calc.pi / 180
  let px = center.at(0) + radius * calc.cos(angle-rad)
  let py = center.at(1) + radius * calc.sin(angle-rad)

  // Radial direction (outward from center)
  let rx = calc.cos(angle-rad)
  let ry = calc.sin(angle-rad)

  // Tick mark along radial direction
  (
    (px - tick-size/2 * rx, py - tick-size/2 * ry),
    (px + tick-size/2 * rx, py + tick-size/2 * ry),
  )
}

/// Generate multiple tick marks for equal arc indication
#let arc-tick-marks(center, radius, start-angle-deg, end-angle-deg, count: 1, tick-size: 0.15) = {
  let mid-angle = (start-angle-deg + end-angle-deg) / 2
  let marks = ()

  if count == 1 {
    marks.push(arc-tick-mark(center, radius, mid-angle, tick-size: tick-size))
  } else {
    // Space multiple ticks around midpoint
    let spacing = 3  // degrees between ticks
    for i in range(count) {
      let offset = (i - (count - 1) / 2) * spacing
      marks.push(arc-tick-mark(center, radius, mid-angle + offset, tick-size: tick-size))
    }
  }

  marks
}
