// bullet.typ - Bullet chart (Stephen Few's design)
// A compact gauge replacement showing a quantitative measure against a target
// with qualitative ranges (poor/satisfactory/good).

#import "../theme.typ": _resolve-ctx, get-color
#import "../util.typ": nonzero
#import "../validate.typ": validate-bullet-data, validate-bullet-charts-data
#import "../primitives/container.typ": chart-container
#import "../primitives/layout.typ": resolve-size

/// Renders a single bullet chart — a horizontal bar showing an actual value
/// against a target marker, overlaid on qualitative range bands.
///
/// - value (int, float): The actual measured value
/// - target (int, float): The target/comparative value shown as a vertical marker
/// - ranges (array): Three ascending thresholds defining poor, satisfactory, and good zones
/// - width (length): Chart width
/// - height (length): Chart height (bar thickness)
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
  height: 30pt,
  title: none,
  label: none,
  show-target: true,
  theme: none,
) = context {
  layout(size => {
  validate-bullet-data((value: value, target: target, ranges: ranges), "bullet-chart")
  let t = _resolve-ctx(theme)
  let (width, height) = resolve-size(width, height, size, container: false)
  let bar-color = get-color(t, 0)

  let max-range = nonzero(ranges.last())

  // Qualitative range shades (darkest = poor, lightest = good)
  let is-dark = t.background != none
  let range-fills = if is-dark {
    let bg = t.background
    (bg.lighten(15%), bg.lighten(25%), bg.lighten(35%))
  } else {
    (t.text-color-light.transparentize(50%), t.text-color-light.transparentize(70%), t.text-color-light.transparentize(85%))
  }

  // Title column width
  let title-width = if title != none { calc.min(90pt, width * 0.35) } else { 0pt }
  let bar-width = width - title-width

  box(width: width, height: height)[
    // Title area
    #if title != none {
      place(
        left + top,
        dy: if label != none { 0pt } else { height / 2 - 7pt },
        box(width: title-width - 8pt)[
          #text(size: t.axis-title-size, weight: "bold", fill: t.text-color)[#title]
          #if label != none {
            linebreak()
            text(size: t.axis-label-size, fill: t.text-color-light)[#label]
          }
        ]
      )
    }

    // Chart area
    #let x0 = title-width

    // Draw qualitative ranges (3 bands, full to partial)
    #place(left + top, dx: x0, rect(
      width: bar-width * (ranges.at(2) / max-range),
      height: height,
      fill: range-fills.at(2),
      stroke: none,
    ))
    #place(left + top, dx: x0, rect(
      width: bar-width * (ranges.at(1) / max-range),
      height: height,
      fill: range-fills.at(1),
      stroke: none,
    ))
    #place(left + top, dx: x0, rect(
      width: bar-width * (ranges.at(0) / max-range),
      height: height,
      fill: range-fills.at(0),
      stroke: none,
    ))

    // Value bar (thinner, ~60% height, centered vertically)
    #let bar-h = height * 0.6
    #let bar-y = (height - bar-h) / 2
    #let val-w = bar-width * calc.min(1, calc.max(0, value / max-range))
    #place(left + top, dx: x0, dy: bar-y, rect(
      width: val-w,
      height: bar-h,
      fill: bar-color,
      stroke: none,
    ))

    // Target marker (short vertical line)
    #if show-target {
      let target-x = x0 + bar-width * calc.min(1, calc.max(0, target / max-range))
      let marker-h = height * 0.85
      let marker-y = (height - marker-h) / 2
      place(
        left + top,
        dx: target-x - 1pt,
        dy: marker-y,
        rect(width: 2.5pt, height: marker-h, fill: t.text-color, stroke: none)
      )
    }

    // X-axis tick labels along the bottom
    #{
      let tick-count = t.tick-count
      let tick-size = t.axis-label-size
      for ti in range(tick-count + 1) {
        let frac = ti / tick-count
        let tick-val = calc.round(frac * max-range, digits: 0)
        let tx = x0 + bar-width * frac
        place(left + top, dx: tx, dy: height,
          line(start: (0pt, 0pt), end: (0pt, 3pt), stroke: 0.4pt + t.text-color))
        place(left + top,
          dx: tx - 10pt,
          dy: height + 3pt,
          box(width: 20pt, align(center,
            text(size: tick-size, fill: t.text-color)[#int(tick-val)])))
      }
    }
  ]
  })
}

/// Renders multiple bullet charts stacked vertically for KPI dashboards.
///
/// - data (dictionary): Must contain a `bullets` key with an array of bullet specs.
///   Each spec: `(value: ..., target: ..., ranges: ..., title: "...")`.
///   Optional per-bullet keys: `label`.
/// - width (length): Overall width for each bullet
/// - bar-height (length): Height of each individual bullet bar
/// - gap (length): Vertical spacing between bullets
/// - title (none, content, str): Optional heading above all bullets
/// - theme (none, dictionary): Theme overrides
/// -> content
#let bullet-charts(
  data,
  width: 300pt,
  bar-height: 25pt,
  gap: 15pt,
  title: none,
  theme: none,
) = context {
  layout(size => {
  validate-bullet-charts-data(data, "bullet-charts")
  let t = _resolve-ctx(theme)
  let width = resolve-size(width, 0pt, size, container: false).width
  let bullets = data.bullets
  let n = bullets.len()

  let bar-color = get-color(t, 0)
  let is-dark = t.background != none
  let range-fills = if is-dark {
    let bg = t.background
    (bg.lighten(15%), bg.lighten(25%), bg.lighten(35%))
  } else {
    (t.text-color-light.transparentize(50%), t.text-color-light.transparentize(70%), t.text-color-light.transparentize(85%))
  }

  // Extra space for tick labels + legend
  let tick-space = 18pt
  let legend-space = 22pt
  let total-height = n * (bar-height + tick-space) + (n - 1) * gap + legend-space + (if title != none { 25pt } else { 0pt })

  box(width: width, height: total-height)[
    #if title != none {
      align(center, text(size: t.title-size, weight: t.title-weight, fill: t.text-color)[#title])
      v(8pt)
    }

    #for (i, b) in bullets.enumerate() {
      bullet-chart(
        b.value,
        b.target,
        b.ranges,
        width: width,
        height: bar-height,
        title: if "title" in b { b.title } else { none },
        label: if "label" in b { b.label } else { none },
        show-target: true,
        theme: theme,
      )
      v(tick-space)
      if i < n - 1 {
        v(gap)
      }
    }

    // Legend explaining the visual elements
    #v(4pt)
    #align(center)[
      #box(baseline: 2pt, rect(width: 12pt, height: 6pt, fill: bar-color, stroke: none))
      #h(2pt)
      #text(size: t.axis-label-size, fill: t.text-color)[Actual]
      #h(8pt)
      #box(baseline: 2pt, rect(width: 2.5pt, height: 10pt, fill: t.text-color, stroke: none))
      #h(2pt)
      #text(size: t.axis-label-size, fill: t.text-color)[Target]
      #h(8pt)
      #box(baseline: 2pt, rect(width: 10pt, height: 8pt, fill: range-fills.at(0), stroke: none))
      #h(2pt)
      #text(size: t.axis-label-size, fill: t.text-color)[Poor]
      #h(6pt)
      #box(baseline: 2pt, rect(width: 10pt, height: 8pt, fill: range-fills.at(1), stroke: none))
      #h(2pt)
      #text(size: t.axis-label-size, fill: t.text-color)[Fair]
      #h(6pt)
      #box(baseline: 2pt, rect(width: 10pt, height: 8pt, fill: range-fills.at(2), stroke: none))
      #h(2pt)
      #text(size: t.axis-label-size, fill: t.text-color)[Good]
    ]
  ]
  })
}
