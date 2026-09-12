// annotations.typ — scene-dimension-arrow, scene-sight-line

#import "@preview/cetz:0.5.2"
#import "theme.typ": scene-theme, _f, _s

/// Draw a dimension arrow between two points with a label
/// - p1 (array): first point
/// - p2 (array): second point
/// - label (content): the label to display (e.g., "200 m")
/// - offset (float): perpendicular offset from the line p1-p2 (negative = below/left)
/// - color (color): arrow and text color
/// - size (length): text size
/// - extension (float): length of extension lines from points to dimension line
#let scene-dimension-arrow(
  p1,
  p2,
  label,
  offset: -0.6,
  color: black,
  size: 10pt,
  extension: true,
  inline: false,
  bw: false,
) = {
  import cetz.draw: *

  let x1 = p1.at(0)
  let y1 = p1.at(1)
  let x2 = p2.at(0)
  let y2 = p2.at(1)

  // Direction vector
  let dx = x2 - x1
  let dy = y2 - y1
  let len = calc.sqrt(dx * dx + dy * dy)
  if len == 0 { return }

  let sgn = if offset < 0 { -1 } else { 1 }

  // Normal vector (perpendicular)
  let nx = -dy / len * offset
  let ny = dx / len * offset

  // Offset points
  let op1 = (x1 + nx, y1 + ny)
  let op2 = (x2 + nx, y2 + ny)

  // Extension lines from original points to offset line
  if extension == true {
    let ext-nx = -dy / len * (offset + sgn * 0.1)
    let ext-ny = dx / len * (offset + sgn * 0.1)
    line(p1, (x1 + ext-nx, y1 + ext-ny), stroke: (dash: "dashed", thickness: 0.5pt, paint: _s(black, bw)))
    line(p2, (x2 + ext-nx, y2 + ext-ny), stroke: (dash: "dashed", thickness: 0.5pt, paint: _s(black, bw)))
  }

  // Label at midpoint
  let mid-x = (op1.at(0) + op2.at(0)) / 2
  let mid-y = (op1.at(1) + op2.at(1)) / 2

  if inline {
    // Measure label to create a gap in the arrow line
    let gap = 0.4  // half-gap size along the line direction
    let tx = dx / len  // unit tangent
    let ty = dy / len
    let gap-start = (mid-x - tx * gap, mid-y - ty * gap)
    let gap-end = (mid-x + tx * gap, mid-y + ty * gap)

    // Two arrow segments with a gap for the label
    set-style(mark: (fill: _f(color, bw)))
    line(op1, gap-start, mark: (start: "stealth", size: 0.15), stroke: _s(color, bw) + 0.8pt)
    line(gap-end, op2, mark: (end: "stealth", size: 0.15), stroke: _s(color, bw) + 0.8pt)

    // Label in the gap
    content((mid-x, mid-y),
      text(fill: _f(color, bw), weight: "bold", size: size, label))
  } else {
    // Dimension line with arrows
    set-style(mark: (fill: _f(color, bw)))
    line(op1, op2, mark: (start: "stealth", end: "stealth", size: 0.15), stroke: _s(color, bw) + 0.8pt)

    // Label offset perpendicular to the line
    let label-nx = -dy / len * sgn * 0.35
    let label-ny = dx / len * sgn * 0.35
    content((mid-x + label-nx, mid-y + label-ny), text(fill: _f(color, bw), weight: "bold", size: size, label))
  }

}

/// Draw a sight line (dashed line between two points)
/// - p1 (array): first point (observer)
/// - p2 (array): second point (target)
/// - color (color): line color
/// - dash (string): dash pattern
/// - thickness (float): line thickness in pt
#let scene-sight-line(
  p1,
  p2,
  color: auto,
  dash: "dashed",
  thickness: 0.8,
  bw: false,
) = {
  import cetz.draw: *

  let c = if color == auto { rgb("#555555") } else { color }
  line(p1, p2, stroke: (dash: dash, thickness: thickness * 1pt, paint: _s(c, bw)))
}

/// Draw a horizontal dashed reference line
/// - left (float): left x
/// - right (float): right x
/// - y (float): y level
/// - color (color): line color
#let scene-horizontal-ref(
  left,
  right,
  y,
  color: auto,
  dash: "dashed",
  thickness: 0.6,
  bw: false,
) = {
  import cetz.draw: *

  let c = if color == auto { rgb("#888888") } else { color }
  line((left, y), (right, y), stroke: (dash: dash, thickness: thickness * 1pt, paint: _s(c, bw)))
}

/// Draw an angle arc with label (wraps cetz.angle.angle)
/// - origin (array): vertex of the angle
/// - p1 (array): point on one ray
/// - p2 (array): point on the other ray
/// - label (content): angle label
/// - radius (float): arc radius
/// - label-radius (float): fraction for label placement
#let scene-angle-arc(
  origin,
  p1,
  p2,
  label,
  radius: 1.3,
  label-radius: 55%,
  bw: false,
) = {
  import cetz.draw: *
  cetz.angle.angle(origin, p1, p2, label: label, radius: radius, label-radius: label-radius)
}

/// Draw a right-angle square
/// - vertex (array): the right-angle vertex
/// - p1 (array): point along one side
/// - p2 (array): point along the other side
/// - size (float): size of the square mark
#let scene-right-angle(
  vertex,
  p1,
  p2,
  size: 0.2,
  bw: false,
) = {
  import cetz.draw: *

  let vx = vertex.at(0)
  let vy = vertex.at(1)

  // Direction vectors from vertex to each point
  let d1x = p1.at(0) - vx
  let d1y = p1.at(1) - vy
  let l1 = calc.sqrt(d1x * d1x + d1y * d1y)
  let d2x = p2.at(0) - vx
  let d2y = p2.at(1) - vy
  let l2 = calc.sqrt(d2x * d2x + d2y * d2y)

  if l1 > 0 and l2 > 0 {
    // Unit vectors
    let u1x = d1x / l1 * size
    let u1y = d1y / l1 * size
    let u2x = d2x / l2 * size
    let u2y = d2y / l2 * size

    line(
      (vx + u1x, vy + u1y),
      (vx + u1x + u2x, vy + u1y + u2y),
      (vx + u2x, vy + u2y),
      stroke: 0.6pt,
    )
  }
}

/// Draw a dashed auxiliary/construction line between two points
/// - p1 (array): first point
/// - p2 (array): second point
/// - color (color): line color (default: light grey)
/// - dash (string): dash pattern — "dashed", "dotted", or "dash-dotted"
/// - thickness (float): line thickness in pt
#let scene-dashed-line(
  p1,
  p2,
  color: auto,
  dash: "dashed",
  thickness: 0.6,
  bw: false,
) = {
  import cetz.draw: *

  let c = if color == auto { rgb("#AAAAAA") } else { color }
  line(p1, p2, stroke: (dash: dash, thickness: thickness * 1pt, paint: _s(c, bw)))
}

/// Draw a curly brace between two points with a label
/// - p1 (array): first endpoint
/// - p2 (array): second endpoint
/// - label (content): text label placed at the brace tip
/// - offset (float): how far the brace extends outward (perpendicular distance)
/// - color (color): brace and label color
/// - size (length): label text size
/// - flip (bool): if true, the brace opens on the opposite side
#let scene-brace(
  p1,
  p2,
  label,
  offset: 0.3,
  color: black,
  size: 9pt,
  flip: false,
  bw: false,
) = {
  import cetz.draw: *

  let x1 = p1.at(0)
  let y1 = p1.at(1)
  let x2 = p2.at(0)
  let y2 = p2.at(1)

  // Direction vector from p1 to p2
  let dx = x2 - x1
  let dy = y2 - y1
  let len = calc.sqrt(dx * dx + dy * dy)
  if len == 0 { return }

  // Unit tangent (along p1-p2)
  let tx = dx / len
  let ty = dy / len

  // Unit normal (perpendicular), flip if requested
  let sign = if flip { -1 } else { 1 }
  let nx = -ty * sign
  let ny = tx * sign

  // Key positions along the segment (fractions of length)
  // p1 -- q1 (1/4) -- mid (1/2) -- q2 (3/4) -- p2
  let mid-x = (x1 + x2) / 2
  let mid-y = (y1 + y2) / 2

  // Slight inward shift at endpoints (1/8 along)
  let e1-x = x1 + tx * len * 0.06
  let e1-y = y1 + ty * len * 0.06
  let e2-x = x2 - tx * len * 0.06
  let e2-y = y2 - ty * len * 0.06

  // Quarter points offset outward
  let q1-x = x1 + tx * len * 0.25 + nx * offset * 0.6
  let q1-y = y1 + ty * len * 0.25 + ny * offset * 0.6
  let q2-x = x1 + tx * len * 0.75 + nx * offset * 0.6
  let q2-y = y1 + ty * len * 0.75 + ny * offset * 0.6

  // Midpoint offset outward (the brace tip)
  let tip-x = mid-x + nx * offset
  let tip-y = mid-y + ny * offset

  // Approach points near the tip (to create the pointed shape)
  let a1-x = mid-x - tx * len * 0.04 + nx * offset * 0.85
  let a1-y = mid-y - ty * len * 0.04 + ny * offset * 0.85
  let a2-x = mid-x + tx * len * 0.04 + nx * offset * 0.85
  let a2-y = mid-y + ty * len * 0.04 + ny * offset * 0.85

  // Draw the brace as a polyline through these points
  line(
    (e1-x, e1-y),
    (q1-x, q1-y),
    (a1-x, a1-y),
    (tip-x, tip-y),
    (a2-x, a2-y),
    (q2-x, q2-y),
    (e2-x, e2-y),
    stroke: _s(color, bw) + 0.8pt,
  )

  // Small ticks at endpoints connecting to p1 and p2
  line(p1, (e1-x, e1-y), stroke: _s(color, bw) + 0.8pt)
  line(p2, (e2-x, e2-y), stroke: _s(color, bw) + 0.8pt)

  // Label at the tip, offset a bit further outward
  let label-x = tip-x + nx * 0.25
  let label-y = tip-y + ny * 0.25
  content((label-x, label-y), text(fill: _f(color, bw), size: size, label))
}

/// Place a text label at a position with optional background box
/// - position (array): (x, y) coordinates
/// - text-content (content): the text to display
/// - anchor (string): which edge/corner of the label box touches the position.
///   Use CeTZ anchor names: "south" → label above the point,
///   "north" → label below, "east" → label to the left,
///   "west" → label to the right, "center" → centered on the point.
///   Also accepts "north-east", "north-west", "south-east", "south-west".
/// - size (length): text size
/// - color (color): text color
/// - bg (color or none): optional background box fill
#let scene-label(
  position,
  text-content,
  anchor: "south",
  size: 9pt,
  color: black,
  bg: none,
  bw: false,
) = {
  // Save before `import cetz.draw: *` which exports its own `anchor` function
  let _anchor = anchor
  import cetz.draw: *

  let label-content = text(fill: _f(color, bw), size: size, text-content)

  if bg != none {
    content(
      position,
      padding: 0.08,
      label-content,
      anchor: _anchor,
      frame: "rect",
      fill: _f(bg, bw),
      stroke: none,
    )
  } else {
    content(position, label-content, anchor: _anchor)
  }
}

/// Mark a point with a dot and optional label
/// - position (array): (x, y) coordinates
/// - label (content or none): optional text label
/// - radius (float): dot radius
/// - color (color): dot and label color
/// - size (length): label text size
/// - anchor (string): label direction — "north", "south", "east", "west",
///   "north-east", "north-west", "south-east", "south-west"
/// - shift (float): extra distance added to the default label offset
#let scene-point-mark(
  position,
  label: none,
  radius: 0.05,
  color: black,
  size: 8pt,
  anchor: "north-east",
  shift: 0,
  bw: false,
) = {
  // Save before `import cetz.draw: *` which exports its own `anchor` function
  let _anchor = anchor
  import cetz.draw: *

  let px = position.at(0)
  let py = position.at(1)

  circle((px, py), radius: radius, fill: _f(color, bw), stroke: none)

  if label != none {
    let d = radius + 0.12 + shift
    let s = 0.71  // 1/sqrt(2) for diagonal directions
    let (dx, dy, ca) = if _anchor == "north" {
      (0, d, "south")
    } else if _anchor == "south" {
      (0, -d, "north")
    } else if _anchor == "east" {
      (d, 0, "west")
    } else if _anchor == "west" {
      (-d, 0, "east")
    } else if _anchor == "north-west" {
      (-d * s, d * s, "south-east")
    } else if _anchor == "south-east" {
      (d * s, -d * s, "north-west")
    } else if _anchor == "south-west" {
      (-d * s, -d * s, "north-east")
    } else {
      // default: "north-east"
      (d * s, d * s, "south-west")
    }
    content(
      (px + dx, py + dy),
      text(fill: _f(color, bw), size: size, label),
      anchor: ca,
    )
  }
}
