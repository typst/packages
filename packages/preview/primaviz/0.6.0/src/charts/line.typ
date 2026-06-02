// line.typ - Line charts (single and multi-series)
#import "../theme.typ": _resolve-ctx, get-color
#import "../util.typ": normalize-data, nonzero, nice-ticks, normalize-errors
#import "../validate.typ": validate-simple-data, validate-series-data
#import "../primitives/container.typ": chart-container
#import "../primitives/axes.typ": cartesian-layout, draw-axis-lines, draw-grid, draw-axis-titles, draw-y-ticks, draw-x-category-labels, draw-x-even-labels, measure-y-tick-width, measure-x-tick-height
#import "../primitives/legend.typ": draw-legend-auto
#import "../primitives/annotations.typ": draw-annotations
#import "../primitives/layout.typ": resolve-size

/// Renders a single-series line chart.
///
/// - data (dictionary, array): Label-value pairs as dict or array of tuples
/// - width (length): Chart width
/// - height (length): Chart height
/// - title (none, content): Optional chart title
/// - show-points (bool): Draw data point markers
/// - show-values (bool): Display value labels at data points
/// - line-width (length): Stroke width of the line
/// - point-size (length): Diameter of point markers
/// - fill-area (bool): Fill the area under the line
/// - x-label (none, content): X-axis title
/// - y-label (none, content): Y-axis title
/// - annotations (none, array): Optional annotation descriptors
/// - theme (none, dictionary): Theme overrides
/// - extra-legend-separation (length): Extra space between legend and chart
/// -> content
#let line-chart(
  data,
  width: auto,
  height: auto,
  title: none,
  show-points: true,
  show-values: false,
  line-width: 1.5pt,
  point-size: 4pt,
  fill-area: false,
  x-label: none,
  y-label: none,
  errors: none,
  error-color: auto,
  error-cap-width: 6pt,
  annotations: none,
  show-ticks: false,
  show-minor-grid: false,
  subtitle: none,
  radius: 0pt,
  theme: none,
  extra-legend-separation: 0pt
) = context {
  layout(size => {
  validate-simple-data(data, "line-chart")
  let t = _resolve-ctx(theme)
  let norm = normalize-data(data)
  let labels = norm.labels
  let values = norm.values
  let n = values.len()
  let (width, height) = resolve-size(width, height, size, n: n, theme: t)
  let errs = normalize-errors(errors, n)

  // Extend axis to cover error extremes
  let data-min = if errs != none {
    calc.min(..values.enumerate().map(((i, v)) => v - errs.at(i).low))
  } else { calc.min(..values) }
  let data-max = if errs != none {
    calc.max(..values.enumerate().map(((i, v)) => v + errs.at(i).high))
  } else { calc.max(..values) }
  let nt = nice-ticks(data-min, data-max, count: t.tick-count)
  let max-val = nt.max
  let min-val = nt.min
  let val-range = nonzero(max-val - min-val)

  let cl = cartesian-layout(width, height, t)

  chart-container(width, height, title, t, extra-height: 30pt, subtitle: subtitle, radius: radius, extra-legend-separation: extra-legend-separation)[
    #let pad-top = cl.pad-top
    #let chart-height = cl.chart-height
    #let chart-width = cl.chart-width
    #let origin-x = cl.origin-x
    #let origin-y = cl.origin-y

    #box(width: width, height: height)[
      // Grid
      #draw-grid(origin-x, pad-top, chart-width, chart-height, t, show-minor-grid: show-minor-grid, num-ticks: nt.ticks.len())

      // Axes
      #draw-axis-lines(origin-x, origin-y, origin-x + chart-width, pad-top, t, show-ticks: show-ticks)

      // Y-axis ticks
      #draw-y-ticks(min-val, max-val, chart-height, pad-top, origin-x, t)

      // Compute data point positions
      #let points = ()
      #for (i, val) in values.enumerate() {
        let x = if n == 1 { origin-x + chart-width / 2 } else { origin-x + (i / (n - 1)) * chart-width }
        let y = pad-top + chart-height - ((val - min-val) / val-range) * chart-height
        points.push((x, y))
      }

      // Draw lines between points
      #for i in array.range(calc.max(n - 1, 0)) {
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

      // Error bars (drawn under points so the marker sits on top)
      #if errs != none {
        let err-color-resolved = if error-color != auto { error-color } else { get-color(t, 0) }
        let err-stroke = t.stroke-thin + err-color-resolved
        for (i, pt) in points.enumerate() {
          let err = errs.at(i)
          let val = values.at(i)
          let y-low = pad-top + chart-height - ((val - err.low - min-val) / val-range) * chart-height
          let y-high = pad-top + chart-height - ((val + err.high - min-val) / val-range) * chart-height
          let x-c = pt.at(0)
          place(left + top,
            line(start: (x-c, y-low), end: (x-c, y-high), stroke: err-stroke)
          )
          place(left + top,
            line(start: (x-c - error-cap-width / 2, y-low), end: (x-c + error-cap-width / 2, y-low), stroke: err-stroke)
          )
          place(left + top,
            line(start: (x-c - error-cap-width / 2, y-high), end: (x-c + error-cap-width / 2, y-high), stroke: err-stroke)
          )
        }
      }

      // Draw points and value labels
      #if show-points {
        for (i, pt) in points.enumerate() {
          place(
            left + top,
            dx: pt.at(0) - point-size / 2,
            dy: pt.at(1) - point-size / 2,
            circle(radius: point-size / 2, fill: get-color(t, 0), stroke: t.marker-stroke)
          )

          if show-values {
            place(
              left + top,
              dx: pt.at(0),
              dy: pt.at(1) - 1.5em,
              move(dx: -1em, dy: -0.5em, text(size: t.axis-label-size, fill: t.text-color)[#values.at(i)])
            )
          }
        }
      }

      // X-axis category labels — spread evenly across chart width
      #draw-x-even-labels(labels, n, origin-x, chart-width, origin-y, t)

      // Axis titles
      #let y-tw = measure-y-tick-width(min-val, max-val, t)
      #let x-th = measure-x-tick-height(labels, t, rotated: n>t.rotated-threshold)
      #draw-axis-titles(x-label, y-label, origin-x + chart-width / 2, pad-top + chart-height / 2, t, origin-x: origin-x, origin-y: origin-y, y-tick-width: y-tw, x-tick-height: x-th)

      // Annotations
      #draw-annotations(annotations, origin-x, pad-top, chart-width, chart-height, 0, calc.max(n - 1, 1), min-val, max-val, t)
    ]
  ]
  })
}

/// Renders a multi-series line chart with a shared axis.
///
/// - data (dictionary): Dict with `labels` and `series` (each with `name` and `values`)
/// - width (length): Chart width
/// - height (length): Chart height
/// - title (none, content): Optional chart title
/// - show-points (bool): Draw data point markers
/// - show-legend (bool): Show series legend
/// - x-label (none, content): X-axis title
/// - y-label (none, content): Y-axis title
/// - theme (none, dictionary): Theme overrides
/// - extra-legend-separation (length): Extra space between legend and chart
/// -> content
#let multi-line-chart(
  data,
  width: auto,
  height: auto,
  title: none,
  show-points: true,
  show-legend: true,
  line-width: 1.5pt,
  point-size: 3pt,
  x-label: none,
  y-label: none,
  annotations: none,
  theme: none,
  extra-legend-separation: 0pt
) = context {
  layout(size => {
  validate-series-data(data, "multi-line-chart")
  let t = _resolve-ctx(theme)
  let (width, height) = resolve-size(width, height, size, n: data.labels.len(), theme: t)
  let labels = data.labels
  let series = data.series

  let all-values = series.map(s => s.values).flatten()
  let nt = nice-ticks(calc.min(..all-values), calc.max(..all-values), count: t.tick-count)
  let max-val = nt.max
  let min-val = nt.min
  let val-range = nonzero(max-val - min-val)

  let n = labels.len()

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
      #draw-grid(origin-x, pad-top, chart-width, chart-height, t, num-ticks: nt.ticks.len())

      // Axes
      #draw-axis-lines(origin-x, origin-y, origin-x + chart-width, pad-top, t)

      // Y-axis ticks
      #draw-y-ticks(min-val, max-val, chart-height, pad-top, origin-x, t)

      #for (si, s) in series.enumerate() {
        let values = s.values
        let color = get-color(t, si)

        let points = ()
        for (i, val) in values.enumerate() {
          let x = if n == 1 { origin-x + chart-width / 2 } else { origin-x + (i / (n - 1)) * chart-width }
          let y = pad-top + chart-height - ((val - min-val) / val-range) * chart-height
          points.push((x, y))
        }

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

        if show-points {
          for pt in points {
            place(
              left + top,
              dx: pt.at(0) - point-size,
              dy: pt.at(1) - point-size,
              circle(radius: point-size, fill: color, stroke: t.marker-stroke)
            )
          }
        }
      }

      // X-axis category labels — spread evenly across chart width
      #draw-x-even-labels(labels, n, origin-x, chart-width, origin-y, t)

      // Axis titles
      #let y-tw = measure-y-tick-width(min-val, max-val, t)
      #let x-th = measure-x-tick-height(labels, t, rotated: n>t.rotated-threshold)

      #draw-axis-titles(x-label, y-label, origin-x + chart-width / 2, pad-top + chart-height / 2, t, origin-x: origin-x, origin-y: origin-y, y-tick-width: y-tw, x-tick-height: x-th)

      // Annotations — x is point index [0, n-1], y is [min-val, max-val]
      #draw-annotations(annotations, origin-x, pad-top, chart-width, chart-height, 0, calc.max(n - 1, 1), min-val, max-val, t)
    ]
  ]
  })
}
