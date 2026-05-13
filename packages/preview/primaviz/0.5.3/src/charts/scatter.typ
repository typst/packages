// scatter.typ - Scatter plot and bubble chart
#import "../theme.typ": _resolve-ctx, get-color
#import "../util.typ": nonzero, clamp, nice-ceil, nice-floor, numeric-range
#import "../primitives/layout.typ": label-fits-inside, place-cartesian-label, try-fit-label, greedy-deconflict, resolve-size
#import "../validate.typ": validate-scatter-data, validate-multi-scatter-data, validate-bubble-data, validate-multi-bubble-data
#import "../primitives/container.typ": chart-container
#import "../primitives/axes.typ": cartesian-layout, draw-axis-lines, draw-grid, draw-axis-titles, draw-y-ticks, draw-x-ticks, measure-y-tick-width
#import "../primitives/legend.typ": draw-legend-auto, draw-size-legend
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
  width: auto,
  height: auto,
  title: none,
  x-label: none,
  y-label: none,
  point-size: 5pt,
  show-grid: auto,
  color: none,
  annotations: none,
  show-ticks: false,
  show-minor-grid: false,
  subtitle: none,
  radius: 0pt,
  theme: none,
) = context {
  layout(size => {
  validate-scatter-data(data, "scatter-plot")
  let grid-overrides = if show-grid != auto { (show-grid: show-grid) } else { none }
  let t = _resolve-ctx(theme, overrides: grid-overrides)
  let (width, height) = resolve-size(width, height, size, n: 10, theme: t)
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

  chart-container(width, height, title, t, extra-height: 30pt, subtitle: subtitle, radius: radius)[
    #let pad-top = cl.pad-top
    #let chart-height = cl.chart-height
    #let chart-width = cl.chart-width
    #let origin-x = cl.origin-x
    #let origin-y = cl.origin-y

    #box(width: width, height: height)[
      // Grid lines
      #draw-grid(origin-x, pad-top, chart-width, chart-height, t, show-minor-grid: show-minor-grid)

      // Axes
      #draw-axis-lines(origin-x, origin-y, origin-x + chart-width, pad-top, t, show-ticks: show-ticks)

      // Y-axis ticks
      #draw-y-ticks(y-min, y-max, chart-height, pad-top, origin-x, t)

      // X-axis ticks
      #draw-x-ticks(x-min, x-max, chart-width, origin-x, origin-y + t.label-offset, t)

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
          circle(radius: point-size / 2, fill: point-color, stroke: t.marker-stroke)
        )
      }

      // Axis titles
      #let y-tw = measure-y-tick-width(y-min, y-max, t)
      #draw-axis-titles(x-label, y-label, origin-x + chart-width / 2, pad-top + chart-height / 2, t, origin-x: origin-x, origin-y: origin-y, y-tick-width: y-tw)

      // Annotations
      #draw-annotations(annotations, origin-x, pad-top, chart-width, chart-height, x-min, x-max, y-min, y-max, t)
    ]
  ]
  })
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
  width: auto,
  height: auto,
  title: none,
  x-label: none,
  y-label: none,
  point-size: 5pt,
  show-grid: auto,
  show-legend: true,
  theme: none,
) = context {
  layout(size => {
  validate-multi-scatter-data(data, "multi-scatter-plot")
  let grid-overrides = if show-grid != auto { (show-grid: show-grid) } else { none }
  let t = _resolve-ctx(theme, overrides: grid-overrides)
  let (width, height) = resolve-size(width, height, size, n: 10, theme: t)
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

  let legend-content = draw-legend-auto(series.map(s => s.name), t, show-legend: show-legend, swatch-type: "circle")
  chart-container(width, height, title, t, extra-height: 50pt, legend: legend-content)[
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
      #draw-x-ticks(x-min, x-max, chart-width, origin-x, origin-y + t.label-offset, t)

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
            circle(radius: point-size / 2, fill: color, stroke: t.marker-stroke)
          )
        }
      }

      #let y-tw = measure-y-tick-width(y-min, y-max, t)
      #draw-axis-titles(x-label, y-label, origin-x + chart-width / 2, pad-top + chart-height / 2, t, origin-x: origin-x, origin-y: origin-y, y-tick-width: y-tw)
    ]
  ]
  })
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
  width: auto,
  height: auto,
  title: none,
  x-label: none,
  y-label: none,
  size-label: none,
  min-radius: 5pt,
  max-radius: 30pt,
  show-grid: auto,
  color: none,
  show-labels: false,
  labels: none,
  theme: none,
) = context {
  layout(size => {
  validate-bubble-data(data, "bubble-chart")
  let grid-overrides = if show-grid != auto { (show-grid: show-grid) } else { none }
  let t = _resolve-ctx(theme, overrides: grid-overrides)
  let (width, height) = resolve-size(width, height, size, n: 10, theme: t)
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
      #draw-x-ticks(x-min, x-max, chart-width, origin-x, origin-y + t.label-offset, t)

      // Plot bubbles — clamp max-radius to chart dimensions
      #let effective-max-r = calc.min(max-radius, chart-height * 0.25, chart-width * 0.15)
      #let effective-min-r = calc.min(min-radius, effective-max-r * 0.3)
      #let bounds = (left: origin-x, right: origin-x + chart-width, top: pad-top, bottom: origin-y)

      // Pass 0: Pre-compute all bubble positions
      #let computed = points.enumerate().map(((i, pt)) => {
        let px = origin-x + ((pt.at(0) - x-min) / x-range) * chart-width
        let py = pad-top + chart-height - ((pt.at(1) - y-min) / y-range) * chart-height
        let radius = effective-min-r + ((pt.at(2) - size-min) / size-range) * (effective-max-r - effective-min-r)
        let px = clamp(px, origin-x + radius, origin-x + chart-width - radius)
        let py = clamp(py, pad-top + radius, origin-y - radius)
        (i: i, px: px, py: py, radius: radius)
      })

      // Draw all bubbles
      #for b in computed {
        place(
          left + top,
          dx: b.px - b.radius,
          dy: b.py - b.radius,
          circle(
            radius: b.radius,
            fill: bubble-color.transparentize(40%),
            stroke: bubble-color + 1.5pt
          )
        )
      }

      // Two-pass label placement
      #if show-labels and labels != none {
        let inside-labels = ()
        let outside-proposals = ()
        let lbl-size = t.axis-label-size
        let lbl-h = lbl-size * 1.4

        // Pass 1: Decide inside vs outside for each bubble
        for b in computed {
          if b.i >= labels.len() { continue }
          let lbl = labels.at(b.i)
          let lbl-len = if type(lbl) == str { lbl.len() } else { str(lbl).len() }
          let fit = try-fit-label(b.radius * 2, b.radius * 2, lbl-size, lbl-len)

          if fit.fits {
            inside-labels.push((px: b.px, py: b.py, radius: b.radius, lbl: lbl, size: fit.size))
          } else {
            // Propose label position, quadrant-aware horizontal offset
            let chart-cx = (bounds.left + bounds.right) / 2
            let chart-cy = (bounds.top + bounds.bottom) / 2
            let lbl-w = calc.max(40pt, lbl-size * 0.6 * lbl-len + 4pt)
            let lx = if b.px >= chart-cx {
              b.px + 4pt
            } else {
              b.px - lbl-w - 4pt
            }
            // Place label above or below bubble based on vertical position:
            // bubbles in the upper half get labels below, lower half get labels above.
            // This naturally separates labels for vertically-close bubbles.
            let ly = if b.py <= chart-cy {
              b.py + b.radius + 4pt                   // below bubble
            } else {
              b.py - b.radius - lbl-h - 4pt           // above bubble
            }
            outside-proposals.push((
              cx: b.px, cy: b.py, radius: b.radius,
              lx: lx, ly: ly, w: lbl-w, h: lbl-h,
              lbl: lbl,
            ))
          }
        }

        // Pass 2: Deconflict outside labels
        let deconflicted = greedy-deconflict(outside-proposals, bounds)

        // Render inside labels
        for il in inside-labels {
          let lbl-w = il.size * 0.6 * il.lbl.len() + 4pt
          let lbl-w = calc.max(il.radius * 2, lbl-w)
          place(
            left + top,
            dx: il.px - lbl-w / 2,
            dy: il.py - il.size * 0.7,
            box(width: lbl-w, height: il.size * 1.4,
              align(center + horizon,
                text(size: il.size, fill: t.text-color, weight: "bold")[#il.lbl]))
          )
        }

        // Render outside labels with leaders
        for ol in deconflicted {
          let anchor-x = ol.lx + ol.w / 2
          let anchor-y = ol.ly + ol.h / 2
          // Leader from bubble edge toward label center
          let dx = anchor-x - ol.cx
          let dy = anchor-y - ol.cy
          // Approximate point on bubble edge toward label
          let dx-f = dx / 1pt
          let dy-f = dy / 1pt
          let dist = calc.max(1.0, calc.sqrt(dx-f * dx-f + dy-f * dy-f))
          let edge-x = ol.cx + dx-f / dist * ol.radius
          let edge-y = ol.cy + dy-f / dist * ol.radius
          place(left + top,
            line(start: (edge-x, edge-y),
                 end: (anchor-x, anchor-y),
                 stroke: 0.5pt + t.text-color-light))
          place(
            left + top,
            dx: ol.lx,
            dy: ol.ly,
            box(width: ol.w,
              align(center,
                text(size: lbl-size, fill: t.text-color, weight: "bold")[#ol.lbl]))
          )
        }
      }

      // Axis titles
      #let y-tw = measure-y-tick-width(y-min, y-max, t)
      #draw-axis-titles(x-label, y-label, origin-x + chart-width / 2, pad-top + chart-height / 2, t, origin-x: origin-x, origin-y: origin-y, y-tick-width: y-tw)
    ]

    // Size legend below chart
    #if size-label != none {
      let ref-sizes = (
        (size-max, str(calc.round(size-max))),
        (calc.round(size-max * 0.5), str(calc.round(size-max * 0.5))),
        (calc.round(size-max * 0.15), str(calc.round(size-max * 0.15))),
      )
      draw-size-legend(ref-sizes, max-radius, size-max, t, title: size-label)
    }
  ]
  })
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
  width: auto,
  height: auto,
  title: none,
  x-label: none,
  y-label: none,
  size-label: none,
  min-radius: 4pt,
  max-radius: 25pt,
  show-grid: auto,
  show-legend: true,
  theme: none,
) = context {
  layout(size => {
  validate-multi-bubble-data(data, "multi-bubble-chart")
  let grid-overrides = if show-grid != auto { (show-grid: show-grid) } else { none }
  let t = _resolve-ctx(theme, overrides: grid-overrides)
  let (width, height) = resolve-size(width, height, size, n: 10, theme: t)
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

  let legend-content = draw-legend-auto(series.map(s => s.name), t, show-legend: show-legend, swatch-type: "circle")
  chart-container(width, height, title, t, extra-height: 50pt, legend: legend-content)[
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
      #draw-x-ticks(x-min, x-max, chart-width, origin-x, origin-y + t.label-offset, t)

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

    // Size legend
    #if size-label != none {
      let ref-sizes = (
        (size-max, str(calc.round(size-max))),
        (calc.round(size-max * 0.5), str(calc.round(size-max * 0.5))),
        (calc.round(size-max * 0.15), str(calc.round(size-max * 0.15))),
      )
      draw-size-legend(ref-sizes, max-radius, size-max, t, title: size-label)
    }
  ]
  })
}
