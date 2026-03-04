// scatter.typ - Scatter plot and bubble chart
#import "../theme.typ": _resolve-ctx, get-color
#import "../util.typ": nonzero, clamp, nice-ceil, nice-floor, numeric-range
#import "../primitives/layout.typ": label-fits-inside, place-cartesian-label
#import "../validate.typ": validate-scatter-data, validate-multi-scatter-data, validate-bubble-data, validate-multi-bubble-data
#import "../primitives/container.typ": chart-container
#import "../primitives/axes.typ": cartesian-layout, draw-axis-lines, draw-grid, draw-axis-titles, draw-y-ticks, draw-x-ticks
#import "../primitives/legend.typ": draw-legend-auto
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
/// - show-grid (auto, bool): Draw background grid lines; `auto` uses theme default
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
  show-grid: auto,
  color: none,
  annotations: none,
  theme: none,
) = context {
  validate-scatter-data(data, "scatter-plot")
  let grid-overrides = if show-grid != auto { (show-grid: show-grid) } else { none }
  let t = _resolve-ctx(theme, overrides: grid-overrides)
  // Normalize data format
  let points = if type(data) == dictionary {
    data.x.zip(data.y)
  } else {
    data
  }

  let x-vals = points.map(p => p.at(0))
  let y-vals = points.map(p => p.at(1))

  let xr = numeric-range(x-vals)
  let yr = numeric-range(y-vals)
  let (x-min, x-max, x-range) = (xr.min, xr.max, xr.range)
  let (y-min, y-max, y-range) = (yr.min, yr.max, yr.range)

  let point-color = if color != none { color } else { get-color(t, 0) }

  let cl = cartesian-layout(width, height, t, extra-left: 10pt)

  chart-container(width, height, title, t, extra-height: 30pt)[
    #let pad-top = cl.pad-top
    #let chart-height = cl.chart-height
    #let chart-width = cl.chart-width
    #let origin-x = cl.origin-x
    #let origin-y = cl.origin-y

    #box(width: width, height: height)[
      // Grid lines
      #draw-grid(origin-x, pad-top, chart-width, chart-height, t)

      // Axes
      #draw-axis-lines(origin-x, origin-y, origin-x + chart-width, pad-top, t)

      // Y-axis ticks
      #draw-y-ticks(y-min, y-max, chart-height, pad-top, origin-x, t)

      // X-axis ticks
      #draw-x-ticks(x-min, x-max, chart-width, origin-x, origin-y + 4pt, t)

      // Plot points — clamp to chart bounds
      #let half = point-size / 2
      #for pt in points {
        let px = origin-x + ((pt.at(0) - x-min) / x-range) * chart-width
        let py = pad-top + chart-height - ((pt.at(1) - y-min) / y-range) * chart-height
        let px = clamp(px, origin-x + half, origin-x + chart-width - half)
        let py = clamp(py, pad-top + half, origin-y - half)

        place(
          left + top,
          dx: px - half,
          dy: py - half,
          circle(radius: point-size / 2, fill: point-color, stroke: white + 0.5pt)
        )
      }

      // Axis titles
      #draw-axis-titles(x-label, y-label, origin-x + chart-width / 2, origin-y / 2, t)

      // Annotations
      #draw-annotations(annotations, origin-x, pad-top, chart-width, chart-height, x-min, x-max, y-min, y-max, t)
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
/// - show-grid (auto, bool): Draw background grid lines; `auto` uses theme default
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
  show-grid: auto,
  show-legend: true,
  theme: none,
) = context {
  validate-multi-scatter-data(data, "multi-scatter-plot")
  let grid-overrides = if show-grid != auto { (show-grid: show-grid) } else { none }
  let t = _resolve-ctx(theme, overrides: grid-overrides)
  let series = data.series

  // Get all points to find ranges
  let x-vals = ()
  let y-vals = ()
  for s in series {
    for pt in s.points {
      x-vals.push(pt.at(0))
      y-vals.push(pt.at(1))
    }
  }

  let xr = numeric-range(x-vals)
  let yr = numeric-range(y-vals)
  let (x-min, x-max, x-range) = (xr.min, xr.max, xr.range)
  let (y-min, y-max, y-range) = (yr.min, yr.max, yr.range)

  let cl = cartesian-layout(width, height, t, extra-left: 10pt)

  chart-container(width, height, title, t, extra-height: 50pt)[
    #let pad-top = cl.pad-top
    #let chart-height = cl.chart-height
    #let chart-width = cl.chart-width
    #let origin-x = cl.origin-x
    #let origin-y = cl.origin-y

    #box(width: width, height: height)[
      // Grid lines
      #draw-grid(origin-x, pad-top, chart-width, chart-height, t)

      // Axes
      #draw-axis-lines(origin-x, origin-y, origin-x + chart-width, pad-top, t)

      // Y-axis ticks
      #draw-y-ticks(y-min, y-max, chart-height, pad-top, origin-x, t)

      // X-axis ticks
      #draw-x-ticks(x-min, x-max, chart-width, origin-x, origin-y + 4pt, t)

      // Plot points for each series — clamp to chart bounds
      #let half = point-size / 2
      #for (si, s) in series.enumerate() {
        let color = get-color(t, si)
        for pt in s.points {
          let px = origin-x + ((pt.at(0) - x-min) / x-range) * chart-width
          let py = pad-top + chart-height - ((pt.at(1) - y-min) / y-range) * chart-height
          let px = clamp(px, origin-x + half, origin-x + chart-width - half)
          let py = clamp(py, pad-top + half, origin-y - half)

          place(
            left + top,
            dx: px - half,
            dy: py - half,
            circle(radius: point-size / 2, fill: color, stroke: white + 0.5pt)
          )
        }
      }
    ]

    // Legend
    #draw-legend-auto(series.map(s => s.name), t, show-legend: show-legend, swatch-type: "circle")
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
/// - show-grid (auto, bool): Draw background grid lines; `auto` uses theme default
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
  show-grid: auto,
  color: none,
  show-labels: false,
  labels: none,
  theme: none,
) = context {
  validate-bubble-data(data, "bubble-chart")
  let grid-overrides = if show-grid != auto { (show-grid: show-grid) } else { none }
  let t = _resolve-ctx(theme, overrides: grid-overrides)
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

  let xr = numeric-range(x-vals)
  let yr = numeric-range(y-vals)
  let (x-min, x-max, x-range) = (xr.min, xr.max, xr.range)
  let (y-min, y-max, y-range) = (yr.min, yr.max, yr.range)
  let size-min = calc.min(..size-vals)
  let size-max = calc.max(..size-vals)
  let size-range = nonzero(size-max - size-min)

  let bubble-color = if color != none { color } else { get-color(t, 0) }

  let cl = cartesian-layout(width, height, t, extra-left: 10pt)

  chart-container(width, height, title, t, extra-height: 30pt)[
    #let pad-top = cl.pad-top
    #let chart-height = cl.chart-height
    #let chart-width = cl.chart-width
    #let origin-x = cl.origin-x
    #let origin-y = cl.origin-y

    #box(width: width, height: height)[
      // Grid lines
      #draw-grid(origin-x, pad-top, chart-width, chart-height, t)

      // Axes
      #draw-axis-lines(origin-x, origin-y, origin-x + chart-width, pad-top, t)

      // Y-axis ticks
      #draw-y-ticks(y-min, y-max, chart-height, pad-top, origin-x, t)

      // X-axis ticks
      #draw-x-ticks(x-min, x-max, chart-width, origin-x, origin-y + 4pt, t)

      // Plot bubbles — clamp max-radius to chart dimensions
      #let effective-max-r = calc.min(max-radius, chart-height * 0.25, chart-width * 0.15)
      #let effective-min-r = calc.min(min-radius, effective-max-r * 0.3)
      #let bounds = (left: origin-x, right: origin-x + chart-width, top: pad-top, bottom: origin-y)
      #for (i, pt) in points.enumerate() {
        let px = origin-x + ((pt.at(0) - x-min) / x-range) * chart-width
        let py = pad-top + chart-height - ((pt.at(1) - y-min) / y-range) * chart-height
        let radius = effective-min-r + ((pt.at(2) - size-min) / size-range) * (effective-max-r - effective-min-r)
        // Clamp bubble center to chart bounds
        let px = clamp(px, origin-x + radius, origin-x + chart-width - radius)
        let py = clamp(py, pad-top + radius, origin-y - radius)

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

        // Optional label — inside bubble if it fits, otherwise above with leader
        if show-labels and labels != none and i < labels.len() {
          let lbl = labels.at(i)
          let lbl-len = if type(lbl) == str { lbl.len() } else { str(lbl).len() }
          let lbl-w = calc.max(radius * 2, t.axis-label-size * 0.6 * lbl-len + 4pt)
          if label-fits-inside(radius * 2, radius * 2, t.axis-label-size, lbl-len) {
            // Center label inside bubble
            place(
              left + top,
              dx: px - lbl-w / 2,
              dy: py - t.axis-label-size * 0.7,
              box(width: lbl-w, height: t.axis-label-size * 1.4,
                align(center + horizon,
                  text(size: t.axis-label-size, fill: t.text-color, weight: "bold")[#lbl]))
            )
          } else {
            // Place above the bubble with a leader line
            let label-y = py - radius - t.axis-label-size * 1.6
            let label-y = calc.max(bounds.top, label-y)
            place(left + top,
              line(start: (px, py - radius), end: (px, label-y + t.axis-label-size),
                stroke: 0.5pt + luma(140)))
            place(
              left + top,
              dx: calc.max(bounds.left, calc.min(bounds.right - lbl-w, px - lbl-w / 2)),
              dy: label-y,
              box(width: lbl-w,
                align(center,
                  text(size: t.axis-label-size, fill: t.text-color, weight: "bold")[#lbl]))
            )
          }
        }
      }

      // Axis titles
      #draw-axis-titles(x-label, y-label, origin-x + chart-width / 2, origin-y / 2, t)
    ]
  ]
}

/// Renders a multi-series bubble chart with color-coded point groups and
/// per-point size dimension.
///
/// - data (dictionary): Dict with `series` array, each containing `name` and
///   `points` (array of `(x, y, size)` tuples)
/// - width (length): Chart width
/// - height (length): Chart height
/// - title (none, content): Optional chart title
/// - x-label (none, content): X-axis title
/// - y-label (none, content): Y-axis title
/// - min-radius (length): Minimum bubble radius
/// - max-radius (length): Maximum bubble radius
/// - show-grid (auto, bool): Draw background grid lines; `auto` uses theme default
/// - show-legend (bool): Show series legend
/// - theme (none, dictionary): Theme overrides
/// -> content
#let multi-bubble-chart(
  data,
  width: 350pt,
  height: 250pt,
  title: none,
  x-label: none,
  y-label: none,
  min-radius: 4pt,
  max-radius: 25pt,
  show-grid: auto,
  show-legend: true,
  theme: none,
) = context {
  validate-multi-bubble-data(data, "multi-bubble-chart")
  let grid-overrides = if show-grid != auto { (show-grid: show-grid) } else { none }
  let t = _resolve-ctx(theme, overrides: grid-overrides)
  let series = data.series

  // Collect all x, y, size values across all series for axis/size scaling
  let x-vals = ()
  let y-vals = ()
  let size-vals = ()
  for s in series {
    for pt in s.points {
      x-vals.push(pt.at(0))
      y-vals.push(pt.at(1))
      size-vals.push(pt.at(2))
    }
  }

  let xr = numeric-range(x-vals)
  let yr = numeric-range(y-vals)
  let (x-min, x-max, x-range) = (xr.min, xr.max, xr.range)
  let (y-min, y-max, y-range) = (yr.min, yr.max, yr.range)
  let size-min = calc.min(..size-vals)
  let size-max = calc.max(..size-vals)
  let size-range = nonzero(size-max - size-min)

  let cl = cartesian-layout(width, height, t, extra-left: 10pt)

  chart-container(width, height, title, t, extra-height: 50pt)[
    #let pad-top = cl.pad-top
    #let chart-height = cl.chart-height
    #let chart-width = cl.chart-width
    #let origin-x = cl.origin-x
    #let origin-y = cl.origin-y

    #box(width: width, height: height)[
      // Grid lines
      #draw-grid(origin-x, pad-top, chart-width, chart-height, t)

      // Axes
      #draw-axis-lines(origin-x, origin-y, origin-x + chart-width, pad-top, t)

      // Y-axis ticks
      #draw-y-ticks(y-min, y-max, chart-height, pad-top, origin-x, t)

      // X-axis ticks
      #draw-x-ticks(x-min, x-max, chart-width, origin-x, origin-y + 4pt, t)

      // Plot bubbles for each series — clamp to chart bounds
      #let effective-max-r = calc.min(max-radius, chart-height * 0.25, chart-width * 0.15)
      #let effective-min-r = calc.min(min-radius, effective-max-r * 0.3)
      #for (si, s) in series.enumerate() {
        let color = get-color(t, si)
        for pt in s.points {
          let px = origin-x + ((pt.at(0) - x-min) / x-range) * chart-width
          let py = pad-top + chart-height - ((pt.at(1) - y-min) / y-range) * chart-height
          let radius = effective-min-r + ((pt.at(2) - size-min) / size-range) * (effective-max-r - effective-min-r)
          // Clamp bubble center to chart bounds
          let px = clamp(px, origin-x + radius, origin-x + chart-width - radius)
          let py = clamp(py, pad-top + radius, origin-y - radius)

          place(
            left + top,
            dx: px - radius,
            dy: py - radius,
            circle(
              radius: radius,
              fill: color.transparentize(40%),
              stroke: color + 1.5pt,
            )
          )
        }
      }
    ]

    // Legend
    #draw-legend-auto(series.map(s => s.name), t, show-legend: show-legend, swatch-type: "circle")
  ]
}
