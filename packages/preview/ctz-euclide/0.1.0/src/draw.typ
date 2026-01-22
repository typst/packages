// ctz-euclide/src/draw.typ
// Drawing functions for points, angles, arcs, labels

#import "util.typ"

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

/// Default point style
#let default-point-style = (
  shape: "cross",
  size: 0.08,
  fill: black,
  stroke: black,
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
      stroke: s.stroke,
    ),)
  } else if s.shape == "cross" {
    // X mark
    (
      (
        type: "line",
        points: ((x - sz, y - sz), (x + sz, y + sz)),
        stroke: s.stroke + 1.5pt,
      ),
      (
        type: "line",
        points: ((x - sz, y + sz), (x + sz, y - sz)),
        stroke: s.stroke + 1.5pt,
      ),
    )
  } else if s.shape == "plus" {
    // + mark
    (
      (
        type: "line",
        points: ((x - sz, y), (x + sz, y)),
        stroke: s.stroke + 1.5pt,
      ),
      (
        type: "line",
        points: ((x, y - sz), (x, y + sz)),
        stroke: s.stroke + 1.5pt,
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

/// Convert tkz position to cetz anchor
#let tkz-pos-to-anchor(pos) = {
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
