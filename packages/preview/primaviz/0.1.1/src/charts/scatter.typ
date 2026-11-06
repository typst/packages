// scatter.typ - Scatter plot and bubble chart
#import "../theme.typ": resolve-theme, get-color
#import "../validate.typ": validate-scatter-data, validate-multi-scatter-data, validate-bubble-data
#import "../primitives/container.typ": chart-container
#import "../primitives/axes.typ": draw-grid, draw-axis-titles
#import "../primitives/legend.typ": draw-legend, draw-legend-vertical
#import "../primitives/annotations.typ": draw-annotations

/// Renders a scatter plot of x-y data points.
///
/// - data (array, dictionary): Array of `(x, y)` tuples or dict with `x` and `y` arrays
/// - width (length): Chart width
/// - height (length): Chart height
/// - title (none, content): Optional chart title
/// - x-label (none, content): X-axis title
/// - y-label (none, content): Y-axis title
/// - point-size (length): Diameter of point markers
/// - show-grid (bool): Draw background grid lines
/// - color (none, color): Override point color
/// - annotations (none, array): Optional annotation descriptors
/// - theme (none, dictionary): Theme overrides
/// -> content
#let scatter-plot(
  data,
  width: 300pt,
  height: 250pt,
  title: none,
  x-label: none,
  y-label: none,
  point-size: 5pt,
  show-grid: true,
  color: none,
  annotations: none,
  theme: none,
) = {
  validate-scatter-data(data, "scatter-plot")
  let t = resolve-theme(theme)
  // Normalize data format
  let points = if type(data) == dictionary {
    data.x.zip(data.y)
  } else {
    data
  }

  let x-vals = points.map(p => p.at(0))
  let y-vals = points.map(p => p.at(1))

  let x-min = calc.min(..x-vals)
  let x-max = calc.max(..x-vals)
  let y-min = calc.min(..y-vals)
  let y-max = calc.max(..y-vals)

  // Add padding to ranges
  let x-range = x-max - x-min
  let y-range = y-max - y-min
  if x-range == 0 { x-range = 1 }
  if y-range == 0 { y-range = 1 }

  let point-color = if color != none { color } else { get-color(t, 0) }

  chart-container(width, height, title, t, extra-height: 30pt)[
    #let chart-height = height - 30pt
    #let chart-width = width - 60pt
    #let x-start = 50pt
    #let y-start = 10pt

    #box(width: width, height: chart-height + 20pt)[
      // Grid lines
      #if show-grid {
        for i in array.range(t.tick-count) {
          let fraction = if t.tick-count > 1 { i / (t.tick-count - 1) } else { 0 }
          // Horizontal grid
          let y-pos = y-start + fraction * chart-height
          place(
            left + top,
            line(
              start: (x-start, y-pos),
              end: (x-start + chart-width, y-pos),
              stroke: t.grid-stroke
            )
          )
          // Vertical grid
          let x-pos = x-start + fraction * chart-width
          place(
            left + top,
            line(
              start: (x-pos, y-start),
              end: (x-pos, y-start + chart-height),
              stroke: t.grid-stroke
            )
          )
        }
      }

      // Axes
      #place(left + top, line(start: (x-start, y-start), end: (x-start, y-start + chart-height), stroke: t.axis-stroke))
      #place(left + top, line(start: (x-start, y-start + chart-height), end: (x-start + chart-width, y-start + chart-height), stroke: t.axis-stroke))

      // Plot points
      #for pt in points {
        let px = x-start + ((pt.at(0) - x-min) / x-range) * chart-width
        let py = y-start + chart-height - ((pt.at(1) - y-min) / y-range) * chart-height

        place(
          left + top,
          dx: px - point-size / 2,
          dy: py - point-size / 2,
          circle(radius: point-size / 2, fill: point-color, stroke: white + 0.5pt)
        )
      }

      // X-axis labels
      #for i in array.range(t.tick-count) {
        let fraction = if t.tick-count > 1 { i / (t.tick-count - 1) } else { 0 }
        let x-val = calc.round(x-min + x-range * fraction, digits: 1)
        let x-pos = x-start + fraction * chart-width
        place(
          left + top,
          dx: x-pos - 12pt,
          dy: y-start + chart-height + 8pt,
          text(size: t.axis-label-size, fill: t.text-color)[#x-val]
        )
      }

      // Y-axis labels
      #for i in array.range(t.tick-count) {
        let fraction = if t.tick-count > 1 { i / (t.tick-count - 1) } else { 0 }
        let y-val = calc.round(y-min + y-range * fraction, digits: 1)
        let y-pos = y-start + chart-height - fraction * chart-height
        place(
          left + top,
          dx: 5pt,
          dy: y-pos - 5pt,
          text(size: t.axis-label-size, fill: t.text-color)[#y-val]
        )
      }

      // Axis labels
      #if x-label != none {
        place(
          left + bottom,
          dx: x-start + chart-width / 2 - 20pt,
          dy: -5pt,
          text(size: t.axis-title-size, fill: t.text-color)[#x-label]
        )
      }

      #if y-label != none {
        place(
          left + top,
          dx: -5pt,
          dy: y-start + chart-height / 2,
          rotate(-90deg, text(size: t.axis-title-size, fill: t.text-color)[#y-label])
        )
      }

      // Annotations
      #draw-annotations(annotations, x-start, y-start, chart-width, chart-height, x-min, x-max, y-min, y-max, t)
    ]
  ]
}

/// Renders a multi-series scatter plot with color-coded point groups.
///
/// - data (dictionary): Dict with `series` array, each containing `name` and `points` (array of `(x, y)`)
/// - width (length): Chart width
/// - height (length): Chart height
/// - title (none, content): Optional chart title
/// - x-label (none, content): X-axis title
/// - y-label (none, content): Y-axis title
/// - point-size (length): Diameter of point markers
/// - show-grid (bool): Draw background grid lines
/// - show-legend (bool): Show series legend
/// - theme (none, dictionary): Theme overrides
/// -> content
#let multi-scatter-plot(
  data,
  width: 300pt,
  height: 250pt,
  title: none,
  x-label: none,
  y-label: none,
  point-size: 5pt,
  show-grid: true,
  show-legend: true,
  theme: none,
) = {
  validate-multi-scatter-data(data, "multi-scatter-plot")
  let t = resolve-theme(theme)
  let series = data.series

  // Get all points to find ranges
  let all-points = series.map(s => s.points).flatten()
  let x-vals = ()
  let y-vals = ()
  for s in series {
    for pt in s.points {
      x-vals.push(pt.at(0))
      y-vals.push(pt.at(1))
    }
  }

  let x-min = calc.min(..x-vals)
  let x-max = calc.max(..x-vals)
  let y-min = calc.min(..y-vals)
  let y-max = calc.max(..y-vals)

  let x-range = x-max - x-min
  let y-range = y-max - y-min
  if x-range == 0 { x-range = 1 }
  if y-range == 0 { y-range = 1 }

  chart-container(width, height, title, t, extra-height: 50pt)[
    #let chart-height = height - 30pt
    #let chart-width = width - 60pt
    #let x-start = 50pt
    #let y-start = 10pt

    #box(width: width, height: chart-height + 20pt)[
      // Grid lines
      #if show-grid {
        for i in array.range(t.tick-count) {
          let fraction = if t.tick-count > 1 { i / (t.tick-count - 1) } else { 0 }
          let y-pos = y-start + fraction * chart-height
          place(left + top, line(start: (x-start, y-pos), end: (x-start + chart-width, y-pos), stroke: t.grid-stroke))
          let x-pos = x-start + fraction * chart-width
          place(left + top, line(start: (x-pos, y-start), end: (x-pos, y-start + chart-height), stroke: t.grid-stroke))
        }
      }

      // Axes
      #place(left + top, line(start: (x-start, y-start), end: (x-start, y-start + chart-height), stroke: t.axis-stroke))
      #place(left + top, line(start: (x-start, y-start + chart-height), end: (x-start + chart-width, y-start + chart-height), stroke: t.axis-stroke))

      // Plot points for each series
      #for (si, s) in series.enumerate() {
        let color = get-color(t, si)
        for pt in s.points {
          let px = x-start + ((pt.at(0) - x-min) / x-range) * chart-width
          let py = y-start + chart-height - ((pt.at(1) - y-min) / y-range) * chart-height

          place(
            left + top,
            dx: px - point-size / 2,
            dy: py - point-size / 2,
            circle(radius: point-size / 2, fill: color, stroke: white + 0.5pt)
          )
        }
      }

      // X-axis labels
      #for i in array.range(t.tick-count) {
        let fraction = if t.tick-count > 1 { i / (t.tick-count - 1) } else { 0 }
        let x-val = calc.round(x-min + x-range * fraction, digits: 1)
        let x-pos = x-start + fraction * chart-width
        place(left + top, dx: x-pos - 12pt, dy: y-start + chart-height + 8pt, text(size: t.axis-label-size, fill: t.text-color)[#x-val])
      }

      // Y-axis labels
      #for i in array.range(t.tick-count) {
        let fraction = if t.tick-count > 1 { i / (t.tick-count - 1) } else { 0 }
        let y-val = calc.round(y-min + y-range * fraction, digits: 1)
        let y-pos = y-start + chart-height - fraction * chart-height
        place(left + top, dx: 5pt, dy: y-pos - 5pt, text(size: t.axis-label-size, fill: t.text-color)[#y-val])
      }
    ]

    // Legend
    #if show-legend and t.legend-position != "none" {
      if t.legend-position == "right" {
        draw-legend-vertical(series.map(s => s.name), t)
      } else {
        draw-legend(
          series.map(s => s.name),
          t,
          swatch-type: "circle",
        )
      }
    }
  ]
}

/// Renders a bubble chart where each point has an x, y, and size dimension.
///
/// - data (array, dictionary): Array of `(x, y, size)` tuples or dict with `x`, `y`, `size` arrays
/// - width (length): Chart width
/// - height (length): Chart height
/// - title (none, content): Optional chart title
/// - x-label (none, content): X-axis title
/// - y-label (none, content): Y-axis title
/// - min-radius (length): Minimum bubble radius
/// - max-radius (length): Maximum bubble radius
/// - show-grid (bool): Draw background grid lines
/// - color (none, color): Override bubble color
/// - show-labels (bool): Display text labels on bubbles
/// - labels (none, array): Array of label strings for each bubble
/// - theme (none, dictionary): Theme overrides
/// -> content
#let bubble-chart(
  data,
  width: 300pt,
  height: 250pt,
  title: none,
  x-label: none,
  y-label: none,
  min-radius: 5pt,
  max-radius: 30pt,
  show-grid: true,
  color: none,
  show-labels: false,
  labels: none,
  theme: none,
) = {
  validate-bubble-data(data, "bubble-chart")
  let t = resolve-theme(theme)
  // Normalize data format
  let points = if type(data) == dictionary {
    let zipped = data.x.zip(data.y).zip(data.size)
    zipped.map(p => (p.at(0).at(0), p.at(0).at(1), p.at(1)))
  } else {
    data
  }

  let x-vals = points.map(p => p.at(0))
  let y-vals = points.map(p => p.at(1))
  let size-vals = points.map(p => p.at(2))

  let x-min = calc.min(..x-vals)
  let x-max = calc.max(..x-vals)
  let y-min = calc.min(..y-vals)
  let y-max = calc.max(..y-vals)
  let size-min = calc.min(..size-vals)
  let size-max = calc.max(..size-vals)

  let x-range = x-max - x-min
  let y-range = y-max - y-min
  let size-range = size-max - size-min
  if x-range == 0 { x-range = 1 }
  if y-range == 0 { y-range = 1 }
  if size-range == 0 { size-range = 1 }

  let bubble-color = if color != none { color } else { get-color(t, 0) }

  chart-container(width, height, title, t, extra-height: 30pt)[
    #let chart-height = height - 30pt
    #let chart-width = width - 60pt
    #let x-start = 50pt
    #let y-start = 10pt

    #box(width: width, height: chart-height + 20pt)[
      // Grid lines
      #if show-grid {
        for i in array.range(t.tick-count) {
          let fraction = if t.tick-count > 1 { i / (t.tick-count - 1) } else { 0 }
          let y-pos = y-start + fraction * chart-height
          place(left + top, line(start: (x-start, y-pos), end: (x-start + chart-width, y-pos), stroke: t.grid-stroke))
          let x-pos = x-start + fraction * chart-width
          place(left + top, line(start: (x-pos, y-start), end: (x-pos, y-start + chart-height), stroke: t.grid-stroke))
        }
      }

      // Axes
      #place(left + top, line(start: (x-start, y-start), end: (x-start, y-start + chart-height), stroke: t.axis-stroke))
      #place(left + top, line(start: (x-start, y-start + chart-height), end: (x-start + chart-width, y-start + chart-height), stroke: t.axis-stroke))

      // Plot bubbles
      #for (i, pt) in points.enumerate() {
        let px = x-start + ((pt.at(0) - x-min) / x-range) * chart-width
        let py = y-start + chart-height - ((pt.at(1) - y-min) / y-range) * chart-height
        let radius = min-radius + ((pt.at(2) - size-min) / size-range) * (max-radius - min-radius)

        place(
          left + top,
          dx: px - radius,
          dy: py - radius,
          circle(
            radius: radius,
            fill: bubble-color.transparentize(40%),
            stroke: bubble-color + 1.5pt
          )
        )

        // Optional label
        if show-labels and labels != none and i < labels.len() {
          place(
            left + top,
            dx: px - 15pt,
            dy: py - 5pt,
            text(size: t.axis-label-size, fill: t.text-color, weight: "bold")[#labels.at(i)]
          )
        }
      }

      // X-axis labels
      #for i in array.range(t.tick-count) {
        let fraction = if t.tick-count > 1 { i / (t.tick-count - 1) } else { 0 }
        let x-val = calc.round(x-min + x-range * fraction, digits: 1)
        let x-pos = x-start + fraction * chart-width
        place(left + top, dx: x-pos - 12pt, dy: y-start + chart-height + 8pt, text(size: t.axis-label-size, fill: t.text-color)[#x-val])
      }

      // Y-axis labels
      #for i in array.range(t.tick-count) {
        let fraction = if t.tick-count > 1 { i / (t.tick-count - 1) } else { 0 }
        let y-val = calc.round(y-min + y-range * fraction, digits: 1)
        let y-pos = y-start + chart-height - fraction * chart-height
        place(left + top, dx: 5pt, dy: y-pos - 5pt, text(size: t.axis-label-size, fill: t.text-color)[#y-val])
      }

      // Axis labels
      #if x-label != none {
        place(left + bottom, dx: x-start + chart-width / 2 - 20pt, dy: -5pt, text(size: t.axis-title-size, fill: t.text-color)[#x-label])
      }
    ]
  ]
}
