// lollipop.typ - Lollipop charts (vertical and horizontal)
#import "../theme.typ": resolve-theme, get-color
#import "../util.typ": normalize-data
#import "../validate.typ": validate-simple-data
#import "../primitives/container.typ": chart-container
#import "../primitives/axes.typ": draw-axis-lines, draw-grid, draw-axis-titles
#import "../primitives/annotations.typ": draw-annotations

/// Renders a vertical lollipop chart with a thin stem and circle dot per category.
///
/// A lollipop chart is like a bar chart but uses a thin line (stem) capped by a
/// filled circle (dot) instead of a filled bar. Useful for ranked or comparison data
/// where a cleaner look is desired.
///
/// - data (dictionary, array): Label-value pairs as dict or array of tuples
/// - width (length): Chart width
/// - height (length): Chart height
/// - dot-size (length): Radius of the dot at the end of each stem
/// - stem-width (length): Thickness of the stem line
/// - title (none, content): Optional chart title
/// - show-values (bool): Display value labels above dots
/// - x-label (none, content): X-axis title
/// - y-label (none, content): Y-axis title
/// - annotations (none, array): Optional annotation descriptors
/// - theme (none, dictionary): Theme overrides
/// -> content
#let lollipop-chart(
  data,
  width: 300pt,
  height: 200pt,
  dot-size: 4pt,
  stem-width: 1.5pt,
  title: none,
  show-values: true,
  x-label: none,
  y-label: none,
  annotations: none,
  theme: none,
) = {
  validate-simple-data(data, "lollipop-chart")
  let t = resolve-theme(theme)
  let norm = normalize-data(data)
  let labels = norm.labels
  let values = norm.values

  let max-val = if values.len() > 0 { calc.max(..values) } else { 0 }
  if max-val == 0 { max-val = 1 }
  let n = values.len()
  if n == 0 { return }

  chart-container(width, height, title, t, extra-height: 30pt)[
    #let chart-height = height - 20pt
    #let chart-width = width - 40pt

    #box(width: width, height: chart-height)[
      // Grid
      #draw-grid(30pt, 0pt, chart-width + 10pt, chart-height, t)

      // Y-axis
      #place(left + top, line(start: (30pt, 0pt), end: (30pt, chart-height), stroke: t.axis-stroke))
      // X-axis
      #place(left + bottom, line(start: (30pt, 0pt), end: (width, 0pt), stroke: t.axis-stroke))

      #let spacing = chart-width / n

      #for (i, val) in values.enumerate() {
        let stem-h = (val / max-val) * (chart-height - 10pt)
        let x-center = 35pt + i * spacing + spacing / 2

        // Stem
        place(
          left + bottom,
          dx: x-center,
          dy: 0pt,
          line(
            start: (0pt, 0pt),
            end: (0pt, -stem-h),
            stroke: get-color(t, i) + stem-width,
          )
        )

        // Dot
        place(
          left + bottom,
          dx: x-center - dot-size,
          dy: -stem-h - dot-size,
          circle(
            radius: dot-size,
            fill: get-color(t, i),
            stroke: none,
          )
        )

        // Value label
        if show-values {
          place(
            left + bottom,
            dx: x-center - 8pt,
            dy: -stem-h - dot-size * 2 - 10pt,
            text(size: t.value-label-size, fill: t.text-color)[#val]
          )
        }

        // X-axis label
        place(
          left + bottom,
          dx: x-center - 15pt,
          dy: 12pt,
          text(size: t.axis-label-size, fill: t.text-color)[#labels.at(i)]
        )
      }

      // Y-axis tick labels
      #for i in array.range(t.tick-count) {
        let fraction = if t.tick-count > 1 { i / (t.tick-count - 1) } else { 0 }
        let y-val = calc.round(max-val * fraction, digits: 1)
        let y-pos = chart-height - fraction * (chart-height - 10pt)
        place(
          left + top,
          dx: 0pt,
          dy: y-pos - 5pt,
          text(size: t.axis-label-size, fill: t.text-color)[#y-val]
        )
      }

      // Axis titles
      #draw-axis-titles(x-label, y-label, 30pt + chart-width / 2, chart-height / 2, t)

      // Annotations
      #draw-annotations(annotations, 35pt, 10pt, chart-width, chart-height - 10pt, -0.5, n - 0.5, 0, max-val, t)
    ]
  ]
}

/// Renders a horizontal lollipop chart with category labels on the y-axis.
///
/// Like a horizontal bar chart but uses a thin line (stem) from the y-axis and a
/// filled circle (dot) at the value endpoint.
///
/// - data (dictionary, array): Label-value pairs as dict or array of tuples
/// - width (length): Chart width
/// - height (length): Chart height
/// - dot-size (length): Radius of the dot at the end of each stem
/// - stem-width (length): Thickness of the stem line
/// - title (none, content): Optional chart title
/// - show-values (bool): Display value labels beside dots
/// - x-label (none, content): X-axis title
/// - y-label (none, content): Y-axis title
/// - theme (none, dictionary): Theme overrides
/// -> content
#let horizontal-lollipop-chart(
  data,
  width: 350pt,
  height: 200pt,
  dot-size: 4pt,
  stem-width: 1.5pt,
  title: none,
  show-values: true,
  x-label: none,
  y-label: none,
  theme: none,
) = {
  validate-simple-data(data, "horizontal-lollipop-chart")
  let t = resolve-theme(theme)
  let norm = normalize-data(data)
  let labels = norm.labels
  let values = norm.values

  let max-val = if values.len() > 0 { calc.max(..values) } else { 0 }
  if max-val == 0 { max-val = 1 }
  let n = values.len()
  if n == 0 { return }

  let label-area = 80pt

  chart-container(width, height, title, t, extra-height: 30pt)[
    #let chart-height = height - 10pt
    #let chart-width = width - label-area - 30pt

    #box(width: width, height: chart-height)[
      // Grid
      #draw-grid(label-area, 0pt, chart-width, chart-height, t)

      // Y-axis
      #place(left + top, line(start: (label-area, 0pt), end: (label-area, chart-height), stroke: t.axis-stroke))
      // X-axis
      #place(left + bottom, line(start: (label-area, 0pt), end: (width - 10pt, 0pt), stroke: t.axis-stroke))

      #let spacing = chart-height / n

      #for (i, val) in values.enumerate() {
        let stem-len = (val / max-val) * chart-width
        let y-center = i * spacing + spacing / 2

        // Stem
        place(
          left + top,
          dx: label-area,
          dy: y-center,
          line(
            start: (0pt, 0pt),
            end: (stem-len, 0pt),
            stroke: get-color(t, i) + stem-width,
          )
        )

        // Dot
        place(
          left + top,
          dx: label-area + stem-len - dot-size,
          dy: y-center - dot-size,
          circle(
            radius: dot-size,
            fill: get-color(t, i),
            stroke: none,
          )
        )

        // Value label
        if show-values {
          place(
            left + top,
            dx: label-area + stem-len + dot-size + 5pt,
            dy: y-center - 5pt,
            text(size: t.value-label-size, fill: t.text-color)[#val]
          )
        }

        // Y-axis label (category)
        place(
          left + top,
          dx: 5pt,
          dy: y-center - 5pt,
          text(size: t.axis-label-size, fill: t.text-color)[#labels.at(i)]
        )
      }

      // X-axis labels
      #for i in array.range(t.tick-count) {
        let fraction = if t.tick-count > 1 { i / (t.tick-count - 1) } else { 0 }
        let x-val = calc.round(max-val * fraction, digits: 0)
        let x-pos = label-area + fraction * chart-width
        place(
          left + bottom,
          dx: x-pos - 10pt,
          dy: 8pt,
          text(size: t.axis-label-size, fill: t.text-color)[#x-val]
        )
      }

      // Axis titles
      #draw-axis-titles(x-label, y-label, label-area + chart-width / 2, chart-height / 2, t)
    ]
  ]
}
