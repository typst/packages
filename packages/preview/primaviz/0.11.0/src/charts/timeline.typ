// timeline.typ - Vertical event timeline chart
#import "../theme.typ": _resolve-ctx, get-color
#import "../validate.typ": validate-timeline-data
#import "../primitives/container.typ": chart-container
#import "../primitives/layout.typ": resolve-size

/// Renders a vertical event timeline — a series of dated events along a
/// central vertical line, alternating left and right for visual variety.
///
/// Ideal for changelogs, milestone trackers, project histories, and roadmaps.
///
/// - data (dictionary): Must contain `events` array. Each event is a dict with
///   `date` (str), `title` (str), and optional `description` (str) and
///   `category` (str) for color coding.
/// - width (length): Chart width
/// - event-gap (length): Vertical spacing between events
/// - title (none, content): Optional chart title
/// - marker-size (length): Diameter of event marker circles
/// - theme (none, dictionary): Theme overrides
/// -> content
#let timeline-chart(
  data,
  width: auto,
  event-gap: 60pt,
  title: none,
  marker-size: 12pt,
  theme: none,
) = context {
  layout(size => {
  validate-timeline-data(data, "timeline-chart")
  let t = _resolve-ctx(theme)
  let width = resolve-size(width, 0pt, size, n: 10, theme: t).width
  let events = data.events

  // Auto-compute height from event count
  let chart-height = events.len() * event-gap + 40pt

  // Center x position for the vertical spine
  let center-x = width / 2

  // Horizontal arm from the spine, then an 8pt gap before the text
  let arm-length = 20pt
  let text-gap = 8pt
  // Content area for left/right text: from the chart edge (10pt margin) to the gap
  let text-area-width = center-x - arm-length - text-gap - 10pt

  // Build category-to-color mapping for optional color coding
  let category-names = ()
  for ev in events {
    if "category" in ev {
      if ev.category not in category-names {
        category-names.push(ev.category)
      }
    }
  }

  chart-container(width, chart-height, title, t, extra-height: 20pt)[
    #box(width: width, height: chart-height)[
      // Central vertical line (spine)
      #place(
        left + top,
        dx: center-x,
        dy: 10pt,
        line(
          start: (0pt, 0pt),
          end: (0pt, chart-height - 20pt),
          stroke: 1.5pt + t.text-color-light,
        ),
      )

      // Events
      #for (i, ev) in events.enumerate() {
        let y-pos = i * event-gap + 20pt
        let is-left = calc.rem(i, 2) == 0

        // Determine color
        let color-idx = if category-names.len() > 0 and "category" in ev {
          let idx = category-names.position(c => c == ev.category)
          if idx == none { i } else { idx }
        } else {
          i
        }
        let marker-color = get-color(t, color-idx)

        // Connecting line from spine to marker (horizontal arm)
        place(
          left + top,
          dx: if is-left { center-x - arm-length } else { center-x },
          dy: y-pos,
          line(
            start: (0pt, 0pt),
            end: (arm-length, 0pt),
            stroke: 1pt + t.text-color-light,
          ),
        )

        // Marker circle on the spine
        place(
          left + top,
          dx: center-x - marker-size / 2,
          dy: y-pos - marker-size / 2,
          circle(
            radius: marker-size / 2,
            fill: marker-color,
            stroke: t.marker-stroke,
          ),
        )

        // Text content (date, title, description)
        let text-x = if is-left {
          // Right-align text to the left of the arm
          10pt
        } else {
          // Left-align text to the right of the arm
          center-x + arm-length + text-gap
        }

        let text-align = if is-left { right } else { left }

        // Date (small, muted), title (bold) and optional description, stacked
        // as one block centred on the arm so long titles push lines apart
        // instead of overlapping them
        let lines = (
          text(size: t.axis-label-size, fill: t.text-color-light, weight: "medium")[#ev.date],
          text(size: t.value-label-size, fill: t.text-color, weight: "bold")[#ev.title],
        )
        if "description" in ev {
          lines.push(text(size: t.axis-label-size, fill: t.text-color-light)[#ev.description])
        }
        let block-body = box(width: text-area-width,
          stack(dir: ttb, spacing: t.axis-label-size * 0.45, ..lines.map(l => align(text-align, l))))
        place(
          left + top,
          dx: text-x,
          dy: y-pos - measure(block-body).height / 2,
          block-body,
        )
      }
    ]
  ]
  })
}
