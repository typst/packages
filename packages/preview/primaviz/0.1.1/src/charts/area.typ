// area.typ - Area charts (single and stacked)
#import "../theme.typ": resolve-theme, get-color
#import "../util.typ": normalize-data
#import "../validate.typ": validate-simple-data, validate-series-data
#import "../primitives/container.typ": chart-container
#import "../primitives/axes.typ": draw-grid, draw-axis-titles
#import "../primitives/legend.typ": draw-legend, draw-legend-vertical

/// Renders a single-series area chart with a filled region below the line.
///
/// - data (dictionary, array): Label-value pairs as dict or array of tuples
/// - width (length): Chart width
/// - height (length): Chart height
/// - title (none, content): Optional chart title
/// - show-line (bool): Draw the line on top of the filled area
/// - show-points (bool): Draw data point markers
/// - fill-opacity (ratio): Opacity of the filled area
/// - line-width (length): Stroke width of the line
/// - x-label (none, content): X-axis title
/// - y-label (none, content): Y-axis title
/// - theme (none, dictionary): Theme overrides
/// -> content
#let area-chart(
  data,
  width: 300pt,
  height: 200pt,
  title: none,
  show-line: true,
  show-points: false,
  fill-opacity: 40%,
  line-width: 1.5pt,
  x-label: none,
  y-label: none,
  theme: none,
) = {
  validate-simple-data(data, "area-chart")
  let t = resolve-theme(theme)
  let norm = normalize-data(data)
  let labels = norm.labels
  let values = norm.values

  let max-val = calc.max(..values)
  let min-val = calc.min(0, ..values)  // Include 0 for area charts
  let val-range = max-val - min-val
  if val-range == 0 { val-range = 1 }

  let n = values.len()

  chart-container(width, height, title, t, extra-height: 30pt)[
    #let chart-height = height - 20pt
    #let chart-width = width - 50pt
    #let x-start = 45pt

    #box(width: width, height: chart-height)[
      // Grid (no-op by default)
      #draw-grid(40pt, 0pt, chart-width, chart-height, t)

      // Axes
      #place(left + top, line(start: (40pt, 0pt), end: (40pt, chart-height), stroke: t.axis-stroke))
      #place(left + bottom, line(start: (40pt, 0pt), end: (width, 0pt), stroke: t.axis-stroke))

      // Calculate points
      #let points = ()
      #for (i, val) in values.enumerate() {
        let x = if n == 1 { x-start + chart-width / 2 } else { x-start + (i / (n - 1)) * (chart-width - 10pt) }
        let y = chart-height - ((val - min-val) / val-range) * (chart-height - 20pt) - 10pt
        points.push((x, y))
      }

      // Build polygon for filled area (include baseline)
      #let baseline-y = chart-height - ((0 - min-val) / val-range) * (chart-height - 20pt) - 10pt
      #let area-pts = {
        let pts = ()
        pts.push((points.at(0).at(0), baseline-y))
        for pt in points {
          pts.push(pt)
        }
        pts.push((points.at(n - 1).at(0), baseline-y))
        pts
      }

      // Draw filled area
      #place(
        left + top,
        polygon(
          fill: get-color(t, 0).transparentize(100% - fill-opacity),
          stroke: none,
          ..area-pts.map(p => (p.at(0), p.at(1)))
        )
      )

      // Draw line on top
      #if show-line {
        for i in array.range(calc.max(n - 1, 0)) {
          let p1 = points.at(i)
          let p2 = points.at(i + 1)
          place(
            left + top,
            line(
              start: (p1.at(0), p1.at(1)),
              end: (p2.at(0), p2.at(1)),
              stroke: line-width + get-color(t, 0),
            )
          )
        }
      }

      // Draw points
      #if show-points {
        for pt in points {
          place(
            left + top,
            dx: pt.at(0) - 3pt,
            dy: pt.at(1) - 3pt,
            circle(radius: 3pt, fill: get-color(t, 0), stroke: white + 1pt)
          )
        }
      }

      // X-axis labels
      #for (i, lbl) in labels.enumerate() {
        let x = if n == 1 { x-start + chart-width / 2 } else { x-start + (i / (n - 1)) * (chart-width - 10pt) }
        place(
          left + bottom,
          dx: x - 15pt,
          dy: 10pt,
          text(size: t.axis-label-size, fill: t.text-color)[#lbl]
        )
      }

      // Y-axis labels
      #for i in array.range(t.tick-count) {
        let fraction = if t.tick-count > 1 { i / (t.tick-count - 1) } else { 0 }
        let y-val = calc.round(min-val + val-range * fraction, digits: 1)
        let y-pos = chart-height - fraction * (chart-height - 20pt) - 10pt
        place(
          left + top,
          dx: 5pt,
          dy: y-pos - 5pt,
          text(size: t.axis-label-size, fill: t.text-color)[#y-val]
        )
      }

      // Axis titles
      #draw-axis-titles(x-label, y-label, 40pt + chart-width / 2, chart-height / 2, t)
    ]
  ]
}

/// Renders a stacked area chart with multiple series layered cumulatively.
///
/// - data (dictionary): Dict with `labels` and `series` (each with `name` and `values`)
/// - width (length): Chart width
/// - height (length): Chart height
/// - title (none, content): Optional chart title
/// - show-lines (bool): Draw boundary lines between series
/// - fill-opacity (ratio): Opacity of each filled area
/// - show-legend (bool): Show series legend
/// - x-label (none, content): X-axis title
/// - y-label (none, content): Y-axis title
/// - theme (none, dictionary): Theme overrides
/// -> content
#let stacked-area-chart(
  data,
  width: 350pt,
  height: 200pt,
  title: none,
  show-lines: true,
  fill-opacity: 70%,
  show-legend: true,
  x-label: none,
  y-label: none,
  theme: none,
) = {
  validate-series-data(data, "stacked-area-chart")
  let t = resolve-theme(theme)
  let labels = data.labels
  let series = data.series
  let n = labels.len()
  let n-series = series.len()

  // Calculate cumulative values for stacking
  let cumulative = ()
  for i in array.range(n) {
    let cum = ()
    let running = 0
    for s in series {
      running = running + s.values.at(i)
      cum.push(running)
    }
    cumulative.push(cum)
  }

  let max-val = calc.max(..cumulative.map(c => c.at(n-series - 1)))
  if max-val == 0 { max-val = 1 }

  chart-container(width, height, title, t, extra-height: 50pt)[
    #let chart-height = height - 20pt
    #let chart-width = width - 50pt
    #let x-start = 45pt

    #box(width: width, height: chart-height)[
      // Grid (no-op by default)
      #draw-grid(40pt, 0pt, chart-width, chart-height, t)

      // Axes
      #place(left + top, line(start: (40pt, 0pt), end: (40pt, chart-height), stroke: t.axis-stroke))
      #place(left + bottom, line(start: (40pt, 0pt), end: (width, 0pt), stroke: t.axis-stroke))

      // Draw areas from top to bottom (reverse order so bottom series is on top visually)
      #for si in array.range(n-series - 1, -1, step: -1) {
        let color = get-color(t, si)

        // Build polygon points
        let area-pts = ()

        // Top edge (current cumulative)
        for i in array.range(n) {
          let x = if n == 1 { x-start + chart-width / 2 } else { x-start + (i / (n - 1)) * (chart-width - 10pt) }
          let y = chart-height - (cumulative.at(i).at(si) / max-val) * (chart-height - 20pt) - 10pt
          area-pts.push((x, y))
        }

        // Bottom edge (previous cumulative or baseline)
        for i in array.range(n - 1, -1, step: -1) {
          let x = if n == 1 { x-start + chart-width / 2 } else { x-start + (i / (n - 1)) * (chart-width - 10pt) }
          let y = if si == 0 {
            chart-height - 10pt  // baseline
          } else {
            chart-height - (cumulative.at(i).at(si - 1) / max-val) * (chart-height - 20pt) - 10pt
          }
          area-pts.push((x, y))
        }

        place(
          left + top,
          polygon(
            fill: color.transparentize(100% - fill-opacity),
            stroke: if show-lines { color + 1pt } else { none },
            ..area-pts.map(p => (p.at(0), p.at(1)))
          )
        )
      }

      // X-axis labels
      #for (i, lbl) in labels.enumerate() {
        let x = if n == 1 { x-start + chart-width / 2 } else { x-start + (i / (n - 1)) * (chart-width - 10pt) }
        place(
          left + bottom,
          dx: x - 15pt,
          dy: 10pt,
          text(size: t.axis-label-size, fill: t.text-color)[#lbl]
        )
      }

      // Y-axis labels
      #for i in array.range(t.tick-count) {
        let fraction = if t.tick-count > 1 { i / (t.tick-count - 1) } else { 0 }
        let y-val = calc.round(max-val * fraction, digits: 0)
        let y-pos = chart-height - fraction * (chart-height - 20pt) - 10pt
        place(
          left + top,
          dx: 5pt,
          dy: y-pos - 5pt,
          text(size: t.axis-label-size, fill: t.text-color)[#y-val]
        )
      }

      // Axis titles
      #draw-axis-titles(x-label, y-label, 40pt + chart-width / 2, chart-height / 2, t)
    ]

    // Legend
    #if show-legend and t.legend-position != "none" {
      if t.legend-position == "right" {
        draw-legend-vertical(series.map(s => s.name), t)
      } else {
        draw-legend(series.map(s => s.name), t)
      }
    }
  ]
}
