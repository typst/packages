// bump.typ - Bump chart (multi-period ranking chart)
#import "../theme.typ": _resolve-ctx, get-color
#import "../validate.typ": validate-series-data
#import "../primitives/frame.typ": cartesian-frame
#import "../primitives/axes.typ": value-axis, category-axis
#import "../primitives/legend.typ": draw-legend-auto, legend-max-width
#import "../primitives/layout.typ": resolve-size, spread-labels
#import "../primitives/paths.typ": draw-polyline

/// Renders a bump chart showing how items change ranking over time periods.
///
/// Rankings are displayed with rank 1 at the top and rank N at the bottom
/// (inverted Y-axis). Each series is drawn as a thick colored line with dots
/// at each time period, similar to F1 race position charts. The ranks sit
/// inside the plot with room above and below, clear of the period labels, and
/// there are no axis lines: the lines and their end labels are the data. Labels
/// of series that share a rank (or sit closer than a line of text) are moved
/// apart, in order, and joined to their dot by a short leader line.
///
/// - data (dictionary): Dict with `labels` (time periods) and `series`
///   (each with `name` and `values` representing rankings per period)
/// - width (length): Chart width
/// - height (length): Chart height
/// - title (none, content): Optional chart title
/// - dot-size (length): Diameter of point markers at each period
/// - line-width (auto, length): Stroke width of ranking lines; `auto` uses the theme's `stroke-heavy`
/// - show-labels (bool): Show series name labels at start and end of lines
/// - show-legend (bool): Show series legend below the chart (redundant, so not drawn, while the lines carry their own labels)
/// - theme (none, dictionary): Theme overrides
/// - extra-legend-separation (length): Extra space between legend and chart
/// -> content
#let bump-chart(
  data,
  width: auto,
  height: auto,
  title: none,
  dot-size: 5pt,
  line-width: auto,
  show-labels: true,
  show-legend: true,
  theme: none,
  extra-legend-separation: 0pt
) = context {
  layout(size => {
  validate-series-data(data, "bump-chart")
  let t = _resolve-ctx(theme)
  let line-width = if line-width == auto { t.stroke-heavy } else { line-width }
  let (width, height) = resolve-size(width, height, size, n: data.labels.len(), theme: t)
  let (labels, series) = (data.labels, data.series)
  let n = labels.len()
  if n == 0 or series.len() == 0 { return }

  // Ranks run from the best to the worst rank in the data, best at the top.
  // The value axis grows upward, so it holds the negated rank; ticks label it back.
  let all-values = series.map(s => s.values).flatten()
  let (best, worst) = (calc.min(..all-values), calc.max(..all-values))
  let ranks = range(int(calc.floor(best)), int(calc.ceil(worst)) + 1)
  let rank-axis = (
    min: -ranks.last(), max: -ranks.first(), step: 1, digits: 0,
    ticks: ranks.rev().map(r => -r), labels: ranks.rev().map(str),
  )

  // Room for a series name beside the first and last dots
  let name-w = if show-labels {
    calc.max(..series.map(s => measure(text(size: t.axis-label-size, weight: "bold")[#s.name]).width))
  } else { 0pt }
  let marker = dot-size / 2 + line-width / 2
  let name-room = if show-labels { name-w + dot-size / 2 + 4pt } else { 0pt }
  // Lines keep half a rank (at most 24pt) away from the plot's top and bottom
  let inset-y = calc.min(24pt, calc.max(marker + 2pt, height / ranks.len() * 0.35))

  cartesian-frame(width, height, t,
    x: category-axis(labels, mode: "points", inset: marker + 2pt),
    y: value-axis(rank-axis.min, rank-axis.max, ticks: rank-axis, inset: inset-y, labelled: not show-labels),
    axis-lines: (x: false, y: false),
    title: title, extra-legend-separation: extra-legend-separation,
    legend: draw-legend-auto(series.map(s => s.name), t, show-legend: show-legend and not show-labels, swatch-type: "line", fit-width: true, max-width: legend-max-width(width, t)),
    reserve: (left: calc.max(0pt, name-room - marker - 2pt), right: calc.max(0pt, name-room - marker - 2pt)),
    p => {
      let (px, py) = (p.px, p.py)

      // End labels: where each series ends, nudged apart so none touch (ties share a
      // position). Labels of the first period and of the last are spread separately; the
      // room grows (`extra`) so that every label has a place.
      // The text shrinks (to a floor) when the series are more than the plot's height holds
      let lbl-h0 = measure(text(size: t.axis-label-size, weight: "bold", top-edge: "ascender", bottom-edge: "descender")[Ag]).height
      let lbl-size = calc.max(
        calc.min(5.5pt, t.axis-label-size),
        calc.min(t.axis-label-size, (p.y1 - p.y0) / calc.max(1, series.len() - 1) / (lbl-h0 / t.axis-label-size)))
      let lbl-h = lbl-h0 * (lbl-size / t.axis-label-size)
      let spread(ranks) = {
        let need = (ranks.len() - 1) * lbl-h
        let extra = calc.max(0pt, need - (p.y1 - p.y0)) / 2
        spread-labels(ranks.map(r => py(-r)), gap: lbl-h, lo: p.y0 - extra, hi: p.y1 + extra)
      }
      let first-ys = spread(series.map(s => s.values.first()))
      let last-ys = spread(series.map(s => s.values.last()))

      for (si, s) in series.enumerate() {
        let color = get-color(t, si)
        let points = s.values.enumerate().map(((i, rank)) => (px(i), py(-rank)))
        draw-polyline(points, line-width + color)
        for pt in points {
          place(left + top, dx: pt.at(0) - dot-size / 2, dy: pt.at(1) - dot-size / 2,
            circle(radius: dot-size / 2, fill: color, stroke: t.marker-stroke))
        }

        // Name beside the first dot (left) and the last (right), on a leader when moved
        if show-labels {
          let name = text(size: lbl-size, fill: color, weight: "bold")[#s.name]
          let (first, last) = (points.first(), points.last())
          let leader(pt, y, dir) = if calc.abs(y - pt.at(1)) > 1pt {
            place(left + top, line(
              start: (pt.at(0) + dir * (dot-size / 2 + 0.5pt), pt.at(1)),
              end: (pt.at(0) + dir * (dot-size / 2 + 3.5pt), y), stroke: 0.6pt + color))
          }
          leader(first, first-ys.at(si), -1)
          place(left + top, dx: first.at(0) - dot-size / 2 - 4pt - name-w, dy: first-ys.at(si),
            box(width: name-w, height: 0pt, align(right + horizon, name)))
          if n > 1 {
            leader(last, last-ys.at(si), 1)
            place(left + top, dx: last.at(0) + dot-size / 2 + 4pt, dy: last-ys.at(si),
              box(width: name-w, height: 0pt, align(left + horizon, name)))
          }
        }
      }
    },
  )
  })
}
