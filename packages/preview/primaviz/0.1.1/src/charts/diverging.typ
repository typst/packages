// diverging.typ - Diverging bar chart (bars extend left/right from center axis)
#import "../theme.typ": resolve-theme, get-color
#import "../validate.typ": validate-diverging-data
#import "../primitives/container.typ": chart-container
#import "../primitives/legend.typ": draw-legend, draw-legend-vertical

/// Renders a horizontal diverging bar chart where bars extend left and right
/// from a central vertical axis. Useful for survey results (agree/disagree),
/// sentiment analysis, and population pyramids.
///
/// - data (dictionary): Dictionary with keys:
///   - `labels` (array): Category labels for each row
///   - `left-values` (array): Numeric values for the left side
///   - `right-values` (array): Numeric values for the right side
///   - `left-label` (string, optional): Legend label for the left side
///   - `right-label` (string, optional): Legend label for the right side
/// - width (length): Chart width
/// - height (length): Chart height
/// - title (none, content): Optional chart title
/// - show-values (bool): Display value labels at bar ends
/// - bar-height (auto, float): Bar thickness as fraction of slot (0 to 1), auto = 0.6
/// - theme (none, dictionary): Theme overrides
/// -> content
#let diverging-bar-chart(
  data,
  width: 400pt,
  height: 200pt,
  title: none,
  show-values: true,
  bar-height: auto,
  theme: none,
) = {
  validate-diverging-data(data, "diverging-bar-chart")
  let t = resolve-theme(theme)

  let labels = data.labels
  let left-values = data.left-values
  let right-values = data.right-values
  let left-label = if "left-label" in data { data.left-label } else { none }
  let right-label = if "right-label" in data { data.right-label } else { none }
  let n = labels.len()

  let bar-frac = if bar-height == auto { 0.6 } else { bar-height }

  // Find the max value across both sides for proportional scaling
  let all-values = (..left-values, ..right-values)
  let max-val = calc.max(..all-values)
  if max-val == 0 { max-val = 1 }

  // Layout constants
  let label-area = 80pt        // Space for category labels on the left
  let right-pad = 10pt
  let usable-width = width - label-area - right-pad
  let half-width = usable-width / 2
  let center-x = label-area + half-width

  let show-legend = left-label != none and right-label != none
  let extra-h = if show-legend { 50pt } else { 30pt }

  chart-container(width, height, title, t, extra-height: extra-h)[
    #let chart-height = height - 10pt
    #let spacing = chart-height / n
    #let actual-bar-h = spacing * bar-frac

    #box(width: width, height: chart-height)[
      // Center vertical axis
      #place(left + top, line(
        start: (center-x, 0pt),
        end: (center-x, chart-height),
        stroke: t.axis-stroke,
      ))

      // Horizontal baseline
      #place(left + bottom, line(
        start: (label-area, 0pt),
        end: (width - right-pad, 0pt),
        stroke: t.axis-stroke,
      ))

      #for (i, label) in labels.enumerate() {
        let y-pos = i * spacing + (spacing - actual-bar-h) / 2
        let l-val = left-values.at(i)
        let r-val = right-values.at(i)

        // Left bar (grows leftward from center)
        let l-bar-w = (l-val / max-val) * half-width
        place(
          left + top,
          dx: center-x - l-bar-w,
          dy: y-pos,
          rect(
            width: l-bar-w,
            height: actual-bar-h,
            fill: get-color(t, 0),
            stroke: none,
          )
        )

        // Right bar (grows rightward from center)
        let r-bar-w = (r-val / max-val) * half-width
        place(
          left + top,
          dx: center-x,
          dy: y-pos,
          rect(
            width: r-bar-w,
            height: actual-bar-h,
            fill: get-color(t, 1),
            stroke: none,
          )
        )

        // Left value label
        if show-values {
          place(
            left + top,
            dx: center-x - l-bar-w - 20pt,
            dy: y-pos + actual-bar-h / 2 - 5pt,
            text(size: t.value-label-size, fill: t.text-color)[#l-val]
          )
        }

        // Right value label
        if show-values {
          place(
            left + top,
            dx: center-x + r-bar-w + 5pt,
            dy: y-pos + actual-bar-h / 2 - 5pt,
            text(size: t.value-label-size, fill: t.text-color)[#r-val]
          )
        }

        // Category label on the far left
        place(
          left + top,
          dx: 5pt,
          dy: y-pos + actual-bar-h / 2 - 5pt,
          text(size: t.axis-label-size, fill: t.text-color)[#label]
        )
      }

      // X-axis tick labels (symmetric around center)
      #for i in array.range(t.tick-count) {
        let fraction = if t.tick-count > 1 { i / (t.tick-count - 1) } else { 0 }
        let tick-val = calc.round(max-val * fraction, digits: 0)

        // Right side ticks
        let rx = center-x + fraction * half-width
        place(
          left + bottom,
          dx: rx - 10pt,
          dy: 8pt,
          text(size: t.axis-label-size, fill: t.text-color)[#tick-val]
        )

        // Left side ticks (mirror, skip zero to avoid double-drawing)
        if fraction > 0 {
          let lx = center-x - fraction * half-width
          place(
            left + bottom,
            dx: lx - 10pt,
            dy: 8pt,
            text(size: t.axis-label-size, fill: t.text-color)[#tick-val]
          )
        }
      }
    ]

    // Legend
    #if show-legend {
      let legend-entries = (
        (name: left-label, color: get-color(t, 0)),
        (name: right-label, color: get-color(t, 1)),
      )
      if t.legend-position == "right" {
        draw-legend-vertical(legend-entries, t)
      } else {
        draw-legend(legend-entries, t)
      }
    }
  ]
}
