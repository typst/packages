// radar.typ - Radar/spider charts
#import "../theme.typ": _resolve-ctx, get-color
#import "../util.typ": nonzero
#import "../validate.typ": validate-series-data
#import "../primitives/container.typ": chart-container
#import "../primitives/layout.typ": resolve-size
#import "../primitives/polar.typ": polar-pt
#import "../primitives/polar-labels.typ": legible, polar-fit-radius, polar-label-extent, place-outside-labels, wrap-label
#import "../primitives/radial.typ": side-legend, split-width

/// Renders a radar (spider) chart for comparing series across multiple axes.
///
/// The plot is as large as the axis labels allow: they are measured, and sit
/// just beyond their spoke without touching the polygon, the scale or each
/// other. With one series, each axis label carries that series' value.
///
/// - data (dictionary): Dict with `labels` (axis names) and `series` (each with `name` and `values`)
/// - size (length): Diameter of the radar chart
/// - axis-max-value (none, number): Fixed maximum for every axis; `none` uses the largest data value
/// - title (none, content): Optional chart title
/// - show-legend (bool): Show series legend
/// - show-value-labels (bool): Display scale values and data point labels
/// - fill-opacity (ratio): Opacity of the filled data area
/// - theme (none, dictionary): Theme overrides
/// - extra-legend-separation (length): Extra space between legend and chart
/// -> content
#let radar-chart(
  data,
  size: 200pt,
  axis-max-value: none,
  title: none,
  show-legend: true,
  show-value-labels: true,
  fill-opacity: 15%,
  theme: none,
  extra-legend-separation: 0pt
) = context {
  layout(avail => {
  validate-series-data(data, "radar-chart")
  let t = _resolve-ctx(theme)
  let size = resolve-size(size, size, avail).width
  let labels = data.labels
  let series = data.series
  let n = labels.len()
  let single = series.len() == 1

  let all-values = series.map(s => s.values).flatten()
  let max-val = nonzero(if axis-max-value == none { calc.max(..all-values) } else { axis-max-value })
  let bg = if t.background != none { t.background } else { white }

  // Legend column (several series only); the chart shrinks first if narrow
  let lg = side-legend(series.map(s => s.name), t,
    enabled: show-legend and t.legend-position != "none" and series.len() > 1, max-width: 120pt)
  let legend-side = if lg.legend != none { 10pt + lg.width + extra-legend-separation } else { 0pt }
  let (size, _) = split-width(size, legend-side, avail.width, t)
  let (cx, cy) = (size / 2, size / 2)

  // Axis labels: the name, and with one series, its value under it
  // (a long name wraps instead of shrinking the plot)
  let angle-of(i) = -90 + i / n * 360
  let axis-items-at(label-size) = labels.enumerate().map(((i, lbl)) => {
    let name = text(size: label-size, fill: t.text-color, top-edge: "cap-height", bottom-edge: "descender")[#lbl]
    let name = wrap-label(name, calc.max(60pt, size * 0.3), angle-of(i))
    let body = if single and show-value-labels {
      let v = text(size: label-size, weight: "bold", fill: legible(get-color(t, 0), bg),
        top-edge: "cap-height", bottom-edge: "descender")[#series.at(0).values.at(i)]
      stack(dir: ttb, spacing: 2pt, name, v)
    } else { name }
    (angle: angle-of(i), body: body)
  })
  // The largest type that still leaves the plot most of the box (a small
  // chart gets smaller labels rather than a small plot), down to the theme's floor
  let floor-size = t.at("category-label-min-size", default: 5pt)
  let sizes = (if n > 12 { () } else { (t.legend-size,) }) + (t.axis-label-size, t.axis-label-size * 0.85, floor-size)
  let sizes = sizes.filter(sz => sz >= floor-size).dedup()
  let (axis-items, radius, label-size) = {
    let best = none
    for sz in sizes {
      let items = axis-items-at(sz)
      let r = polar-fit-radius(items, cx, cy, size, size, gap: 5pt, pad: 1pt)
      if best == none or r > best.at(1) { best = (items, r, sz) }
      if r >= 0.3 * size { break }
    }
    best
  }
  // The scale is read after the axis names, never in larger type
  let scale-size = calc.min(t.axis-label-size, label-size)
  // The labels may leave the plot wider than tall: trim the empty height
  let box-h = calc.min(size, 2 * polar-label-extent(axis-items, radius, gap: 5pt).y)
  let cy = box-h / 2

  // Scale labels: fractions of the maximum, in the fewest digits that tell them apart
  let scale-label(level) = {
    let v = max-val * level / 4
    str(calc.round(v, digits: if max-val >= 20 { 0 } else if max-val >= 2 { 1 } else { 2 }))
  }

  align(center, chart-container(size, box-h, title, lg.theme,
    legend: lg.legend, legend-width: lg.width, extra-legend-separation: extra-legend-separation)[
    #box(width: size, height: box-h)[
      // Grid rings
      #for level in array.range(1, 5) {
        let r = radius * level / 4
        place(left + top, polygon(fill: none, stroke: t.grid-stroke,
          ..array.range(n).map(i => polar-pt(cx, cy, r, angle-of(i)))))
      }
      // Spokes
      #for i in array.range(n) {
        place(left + top, line(start: (cx, cy), end: polar-pt(cx, cy, radius, angle-of(i)), stroke: t.grid-stroke))
      }
      // Data
      #for (si, s) in series.enumerate() {
        let color = get-color(t, si)
        let pts = s.values.enumerate().map(((i, val)) => polar-pt(cx, cy, val / max-val * radius, angle-of(i)))
        let dot-r = calc.max(1pt, size / 100)
        place(left + top, polygon(fill: color.transparentize(100% - fill-opacity),
          stroke: color + calc.max(0.4pt, size / 250), ..pts))
        for pt in pts {
          place(left + top, dx: pt.at(0) - dot-r, dy: pt.at(1) - dot-r,
            circle(radius: dot-r, fill: color, stroke: t.marker-stroke))
        }
      }

      // Scale, hanging just under each ring beside the first spoke, over the
      // data on a page-coloured plate so a series line never strikes a number
      #if show-value-labels {
        // (every other ring when four would touch)
        let step = if radius / 4 >= scale-size * 1.4 { 1 } else { 2 }
        for level in array.range(1, 5).filter(l => calc.rem(4 - l, step) == 0) {
          place(left + top, dx: cx + 0.5pt, dy: cy - radius * level / 4 + 0.5pt,
            box(fill: bg.transparentize(10%), inset: (x: 1.5pt, y: 0.5pt), radius: 1pt,
              text(size: scale-size, fill: t.text-color-light, top-edge: "cap-height", bottom-edge: "baseline")[#scale-label(level)]))
        }
      }

      // Axis labels last, on top
      #place-outside-labels(axis-items, cx, cy, radius, (left: 0pt, right: size, top: 0pt, bottom: box-h), gap: 5pt,
        leader-stroke: 0.5pt + t.text-color-light)
    ]
  ])
  })
}
