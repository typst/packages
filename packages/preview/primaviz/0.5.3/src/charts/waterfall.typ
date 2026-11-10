// waterfall.typ - Waterfall chart (bridge chart)
#import "../theme.typ": _resolve-ctx, get-color
#import "../util.typ": normalize-data, format-number, nonzero, nice-ceil
#import "../validate.typ": validate-simple-data
#import "../primitives/container.typ": chart-container
#import "../primitives/axes.typ": cartesian-layout, draw-axis-lines, draw-grid, draw-axis-titles, draw-y-ticks, draw-x-category-labels, measure-y-tick-width
#import "../primitives/legend.typ": draw-legend
#import "../primitives/layout.typ": resolve-size

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
/// - theme (none, dictionary): Theme overrides
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
  theme: none,
) = context {
  layout(size => {
  validate-simple-data(data, "waterfall-chart")
  let t = _resolve-ctx(theme)
  let norm = normalize-data(data)
  let labels = norm.labels
  let values = norm.values
  let n = values.len()
  let (width, height) = resolve-size(width, height, size, n: n, theme: t)

  // Resolve colors — check theme passthrough keys, then params, then defaults
  let has-dark-bg = t.background != none
  let pos-color = if positive-color != none { positive-color }
    else if "positive-color" in t { t.positive-color }
    else if has-dark-bg { rgb("#4ade80") } else { rgb("#16a34a") }
  let neg-color = if negative-color != none { negative-color }
    else if "negative-color" in t { t.negative-color }
    else if has-dark-bg { rgb("#f87171") } else { rgb("#dc2626") }
  let tot-color = if total-color != none { total-color } else { get-color(t, 0) }

  // Determine types: auto-detect if not provided
  let types = if type(data) == dictionary and "types" in data {
    data.types
  } else {
    let result = ()
    for i in array.range(n) {
      if i == 0 or i == n - 1 {
        result.push("total")
      } else if values.at(i) >= 0 {
        result.push("pos")
      } else {
        result.push("neg")
      }
    }
    result
  }

  // Compute running totals and bar positions
  // Each bar has a y-start and y-end
  let running = 0
  let bar-starts = ()
  let bar-ends = ()
  for i in array.range(n) {
    let tp = types.at(i)
    if tp == "total" or tp == "subtotal" {
      // Total/subtotal bars go from 0 to the current value
      bar-starts.push(0)
      bar-ends.push(values.at(i))
      running = values.at(i)
    } else {
      // Incremental bars: start at running total, end at running + value
      let start = running
      let end = running + values.at(i)
      bar-starts.push(start)
      bar-ends.push(end)
      running = end
    }
  }

  // Find min and max across all bar boundaries
  let all-points = bar-starts + bar-ends
  all-points.push(0)
  let min-val = calc.min(..all-points)
  let max-val = calc.max(..all-points)

  let y-min = calc.min(0, min-val)
  let y-max = nice-ceil(max-val)
  let y-range = y-max - y-min

  let cl = cartesian-layout(width, height, t)

  // Extra height only for content outside the chart box (legend)
  // Category labels + axis title fit within axis-padding-bottom
  let extra-h = if show-legend { t.legend-size + t.legend-gap + t.legend-swatch-size } else { 0pt }

  chart-container(width, height, title, t, extra-height: extra-h)[
    #let pad-top = cl.pad-top
    #let chart-height = cl.chart-height
    #let chart-width = cl.chart-width
    #let origin-x = cl.origin-x
    #let origin-y = cl.origin-y

    #box(width: width, height: height)[
      // Grid
      #draw-grid(origin-x, pad-top, chart-width, chart-height, t)

      // Y-axis ticks
      #draw-y-ticks(y-min, y-max, chart-height, pad-top, origin-x, t, digits: 0)

      // Spacing per bar
      #let spacing = chart-width / n
      #let actual-bw = spacing * bar-width

      // Helper: convert value to y-position
      #let val-to-y(v) = {
        pad-top + chart-height - ((v - y-min) / y-range) * chart-height
      }

      // Draw connector lines, bars, and value labels
      #for i in array.range(n) {
        let tp = types.at(i)
        let y-s = bar-starts.at(i)
        let y-e = bar-ends.at(i)
        let y-top = calc.max(y-s, y-e)
        let y-bot = calc.min(y-s, y-e)

        let x-pos = origin-x + i * spacing + (spacing - actual-bw) / 2
        let bar-top-px = val-to-y(y-top)
        let bar-bot-px = val-to-y(y-bot)
        let bar-h = bar-bot-px - bar-top-px

        // Pick color
        let fill-color = if tp == "total" or tp == "subtotal" {
          tot-color
        } else if values.at(i) >= 0 {
          pos-color
        } else {
          neg-color
        }

        // Draw bar
        place(left + top, dx: x-pos, dy: bar-top-px,
          rect(width: actual-bw, height: bar-h, fill: fill-color, stroke: none)
        )

        // Value label
        if show-values {
          let val = values.at(i)
          let label-y = bar-top-px - t.value-label-size * 1.5
          place(left + top, dx: x-pos, dy: label-y,
            box(width: actual-bw, align(center,
              text(size: t.value-label-size, fill: t.text-color)[#format-number(val, digits: 0, mode: t.number-format)])))

        }

        // Connector line to next bar
        if show-connectors and i < n - 1 {
          let next-tp = types.at(i + 1)
          // Connector goes from the end-value of this bar to the start of the next bar
          let connector-y-val = y-e
          // If next bar is total/subtotal, connector goes to its start (0), which is different
          // We only draw connector if next bar is NOT a total (totals start from 0)
          if next-tp != "total" and next-tp != "subtotal" {
            let connector-y-px = val-to-y(connector-y-val)
            let x-end = x-pos + actual-bw
            let x-next-start = origin-x + (i + 1) * spacing + (spacing - actual-bw) / 2
            place(left + top,
              line(
                start: (x-end, connector-y-px),
                end: (x-next-start, connector-y-px),
                stroke: t.grid-stroke,
              )
            )
          }
        }

        // X-axis label — use full slot width for longer labels
        let slot-x = origin-x + i * spacing
        place(left + top, dx: slot-x, dy: origin-y + t.axis-label-size * 0.3,
          box(width: spacing, height: t.axis-label-size * 1.8, align(center,
            text(size: t.axis-label-size, fill: t.text-color)[#labels.at(i)])))

      }

      // Axes (drawn after bars so axis lines appear on top)
      #draw-axis-lines(origin-x, origin-y, origin-x + chart-width, pad-top, t)

      // Axis titles
      #let y-tw = measure-y-tick-width(y-min, y-max, t, digits: 0)
      #draw-axis-titles(x-label, y-label, origin-x + chart-width / 2, pad-top + chart-height / 2, t, origin-x: origin-x, origin-y: origin-y, y-tick-width: y-tw)
    ]

    // Color key legend
    #if show-legend {
      draw-legend(
        ((name: "Increase", color: pos-color), (name: "Decrease", color: neg-color), (name: "Total", color: tot-color)),
        t,
      )
    }
  ]
  })
}
