// ctz-euclide/src/drawing/annotations.typ
// Annotation helpers for educational diagrams (arrows, highlights, callouts)

#import "@preview/cetz:0.4.2" as cetz
#import "../util.typ"

// =============================================================================
// CELL HIGHLIGHTING
// =============================================================================

/// Highlight a position with a filled circle
/// - cetz-draw: cetz draw context
/// - pos: position to highlight
/// - radius: circle radius
/// - fill: fill color
/// - stroke: stroke style (default: none)
#let highlight-fill(cetz-draw, pos, radius: 0.35, fill: red.lighten(70%), stroke: none) = {
  cetz-draw.circle(pos, radius: radius, fill: fill, stroke: stroke)
}

/// Highlight a position with a stroked circle (outline)
/// - cetz-draw: cetz draw context
/// - pos: position to highlight
/// - radius: circle radius
/// - stroke: stroke style
/// - fill: fill color (default: none)
#let highlight-outline(cetz-draw, pos, radius: 0.35, stroke: green + 1.5pt, fill: none) = {
  cetz-draw.circle(pos, radius: radius, fill: fill, stroke: stroke)
}

/// Highlight multiple positions with the same style
/// - cetz-draw: cetz draw context
/// - positions: array of positions
/// - radius: circle radius
/// - fill: fill color (none for outline only)
/// - stroke: stroke style
#let highlight-many(cetz-draw, positions, radius: 0.35, fill: none, stroke: green + 1.5pt) = {
  for pos in positions {
    cetz-draw.circle(pos, radius: radius, fill: fill, stroke: stroke)
  }
}

// =============================================================================
// ANNOTATION ARROWS
// =============================================================================

/// Draw a curved annotation arrow from source to target
/// - cetz-draw: cetz draw context
/// - from: source position
/// - to: target position
/// - bend: curvature factor (positive = bend right, negative = bend left)
/// - stroke: stroke style
/// - mark: arrow mark style
#let curved-arrow(
  cetz-draw,
  from,
  to,
  bend: 0.5,
  stroke: red + 1pt,
  mark: (end: ">"),
) = {
  // Calculate control point for quadratic bezier
  let mid-x = (from.at(0) + to.at(0)) / 2
  let mid-y = (from.at(1) + to.at(1)) / 2

  // Perpendicular direction
  let dx = to.at(0) - from.at(0)
  let dy = to.at(1) - from.at(1)
  let len = calc.sqrt(dx * dx + dy * dy)

  let ctrl = if len > util.eps {
    let px = -dy / len * bend
    let py = dx / len * bend
    (mid-x + px, mid-y + py)
  } else {
    (mid-x, mid-y + bend)
  }

  cetz-draw.bezier(from, to, ctrl, stroke: stroke, mark: mark)
}

/// Draw an annotation with curved arrow pointing to a target
/// - cetz-draw: cetz draw context
/// - target: position being annotated
/// - label: annotation content
/// - label-pos: position for the label
/// - label-anchor: anchor for label positioning
/// - offset: offset from target to start of arrow
/// - bend: curvature factor
/// - stroke: stroke style
/// - mark: arrow mark style
#let annotation-arrow(
  cetz-draw,
  target,
  label,
  label-pos,
  label-anchor: "west",
  offset: (0.4, 0),
  bend: 0.5,
  stroke: red + 1pt,
  mark: (end: ">", fill: red),
) = {
  // Draw the label
  cetz-draw.content(label-pos, label, anchor: label-anchor)

  // Calculate arrow start (offset from target)
  let arrow-start = (target.at(0) + offset.at(0), target.at(1) + offset.at(1))

  // Calculate arrow end (near the label)
  let label-offset = if label-anchor == "west" { (-0.3, 0) }
    else if label-anchor == "east" { (0.3, 0) }
    else if label-anchor == "north" { (0, 0.3) }
    else if label-anchor == "south" { (0, -0.3) }
    else { (0, 0) }

  let arrow-end = (label-pos.at(0) + label-offset.at(0), label-pos.at(1) + label-offset.at(1))

  // Draw curved arrow
  curved-arrow(cetz-draw, arrow-start, arrow-end, bend: bend, stroke: stroke, mark: mark)
}

/// Draw a catmull-rom spline annotation arrow (smoother curves)
/// - cetz-draw: cetz draw context
/// - from: source position
/// - to: target position
/// - waypoints: intermediate control points (array)
/// - stroke: stroke style
/// - mark: arrow mark style
#let smooth-arrow(
  cetz-draw,
  from,
  to,
  waypoints: (),
  stroke: red + 1pt,
  mark: (end: ">", fill: red),
) = {
  let all-points = (from,) + waypoints + (to,)
  cetz-draw.catmull(..all-points, stroke: stroke, mark: mark)
}

// =============================================================================
// ADDITION/COMBINATION INDICATORS
// =============================================================================

/// Draw an addition indicator between two positions pointing to a result
/// Shows: pos1 + pos2 → result with "+" symbol
/// - cetz-draw: cetz draw context
/// - pos1, pos2: positions being combined
/// - result: result position
/// - color: color for the indicator
/// - plus-offset: vertical offset for "+" sign
/// - arrow-gap: gap from result circle
#let draw-addition-indicator(
  cetz-draw,
  pos1,
  pos2,
  result,
  color: green,
  plus-offset: 0.05,
  arrow-gap: 0.35,
) = {
  // Calculate midpoint between pos1 and pos2
  let mid-x = (pos1.at(0) + pos2.at(0)) / 2
  let mid-y = (pos1.at(1) + pos2.at(1)) / 2

  // Draw "+" sign
  cetz-draw.content((mid-x, mid-y + plus-offset), text(size: 14pt, fill: color, $+$))

  // Draw arrow to result
  cetz-draw.line(
    (mid-x, mid-y - 0.25),
    (result.at(0), result.at(1) + arrow-gap),
    stroke: color + 1.5pt,
    mark: (end: ">", fill: color)
  )
}

// =============================================================================
// BRACE ANNOTATIONS
// =============================================================================

/// Draw a horizontal brace with label
/// - cetz-draw: cetz draw context
/// - start: left position
/// - end: right position
/// - label: brace label
/// - side: "above" or "below"
/// - amplitude: brace height
/// - stroke: stroke style
#let draw-brace-h(
  cetz-draw,
  start,
  end,
  label: none,
  side: "below",
  amplitude: 0.3,
  stroke: black + 1pt,
) = {
  let y-dir = if side == "below" { -1 } else { 1 }
  let mid-x = (start.at(0) + end.at(0)) / 2
  let base-y = start.at(1)
  let tip-y = base-y + y-dir * amplitude

  // Draw brace as bezier curves with aligned control points for smooth join
  cetz-draw.bezier(
    start,
    (mid-x, tip-y),
    (start.at(0), tip-y),
    stroke: stroke
  )
  cetz-draw.bezier(
    (mid-x, tip-y),
    end,
    (end.at(0), tip-y),
    stroke: stroke
  )

  // Draw label
  if label != none {
    let label-y = tip-y + y-dir * 0.2
    cetz-draw.content((mid-x, label-y), label)
  }
}

/// Draw a vertical brace with label
/// - cetz-draw: cetz draw context
/// - start: top position
/// - end: bottom position
/// - label: brace label
/// - side: "left" or "right"
/// - amplitude: brace width
/// - stroke: stroke style
#let draw-brace-v(
  cetz-draw,
  start,
  end,
  label: none,
  side: "right",
  amplitude: 0.3,
  stroke: black + 1pt,
) = {
  let x-dir = if side == "right" { 1 } else { -1 }
  let mid-y = (start.at(1) + end.at(1)) / 2
  let base-x = start.at(0)
  let tip-x = base-x + x-dir * amplitude

  // Draw brace as bezier curves with aligned control points for smooth join
  cetz-draw.bezier(
    start,
    (tip-x, mid-y),
    (tip-x, start.at(1)),
    stroke: stroke
  )
  cetz-draw.bezier(
    (tip-x, mid-y),
    end,
    (tip-x, end.at(1)),
    stroke: stroke
  )

  // Draw label
  if label != none {
    let label-x = tip-x + x-dir * 0.2
    let anchor = if side == "right" { "west" } else { "east" }
    cetz-draw.content((label-x, mid-y), label, anchor: anchor)
  }
}
