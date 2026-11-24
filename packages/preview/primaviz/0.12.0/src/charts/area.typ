// area.typ - Area charts (single and stacked)
#import "../theme.typ": _resolve-ctx, get-color
#import "../util.typ": normalize-data
#import "../validate.typ": validate-simple-data, validate-series-data
#import "../primitives/frame.typ": cartesian-frame
#import "../primitives/axes.typ": value-axis, category-axis
#import "../primitives/legend.typ": draw-legend-auto, legend-max-width
#import "../primitives/layout.typ": resolve-size
#import "../primitives/paths.typ": draw-polyline

// Room the first and last point need at the ends of the x axis.
#let _point-inset(show-points, size, line-width) = (if show-points { size } else { line-width }) / 2 + 1pt

/// Renders a single-series area chart with a filled region below the line.
///
/// - data (dictionary, array): Label-value pairs as dict or array of tuples
/// - width (length): Chart width
/// - height (length): Chart height
/// - title (none, content): Optional chart title
/// - show-line (bool): Draw the line on top of the filled area
/// - show-points (bool): Draw data point markers
/// - fill-opacity (ratio): Opacity of the filled area
/// - line-width (auto, length): Stroke width of the line; `auto` uses the theme's `stroke-thick`
/// - point-size (length): Diameter of point markers
/// - x-label (none, content): X-axis title
/// - y-label (none, content): Y-axis title
/// - annotations (none, array): Optional annotation descriptors
/// - show-ticks (bool): Draw tick marks on the axis lines
/// - show-minor-grid (bool): Draw lighter minor grid lines between the major ones
/// - theme (none, dictionary): Theme overrides
/// - extra-legend-separation (length): Extra space between legend and chart
/// -> content
#let area-chart(
  data,
  width: auto,
  height: auto,
  title: none,
  show-line: true,
  show-points: false,
  fill-opacity: 40%,
  line-width: auto,
  point-size: 6pt,
  x-label: none,
  y-label: none,
  annotations: none,
  show-ticks: false,
  show-minor-grid: false,
  theme: none,
  extra-legend-separation: 0pt
) = context {
  layout(size => {
  validate-simple-data(data, "area-chart")
  let t = _resolve-ctx(theme)
  let line-width = if line-width == auto { t.stroke-thick } else { line-width }
  let norm = normalize-data(data)
  let (labels, values) = (norm.labels, norm.values)
  let (width, height) = resolve-size(width, height, size, n: values.len(), theme: t)
  let color = get-color(t, 0)

  cartesian-frame(width, height, t,
    x: category-axis(labels, title: x-label, mode: "points", inset: _point-inset(show-points, point-size, line-width)),
    y: value-axis(calc.min(0, ..values), calc.max(0, ..values), title: y-label),
    baseline: (y: 0), annotations: annotations,
    title: title, show-ticks: show-ticks, show-minor-grid: show-minor-grid,
    extra-legend-separation: extra-legend-separation,
    p => {
      let (px, py) = (p.px, p.py)
      let points = values.enumerate().map(((i, v)) => (px(i), py(v)))
      let base = py(0)

      place(left + top, polygon(
        fill: color.transparentize(100% - fill-opacity), stroke: none,
        (points.first().at(0), base), ..points, (points.last().at(0), base),
      ))
      if show-line { draw-polyline(points, line-width + color) }
      if show-points {
        for pt in points {
          place(left + top, dx: pt.at(0) - point-size / 2, dy: pt.at(1) - point-size / 2,
            circle(radius: point-size / 2, fill: color, stroke: t.marker-stroke))
        }
      }
    },
  )
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
/// - line-width (auto, length): Stroke width of boundary lines; `auto` uses the theme's `stroke-mid`
/// - show-legend (bool): Show series legend
/// - x-label (none, content): X-axis title
/// - y-label (none, content): Y-axis title
/// - annotations (none, array): Optional annotation descriptors
/// - theme (none, dictionary): Theme overrides
/// - extra-legend-separation (length): Extra space between legend and chart
/// -> content
#let stacked-area-chart(
  data,
  width: auto,
  height: auto,
  title: none,
  show-lines: true,
  fill-opacity: 70%,
  line-width: auto,
  show-legend: true,
  x-label: none,
  y-label: none,
  annotations: none,
  theme: none,
  extra-legend-separation: 0pt
) = context {
  layout(size => {
  validate-series-data(data, "stacked-area-chart")
  let t = _resolve-ctx(theme)
  let line-width = if line-width == auto { t.stroke-mid } else { line-width }
  let (width, height) = resolve-size(width, height, size, n: data.labels.len(), theme: t)
  let (labels, series) = (data.labels, data.series)
  let n = labels.len()

  // cumulative.at(i).at(si): running total of series 0..si at label i
  let cumulative = range(n).map(i => {
    let (running, cum) = (0, ())
    for s in series {
      running += s.values.at(i)
      cum.push(running)
    }
    cum
  })
  let all-totals = cumulative.flatten()

  cartesian-frame(width, height, t,
    x: category-axis(labels, title: x-label, mode: "points", inset: _point-inset(false, 0pt, line-width)),
    y: value-axis(calc.min(0, ..all-totals), calc.max(0, ..all-totals), title: y-label),
    baseline: (y: 0), annotations: annotations,
    title: title, extra-legend-separation: extra-legend-separation,
    legend: draw-legend-auto(series.map(s => s.name), t, show-legend: show-legend, fit-width: true, max-width: legend-max-width(width, t)),
    p => {
      let (px, py) = (p.px, p.py)
      // Top series first, so the bottom series is drawn over its neighbour's edge
      for si in range(series.len() - 1, -1, step: -1) {
        let color = get-color(t, si)
        let upper = range(n).map(i => (px(i), py(cumulative.at(i).at(si))))
        let lower = range(n - 1, -1, step: -1).map(i => (px(i), py(if si == 0 { 0 } else { cumulative.at(i).at(si - 1) })))
        place(left + top, polygon(
          fill: color.transparentize(100% - fill-opacity),
          stroke: if show-lines { color + line-width } else { none },
          ..upper, ..lower,
        ))
      }
    },
  )
  })
}
