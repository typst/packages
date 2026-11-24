// diverging.typ - Diverging bar chart (bars extend left/right from center axis)
#import "../theme.typ": _resolve-ctx, get-color
#import "../util.typ": nonzero, nice-ticks, format-number
#import "../validate.typ": validate-diverging-data
#import "../primitives/container.typ": chart-container
#import "../primitives/legend.typ": draw-legend-auto
#import "../primitives/axes.typ": draw-y-label
#import "../primitives/layout.typ": resolve-size, pin

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
/// - x-label (none, content): X-axis title
/// - theme (none, dictionary): Theme overrides
/// - extra-legend-separation (length): Extra space between legend and chart
/// -> content
#let diverging-bar-chart(
  data,
  width: auto,
  height: auto,
  title: none,
  show-values: true,
  bar-height: auto,
  x-label: none,
  theme: none,
  extra-legend-separation: 0pt
) = context {
  layout(size => {
  validate-diverging-data(data, "diverging-bar-chart")
  let t = _resolve-ctx(theme)
  let (width, height) = resolve-size(width, height, size, n: data.labels.len(), theme: t)

  let labels = data.labels
  let left-values = data.left-values
  let right-values = data.right-values
  let left-label = if "left-label" in data { data.left-label } else { none }
  let right-label = if "right-label" in data { data.right-label } else { none }
  let n = labels.len()

  let bar-frac = if bar-height == auto { 0.6 } else { bar-height }

  // Find the max value across both sides for proportional scaling
  let all-values = (..left-values, ..right-values)
  // Scale to the top tick (not the raw max) so bars and tick labels agree
  let max-val = nice-ticks(0, nonzero(calc.max(..all-values)), count: t.tick-count).max

  // Layout constants — scale label area with chart width
  let label-area = calc.min(80pt, width * 0.28)
  let right-pad = t.axis-padding-right
  // Reserve room beside the longest bars for their value labels
  let val-w = if show-values {
    calc.max(..all-values.map(v => measure(text(size: t.value-label-size)[#v]).width)) + 4pt
  } else { 0pt }
  let usable-width = width - label-area - right-pad - 2 * val-w
  let half-width = usable-width / 2
  let center-x = label-area + val-w + half-width

  let show-legend = left-label != none and right-label != none
  let extra-h = if show-legend { 50pt } else { 30pt }

  let tick-area = t.axis-label-size * 2 + t.axis-label-gap
  let legend-content = draw-legend-auto(
    ((name: left-label, color: get-color(t, 0)), (name: right-label, color: get-color(t, 1))),
    t, show-legend: show-legend,
  )
  chart-container(width, height, title, t, extra-height: extra-h, legend: legend-content, extra-legend-separation: extra-legend-separation)[
    #let chart-height = height - t.axis-padding-top - t.axis-padding-bottom - tick-area
    #let spacing = chart-height / n
    #let actual-bar-h = spacing * bar-frac
    // Keep row text within its row when many rows share a short chart
    #let row-t = (..t, axis-label-size: calc.min(t.axis-label-size, spacing * 0.9))
    #let val-size = calc.min(t.value-label-size, spacing * 0.9)

    #box(width: width, height: chart-height + tick-area)[
      // Center vertical axis
      #place(left + top, line(
        start: (center-x, 0pt),
        end: (center-x, chart-height),
        stroke: t.axis-stroke,
      ))

      // Horizontal baseline at bottom of bar area
      #place(left + top, line(
        start: (label-area, chart-height),
        end: (width - right-pad, chart-height),
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

        // Left value label — placed just left of the bar end
        if show-values {
          place(
            left + top,
            dx: center-x - l-bar-w - val-w,
            dy: y-pos + actual-bar-h / 2,
            pin(width: val-w - 4pt, align: right + horizon,
              text(size: val-size, fill: t.text-color)[#l-val])
          )
        }

        // Right value label
        if show-values {
          place(
            left + top,
            dx: center-x + r-bar-w + 4pt,
            dy: y-pos + actual-bar-h / 2,
            pin(text(size: val-size, fill: t.text-color)[#r-val])
          )
        }

        // Category label on the far left — right-aligned into label area
        draw-y-label(label, y-pos + actual-bar-h / 2, label-area, row-t)
      }

      // X-axis tick labels (symmetric around center) — below the bar area
      #let div-nt = nice-ticks(0, max-val, count: t.tick-count)
      // Thin the ticks when their labels would collide on a narrow chart
      #let tick-w = calc.max(..div-nt.ticks.map(v => measure(text(size: t.axis-label-size)[#format-number(v, digits: div-nt.digits, mode: t.number-format, step: div-nt.step)]).width))
      #let tick-gap = half-width / calc.max(1, div-nt.ticks.len() - 1)
      #let tick-skip = calc.max(1, calc.ceil((tick-w + 4pt) / tick-gap))
      #for (ti, value) in div-nt.ticks.enumerate() {
        if calc.rem(ti, tick-skip) != 0 { continue }
        let fraction = if max-val > 0 { value / max-val } else { 0 }
        let tick-label = format-number(value, digits: div-nt.digits, mode: t.number-format, step: div-nt.step)

        // Right side ticks
        let rx = center-x + fraction * half-width
        place(
          left + top,
          dx: rx - 1.5em,
          dy: chart-height + 2pt,
          box(width: 3em, height: 1.5em,
            align(center + top, text(size: t.axis-label-size, fill: t.text-color)[#tick-label]))
        )

        // Left side ticks (mirror, skip zero to avoid double-drawing)
        if fraction > 0 {
          let lx = center-x - fraction * half-width
          place(
            left + top,
            dx: lx - 1.5em,
            dy: chart-height + 2pt,
            box(width: 3em, height: 1.5em,
              align(center + top, text(size: t.axis-label-size, fill: t.text-color)[#tick-label]))
          )
        }
      }
      // X-axis title
      #if x-label != none {
        place(left + top, dx: center-x, dy: chart-height + tick-area - 2pt,
          move(dx: -3em, box(width: 6em, align(center, text(size: t.axis-title-size, fill: t.text-color)[#x-label]))))
      }
    ]
  ]
  })
}
