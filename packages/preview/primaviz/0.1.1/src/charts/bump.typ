// bump.typ - Bump chart (multi-period ranking chart)
#import "../theme.typ": resolve-theme, get-color
#import "../validate.typ": validate-series-data
#import "../primitives/container.typ": chart-container
#import "../primitives/axes.typ": draw-grid, draw-axis-titles
#import "../primitives/legend.typ": draw-legend, draw-legend-vertical

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
/// -> content
#let bump-chart(
  data,
  width: 400pt,
  height: 250pt,
  title: none,
  dot-size: 5pt,
  line-width: 2.5pt,
  show-labels: true,
  show-legend: true,
  theme: none,
) = {
  validate-series-data(data, "bump-chart")
  let t = resolve-theme(theme)
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
  let rank-range = max-rank - min-rank
  if rank-range == 0 { rank-range = 1 }

  chart-container(width, height, title, t, extra-height: 50pt)[
    #let chart-height = height - 20pt
    #let chart-width = width - 50pt
    #let left-pad = 40pt
    #let right-pad = 10pt
    #let top-pad = 10pt
    #let bottom-pad = 10pt

    #box(width: width, height: chart-height)[
      // Grid
      #draw-grid(left-pad, 0pt, chart-width, chart-height, t)

      // Axes
      #place(left + top, line(start: (left-pad, 0pt), end: (left-pad, chart-height), stroke: t.axis-stroke))
      #place(left + bottom, line(start: (left-pad, 0pt), end: (width, 0pt), stroke: t.axis-stroke))

      // Draw each series as a thick line with dots
      #for (si, s) in series.enumerate() {
        let values = s.values
        let color = get-color(t, si)

        // Compute point positions
        // Y is inverted: rank 1 at top, max-rank at bottom
        let points = ()
        for (i, val) in values.enumerate() {
          let x = if n == 1 { left-pad + 5pt + chart-width / 2 } else { left-pad + 5pt + (i / (n - 1)) * (chart-width - right-pad - 5pt) }
          let y = top-pad + ((val - min-rank) / rank-range) * (chart-height - top-pad - bottom-pad)
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
            circle(radius: dot-size / 2, fill: color, stroke: white + 1pt)
          )
        }

        // Labels at start and end of each series line
        if show-labels {
          let first-pt = points.at(0)
          place(
            left + top,
            dx: first-pt.at(0) - 40pt,
            dy: first-pt.at(1) - 5pt,
            text(size: t.axis-label-size, fill: color, weight: "bold")[#s.name]
          )

          if n > 1 {
            let last-pt = points.at(n - 1)
            place(
              left + top,
              dx: last-pt.at(0) + dot-size / 2 + 3pt,
              dy: last-pt.at(1) - 5pt,
              text(size: t.axis-label-size, fill: color, weight: "bold")[#s.name]
            )
          }
        }
      }

      // X-axis labels (time periods)
      #for (i, lbl) in labels.enumerate() {
        let x = if n == 1 { left-pad + 5pt + chart-width / 2 } else { left-pad + 5pt + (i / (n - 1)) * (chart-width - right-pad - 5pt) }
        place(
          left + bottom,
          dx: x - 15pt,
          dy: 10pt,
          text(size: t.axis-label-size, fill: t.text-color)[#lbl]
        )
      }

      // Y-axis labels (rank numbers, 1 at top, max at bottom)
      #for rank in array.range(int(min-rank), int(max-rank) + 1) {
        let y = top-pad + ((rank - min-rank) / rank-range) * (chart-height - top-pad - bottom-pad)
        place(
          left + top,
          dx: 5pt,
          dy: y - 5pt,
          text(size: t.axis-label-size, fill: t.text-color)[#rank]
        )
      }
    ]

    #if show-legend and t.legend-position != "none" {
      if t.legend-position == "right" {
        draw-legend-vertical(series.map(s => s.name), t)
      } else {
        draw-legend(series.map(s => s.name), t, swatch-type: "line")
      }
    }
  ]
}
