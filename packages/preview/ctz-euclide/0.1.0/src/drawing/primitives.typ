// ctz-euclide/src/drawing/primitives.typ
// Basic drawing primitives (points, segments, marks)

#import "@preview/cetz:0.4.2" as cetz
#import "../util.typ"

// =============================================================================
// POINT STYLES
// =============================================================================

/// Point style presets
#let point-styles = (
  cross: (shape: "cross", size: 4pt),
  dot: (shape: "dot", size: 3pt),
  circle: (shape: "circle", size: 3pt),
  plus: (shape: "plus", size: 4pt),
  square: (shape: "square", size: 3pt),
  diamond: (shape: "diamond", size: 4pt),
  triangle: (shape: "triangle", size: 4pt),
)

// =============================================================================
// POINT DRAWING
// =============================================================================

/// Draw a point with specified style
/// Usage: draw-point(cetz-draw, "ctz:A", style: "cross")
#let draw-point(cetz-draw, coord, style: "cross", color: black) = {
  let s = point-styles.at(style, default: point-styles.cross)
  let sz = s.size

  if s.shape == "dot" {
    cetz-draw.circle(coord, radius: sz, fill: color, stroke: none)
  } else if s.shape == "circle" {
    cetz-draw.circle(coord, radius: sz, fill: white, stroke: color + 1pt)
  } else if s.shape == "cross" {
    cetz-draw.line((rel: (-sz, -sz), to: coord), (rel: (sz, sz), to: coord), stroke: color + 1.5pt)
    cetz-draw.line((rel: (-sz, sz), to: coord), (rel: (sz, -sz), to: coord), stroke: color + 1.5pt)
  } else if s.shape == "plus" {
    cetz-draw.line((rel: (-sz, 0pt), to: coord), (rel: (sz, 0pt), to: coord), stroke: color + 1.5pt)
    cetz-draw.line((rel: (0pt, -sz), to: coord), (rel: (0pt, sz), to: coord), stroke: color + 1.5pt)
  } else if s.shape == "square" {
    cetz-draw.rect((rel: (-sz, -sz), to: coord), (rel: (sz, sz), to: coord), fill: color, stroke: none)
  } else if s.shape == "diamond" {
    cetz-draw.line(
      (rel: (0pt, sz), to: coord),
      (rel: (sz, 0pt), to: coord),
      (rel: (0pt, -sz), to: coord),
      (rel: (-sz, 0pt), to: coord),
      close: true, fill: color, stroke: none
    )
  } else if s.shape == "triangle" {
    cetz-draw.line(
      (rel: (0pt, sz), to: coord),
      (rel: (sz * 0.866, -sz * 0.5), to: coord),
      (rel: (-sz * 0.866, -sz * 0.5), to: coord),
      close: true, fill: color, stroke: none
    )
  }
}

/// Draw multiple points
#let draw-points(cetz-draw, pt-func, ..names, style: "cross", color: black) = {
  for name in names.pos() {
    draw-point(cetz-draw, pt-func(name), style: style, color: color)
  }
}

// =============================================================================
// SEGMENT MARKS
// =============================================================================

/// Draw segment tick marks (for indicating equal lengths)
/// count: 1 = |, 2 = ||, 3 = |||
#let draw-segment-mark(cetz-draw, p1, p2, count: 1, size: 0.15, color: black) = {
  // This needs raw coordinates, so we use a get-ctx approach
  cetz-draw.get-ctx(ctx => {
    // Resolve coordinates
    let (_, c1) = cetz.coordinate.resolve(ctx, p1)
    let (_, c2) = cetz.coordinate.resolve(ctx, p2)

    let mx = (c1.at(0) + c2.at(0)) / 2
    let my = (c1.at(1) + c2.at(1)) / 2
    let dx = c2.at(0) - c1.at(0)
    let dy = c2.at(1) - c1.at(1)
    let len = calc.sqrt(dx*dx + dy*dy)

    if len < util.eps-visual { return }

    // Perpendicular direction
    let px = -dy / len * size
    let py = dx / len * size

    // Draw ticks
    let spacing = size * 2.4
    for i in range(count) {
      let offset = (i - (count - 1) / 2) * spacing
      let cx = mx + offset * dx / len
      let cy = my + offset * dy / len
      cetz-draw.line((cx - px, cy - py), (cx + px, cy + py), stroke: color + 1.5pt)
    }
  })
}

/// Draw a compass arc (construction arc showing equal distances)
#let draw-compass(cetz-draw, center, through, delta: 60, color: gray, stroke-width: 0.5pt) = {
  cetz-draw.get-ctx(ctx => {
    let (_, c) = cetz.coordinate.resolve(ctx, center)
    let (_, t) = cetz.coordinate.resolve(ctx, through)

    let radius = util.dist(c, t)
    let theta = calc.atan2(t.at(1) - c.at(1), t.at(0) - c.at(0))

    // Convert to an angle value (Typst angle type) if needed.
    let theta-angle = util.to-angle(if type(theta) == angle { theta / 1deg } else { theta * 180 / calc.pi })

    let half-delta = delta / 2 * 1deg
    cetz-draw.arc(
      center,
      start: theta-angle - half-delta,
      stop: theta-angle + half-delta,
      radius: radius,
      stroke: color + stroke-width
    )
  })
}

/// Draw arc tick mark (for equal arcs)
#let draw-arc-mark(cetz-draw, center, start-pt, end-pt, count: 1, size: 0.2, color: black) = {
  cetz-draw.get-ctx(ctx => {
    let (_, c) = cetz.coordinate.resolve(ctx, center)
    let (_, s) = cetz.coordinate.resolve(ctx, start-pt)
    let (_, e) = cetz.coordinate.resolve(ctx, end-pt)

    let radius = util.dist(c, s)
    let start-angle = calc.atan2(s.at(1) - c.at(1), s.at(0) - c.at(0))
    let end-angle = calc.atan2(e.at(1) - c.at(1), e.at(0) - c.at(0))

    // Convert to degrees
    let to-deg(a) = if type(a) == angle { a / 1deg } else { a * 180 / calc.pi }
    let start-deg = to-deg(start-angle)
    let end-deg = to-deg(end-angle)

    // Normalize angles
    if end-deg < start-deg { end-deg = end-deg + 360 }

    let mid-deg = (start-deg + end-deg) / 2
    let spacing = 3  // degrees

    for i in range(count) {
      let offset = (i - (count - 1) / 2) * spacing
      let angle-deg = mid-deg + offset
      let angle-rad = angle-deg * calc.pi / 180

      let px = c.at(0) + radius * calc.cos(angle-rad)
      let py = c.at(1) + radius * calc.sin(angle-rad)
      let rx = calc.cos(angle-rad)
      let ry = calc.sin(angle-rad)

      cetz-draw.line(
        (px - size/2 * rx, py - size/2 * ry),
        (px + size/2 * rx, py + size/2 * ry),
        stroke: color + 1.5pt
      )
    }
  })
}
