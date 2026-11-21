// metric.typ - Dashboard KPI tiles with big number, label, delta, and optional sparkline
#import "../theme.typ": _resolve-ctx
#import "../util.typ": format-number
#import "../primitives/layout.typ": resolve-size
#import "../primitives/polar-labels.typ": fit-text-size, legible
#import "../primitives/status.typ": status-colors
#import "sparkline.typ": sparkline

// The text a tile shows for `value`
#let _display-value(value, format, suffix) = {
  let shown = if type(value) == str {
    value
  } else if format != none {
    format-number(value, mode: format)
  } else {
    format-number(value)
  }
  if suffix != none { shown + suffix } else { shown }
}

// Largest headline size, from `max-size` down to `min-size`, at which every
// one of `texts` fits `max-w`
#let _fit-value-size(texts, max-w, max-size, min-size) = calc.min(
  ..texts.map(s => fit-text-size(sz => text(size: sz, weight: "bold")[#s], calc.max(max-w, 1pt), max-size, min-size)))

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
/// - suffix (none, str): Optional suffix appended to the display value (e.g., "%", "ms")
/// - value-size (auto, length): Size of the headline number; `auto` is the theme's, shrunk until the number fits the card
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
  suffix: none,
  value-size: auto,
  theme: none,
) = context {
  layout(size => {
  let t = _resolve-ctx(theme)
  set text(size: 11pt)  // sized by the theme, not the document font
  let width = resolve-size(width, 0pt, size, container: false).width
  let card-fill = if t.background != none { t.background } else { white }
  let status = status-colors(t)

  let display-value = _display-value(value, format, suffix)

  // The headline number is as big as the theme says, or as big as the card is
  // wide (a narrow tile in a row of many would otherwise spill over its neighbours)
  let value-size = if value-size != auto { value-size } else {
    _fit-value-size((display-value,), width - 24pt, t.title-size * 2, t.axis-label-size)
  }

  // Delta colour and symbol; text is darkened until it reads on the card
  let delta-content = if delta != none {
    let delta-color = if delta > 0 { status.positive }
      else if delta == 0 { t.text-color-light }
      else { status.negative }
    let arrow = if delta > 0 { "▲" } else if delta == 0 { "–" } else { "▼" }
    let sign = if delta > 0 { "+" } else { "" }
    text(size: t.axis-title-size, fill: legible(delta-color, card-fill, min-ratio: 4.0), weight: "semibold")[#arrow #sign#calc.round(delta, digits: 1)%]
  }

  // The trend is a sparkline, coloured by direction
  let trend-content = if trend != none and trend.len() >= 2 {
    let spark-color = (if trend.last() >= trend.first() { status.positive } else { status.negative }).transparentize(30%)
    sparkline(trend, width: width - 24pt, height: 20pt, color: spark-color, fill-area: true, theme: theme)
  }

  box(
    width: width,
    height: height,
    fill: card-fill,
    stroke: if t.border != none { t.border } else { 0.5pt + t.text-color-light },
    radius: t.border-radius,
    inset: 12pt,
  )[
    #set align(center)
    #stack(dir: ttb, spacing: 6pt,
      text(size: value-size, weight: "bold", fill: t.text-color)[#display-value],
      text(size: t.axis-title-size, fill: t.text-color-light)[#label],
      ..if delta-content != none { (delta-content,) } else { () },
      ..if trend-content != none { (v(3pt), trend-content) } else { () },
    )
  ]
  })
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
) = context {
  let n = metrics.len()
  if n == 0 { return }

  layout(size => {
    let row-w = resolve-size(width, 0pt, size, container: false).width
    let card-w = (row-w - gap * (n - 1)) / n
    // One headline size for the whole row: the largest at which every number
    // fits its tile, so the tiles match
    let t = _resolve-ctx(theme)
    let value-size = _fit-value-size(
      metrics.map(m => _display-value(m.at("value", default: 0), m.at("format", default: none), m.at("suffix", default: none))),
      card-w - 24pt, t.title-size * 2, t.axis-label-size)
    let card(m, h) = metric-card(
      value-size: value-size,
      value: m.at("value", default: 0),
      label: m.at("label", default: ""),
      delta: m.at("delta", default: none),
      trend: m.at("trend", default: none),
      width: card-w,
      height: h,
      format: m.at("format", default: none),
      suffix: m.at("suffix", default: none),
      theme: theme,
    )
    // Cards with and without a delta or trend are different heights: the row
    // takes the tallest, so the tiles line up
    let tallest = calc.max(..metrics.map(m => measure(card(m, auto)).height))
    block(width: row-w, grid(
      columns: range(n).map(_ => card-w),
      column-gutter: gap,
      ..metrics.map(m => card(m, tallest)),
    ))
  })
}
