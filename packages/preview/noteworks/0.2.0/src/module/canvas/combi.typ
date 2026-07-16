// =====================================================
// COMBI CANVAS - Combinatorics visualizations
// =====================================================

#import "@preview/cetz:0.4.2"

/// Draw boxes and balls visualization (stars and bars)
///
/// Parameters:
/// - theme: Theme dictionary
/// - n-boxes: Number of boxes
/// - counts: Array of ball counts per box
/// - x, y: Position offset
/// - label: Optional label below
#let draw-boxes(
  theme: (:),
  n-boxes,
  counts,
  x: 0,
  y: 0,
  label: none,
) = {
  import cetz.draw: *

  let stroke-col = theme.at("plot", default: (:)).at("stroke", default: black)
  let fill-col = theme.at("plot", default: (:)).at("highlight", default: blue)

  let box-width = 1.2
  let box-height = 2.5
  let spacing = 0.5
  let ball-radius = 0.25
  let start-x = float(x)
  let start-y = float(y)

  for i in range(n-boxes) {
    let current-x = start-x + i * (box-width + spacing)
    let n-balls = counts.at(i, default: 0)

    // Draw box (U shape)
    line(
      (current-x, start-y + box-height),
      (current-x, start-y),
      (current-x + box-width, start-y),
      (current-x + box-width, start-y + box-height),
      stroke: (paint: stroke-col, thickness: 1.5pt),
    )

    // Draw balls
    for b in range(n-balls) {
      let ball-cx = current-x + (box-width / 2)
      let ball-cy = start-y + ball-radius + (b * ball-radius * 2.1)
      circle((ball-cx, ball-cy), radius: ball-radius * 0.85, fill: fill-col, stroke: none)
    }
  }

  if label != none {
    let total-width = (n-boxes * box-width) + ((n-boxes - 1) * spacing)
    let center-x = start-x + (total-width / 2)
    content((center-x, start-y - 0.5), text(fill: stroke-col, label))
  }
}

/// Draw linear arrangement (permutation)
///
/// Parameters:
/// - theme: Theme dictionary
/// - items: Array of items to display
/// - x, y: Position offset
/// - label: Optional label below
#let draw-linear(
  theme: (:),
  items,
  x: 0,
  y: 0,
  label: none,
) = {
  import cetz.draw: *

  let stroke-col = theme.at("text-accent", default: gray)
  let text-col = theme.at("text-main", default: black)

  let ball-radius = 0.4
  let spacing = 0.4
  let start-x = float(x)
  let start-y = float(y)

  for (i, item) in items.enumerate() {
    let current-x = start-x + i * (ball-radius * 2 + spacing)

    circle(
      (current-x, start-y),
      radius: ball-radius,
      stroke: (paint: stroke-col, thickness: 1.5pt),
      fill: none,
    )

    content((current-x, start-y), text(fill: text-col, weight: "bold")[#item])
  }

  if label != none {
    let total-width = (items.len() * ball-radius * 2) + ((items.len() - 1) * spacing)
    let center-x = start-x + (total-width / 2) - ball-radius
    content((center-x, start-y - 1), text(fill: stroke-col, label))
  }
}

/// Draw circular arrangement
///
/// Parameters:
/// - theme: Theme dictionary
/// - items: Array of items
/// - x, y: Center position
/// - radius: Circle radius
/// - label: Optional center label
#let draw-circular(
  theme: (:),
  items,
  x: 0,
  y: 0,
  radius: 1.5,
  label: none,
) = {
  import cetz.draw: *

  let fill-col = theme.at("plot", default: (:)).at("highlight", default: blue)
  let grid-col = theme.at("plot", default: (:)).at("stroke", default: black)
  let text-col = theme.at("text-main", default: black)

  let n = items.len()
  let ball-radius = 0.4
  let start-x = float(x)
  let start-y = float(y)

  // Dashed circle
  circle(
    (start-x, start-y),
    radius: radius,
    stroke: (paint: grid-col, dash: "dashed", thickness: 0.5pt),
  )

  // Items around circle
  for (i, item) in items.enumerate() {
    let angle = 90deg - (i * 360deg / n)
    let cx = start-x + radius * calc.cos(angle)
    let cy = start-y + radius * calc.sin(angle)

    circle((cx, cy), radius: ball-radius, fill: fill-col, stroke: none)
    content((cx, cy), text(fill: text-col, weight: "bold")[#item])
  }

  if label != none {
    content((start-x, start-y), text(fill: theme.at("text-accent", default: gray), weight: "bold", label))
  }
}
