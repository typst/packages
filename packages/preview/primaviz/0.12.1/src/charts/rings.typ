// rings.typ - Donut progress / fitness rings chart (Apple Watch style)
#import "../theme.typ": _resolve-ctx, get-color
#import "../util.typ": nonzero
#import "../validate.typ": validate-ring-data
#import "../primitives/container.typ": chart-container
#import "../primitives/layout.typ": resolve-size
#import "../primitives/polar.typ": place-arc-band, polar-pt
#import "../primitives/radial.typ": split-width

/// Concentric ring progress chart (fitness rings).
/// Outermost ring = first entry, innermost = last.
/// Rings that exceed 100 % wrap around (overlap), the head of the second
/// lap marked with a thin outline.
///
/// - entries (array): Array of dicts with `name`, `value`, and `max`
/// - size (length): Outer diameter of the ring stack
/// - title (none, content): Optional chart title
/// - ring-width (length): Stroke thickness of each ring
/// - gap (length): Gap between concentric rings
/// - show-labels (bool): Display entry names beside the rings
/// - show-values (bool): Display each entry's value and max
/// - theme (none, dictionary): Theme overrides
/// -> content
#let ring-progress(
  entries,          // Array of dicts: ((name: "Move", value: 75, max: 100), ...)
  size: 150pt,
  title: none,
  ring-width: 12pt,
  gap: 4pt,
  show-labels: true,
  show-values: true,
  theme: none,
) = context {
  layout(avail => {
  validate-ring-data(entries, "ring-progress")
  let t = _resolve-ctx(theme)
  let size = resolve-size(size, size, avail).width
  let n = entries.len()
  let colors = array.range(n).map(i => get-color(t, i))
  let bg = if t.background != none { t.background } else { white }
  let pct(e) = calc.round(e.value / nonzero(e.max) * 100, digits: 0)

  // Label column: swatch, name, and value / max under it
  let sw = t.legend-swatch-size
  let name-text(e) = text(size: t.legend-size, weight: "bold", fill: t.text-color)[#e.name]
  let value-text(e) = text(size: t.value-label-size, fill: t.text-color-light)[#e.value / #e.max (#pct(e)%)]
  let col-w = if show-labels {
    sw + 6pt + 2pt + calc.max(..entries.map(e => calc.max(measure(name-text(e)).width, if show-values { measure(value-text(e)).width } else { 0pt })))
  } else { 0pt }
  let (size, side) = split-width(size, if show-labels { 14pt + col-w } else { 0pt }, avail.width, t)
  let col-w = if show-labels { side - 14pt } else { 0pt }
  let total-w = size + side

  // Too many rings for the radius: thinner rings, not missing ones
  let span = n * ring-width + (n - 1) * gap
  let fit = calc.min(1, (size / 2 * 0.85) / span)
  let (ring-width, gap) = (ring-width * fit, gap * fit)

  let label-col = if show-labels {
    grid(columns: (sw, col-w - sw - 6pt), column-gutter: 6pt, row-gutter: 8pt, align: left + horizon,
      ..entries.enumerate().map(((i, e)) => (
        box(width: sw, height: sw, fill: colors.at(i), radius: 2pt),
        stack(dir: ttb, spacing: 2pt, name-text(e), if show-values { value-text(e) }),
      )).flatten())
  }
  // Many entries make the label column taller than the rings: the box grows
  // to hold it and the rings stay centred
  let label-h = if show-labels { measure(label-col).height } else { 0pt }
  let body-h = calc.max(size, label-h)
  let (cx, cy) = (size / 2, body-h / 2)

  align(center, chart-container(total-w, body-h, title, t)[
    #box(width: total-w, height: body-h)[
      #for (i, e) in entries.enumerate() {
        let r = size / 2 - ring-width / 2 - i * (ring-width + gap)
        let progress = e.value / nonzero(e.max)
        // The ring's track is its colour, faded into the background
        place-arc-band(cx, cy, r, ring-width, -90, 270, color.mix((colors.at(i), 20%), (bg, 80%)))
        if progress > 0 {
          place-arc-band(cx, cy, r, ring-width, -90, -90 + calc.min(progress, 1) * 360, colors.at(i), round: true)
        }
        if progress > 1 {
          // Second lap: the head rides over the first, so it needs an edge
          let (hx, hy) = polar-pt(cx, cy, r, -90 + calc.min(progress - 1, 1) * 360)
          place(left + top, dx: hx - ring-width / 2, dy: hy - ring-width / 2,
            circle(radius: ring-width / 2, fill: colors.at(i), stroke: 1pt + bg))
        }
      }
      #if show-labels {
        place(left + top, dx: size + 14pt, dy: (body-h - label-h) / 2, box(width: col-w, height: label-h, label-col))
      }
    ]
  ])
  })
}
