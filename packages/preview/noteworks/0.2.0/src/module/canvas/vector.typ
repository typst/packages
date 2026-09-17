// =====================================================
// VECTOR CANVAS - Vector visualization helpers
// =====================================================

#import "@preview/cetz:0.4.2"
#import "../graph/vector.typ": *

/// Draw a vector as an arrow from origin to (x, y)
///
/// Parameters:
/// - theme: Theme dictionary
/// - start: Starting point (default: origin)
/// - vec: The vector object
/// - label-pos: Label position along vector (0-1) (default: 0.5)
/// - label-dist: Label offset distance (default: 0.3)
#let draw-vector(
  theme: (:),
  start: (0, 0),
  vec,
  label-pos: 0.5,
  label-dist: 0.3,
) = {
  import cetz.draw: *

  let stroke-col = if vec.style != auto and vec.style != none and "stroke" in vec.style {
    vec.style.stroke
  } else {
    theme.at("plot", default: (:)).at("stroke", default: black)
  }

  let sx = if type(start) == dictionary { start.x } else { start.at(0) }
  let sy = if type(start) == dictionary { start.y } else { start.at(1) }

  let ex = sx + vec.x
  let ey = sy + vec.y

  line(
    (sx, sy),
    (ex, ey),
    stroke: (paint: stroke-col, thickness: 1.5pt),
    mark: (end: "stealth", fill: stroke-col),
  )

  if vec.label != none {
    let bg-col = theme.at("page-fill", default: white)

    // Midpoint of vector
    let mx = (sx + ex) / 2
    let my = (sy + ey) / 2

    // Calculate pill width based on label (approximate for content)
    let pill-half-width = 0.3

    // Draw background pill for label (covers the vector line)
    rect(
      (mx - pill-half-width, my - 0.15),
      (mx + pill-half-width, my + 0.15),
      fill: bg-col,
      stroke: (paint: stroke-col, thickness: 0.5pt),
      radius: 0.1,
    )

    content((mx, my), text(fill: stroke-col, weight: "bold", vec.label), anchor: "center")
  }
}


/// Draw vector components (dashed projections)
#let draw-vector-components(
  theme: (:),
  start: (0, 0),
  vec,
  label-x: none,
  label-y: none,
  color: gray,
) = {
  import cetz.draw: *

  let sx = if type(start) == dictionary { start.x } else { start.at(0) }
  let sy = if type(start) == dictionary { start.y } else { start.at(1) }

  let ex = sx + vec.x
  let ey = sy + vec.y

  // X component (horizontal)
  line((sx, sy), (ex, sy), stroke: (paint: color, dash: "dashed", thickness: 0.8pt))
  // Y component (vertical)
  line((ex, sy), (ex, ey), stroke: (paint: color, dash: "dotted", thickness: 0.8pt))

  if label-x != none {
    content(((sx + ex) / 2, sy - 0.2), text(fill: color, size: 8pt, label-x), anchor: "north")
  }
  if label-y != none {
    content((ex + 0.2, (sy + ey) / 2), text(fill: color, size: 8pt, label-y), anchor: "west")
  }
}

/// Draw vector addition (parallelogram method)
#let draw-vector-addition(
  theme: (:),
  start: (0, 0),
  v1,
  v2,
  label-sum: none,
  mode: "parallelogram",
  helplines: true,
) = {
  import cetz.draw: *

  let stroke-col = theme.at("plot", default: (:)).at("stroke", default: black)
  let hl-col = theme.at("plot", default: (:)).at("highlight", default: blue)

  let sx = if type(start) == dictionary { start.x } else { start.at(0) }
  let sy = if type(start) == dictionary { start.y } else { start.at(1) }

  let v1-end = (sx + v1.x, sy + v1.y)
  let v2-end = (sx + v2.x, sy + v2.y)
  let sum-end = (sx + v1.x + v2.x, sy + v1.y + v2.y)

  // Draw original vectors
  draw-vector(theme: theme, start: (sx, sy), v1)
  draw-vector(theme: theme, start: (sx, sy), v2)

  if mode == "parallelogram" and helplines {
    // Parallelogram sides - Dotted and same strength
    line(v1-end, sum-end, stroke: (paint: gray, thickness: 1.5pt, dash: "dotted"))
    line(v2-end, sum-end, stroke: (paint: gray, thickness: 1.5pt, dash: "dotted"))
  } else {
    // Tip-to-tail: draw v2 from end of v1
    draw-vector(theme: theme, start: v1-end, v2)
  }

  // Resultant
  let sum-vec = vector(v1.x + v2.x, v1.y + v2.y, label: label-sum, style: (stroke: hl-col))
  draw-vector(theme: theme, start: (sx, sy), sum-vec)
}

/// Draw vector projection
#let draw-vector-projection(
  theme: (:),
  start: (0, 0),
  vec-a,
  vec-b,
  label-proj: none,
  helplines: true,
) = {
  import cetz.draw: *

  let hl-col = theme.at("plot", default: (:)).at("highlight", default: blue)
  let accent-col = theme.at("text-accent", default: purple)

  let sx = if type(start) == dictionary { start.x } else { start.at(0) }
  let sy = if type(start) == dictionary { start.y } else { start.at(1) }

  // Calculate projection
  let proj = vec-project(vec-a, vec-b)

  let a-end = (sx + vec-a.x, sy + vec-a.y)
  let proj-end = (sx + proj.x, sy + proj.y)

  // Extended b axis
  let b-scale = 1.3
  if helplines {
    line(
      (sx - vec-b.x * 0.2, sy - vec-b.y * 0.2),
      (sx + vec-b.x * b-scale, sy + vec-b.y * b-scale),
      stroke: (paint: gray, thickness: 1.5pt, dash: "dotted"),
    )
  }

  // Original vectors
  draw-vector(theme: theme, start: (sx, sy), vec-a)
  draw-vector(theme: theme, start: (sx, sy), vec-b)

  // Perpendicular from a to projection
  if helplines {
    line(a-end, proj-end, stroke: (paint: gray, thickness: 1.5pt, dash: "dotted"))

    // Right angle marker
    // Construct simplified point objects for the drawer
    let p-a = (x: a-end.at(0), y: a-end.at(1))
    let p-proj = (x: proj-end.at(0), y: proj-end.at(1))
    let p-start = (x: sx, y: sy)

    // Draw directly using the helper
    draw-right-angle-marker(
      (
        type: "right-angle",
        p1: p-a,
        vertex: p-proj,
        p2: p-start,
        radius: 0.3,
      ),
      theme,
    )
  }

  // Projection vector
  let proj-labeled = vector(proj.x, proj.y, label: label-proj, style: (stroke: hl-col))
  draw-vector(theme: theme, start: (sx, sy), proj-labeled)
}
