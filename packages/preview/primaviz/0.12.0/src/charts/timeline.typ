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
/// Events are spaced `event-gap` apart, and pushed further apart where the
/// measured text of two events on the same side would otherwise overlap.
///
/// - data (dictionary): Must contain `events` array. Each event is a dict with
///   `date` (str), `title` (str), and optional `description` (str) and
///   `category` (str) for color coding.
/// - width (length): Chart width
/// - event-gap (auto, length): Vertical spacing between events; `auto` scales with the theme's `base-size` (7.5x, 60pt in the default theme)
/// - title (none, content): Optional chart title
/// - marker-size (auto, length): Diameter of event marker circles; `auto` scales with the theme's `base-size` (1.5x, 12pt in the default theme)
/// - theme (none, dictionary): Theme overrides
/// -> content
#let timeline-chart(
  data,
  width: auto,
  event-gap: auto,
  title: none,
  marker-size: auto,
  theme: none,
) = context {
  layout(size => {
  validate-timeline-data(data, "timeline-chart")
  let t = _resolve-ctx(theme)
  let event-gap = if event-gap == auto { 7.5 * t.base-size } else { event-gap }
  let marker-size = if marker-size == auto { 1.5 * t.base-size } else { marker-size }
  let width = resolve-size(width, 0pt, size, n: 10, theme: t).width
  let events = data.events

  // Center x position for the vertical spine
  let center-x = width / 2

  // Horizontal arm from the spine, then a gap before the text
  let arm-length = 20pt
  let text-gap = 8pt
  let margin = 10pt
  let text-area-width = calc.max(20pt, center-x - arm-length - text-gap - margin)

  // Category-to-color mapping for optional color coding
  let category-names = ()
  for ev in events {
    if "category" in ev and ev.category not in category-names { category-names.push(ev.category) }
  }

  // Date (small, muted), title (bold) and optional description, stacked as
  // one block; measured, so the spacing below can respect its real height
  let blocks = events.enumerate().map(((i, ev)) => {
    let is-left = calc.rem(i, 2) == 0
    let text-align = if is-left { right } else { left }
    let lines = (
      text(size: t.axis-label-size, fill: t.text-color-light, weight: "medium")[#ev.date],
      text(size: t.value-label-size, fill: t.text-color, weight: "bold")[#ev.title],
    )
    if "description" in ev {
      lines.push(text(size: t.axis-label-size, fill: t.text-color-light)[#ev.description])
    }
    let body = box(width: text-area-width,
      stack(dir: ttb, spacing: t.axis-label-size * 0.45, ..lines.map(l => align(text-align, l))))
    (body: body, h: measure(body).height)
  })

  // Event positions: `event-gap` apart, but never closer than the text of the
  // previous event on the same side (two back) or the previous marker allows
  let text-gap-v = t.axis-label-gap
  let ys = ()
  for (i, blk) in blocks.enumerate() {
    let y = calc.max(blk.h / 2 + 4pt, 20pt + i * event-gap)
    if i >= 1 { y = calc.max(y, ys.at(i - 1) + marker-size + 2pt) }
    if i >= 2 { y = calc.max(y, ys.at(i - 2) + (blocks.at(i - 2).h + blk.h) / 2 + text-gap-v) }
    ys.push(y)
  }
  let chart-height = ys.last() + calc.max(blocks.last().h / 2, marker-size / 2) + 20pt

  chart-container(width, chart-height, title, t)[
    #box(width: width, height: chart-height)[
      // Central vertical line (spine)
      #place(left + top, dx: center-x, dy: 10pt,
        line(start: (0pt, 0pt), end: (0pt, chart-height - 20pt), stroke: t.stroke-mid + t.text-color-light))

      #for (i, ev) in events.enumerate() {
        let y-pos = ys.at(i)
        let is-left = calc.rem(i, 2) == 0
        let color-idx = if category-names.len() > 0 and "category" in ev {
          let idx = category-names.position(c => c == ev.category)
          if idx == none { i } else { idx }
        } else { i }

        // Arm from the spine to the text
        place(left + top, dx: if is-left { center-x - arm-length } else { center-x }, dy: y-pos,
          line(start: (0pt, 0pt), end: (arm-length, 0pt), stroke: t.stroke-thin + t.text-color-light))

        // Marker on the spine
        place(left + top, dx: center-x - marker-size / 2, dy: y-pos - marker-size / 2,
          circle(radius: marker-size / 2, fill: get-color(t, color-idx), stroke: t.marker-stroke))

        let text-x = if is-left { margin } else { center-x + arm-length + text-gap }
        place(left + top, dx: text-x, dy: y-pos - blocks.at(i).h / 2, blocks.at(i).body)
      }
    ]
  ]
  })
}
