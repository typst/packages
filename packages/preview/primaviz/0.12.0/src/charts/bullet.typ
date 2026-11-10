// bullet.typ - Bullet chart (Stephen Few's design)
// A compact gauge replacement showing a quantitative measure against a target
// with qualitative ranges (poor/satisfactory/good).

#import "../theme.typ": _resolve-ctx, get-color, _is-dark, _shade
#import "../util.typ": nonzero, nice-ticks
#import "../validate.typ": validate-bullet-data, validate-bullet-charts-data
#import "../primitives/container.typ": chart-container
#import "../primitives/layout.typ": resolve-size, text-width, fit-font-size
#import "../primitives/rows.typ": linear-x-ticks, draw-x-axis, x-axis-extent, tick-label-width

// Qualitative band shades, darkest = poor, lightest = good
#let _range-fills(t) = if _is-dark(t) {
  (_shade(t, 15%), _shade(t, 25%), _shade(t, 35%))
} else {
  (t.text-color-light.transparentize(50%), t.text-color-light.transparentize(70%), t.text-color-light.transparentize(85%))
}

// Width of the title column for a set of (title, label) pairs. Bullets that
// are stacked as separate calls should still line up, so the column has a
// steady default width (90pt, or 35% of a narrow chart) and grows only when a
// title, measured, would not fit it, up to 45% of the chart. 0 when nothing
// has a title.
#let _title-column(pairs, width, t) = {
  let gap = t.axis-label-gap * 1.5
  let natural = pairs.fold(0pt, (acc, p) => {
    let (title, label) = p
    let w = if title != none { text-width(title, t.axis-title-size, weight: "bold") } else { 0pt }
    let lw = if label != none { text-width(label, t.axis-label-size) } else { 0pt }
    calc.max(acc, w, lw)
  })
  if natural == 0pt { 0pt } else {
    calc.min(calc.max(natural + gap, calc.min(90pt, width * 0.35)), width * 0.45)
  }
}

// One bullet: title column, bands, value bar, target marker, scale. The box is
// `height` of bar plus the scale below it, plus a trailing gap so a stack of
// bullets reads as rows and each scale stays with its own bar.
#let _bullet(value, target, ranges, width, height, title, label, show-target, t, title-w) = {
  let bar-color = get-color(t, 0)
  let range-fills = _range-fills(t)
  let max-range = nonzero(ranges.last())
  let gap = t.axis-label-gap * 1.5

  let nt = nice-ticks(0, max-range, count: t.tick-count)
  let tick-half = tick-label-width(linear-x-ticks(nt, 0, max-range, 0pt, 1pt, t), t) / 2
  let x0 = title-w
  let bar-width = width - title-w - tick-half
  let scale-h = x-axis-extent(t, marks: true)

  box(width: width, height: height + scale-h + t.axis-label-gap)[
    // Title column, centred on the bar
    #if title != none {
      let avail = title-w - gap
      let title-size = fit-font-size(title, avail, t.axis-title-size, min: 7pt, weight: "bold")
      let label-size = if label != none { fit-font-size(label, avail, t.axis-label-size, min: 6pt) } else { t.axis-label-size }
      place(left + top, box(width: avail, height: height, align(left + horizon, {
        text(size: title-size, weight: "bold", fill: t.text-color)[#title]
        if label != none {
          linebreak()
          text(size: label-size, fill: t.text-color-light)[#label]
        }
      })))
    }

    // Qualitative ranges, widest first so the narrower ones sit on top
    #for k in (2, 1, 0) {
      place(left + top, dx: x0, rect(
        width: bar-width * (ranges.at(k) / max-range),
        height: height,
        fill: range-fills.at(k),
        stroke: none,
      ))
    }

    // Value bar (thinner, ~60% height, centred vertically)
    #let bar-h = height * 0.6
    #place(left + top, dx: x0, dy: (height - bar-h) / 2, rect(
      width: bar-width * calc.min(1, calc.max(0, value / max-range)),
      height: bar-h,
      fill: bar-color,
      stroke: none,
    ))

    // Target marker (short vertical line)
    #if show-target {
      let target-x = x0 + bar-width * calc.min(1, calc.max(0, target / max-range))
      let marker-h = height * 0.85
      place(left + top, dx: target-x - 1pt, dy: (height - marker-h) / 2,
        rect(width: 2.5pt, height: marker-h, fill: t.text-color, stroke: none))
    }

    // Scale below the bar
    #draw-x-axis(linear-x-ticks(nt, 0, max-range, x0, x0 + bar-width, t), height, t,
      axis-line: false, marks: true)
  ]
}

/// Renders a single bullet chart — a horizontal bar showing an actual value
/// against a target marker, overlaid on qualitative range bands.
///
/// - value (int, float): The actual measured value
/// - target (int, float): The target/comparative value shown as a vertical marker
/// - ranges (array): Three ascending thresholds defining poor, satisfactory, and good zones
/// - width (length): Chart width
/// - height (auto, length): Chart height (bar thickness); `auto` scales with the theme's `base-size` (3.75x, 30pt in the default theme)
/// - title (none, content, str): Optional label shown to the left
/// - label (none, content, str): Optional secondary label below the title
/// - show-target (bool): Whether to draw the target marker
/// - theme (none, dictionary): Theme overrides
/// -> content
#let bullet-chart(
  value,
  target,
  ranges,
  width: 250pt,
  height: auto,
  title: none,
  label: none,
  show-target: true,
  theme: none,
) = context {
  layout(size => {
  validate-bullet-data((value: value, target: target, ranges: ranges), "bullet-chart")
  let t = _resolve-ctx(theme)
  let height = if height == auto { 3.75 * t.base-size } else { height }
  set text(size: 11pt)  // sized by the theme, not the document font
  let (width, height) = resolve-size(width, height, size, container: false)
  let title-w = if title != none { _title-column(((title, label),), width, t) } else { 0pt }
  _bullet(value, target, ranges, width, height, title, label, show-target, t, title-w)
  })
}

/// Renders multiple bullet charts stacked vertically for KPI dashboards.
///
/// The bars share one title column (the widest title, measured), so they
/// start at the same x.
///
/// - data (dictionary): Must contain a `bullets` key with an array of bullet specs.
///   Each spec: `(value: ..., target: ..., ranges: ..., title: "...")`.
///   Optional per-bullet keys: `label`.
/// - width (length): Overall width for each bullet
/// - bar-height (auto, length): Height of each individual bullet bar; `auto` scales with the theme's `base-size` (3.125x, 25pt in the default theme)
/// - gap (auto, length): Vertical spacing between bullets; `auto` scales with the theme's `base-size` (1.875x, 15pt in the default theme)
/// - title (none, content, str): Optional heading above all bullets
/// - theme (none, dictionary): Theme overrides
/// -> content
#let bullet-charts(
  data,
  width: 300pt,
  bar-height: auto,
  gap: auto,
  title: none,
  theme: none,
) = context {
  layout(size => {
  validate-bullet-charts-data(data, "bullet-charts")
  let t = _resolve-ctx(theme)
  let bar-height = if bar-height == auto { 3.125 * t.base-size } else { bar-height }
  let gap = if gap == auto { 1.875 * t.base-size } else { gap }
  set text(size: 11pt)  // sized by the theme, not the document font
  let width = resolve-size(width, 0pt, size, container: false).width
  let bullets = data.bullets
  let n = bullets.len()

  let bar-color = get-color(t, 0)
  let range-fills = _range-fills(t)
  let title-w = _title-column(
    bullets.map(b => (b.at("title", default: none), b.at("label", default: none))), width, t)

  let key-size = t.axis-label-size
  let key(mark, name) = box(inset: (right: t.legend-gap), {
    box(baseline: 1.5pt, mark)
    h(3pt)
    text(size: key-size, fill: t.text-color)[#name]
  })

  box(width: width)[
    #if title != none {
      align(center, text(size: t.title-size, weight: t.title-weight, fill: t.text-color)[#title])
      v(t.title-gap)
    }

    #for (i, b) in bullets.enumerate() {
      _bullet(b.value, b.target, b.ranges, width, bar-height, b.at("title", default: none),
        b.at("label", default: none), true, t, title-w)
      if i < n - 1 { v(gap) }
    }

    // Key to the marks
    #v(t.legend-gap)
    #align(center, {
      key(rect(width: 12pt, height: 6pt, fill: bar-color, stroke: none), [Actual])
      key(rect(width: 2.5pt, height: 10pt, fill: t.text-color, stroke: none), [Target])
      key(rect(width: 10pt, height: 8pt, fill: range-fills.at(0), stroke: none), [Poor])
      key(rect(width: 10pt, height: 8pt, fill: range-fills.at(1), stroke: none), [Fair])
      key(rect(width: 10pt, height: 8pt, fill: range-fills.at(2), stroke: none), [Good])
    })
  ]
  })
}
