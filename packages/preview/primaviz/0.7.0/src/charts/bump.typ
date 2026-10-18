// bump.typ - Bump chart (multi-period ranking chart)
#import "../theme.typ": _resolve-ctx, get-color
#import "../util.typ": nonzero
#import "../validate.typ": validate-series-data
#import "../primitives/container.typ": chart-container
#import "../primitives/axes.typ": cartesian-layout, draw-axis-lines, draw-grid, draw-axis-titles, draw-x-even-labels
#import "../primitives/legend.typ": draw-legend-auto
#import "../primitives/layout.typ": resolve-size

/// Renders a bump chart showing how items change ranking over time periods.
///
/// Rankings are displayed with rank 1 at the top and rank N at the bottom
/// (inverted Y-axis). Each series is drawn as a thick colored line with dots
/// at each time period, similar to F1 race position charts.
///
/// - data (dictionary): Dict with `labels` (time periods) and `series`
///   (each with `name` and `values` representing rankings per period)
/// - width (length): Chart width
/// - height (length): Chart height
/// - title (none, content): Optional chart title
/// - dot-size (length): Diameter of point markers at each period
/// - line-width (length): Stroke width of ranking lines
/// - show-labels (bool): Show series name labels at start and end of lines
/// - show-legend (bool): Show series legend below the chart
/// - theme (none, dictionary): Theme overrides
/// - extra-legend-separation (length): Extra space between legend and chart
/// -> content
#let bump-chart(
  data,
  width: auto,
  height: auto,
  title: none,
  dot-size: 5pt,
  line-width: 2.5pt,
  show-labels: true,
  show-legend: true,
  theme: none,
  extra-legend-separation: 0pt
) = context {
  layout(size => {
  validate-series-data(data, "bump-chart")
  let t = _resolve-ctx(theme)
  let (width, height) = resolve-size(width, height, size, n: data.labels.len(), theme: t)
  let labels = data.labels
  let series = data.series

  let n = labels.len()
  if n == 0 { return }
  let n-series = series.len()
  if n-series == 0 { return }

  // Determine the rank range across all values
  let all-values = series.map(s => s.values).flatten()
  let min-rank = calc.min(..all-values)
  let max-rank = calc.max(..all-values)
  let rank-range = nonzero(max-rank - min-rank)

  let cl = cartesian-layout(width, height, t)

  let legend-content = draw-legend-auto(series.map(s => s.name), t, show-legend: show-legend, swatch-type: "line")
  chart-container(width, height, title, t, extra-height: 50pt, legend: legend-content, extra-legend-separation: extra-legend-separation)[
    #let pad-top = cl.pad-top
    #let chart-height = cl.chart-height
    #let chart-width = cl.chart-width
    #let origin-x = cl.origin-x
    #let origin-y = cl.origin-y

    #box(width: width, height: height)[
      // Grid
      #draw-grid(origin-x, pad-top, chart-width, chart-height, t)

      // Axes
      #draw-axis-lines(origin-x, origin-y, origin-x + chart-width, pad-top, t)

      // Draw each series as a thick line with dots
      #for (si, s) in series.enumerate() {
        let values = s.values
        let color = get-color(t, si)

        // Compute point positions
        // Y is inverted: rank 1 at top, max-rank at bottom
        let points = ()
        for (i, val) in values.enumerate() {
          let x = if n == 1 { origin-x + chart-width / 2 } else { origin-x + (i / (n - 1)) * chart-width }
          let y = pad-top + ((val - min-rank) / rank-range) * chart-height
          points.push((x, y))
        }

        // Draw connecting lines
        for i in array.range(calc.max(n - 1, 0)) {
          let p1 = points.at(i)
          let p2 = points.at(i + 1)
          place(
            left + top,
            line(
              start: (p1.at(0), p1.at(1)),
              end: (p2.at(0), p2.at(1)),
              stroke: line-width + color,
            )
          )
        }

        // Draw dots at each period
        for pt in points {
          place(
            left + top,
            dx: pt.at(0) - dot-size / 2,
            dy: pt.at(1) - dot-size / 2,
            circle(radius: dot-size / 2, fill: color, stroke: t.marker-stroke)
          )
        }

        // Labels at start and end of each series line
        if show-labels {
          let first-pt = points.at(0)
          place(
            left + top,
            dx: 0pt,
            dy: first-pt.at(1),
            box(width: origin-x - 4pt, height: 0pt,
              align(right, move(dy: -0.5em,
                text(size: t.axis-label-size, fill: color, weight: "bold")[#s.name])))
          )

          if n > 1 {
            let last-pt = points.at(n - 1)
            let label-x = last-pt.at(0) + dot-size / 2 + 3pt
            let label-w = width - label-x
            if label-w > 10pt {
              place(
                left + top,
                dx: label-x,
                dy: last-pt.at(1),
                box(width: label-w, height: 0pt,
                  move(dy: -0.5em,
                    text(size: t.axis-label-size, fill: color, weight: "bold")[#s.name]))
              )
            }
          }
        }
      }

      // X-axis labels — spread evenly across chart width
      #draw-x-even-labels(labels, n, origin-x, chart-width, origin-y, t)

      // Y-axis labels (rank numbers) — only shown when series labels are off
      #if not show-labels {
        for rank in array.range(int(min-rank), int(max-rank) + 1) {
          let y = pad-top + ((rank - min-rank) / rank-range) * chart-height
          place(left + top, dx: 0pt, dy: y,
            box(width: origin-x - 2pt, height: 0pt,
              align(right, move(dy: -0.5em,
                text(size: t.axis-label-size, fill: t.text-color)[#rank])))
          )
        }
      }
    ]
  ]
  })
}
