// =====================================================
// TIMELINE DRAW FUNCTIONS
// =====================================================
// Draw timeline objects on a CeTZ canvas

#import "@preview/cetz:0.4.2"
#import "timeline.typ": is-event, is-timeline

/// Draw a timeline on a CeTZ canvas
///
/// Parameters:
/// - tl: Timeline object created with timeline()
/// - theme: Theme dictionary for colors
#let draw-timeline(tl, theme: (:)) = {
  import cetz.draw: *

  let events = tl.events
  let direction = tl.direction
  let style = tl.style

  // Default colors
  let line-color = style.at("line-color", default: theme.at("text-muted", default: gray))
  let node-color = style.at("node-color", default: theme.at("text-accent", default: blue))
  let highlight-color = style.at("highlight-color", default: theme.at("text-accent", default: orange))
  let text-color = style.at("text-color", default: theme.at("text-main", default: black))

  let node-radius = style.at("node-radius", default: 0.12)
  let spacing = style.at("spacing", default: 1.5)
  let line-width = style.at("line-width", default: 1.5pt)

  let n = events.len()
  if n == 0 { return }

  if direction == "vertical" {
    // Draw main line
    line(
      (0, 0),
      (0, -(n - 1) * spacing),
      stroke: line-width + line-color,
    )

    // Draw events
    for (i, evt) in events.enumerate() {
      let y = -i * spacing
      let color = if evt.highlight { highlight-color } else { node-color }

      // Node
      circle((0, y), radius: node-radius, fill: color, stroke: none)

      // Date (left side)
      content(
        (-0.3, y),
        text(size: 0.8em, fill: text-color, weight: "bold")[#evt.date],
        anchor: "east",
      )

      // Title (right side)
      content(
        (0.3, y),
        text(size: 0.9em, fill: text-color)[#evt.title],
        anchor: "west",
      )

      // Description (below title, if present)
      if evt.description != none {
        content(
          (0.3, y - 0.25),
          text(size: 0.7em, fill: luma(100))[#evt.description],
          anchor: "north-west",
        )
      }
    }
  } else {
    // Horizontal layout
    line(
      (0, 0),
      ((n - 1) * spacing, 0),
      stroke: line-width + line-color,
    )

    for (i, evt) in events.enumerate() {
      let x = i * spacing
      let color = if evt.highlight { highlight-color } else { node-color }

      // Node
      circle((x, 0), radius: node-radius, fill: color, stroke: none)

      // Date (above)
      content(
        (x, 0.3),
        text(size: 0.75em, fill: text-color, weight: "bold")[#evt.date],
        anchor: "south",
      )

      // Title (below)
      content(
        (x, -0.3),
        text(size: 0.8em, fill: text-color)[#evt.title],
        anchor: "north",
      )
    }
  }
}
