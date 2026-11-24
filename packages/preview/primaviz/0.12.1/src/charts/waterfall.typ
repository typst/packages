// waterfall.typ - Waterfall chart (bridge chart)
#import "../theme.typ": _resolve-ctx, get-color, _is-dark
#import "../util.typ": normalize-data
#import "../validate.typ": validate-simple-data
#import "../primitives/frame.typ": cartesian-frame
#import "../primitives/axes.typ": value-axis, category-axis, fit-label-size, value-text
#import "../primitives/legend.typ": draw-legend
#import "../primitives/layout.typ": resolve-size, pin

/// Renders a waterfall (bridge) chart showing cumulative effect of positive and negative values.
///
/// - data (dictionary, array): Label-value pairs; optionally include a `types` array with `"total"`, `"pos"`, or `"neg"` per bar
/// - width (length): Chart width
/// - height (length): Chart height
/// - title (none, content): Optional chart title
/// - show-values (bool): Display value labels above bars
/// - show-connectors (bool): Draw connector lines between bars
/// - bar-width (float): Bar width as fraction of slot (0 to 1)
/// - positive-color (none, color): Override color for positive bars
/// - negative-color (none, color): Override color for negative bars
/// - total-color (none, color): Override color for total bars
/// - x-label (none, content): X-axis title
/// - y-label (none, content): Y-axis title
/// - annotations (none, array): Optional annotation descriptors
/// - show-legend (bool): Show a legend of the positive, negative, and total bar colors
/// - theme (none, dictionary): Theme overrides
/// - extra-legend-separation (length): Extra space between legend and chart
/// -> content
#let waterfall-chart(
  data,
  width: auto,
  height: auto,
  title: none,
  show-values: true,
  show-connectors: true,
  bar-width: 0.5,
  positive-color: none,
  negative-color: none,
  total-color: none,
  show-legend: false,
  x-label: none,
  y-label: none,
  annotations: none,
  theme: none,
  extra-legend-separation: 0pt
) = context {
  layout(size => {
  validate-simple-data(data, "waterfall-chart")
  let t = _resolve-ctx(theme)
  let norm = normalize-data(data)
  let (labels, values) = (norm.labels, norm.values)
  let n = values.len()
  let (width, height) = resolve-size(width, height, size, n: n, theme: t)

  // Resolve colors — check theme passthrough keys, then params, then defaults
  let has-dark-bg = _is-dark(t)
  let pos-color = if positive-color != none { positive-color }
    else if "positive-color" in t { t.positive-color }
    else if has-dark-bg { rgb("#4ade80") } else { rgb("#16a34a") }
  let neg-color = if negative-color != none { negative-color }
    else if "negative-color" in t { t.negative-color }
    else if has-dark-bg { rgb("#f87171") } else { rgb("#dc2626") }
  let tot-color = if total-color != none { total-color } else { get-color(t, 0) }

  // Types: auto-detect if not provided (first and last bars are totals)
  let types = if type(data) == dictionary and "types" in data {
    data.types
  } else {
    range(n).map(i => if i == 0 or i == n - 1 { "total" } else if values.at(i) >= 0 { "pos" } else { "neg" })
  }
  let is-total(i) = types.at(i) == "total" or types.at(i) == "subtotal"

  // Each bar runs from `starts` to `ends`: totals from zero, steps from the running total
  let (starts, ends) = ((), ())
  let running = 0
  for i in range(n) {
    let from = if is-total(i) { 0 } else { running }
    let to = if is-total(i) { values.at(i) } else { running + values.at(i) }
    starts.push(from)
    ends.push(to)
    running = to
  }
  let all-points = starts + ends + (0,)

  cartesian-frame(width, height, t,
    x: category-axis(labels, title: x-label),
    y: value-axis(calc.min(..all-points), calc.max(..all-points), title: y-label),
    baseline: (y: 0), annotations: annotations,
    title: title, extra-legend-separation: extra-legend-separation,
    legend: if show-legend {
      draw-legend(((name: "Increase", color: pos-color), (name: "Decrease", color: neg-color), (name: "Total", color: tot-color)), t)
    },
    reserve: (top: if show-values { t.value-label-size + t.label-offset } else { 0pt }),
    p => {
      let (px, py) = (p.px, p.py)
      let bw = p.X.pitch * bar-width
      let strs = values.map(v => value-text(v, t))
      let vsize = fit-label-size(strs, p.X.pitch, t.value-label-size)
      for i in range(n) {
        let (top-y, bottom-y) = (py(calc.max(starts.at(i), ends.at(i))), py(calc.min(starts.at(i), ends.at(i))))
        let fill-color = if is-total(i) { tot-color } else if values.at(i) >= 0 { pos-color } else { neg-color }
        place(left + top, dx: px(i) - bw / 2, dy: top-y,
          rect(width: bw, height: bottom-y - top-y, fill: fill-color, stroke: none))

        if show-values and vsize != none {
          place(left + top, dx: px(i) - p.X.pitch / 2, dy: top-y - t.label-offset,
            pin(width: p.X.pitch, align: center + bottom, text(size: vsize, fill: t.text-color)[#strs.at(i)]))
        }

        // Connector from this bar's end to the next step's start (totals start from zero instead)
        if show-connectors and i < n - 1 and not is-total(i + 1) {
          let y = py(ends.at(i))
          place(left + top, line(start: (px(i) + bw / 2, y), end: (px(i + 1) - bw / 2, y), stroke: t.grid-stroke))
        }
      }
    },
  )
  })
}
