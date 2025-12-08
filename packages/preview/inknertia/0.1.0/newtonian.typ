#import "@preview/cetz:0.4.2"

// Vector math helpers
#let vec_sub(a, b) = (a.at(0) - b.at(0), a.at(1) - b.at(1))
#let vec_add(a, b) = (a.at(0) + b.at(0), a.at(1) + b.at(1))
#let vec_scale(v, s) = (v.at(0) * s, v.at(1) * s)
#let vec_norm(v) = calc.sqrt(calc.pow(v.at(0), 2) + calc.pow(v.at(1), 2))
#let vec_rotate_90(v) = (-v.at(1), v.at(0)) // 90 degrees counter-clockwise

// Removed deprecated modpattern import

// Function to create a hatching pattern at arbitrary angle
// For angle θ and perpendicular spacing S between lines:
// - Tile dimensions are calculated so lines connect seamlessly
#let hatch(angle: 45deg, spacing: 5pt, stroke: 0.5pt + black) = {
  // Normalize angle to [0, 180) degrees
  let ang = calc.rem(angle.deg(), 180)
  if ang < 0 { ang = ang + 180 }
  let theta = ang * 1deg

  // Calculate tile dimensions for seamless tiling
  // The perpendicular distance between parallel lines should equal spacing
  let W = if theta == 0deg { spacing } else { spacing / calc.abs(calc.sin(theta)) }
  let H = if theta == 90deg { spacing } else { spacing / calc.abs(calc.cos(theta)) }

  // Draw line based on angle quadrant
  if ang == 0 {
    // Horizontal lines
    // Horizontal lines
    tiling(size: (spacing, spacing))[
      #move(dy: 50%, line(start: (0%, 0%), end: (100%, 0%), stroke: stroke))
    ]
  } else if ang == 90 {
    // Vertical lines
    // Vertical lines
    tiling(size: (spacing, spacing))[
      #move(dx: 50%, line(start: (0%, 0%), end: (0%, 100%), stroke: stroke))
    ]
  } else if ang < 90 {
    // Lines going up-right (like \)
    // Lines going up-right (like \)
    tiling(size: (W, H))[
      #line(start: (0%, 100%), end: (100%, 0%), stroke: stroke)
    ]
  } else {
    // Lines going down-right (like /)
    // Lines going down-right (like /)
    tiling(size: (W, H))[
      #line(start: (0%, 0%), end: (100%, 100%), stroke: stroke)
    ]
  }
}

// Function to draw the spring curve between any two points
#let spring(
  start,
  end,
  R,
  coils,
  samples: 1000,
  startcircle: false,
  endcircle: false,
  starthook: 0%,
  endhook: 0%,
  color: black,
  thickness: 1pt,
  name: none,
) = {
  import cetz.draw: *

  let diff = vec_sub(end, start)
  let L = vec_norm(diff)

  // Calculate spring length based on hooks
  let start_ratio = float(starthook)
  let end_ratio = float(endhook)
  let L_spring = L * (1 - start_ratio - end_ratio)
  let start_hook_len = L * start_ratio

  // Unit vectors
  let u = vec_scale(diff, 1 / L) // Longitudinal unit vector
  let n = vec_rotate_90(u) // Transverse unit vector

  let c = coils

  let pts = ()

  // Add start point (beginning of start hook)
  pts.push(start)

  for i in range(samples + 1) {
    let t = i / samples

    // Use L_spring instead of L for the spring part
    let l_local = R + t * (L_spring - 2 * R) + R * calc.cos((2 * c - 1) * calc.pi * t - calc.pi)
    let h_local = R * calc.sin((2 * c - 1) * calc.pi * t - calc.pi)

    // Global position: P = start + (start_hook_len + l_local)*u + h_local*n
    let P = vec_add(start, vec_add(vec_scale(u, start_hook_len + l_local), vec_scale(n, h_local)))
    pts.push(P)
  }

  // Add the straight line for the end hook if needed
  if end_ratio > 0 {
    pts.push(end)
  }

  line(..pts, stroke: (paint: color, thickness: thickness), ..if name != none { (name: name) } else { (:) })
  if startcircle {
    circle(start, radius: 0.1, fill: color, stroke: none)
  }
  if endcircle {
    circle(end, radius: 0.1, fill: color, stroke: none)
  }
}

// Function to draw a wall (filled polygon)
#let wall(points, fill_paint: hatch(), stroke_style: none, sides: "all") = {
  import cetz.draw: *
  // Draw the filled polygon without stroke
  line(..points, close: true, fill: fill_paint, stroke: none)

  // Draw strokes if requested
  if stroke_style != none {
    let n = points.len()
    let indices = if sides == "all" { range(n) } else { sides }

    for i in indices {
      let p1 = points.at(i)
      let p2 = points.at(calc.rem(i + 1, n))
      line(p1, p2, stroke: stroke_style)
    }
  }
}

// Helper to find tangent points from P to circle (C, R)
#let tangent_points(C, R, P) = {
  let d = vec_sub(P, C)
  let dist = vec_norm(d)
  if dist <= R { return (none, none) }
  let base_angle = calc.atan2(d.at(0), d.at(1))
  let alpha = calc.acos(R / dist)

  let t1 = (
    C.at(0) + R * calc.cos(base_angle + alpha),
    C.at(1) + R * calc.sin(base_angle + alpha),
  )
  let t2 = (
    C.at(0) + R * calc.cos(base_angle - alpha),
    C.at(1) + R * calc.sin(base_angle - alpha),
  )
  (t1, t2)
}

// Function to draw a rope around a pulley
#let rope(pulley, start, end, radius: 1, stroke_style: 3pt + rgb("964B00")) = {
  import cetz.draw: *

  let (ts1, ts2) = tangent_points(pulley, radius, start)
  let (te1, te2) = tangent_points(pulley, radius, end)

  if ts1 == none or te1 == none {
    line(start, end, stroke: stroke_style)
    return
  }

  // Calculate angles
  let ang_ts1 = calc.atan2(ts1.at(0) - pulley.at(0), ts1.at(1) - pulley.at(1))
  let ang_ts2 = calc.atan2(ts2.at(0) - pulley.at(0), ts2.at(1) - pulley.at(1))
  let ang_te1 = calc.atan2(te1.at(0) - pulley.at(0), te1.at(1) - pulley.at(1))
  let ang_te2 = calc.atan2(te2.at(0) - pulley.at(0), te2.at(1) - pulley.at(1))

  // Helper to normalize angle to [0, 2pi)
  let norm_ang(a) = {
    let v = a.rad()
    let r = calc.rem(v, 2 * calc.pi)
    let res = if r < 0 { r + 2 * calc.pi } else { r }
    res * 1rad
  }

  // Path 1: CCW (ts1 -> te2)
  // ts1 (Left Entry) -> te2 (Left Exit)
  // Requires CCW arc
  let dist_ccw = vec_norm(vec_sub(start, ts1)) + vec_norm(vec_sub(end, te2))
  let delta_ccw = norm_ang(ang_te2 - ang_ts1)
  let arc_len_ccw = delta_ccw.rad() * radius
  let total_len_ccw = dist_ccw + arc_len_ccw

  // Path 2: CW (ts2 -> te1)
  // ts2 (Right Entry) -> te1 (Right Exit)
  // Requires CW arc
  let dist_cw = vec_norm(vec_sub(start, ts2)) + vec_norm(vec_sub(end, te1))
  let delta_cw = -norm_ang(ang_ts2 - ang_te1)
  let arc_len_cw = calc.abs(delta_cw.rad()) * radius
  let total_len_cw = dist_cw + arc_len_cw

  if total_len_ccw < total_len_cw {
    // Draw CCW path
    line(start, ts1, stroke: stroke_style)
    line(end, te2, stroke: stroke_style)
    if calc.abs(delta_ccw.rad()) > 0.001 {
      arc(ts1, start: ang_ts1, delta: delta_ccw, radius: radius, stroke: stroke_style, mode: "OPEN")
    }
  } else {
    // Draw CW path
    line(start, ts2, stroke: stroke_style)
    line(end, te1, stroke: stroke_style)
    if calc.abs(delta_cw.rad()) > 0.001 {
      arc(ts2, start: ang_ts2, delta: delta_cw, radius: radius, stroke: stroke_style, mode: "OPEN")
    }
  }
}

// Function to draw a pulley
#let pulley(
  pos,
  R: 1,
  fill_paint: white,
  stroke_style: 1pt + black,
  rope_start: none,
  rope_end: none,
  rope_stroke: 3pt + rgb("964B00"),
) = {
  import cetz.draw: *

  // Draw rope if requested
  if rope_start != none and rope_end != none {
    rope(pos, rope_start, rope_end, radius: R, stroke_style: rope_stroke)
  }

  circle(pos, radius: R, fill: fill_paint, stroke: stroke_style)
  circle(pos, radius: R * 0.1, fill: black)
}

// Function to draw Cartesian axes
#let axes(
  xmin: -10,
  xmax: 10,
  ymin: -10,
  ymax: 10,
  xlabel: "x",
  ylabel: "y",
  color: gray,
  grid_stroke: none,
  grid_step: 1,
) = {
  import cetz.draw: *

  if grid_stroke != none {
    // Draw vertical grid lines (excluding outermost)
    let x = xmin + grid_step
    while x < xmax {
      line((x, ymin), (x, ymax), stroke: grid_stroke)
      x = x + grid_step
    }
    // Draw horizontal grid lines (excluding outermost)
    let y = ymin + grid_step
    while y < ymax {
      line((xmin, y), (xmax, y), stroke: grid_stroke)
      y = y + grid_step
    }
  }

  let style = (
    mark: (end: "stealth", fill: black, scale: .5, length: 1em, width: .5em),
    stroke: (thickness: 0.4pt, paint: black),
  )
  line((xmin, 0), (xmax, 0), name: "OX", ..style)
  line((0, ymin), (0, ymax), name: "OY", ..style)
  content(("OX.start", 98.5%, "OX.end"), text(color)[#xlabel], padding: 0.4em, anchor: "south")
  content(("OY.start", 98.5%, "OY.end"), text(color)[#ylabel], padding: 0.4em, anchor: "east")
}

// Function to draw a vector (arrow)
#let vector(
  start,
  end,
  label: none,
  stroke_style: 1pt + black,
  fill_paint: black,
  anchor: "auto",
  padding: 0.2em,
) = {
  let drawables = ()

  // Draw arrow
  drawables.push(cetz.draw.line(start, end, stroke: stroke_style, mark: (end: "stealth", fill: fill_paint)))

  // Draw label
  if label != none {
    let anchor_val = if anchor == "auto" {
      "south"
    } else {
      anchor
    }
    drawables.push(cetz.draw.content(end, text(fill: fill_paint, label), anchor: anchor_val, padding: padding))
  }
  cetz.draw.group(name: "vector", {
    for d in drawables { d }
  })
}

// Function to draw a curved arrow (arc with arrowhead)
#let curved_arrow(
  center,
  radius: 1,
  start_angle: 0deg,
  end_angle: 90deg,
  direction: "auto",
  color: black,
  thickness: 1pt,
  label: none,
  label_radius: auto,
) = {
  import cetz.draw: *
  import cetz.angle: angle

  // Determine direction
  let direc = if direction == "auto" {
    if start_angle < end_angle { "ccw" } else { "cw" }
  } else {
    direction
  }

  // Calculate start and end points on the circle
  let p_start = (
    center.at(0) + calc.cos(start_angle),
    center.at(1) + calc.sin(start_angle),
  )
  let p_end = (
    center.at(0) + calc.cos(end_angle),
    center.at(1) + calc.sin(end_angle),
  )

  // Label radius
  let lbl_r = if label_radius == auto { radius * 1.3 } else { label_radius }

  // Draw the arc with arrowhead
  angle(
    center,
    p_start,
    p_end,
    label: if label != none { text(color, label) } else { none },
    radius: radius,
    label-radius: lbl_r,
    stroke: (paint: color, thickness: thickness),
    mark: (end: "stealth", fill: color, scale: .5, length: 1em, width: .5em),
    direction: direc,
  )
}

