// =====================================================
// TIMELINE FIGURE
// =====================================================
// Standalone timeline figure without canvas context

#import "@preview/cetz:0.4.2"
#import "timeline.typ": event, is-event, timeline
#import "draw.typ": draw-timeline

/// Create a standalone timeline figure
///
/// Parameters:
/// - events: Array of event objects OR array of (date, title) tuples
/// - direction: "vertical" or "horizontal"
/// - width: Figure width (default: auto)
/// - theme: Theme colors
#let timeline-figure(
  events,
  direction: "vertical",
  width: auto,
  theme: (:),
) = {
  // Convert simple tuples to event objects if needed
  let processed-events = events.map(e => {
    if is-event(e) {
      e
    } else if type(e) == array and e.len() >= 2 {
      event(e.at(0), e.at(1), description: e.at(2, default: none))
    } else {
      e
    }
  })

  let tl = timeline(processed-events, direction: direction)

  let n = processed-events.len()
  let spacing = 1.5

  // Calculate canvas size
  let (canvas-width, canvas-height) = if direction == "vertical" {
    (6, n * spacing + 0.5)
  } else {
    (n * spacing + 1, 2)
  }

  let fig-width = if width == auto {
    if direction == "vertical" { 100% } else { 100% }
  } else {
    width
  }

  align(center, box(width: fig-width)[
    #cetz.canvas(length: 1cm, {
      import cetz.draw: *

      if direction == "vertical" {
        translate((2, canvas-height - 0.5))
      } else {
        translate((0.5, 1))
      }

      draw-timeline(tl, theme: theme)
    })
  ])
}
