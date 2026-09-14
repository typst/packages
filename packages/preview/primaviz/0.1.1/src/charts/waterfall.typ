// waterfall.typ - Waterfall chart (bridge chart)
#import "../theme.typ": resolve-theme, get-color
#import "../util.typ": normalize-data, format-number
#import "../validate.typ": validate-waterfall-data
#import "../primitives/container.typ": chart-container
#import "../primitives/axes.typ": draw-axis-lines, draw-grid, draw-axis-titles, draw-y-ticks, draw-x-category-labels

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
  width: 400pt,
  height: 250pt,
  title: none,
  show-values: true,
  show-connectors: true,
  bar-width: 0.5,
  positive-color: none,
  negative-color: none,
  total-color: none,
  x-label: none,
  y-label: none,
  theme: none,
) = {
  validate-waterfall-data(data, "waterfall-chart")
  let t = resolve-theme(theme)
  let norm = normalize-data(data)
  let labels = norm.labels
  let values = norm.values
  let n = values.len()

  // Resolve colors
  let pos-color = if positive-color != none { positive-color } else { rgb("#59a14f") }
  let neg-color = if negative-color != none { negative-color } else { rgb("#e15759") }
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

  // Add some padding to the range
  let val-range = max-val - min-val
  if val-range == 0 { val-range = 1 }
  let padding = val-range * 0.1
  let y-min = min-val - padding
  let y-max = max-val + padding
  let y-range = y-max - y-min

  chart-container(width, height, title, t, extra-height: 30pt)[
    #let pad-left = t.axis-padding-left
    #let pad-bottom = t.axis-padding-bottom
    #let pad-top = t.axis-padding-top
    #let pad-right = t.axis-padding-right
    #let chart-height = height - pad-top - pad-bottom
    #let chart-width = width - pad-left - pad-right

    #box(width: width, height: height)[
      // Grid
      #draw-grid(pad-left, pad-top, chart-width, chart-height, t)

      // Axes
      #draw-axis-lines(pad-left, pad-top + chart-height, pad-left + chart-width, pad-top, t)

      // Y-axis ticks
      #draw-y-ticks(y-min, y-max, chart-height, pad-top, 0pt, t, digits: 0)

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

        let x-pos = pad-left + i * spacing + (spacing - actual-bw) / 2
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
          let label-y = bar-top-px - 12pt
          place(left + top, dx: x-pos + actual-bw / 2 - 10pt, dy: label-y,
            text(size: t.value-label-size, fill: t.text-color)[#format-number(val, digits: 0, mode: t.number-format)]
          )
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
            let x-next-start = pad-left + (i + 1) * spacing + (spacing - actual-bw) / 2
            place(left + top,
              line(
                start: (x-end, connector-y-px),
                end: (x-next-start, connector-y-px),
                stroke: 0.5pt + luma(180),
              )
            )
          }
        }

        // X-axis label
        place(left + top, dx: x-pos + actual-bw / 2 - 15pt, dy: pad-top + chart-height + 4pt,
          text(size: t.axis-label-size, fill: t.text-color)[#labels.at(i)]
        )
      }

      // Axis titles
      #draw-axis-titles(x-label, y-label, pad-left + chart-width / 2, pad-top + chart-height / 2, t)
    ]
  ]
}
