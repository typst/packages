// dual-axis.typ - Dual Y-axis line chart
#import "../theme.typ": _resolve-ctx, get-color
#import "../validate.typ": validate-dual-axis-data
#import "../primitives/frame.typ": cartesian-frame
#import "../primitives/axes.typ": value-axis, category-axis
#import "../primitives/legend.typ": draw-legend-auto, legend-max-width
#import "../primitives/layout.typ": resolve-size
#import "../primitives/paths.typ": draw-polyline

/// Renders a line chart with two series on independent left and right y-axes.
///
/// The two axes share one set of grid lines whenever their ranges allow it, so
/// every tick on the left lines up with a tick on the right.
///
/// - data (dictionary): `labels`, `left` and `right` series (`name`, `values`)
/// - width (auto, length): Chart width
/// - height (auto, length): Chart height
/// - title (none, content): Optional chart title
/// - show-points (bool): Draw point markers
/// - line-width (auto, length): Stroke width of both lines; `auto` uses the theme's `stroke-thick`
/// - point-size (length): Diameter of point markers
/// - left-color (none, color): Left series color (theme palette when `none`)
/// - right-color (none, color): Right series color (theme palette when `none`)
/// - left-label (none, content): Left y-axis title
/// - right-label (none, content): Right y-axis title
/// - x-label (none, content): X-axis title
/// - show-grid (auto, bool): Override the theme's grid setting
/// - annotations (none, array): Annotation overlays
/// - theme (none, dictionary): Theme overrides
/// - extra-legend-separation (length): Extra space between legend and chart
/// -> content
#let dual-axis-chart(
  data,
  width: auto,
  height: auto,
  title: none,
  show-points: true,
  line-width: auto,
  point-size: 6pt,
  left-color: none,
  right-color: none,
  left-label: none,
  right-label: none,
  x-label: none,
  show-grid: auto,
  annotations: none,
  theme: none,
  extra-legend-separation: 0pt
) = context {
  layout(size => {
  validate-dual-axis-data(data, "dual-axis-chart")
  let grid-overrides = if show-grid != auto { (show-grid: show-grid) } else { none }
  let t = _resolve-ctx(theme, overrides: grid-overrides)
  let line-width = if line-width == auto { t.stroke-thick } else { line-width }
  let (width, height) = resolve-size(width, height, size, n: data.labels.len(), theme: t)
  let (labels, ls, rs) = (data.labels, data.left, data.right)

  let l-color = if left-color != none { left-color } else { get-color(t, 0) }
  let r-color = if right-color != none { right-color } else { get-color(t, 1) }
  let inset = (if show-points { point-size } else { line-width }) / 2 + 1pt

  cartesian-frame(width, height, t,
    x: category-axis(labels, title: x-label, mode: "points", inset: inset),
    y: value-axis(calc.min(..ls.values), calc.max(..ls.values), title: left-label, color: l-color, inset: inset),
    y2: value-axis(calc.min(..rs.values), calc.max(..rs.values), title: right-label, color: r-color, inset: inset),
    title: title, extra-legend-separation: extra-legend-separation, annotations: annotations,
    legend: draw-legend-auto(
      ((name: ls.name, color: l-color), (name: rs.name, color: r-color)),
      t, swatch-type: "line", fit-width: true, max-width: legend-max-width(width, t),
    ),
    p => {
      for (series, color, pos) in ((ls, l-color, p.py), (rs, r-color, p.py2)) {
        let points = series.values.enumerate().map(((i, v)) => ((p.px)(i), pos(v)))
        draw-polyline(points, line-width + color)
        if show-points {
          for pt in points {
            place(left + top, dx: pt.at(0) - point-size / 2, dy: pt.at(1) - point-size / 2,
              circle(radius: point-size / 2, fill: color, stroke: t.marker-stroke))
          }
        }
      }
    },
  )
  })
}
