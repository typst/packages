// line.typ - Line charts (single and multi-series)
#import "../theme.typ": _resolve-ctx, get-color
#import "../util.typ": normalize-data, normalize-errors
#import "../validate.typ": validate-simple-data, validate-series-data, validate-line-style
#import "../primitives/frame.typ": cartesian-frame
#import "../primitives/axes.typ": value-axis, category-axis, fit-label-size, value-text
#import "../primitives/legend.typ": draw-legend-auto, legend-max-width
#import "../primitives/layout.typ": resolve-size, pin
#import "../primitives/paths.typ": round-stroke

// Moving average of the y values over `smooth-radius` neighbours on each side. A radius
// of 0 leaves every point where it is, so the curve through them interpolates the data.
#let _smooth-points(points, smooth-radius) = {
  let smoothed = ()
  for i in array.range(points.len()) {
    let pt = points.at(i)
    let lo = calc.max(i - smooth-radius, 0)
    let hi = calc.min(i + smooth-radius, points.len() - 1)
    let total-y = 0pt
    let count = 0
    for j in array.range(lo, hi + 1) {
      total-y += points.at(j).at(1)
      count += 1
    }
    smoothed.push((pt.at(0), total-y / count))
  }
  smoothed
}

#let _line-curve-components(points, line-interpolation) = {
  let comps = (curve.move(points.first()),)
  for i in array.range(points.len() - 1) {
    let p1 = points.at(i)
    let p2 = points.at(i + 1)
    if line-interpolation == "linear" {
      comps.push(curve.line(p2))
    } else if line-interpolation == "smooth" {
      let mid-x = (p1.at(0) + p2.at(0)) / 2
      comps.push(curve.cubic((mid-x, p1.at(1)), (mid-x, p2.at(1)), p2))
    } else if line-interpolation == "catmull-rom" {
      let p0 = points.at(calc.max(i - 1, 0))
      let p3 = points.at(calc.min(i + 2, points.len() - 1))
      let c1 = (p1.at(0) + (p2.at(0) - p0.at(0)) / 6, p1.at(1) + (p2.at(1) - p0.at(1)) / 6)
      let c2 = (p2.at(0) - (p3.at(0) - p1.at(0)) / 6, p2.at(1) - (p3.at(1) - p1.at(1)) / 6)
      comps.push(curve.cubic(c1, c2, p2))
    }
  }
  comps
}

#let draw-line-series(points, stroke, line-interpolation, smooth-radius) = {
  if points.len() <= 1 {
    return
  }

  let curve-points = if line-interpolation == "smooth" {
    _smooth-points(points, smooth-radius)
  } else {
    points
  }
  place(
    left + top,
    curve(stroke: round-stroke(stroke), fill: none, .._line-curve-components(curve-points, line-interpolation))
  )
}

// Fills the region between the line and `baseline-y`, following the same
// interpolation as the drawn line so fill and stroke share an edge.
#let draw-line-fill(points, fill, baseline-y, line-interpolation, smooth-radius) = {
  if points.len() <= 1 {
    return
  }

  let curve-points = if line-interpolation == "smooth" {
    _smooth-points(points, smooth-radius)
  } else {
    points
  }
  place(
    left + top,
    curve(
      stroke: none,
      fill: fill,
      .._line-curve-components(curve-points, line-interpolation),
      curve.line((curve-points.last().at(0), baseline-y)),
      curve.line((curve-points.first().at(0), baseline-y)),
      curve.close(mode: "straight"),
    )
  )
}

// A marker on a series point.
#let _dot(pt, size, fill, t) = place(left + top, dx: pt.at(0) - size / 2, dy: pt.at(1) - size / 2,
  circle(radius: size / 2, fill: fill, stroke: t.marker-stroke))

// Room a marker of `size` needs at the ends of an axis.
#let _marker-inset(show-points, size, line-width) = (if show-points { size } else { line-width }) / 2 + 1pt

/// Renders a single-series line chart.
///
/// - data (dictionary, array): Label-value pairs as dict or array of tuples
/// - width (length): Chart width
/// - height (length): Chart height
/// - title (none, content): Optional chart title
/// - show-points (bool): Draw data point markers
/// - show-values (bool): Display value labels at data points
/// - line-width (auto, length): Stroke width of the line; `auto` uses the theme's `stroke-thick`
/// - line-interpolation (str): "linear", "smooth", or "catmull-rom". Smooth and catmull-rom
///   curves pass through every data point (smooth with level tangents at each point, so
///   it never overshoots); markers, value labels and error bars always sit on the data
/// - smooth-radius (int): For `"smooth"`: 0 draws the curve through the data points;
///   1 to 5 draws a trend, the curve through a moving average of that radius, which
///   no longer meets the points (they stay at their true values)
/// - point-size (length): Diameter of point markers
/// - fill-area (bool): Fill the area under the line
/// - fill-opacity (ratio): Opacity of the filled area
/// - x-label (none, content): X-axis title
/// - y-label (none, content): Y-axis title
/// - errors (none, array): Symmetric `(e1, e2, ...)` or asymmetric `((lo1, hi1), ...)`
/// - error-color (auto, color): Error bar color; `auto` uses the series color
/// - error-cap-width (length): Width of the error bar caps
/// - annotations (none, array): Optional annotation descriptors
/// - show-ticks (bool): Draw tick marks on the axis lines
/// - show-minor-grid (bool): Draw lighter minor grid lines between the major ones
/// - subtitle (none, content): Optional subtitle below the title
/// - radius (length): Corner radius of the chart container
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
  line-width: auto,
  line-interpolation: "linear",
  smooth-radius: 0,
  point-size: 4pt,
  fill-area: false,
  fill-opacity: 40%,
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
  validate-line-style(line-interpolation, smooth-radius, "line-chart")
  let t = _resolve-ctx(theme)
  let line-width = if line-width == auto { t.stroke-thick } else { line-width }
  let norm = normalize-data(data)
  let (labels, values) = (norm.labels, norm.values)
  let n = values.len()
  let (width, height) = resolve-size(width, height, size, n: n, theme: t)
  let errs = normalize-errors(errors, n)
  let strs = values.map(v => value-text(v, t))
  let color = get-color(t, 0)

  // The axis covers the error bars too
  let lo = calc.min(..values.enumerate().map(((i, v)) => v - if errs != none { errs.at(i).low } else { 0 }))
  let hi = calc.max(..values.enumerate().map(((i, v)) => v + if errs != none { errs.at(i).high } else { 0 }))
  let inset = _marker-inset(show-points, point-size, line-width)

  cartesian-frame(width, height, t,
    x: category-axis(labels, title: x-label, mode: "points", inset: inset),
    y: value-axis(lo, hi, title: y-label, inset: inset),
    title: title, subtitle: subtitle, radius: radius,
    show-ticks: show-ticks, show-minor-grid: show-minor-grid,
    extra-legend-separation: extra-legend-separation, annotations: annotations,
    p => {
      let (px, py) = (p.px, p.py)
      let points = values.enumerate().map(((i, v)) => (px(i), py(v)))

      // Fill baseline: zero, or the axis floor when the visible range excludes it
      if fill-area {
        let baseline-y = calc.max(p.y0, calc.min(p.y1, py(0)))
        draw-line-fill(points, color.transparentize(100% - fill-opacity), baseline-y, line-interpolation, smooth-radius)
      }

      draw-line-series(points, line-width + color, line-interpolation, smooth-radius)

      // Error bars (under the points, so the marker sits on top)
      if errs != none {
        let err-stroke = t.stroke-thin + if error-color != auto { error-color } else { color }
        for (i, pt) in points.enumerate() {
          let (y-low, y-high) = (py(values.at(i) - errs.at(i).low), py(values.at(i) + errs.at(i).high))
          let cx = pt.at(0)
          place(left + top, line(start: (cx, y-low), end: (cx, y-high), stroke: err-stroke))
          for y in (y-low, y-high) {
            place(left + top, line(start: (cx - error-cap-width / 2, y), end: (cx + error-cap-width / 2, y), stroke: err-stroke))
          }
        }
      }

      let vsize = fit-label-size(strs, p.X.pitch, t.value-label-size)
      for (i, pt) in points.enumerate() {
        if show-points { _dot(pt, point-size, color, t) }
        if show-values and vsize != none {
          let lift = if show-points { point-size / 2 } else { 0pt }
          place(left + top, dx: pt.at(0) - p.X.pitch / 2, dy: pt.at(1) - lift - t.label-offset,
            pin(width: p.X.pitch, align: center + bottom, text(size: vsize, fill: t.text-color)[#strs.at(i)]))
        }
      }
    },
  )
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
/// - line-interpolation (str): "linear", "smooth", or "catmull-rom". Smooth and catmull-rom
///   curves pass through every data point (smooth with level tangents at each point, so
///   it never overshoots); markers, value labels and error bars always sit on the data
/// - smooth-radius (int): For `"smooth"`: 0 draws the curve through the data points;
///   1 to 5 draws a trend, the curve through a moving average of that radius, which
///   no longer meets the points (they stay at their true values)
/// - line-width (auto, length): Stroke width of each series line; `auto` uses the theme's `stroke-thick`
/// - point-size (length): Diameter of point markers
/// - x-label (none, content): X-axis title
/// - y-label (none, content): Y-axis title
/// - annotations (none, array): Optional annotation descriptors
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
  line-width: auto,
  line-interpolation: "linear",
  smooth-radius: 0,
  point-size: 6pt,
  x-label: none,
  y-label: none,
  annotations: none,
  theme: none,
  extra-legend-separation: 0pt
) = context {
  layout(size => {
  validate-series-data(data, "multi-line-chart")
  validate-line-style(line-interpolation, smooth-radius, "multi-line-chart")
  let t = _resolve-ctx(theme)
  let line-width = if line-width == auto { t.stroke-thick } else { line-width }
  let (width, height) = resolve-size(width, height, size, n: data.labels.len(), theme: t)
  let (labels, series) = (data.labels, data.series)
  let all-values = series.map(s => s.values).flatten()
  let inset = _marker-inset(show-points, point-size, line-width)

  cartesian-frame(width, height, t,
    x: category-axis(labels, title: x-label, mode: "points", inset: inset),
    y: value-axis(calc.min(..all-values), calc.max(..all-values), title: y-label, inset: inset),
    title: title, extra-legend-separation: extra-legend-separation, annotations: annotations,
    legend: draw-legend-auto(series.map(s => s.name), t, show-legend: show-legend, swatch-type: "line", fit-width: true, max-width: legend-max-width(width, t)),
    p => {
      let (px, py) = (p.px, p.py)
      for (si, s) in series.enumerate() {
        let color = get-color(t, si)
        let points = s.values.enumerate().map(((i, v)) => (px(i), py(v)))
        draw-line-series(points, line-width + color, line-interpolation, smooth-radius)
        if show-points {
          for pt in points { _dot(pt, point-size, color, t) }
        }
      }
    },
  )
  })
}
