// metric.typ - Dashboard KPI tiles with big number, label, delta, and optional sparkline
#import "../theme.typ": resolve-theme, get-color
#import "../util.typ": format-number

/// Renders a dashboard KPI tile with a prominent value, label, optional delta indicator,
/// and optional trend sparkline.
///
/// - value (int, float, str): The primary metric value to display
/// - label (str, content): Descriptive label shown below the value
/// - delta (none, int, float): Percentage change; positive renders green with ▲, negative renders red with ▼
/// - trend (none, array): Array of numeric values rendered as a small sparkline at the bottom
/// - width (length): Card width
/// - height (auto, length): Card height; `auto` sizes to content
/// - format (none, str): Number formatting mode passed to `format-number` ("auto", "si", "comma")
/// - theme (none, dictionary): Theme overrides
/// -> content
#let metric-card(
  value: 0,
  label: "",
  delta: none,
  trend: none,
  width: 150pt,
  height: auto,
  format: none,
  theme: none,
) = {
  let t = resolve-theme(theme)
  let accent = get-color(t, 0)

  // Format the display value
  let display-value = if type(value) == str {
    value
  } else if format != none {
    format-number(value, mode: format)
  } else {
    format-number(value)
  }

  // Delta colors and symbols
  let delta-content = if delta != none {
    let is-positive = delta > 0
    let is-zero = delta == 0
    let delta-color = if is-positive { rgb("#2d9d3a") } else if is-zero { gray } else { rgb("#d13438") }
    let arrow = if is-positive { "▲" } else if is-zero { "–" } else { "▼" }
    let sign = if is-positive { "+" } else { "" }
    let delta-str = sign + str(calc.round(delta, digits: 1)) + "%"

    text(size: 9pt, fill: delta-color, weight: "semibold")[#arrow #delta-str]
  }

  // Build the sparkline if trend data is provided
  let trend-content = if trend != none and trend.len() >= 2 {
    let n = trend.len()
    let spark-width = width - 20pt
    let spark-height = 20pt
    let min-val = calc.min(..trend)
    let max-val = calc.max(..trend)
    let val-range = if max-val - min-val == 0 { 1 } else { max-val - min-val }

    let points = ()
    for i in array.range(n) {
      let x = (i / (n - 1)) * spark-width
      let y = spark-height - ((trend.at(i) - min-val) / val-range) * spark-height
      points.push((x, y))
    }

    // Determine sparkline color from trend direction
    let spark-color = if trend.last() >= trend.first() { rgb("#2d9d3a").transparentize(30%) } else { rgb("#d13438").transparentize(30%) }

    v(6pt)
    box(width: spark-width, height: spark-height)[
      // Fill area
      #let fill-points = ()
      #fill-points.push((0pt, spark-height))
      #for pt in points {
        fill-points.push((pt.at(0), pt.at(1)))
      }
      #fill-points.push((spark-width, spark-height))
      #place(left + top,
        polygon(fill: spark-color.transparentize(60%), stroke: none, ..fill-points))
      // Line segments
      #for i in array.range(n - 1) {
        let p1 = points.at(i)
        let p2 = points.at(i + 1)
        place(left + top,
          line(
            start: (p1.at(0), p1.at(1)),
            end: (p2.at(0), p2.at(1)),
            stroke: 1pt + spark-color,
          ))
      }
      // Endpoint dot
      #let last = points.at(n - 1)
      #place(left + top, dx: last.at(0) - 1.5pt, dy: last.at(1) - 1.5pt,
        circle(radius: 1.5pt, fill: spark-color, stroke: none))
    ]
  }

  box(
    width: width,
    height: height,
    fill: if t.background != none { t.background } else { white },
    stroke: if t.border != none { t.border } else { 0.5pt + luma(220) },
    radius: 4pt,
    inset: 12pt,
  )[
    // Big number
    #text(size: 22pt, weight: "bold", fill: t.text-color)[#display-value]

    // Label
    #v(2pt)
    #text(size: 9pt, fill: t.text-color-light)[#label]

    // Delta indicator
    #if delta-content != none {
      v(3pt)
      delta-content
    }

    // Trend sparkline
    #if trend-content != none {
      trend-content
    }
  ]
}

/// Renders multiple metric cards side by side in a responsive row.
///
/// - metrics (array): Array of dictionaries, each passed as arguments to `metric-card`.
///   Keys: `value`, `label`, and optionally `delta`, `trend`, `format`.
/// - width (length): Total row width
/// - gap (length): Space between cards
/// - theme (none, dictionary): Theme overrides
/// -> content
#let metric-row(
  metrics,
  width: 100%,
  gap: 10pt,
  theme: none,
) = {
  let n = metrics.len()
  if n == 0 { return }

  let cols = range(n).map(_ => 1fr)

  grid(
    columns: cols,
    column-gutter: gap,
    ..metrics.map(m => {
      metric-card(
        value: m.at("value", default: 0),
        label: m.at("label", default: ""),
        delta: m.at("delta", default: none),
        trend: m.at("trend", default: none),
        width: 100%,
        format: m.at("format", default: none),
        theme: theme,
      )
    })
  )
}
