// area.typ - Area charts (single and stacked)
#import "../theme.typ": _resolve-ctx, get-color
#import "../util.typ": normalize-data, nonzero, nice-ceil
#import "../validate.typ": validate-simple-data, validate-series-data
#import "../primitives/container.typ": chart-container
#import "../primitives/axes.typ": cartesian-layout, draw-axis-lines, draw-grid, draw-axis-titles, draw-y-ticks, draw-x-even-labels, measure-y-tick-width
#import "../primitives/legend.typ": draw-legend-auto
#import "../primitives/layout.typ": resolve-size

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
/// - point-size (length): Radius of point markers
/// - x-label (none, content): X-axis title
/// - y-label (none, content): Y-axis title
/// - theme (none, dictionary): Theme overrides
/// -> content
#let area-chart(
  data,
  width: auto,
  height: auto,
  title: none,
  show-line: true,
  show-points: false,
  fill-opacity: 40%,
  line-width: 1.5pt,
  point-size: 3pt,
  x-label: none,
  y-label: none,
  show-ticks: false,
  show-minor-grid: false,
  theme: none,
) = context {
  layout(size => {
  validate-simple-data(data, "area-chart")
  let t = _resolve-ctx(theme)
  let norm = normalize-data(data)
  let labels = norm.labels
  let values = norm.values
  let (width, height) = resolve-size(width, height, size, n: values.len(), theme: t)

  let max-val = nice-ceil(calc.max(..values))
  let min-val = calc.min(0, ..values)  // Include 0 for area charts
  let val-range = nonzero(max-val - min-val)

  let n = values.len()

  let cl = cartesian-layout(width, height, t)

  chart-container(width, height, title, t, extra-height: 30pt)[
    #let pad-top = cl.pad-top
    #let chart-height = cl.chart-height
    #let chart-width = cl.chart-width
    #let origin-x = cl.origin-x
    #let origin-y = cl.origin-y

    #box(width: width, height: height)[
      // Grid
      #draw-grid(origin-x, pad-top, chart-width, chart-height, t, show-minor-grid: show-minor-grid)

      // Axes
      #draw-axis-lines(origin-x, origin-y, origin-x + chart-width, pad-top, t, show-ticks: show-ticks)

      // Y-axis ticks
      #draw-y-ticks(min-val, max-val, chart-height, pad-top, origin-x, t)

      // Calculate points
      #let points = ()
      #for (i, val) in values.enumerate() {
        let x = if n == 1 { origin-x + chart-width / 2 } else { origin-x + (i / (n - 1)) * chart-width }
        let y = pad-top + chart-height - ((val - min-val) / val-range) * chart-height
        points.push((x, y))
      }

      // Build polygon for filled area (include baseline)
      #let baseline-y = pad-top + chart-height - ((0 - min-val) / val-range) * chart-height
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
            dx: pt.at(0) - point-size,
            dy: pt.at(1) - point-size,
            circle(radius: point-size, fill: get-color(t, 0), stroke: t.marker-stroke)
          )
        }
      }

      // X-axis labels — spread evenly across chart width
      #draw-x-even-labels(labels, n, origin-x, chart-width, origin-y, t)

      // Axis titles
      #let y-tw = measure-y-tick-width(min-val, max-val, t)
      #draw-axis-titles(x-label, y-label, origin-x + chart-width / 2, pad-top + chart-height / 2, t, origin-x: origin-x, origin-y: origin-y, y-tick-width: y-tw)
    ]
  ]
  })
}

/// Renders a stacked area chart with multiple series layered cumulatively.
///
/// - data (dictionary): Dict with `labels` and `series` (each with `name` and `values`)
/// - width (length): Chart width
/// - height (length): Chart height
/// - title (none, content): Optional chart title
/// - show-lines (bool): Draw boundary lines between series
/// - fill-opacity (ratio): Opacity of each filled area
/// - line-width (length): Stroke width of boundary lines
/// - show-legend (bool): Show series legend
/// - x-label (none, content): X-axis title
/// - y-label (none, content): Y-axis title
/// - theme (none, dictionary): Theme overrides
/// -> content
#let stacked-area-chart(
  data,
  width: auto,
  height: auto,
  title: none,
  show-lines: true,
  fill-opacity: 70%,
  line-width: 1pt,
  show-legend: true,
  x-label: none,
  y-label: none,
  theme: none,
) = context {
  layout(size => {
  validate-series-data(data, "stacked-area-chart")
  let t = _resolve-ctx(theme)
  let (width, height) = resolve-size(width, height, size, n: data.labels.len(), theme: t)
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

  let max-val = nice-ceil(nonzero(calc.max(..cumulative.map(c => c.at(n-series - 1)))))

  let cl = cartesian-layout(width, height, t)

  let legend-content = draw-legend-auto(series.map(s => s.name), t, show-legend: show-legend)
  chart-container(width, height, title, t, extra-height: 50pt, legend: legend-content)[
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

      // Y-axis ticks
      #draw-y-ticks(0, max-val, chart-height, pad-top, origin-x, t, digits: 0)

      // Draw areas from top to bottom (reverse order so bottom series is on top visually)
      #for si in array.range(n-series - 1, -1, step: -1) {
        let color = get-color(t, si)

        // Build polygon points
        let area-pts = ()

        // Top edge (current cumulative)
        for i in array.range(n) {
          let x = if n == 1 { origin-x + chart-width / 2 } else { origin-x + (i / (n - 1)) * chart-width }
          let y = pad-top + chart-height - (cumulative.at(i).at(si) / max-val) * chart-height
          area-pts.push((x, y))
        }

        // Bottom edge (previous cumulative or baseline)
        for i in array.range(n - 1, -1, step: -1) {
          let x = if n == 1 { origin-x + chart-width / 2 } else { origin-x + (i / (n - 1)) * chart-width }
          let y = if si == 0 {
            origin-y  // baseline
          } else {
            pad-top + chart-height - (cumulative.at(i).at(si - 1) / max-val) * chart-height
          }
          area-pts.push((x, y))
        }

        place(
          left + top,
          polygon(
            fill: color.transparentize(100% - fill-opacity),
            stroke: if show-lines { color + line-width } else { none },
            ..area-pts.map(p => (p.at(0), p.at(1)))
          )
        )
      }

      // X-axis labels — spread evenly across chart width
      #draw-x-even-labels(labels, n, origin-x, chart-width, origin-y, t)

      // Axis titles
      #let y-tw = measure-y-tick-width(0, max-val, t, digits: 0)
      #draw-axis-titles(x-label, y-label, origin-x + chart-width / 2, pad-top + chart-height / 2, t, origin-x: origin-x, origin-y: origin-y, y-tick-width: y-tw)
    ]
  ]
  })
}
