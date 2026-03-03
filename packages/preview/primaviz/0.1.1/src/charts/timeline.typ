// timeline.typ - Vertical event timeline chart
#import "../theme.typ": resolve-theme, get-color
#import "../validate.typ": validate-timeline-data
#import "../primitives/container.typ": chart-container

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
/// - marker-size (length): Radius of event marker circles
/// - theme (none, dictionary): Theme overrides
/// -> content
#let timeline-chart(
  data,
  width: 350pt,
  event-gap: 60pt,
  title: none,
  marker-size: 6pt,
  theme: none,
) = {
  validate-timeline-data(data, "timeline-chart")
  let t = resolve-theme(theme)
  let events = data.events

  // Auto-compute height from event count
  let chart-height = events.len() * event-gap + 40pt

  // Center x position for the vertical spine
  let center-x = width / 2

  // Content area for left/right text
  let text-area-width = center-x - marker-size - 20pt

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
          stroke: 1.5pt + luma(200),
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
        let arm-length = 20pt
        let arm-start-x = if is-left { center-x - arm-length } else { center-x + arm-length }

        place(
          left + top,
          dx: if is-left { center-x - arm-length } else { center-x },
          dy: y-pos + marker-size / 2,
          line(
            start: (0pt, 0pt),
            end: (arm-length, 0pt),
            stroke: 1pt + luma(200),
          ),
        )

        // Marker circle on the spine
        place(
          left + top,
          dx: center-x - marker-size,
          dy: y-pos - marker-size / 2,
          circle(
            radius: marker-size,
            fill: marker-color,
            stroke: 1pt + white,
          ),
        )

        // Text content (date, title, description)
        let text-x = if is-left {
          // Right-align text to the left of the arm
          10pt
        } else {
          // Left-align text to the right of the arm
          center-x + arm-length + 8pt
        }

        let text-align = if is-left { right } else { left }

        // Date label (small, muted)
        place(
          left + top,
          dx: text-x,
          dy: y-pos - 10pt,
          box(width: text-area-width, height: auto)[
            #set align(text-align)
            #text(size: t.axis-label-size, fill: luma(120), weight: "medium")[#ev.date]
          ],
        )

        // Title (bold)
        place(
          left + top,
          dx: text-x,
          dy: y-pos + 2pt,
          box(width: text-area-width, height: auto)[
            #set align(text-align)
            #text(size: t.value-label-size, fill: t.text-color, weight: "bold")[#ev.title]
          ],
        )

        // Description (optional, smaller)
        if "description" in ev {
          place(
            left + top,
            dx: text-x,
            dy: y-pos + 16pt,
            box(width: text-area-width, height: auto)[
              #set align(text-align)
              #text(size: t.axis-label-size, fill: luma(100))[#ev.description]
            ],
          )
        }
      }
    ]
  ]
}
