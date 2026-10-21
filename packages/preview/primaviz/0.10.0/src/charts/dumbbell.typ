// dumbbell.typ - Dumbbell chart (before/after or range comparison)
#import "../theme.typ": _resolve-ctx, get-color
#import "../util.typ": nonzero, nice-floor, nice-ceil, nice-ticks, format-number
#import "../validate.typ": validate-dumbbell-data
#import "../primitives/container.typ": chart-container
#import "../primitives/legend.typ": draw-legend-auto
#import "../primitives/axes.typ": draw-y-label
#import "../primitives/layout.typ": resolve-size

/// Renders a dumbbell chart showing range or before/after comparisons.
///
/// Each category is drawn as a horizontal row with two dots (start and end
/// values) connected by a thin line. Categories appear on the Y-axis (left)
/// and values on the X-axis (bottom).
///
/// - data (dictionary): Must contain `labels`, `start-values`, `end-values`,
///   and optionally `start-label` and `end-label`.
/// - width (length): Chart width
/// - height (length): Chart height
/// - title (none, content): Optional chart title
/// - dot-size (length): Radius of endpoint dots
/// - line-width (length): Stroke width of connecting lines
/// - show-values (bool): Display numeric values next to dots
/// - theme (none, dictionary): Theme overrides
/// - extra-legend-separation (length): Extra space between legend and chart
/// -> content
#let dumbbell-chart(
  data,
  width: auto,
  height: auto,
  title: none,
  dot-size: 5pt,
  line-width: 1.5pt,
  show-values: false,
  theme: none,
  extra-legend-separation: 0pt
) = context {
  layout(size => {
  validate-dumbbell-data(data, "dumbbell-chart")
  let t = _resolve-ctx(theme)
  let (width, height) = resolve-size(width, height, size, n: data.labels.len(), theme: t)

  let labels = data.labels
  let start-values = data.start-values
  let end-values = data.end-values
  let start-label = if "start-label" in data { data.start-label } else { "Start" }
  let end-label = if "end-label" in data { data.end-label } else { "End" }
  let n = labels.len()

  // Compute nice step-aligned axis range
  let all-values = start-values + end-values
  let nt = nice-ticks(calc.min(..all-values), calc.max(..all-values), count: t.tick-count)
  let min-val = nt.min
  let max-val = nt.max
  let val-range = nonzero(max-val - min-val)

  // Measure actual label widths for the left margin
  let label-margin = {
    let max-w = 0pt
    for lbl in labels {
      let w = measure(text(size: t.axis-label-size)[#lbl]).width
      if w > max-w { max-w = w }
    }
    max-w + t.axis-label-gap
  }
  let gap = t.axis-label-gap
  let right-pad = calc.max(gap * 2, width * 0.05)
  let top-pad = calc.max(gap, height * 0.04)
  let bottom-pad = t.axis-padding-bottom
  let plot-left = label-margin + dot-size
  let plot-right = width - right-pad - dot-size
  let plot-width = plot-right - plot-left

  // Colors: start uses palette color 0, end uses palette color 1
  let start-color = get-color(t, 0)
  let end-color = get-color(t, 1)
  let connector-color = t.text-color-light

  // Build legend entries
  let legend-entries = (
    (name: start-label, color: start-color),
    (name: end-label, color: end-color),
  )

  let legend-content = draw-legend-auto(legend-entries, t, swatch-type: "circle")

  chart-container(width, height, title, t, extra-height: 30pt, legend: legend-content, extra-legend-separation: extra-legend-separation)[
    #box(width: width, height: height)[
      #let chart-height = height
      // Usable vertical space for rows — extra slot keeps last row off the axis
      #let usable-height = chart-height - top-pad - bottom-pad
      #let row-height = usable-height / (n + 0.5)

      // Helper: map value to x position
      #let val-to-x(v) = {
        plot-left + (v - min-val) / val-range * plot-width
      }

      // Draw light horizontal grid lines
      #for i in range(n) {
        let y = top-pad + row-height * i + row-height / 2
        place(left + top,
          line(
            start: (plot-left, y),
            end: (plot-right, y),
            stroke: t.grid-stroke,
          )
        )
      }

      // Draw value axis line at bottom
      #place(left + top,
        line(
          start: (plot-left, chart-height - bottom-pad),
          end: (plot-right, chart-height - bottom-pad),
          stroke: t.axis-stroke,
        )
      )

      // Draw tick marks on the value axis using nice-ticks values
      #let tick-len = t.axis-label-gap * 0.6
      #let label-w = t.axis-label-size * 4
      #for val in nt.ticks {
        let frac = (val - min-val) / val-range
        let x = plot-left + frac * plot-width
        // Tick mark
        place(left + top,
          line(
            start: (x, chart-height - bottom-pad),
            end: (x, chart-height - bottom-pad + tick-len),
            stroke: t.axis-stroke,
          )
        )
        // Tick label — centered on tick position
        let td = t.at("tick-digits", default: auto)
        let digs = if td != auto { td } else { nt.digits }
        let display-val = format-number(val, digits: digs, mode: t.number-format)
        place(left + top,
          dx: x - label-w / 2,
          dy: chart-height - bottom-pad + tick-len + 2pt,
          box(width: label-w, height: t.axis-label-size * 2,
            align(center + top, text(size: t.axis-label-size, fill: t.text-color)[#display-val]))
        )
      }

      // Draw each dumbbell row
      #for (i, lbl) in labels.enumerate() {
        let y = top-pad + row-height * i + row-height / 2
        let sv = start-values.at(i)
        let ev = end-values.at(i)
        let x-start = val-to-x(sv)
        let x-end = val-to-x(ev)

        // Category label on the left — right-aligned into label margin
        draw-y-label(lbl, y, label-margin, t)

        // Connecting line (muted gray)
        place(left + top,
          line(
            start: (x-start, y),
            end: (x-end, y),
            stroke: line-width + connector-color,
          )
        )

        // Start dot
        place(left + top,
          dx: x-start - dot-size,
          dy: y - dot-size,
          circle(radius: dot-size, fill: start-color, stroke: t.marker-stroke)
        )

        // End dot
        place(left + top,
          dx: x-end - dot-size,
          dy: y - dot-size,
          circle(radius: dot-size, fill: end-color, stroke: t.marker-stroke)
        )

        // Optional value labels — place on the outside of each dot
        if show-values {
          let label-gap = dot-size + gap / 2
          let s-content = text(size: t.value-label-size, fill: start-color)[#sv]
          let e-content = text(size: t.value-label-size, fill: end-color)[#ev]
          let s-w = measure(s-content).width
          let e-w = measure(e-content).width

          // Place labels on the outer side of each dot:
          // whichever dot is leftmost gets its label on the left,
          // whichever is rightmost gets its label on the right
          let s-dx = if sv <= ev {
            x-start - s-w - label-gap
          } else {
            x-start + label-gap
          }
          let e-dx = if ev >= sv {
            x-end + label-gap
          } else {
            x-end - e-w - label-gap
          }

          // Only offset vertically when values are equal (labels on same side)
          let s-dy-adj = 0pt
          let e-dy-adj = 0pt
          if sv == ev {
            s-dy-adj = -0.6em
            e-dy-adj = 0.4em
          }

          place(left + top,
            dx: s-dx,
            dy: y,
            move(dy: -0.5em + s-dy-adj, s-content)
          )
          place(left + top,
            dx: e-dx,
            dy: y,
            move(dy: -0.5em + e-dy-adj, e-content)
          )
        }
      }
    ]
  ]
  })
}
