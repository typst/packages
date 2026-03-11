// dumbbell.typ - Dumbbell chart (before/after or range comparison)
#import "../theme.typ": resolve-theme, get-color
#import "../validate.typ": validate-dumbbell-data
#import "../primitives/container.typ": chart-container
#import "../primitives/legend.typ": draw-legend

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
/// -> content
#let dumbbell-chart(
  data,
  width: 400pt,
  height: 200pt,
  title: none,
  dot-size: 5pt,
  line-width: 1.5pt,
  show-values: false,
  theme: none,
) = {
  validate-dumbbell-data(data, "dumbbell-chart")
  let t = resolve-theme(theme)

  let labels = data.labels
  let start-values = data.start-values
  let end-values = data.end-values
  let start-label = if "start-label" in data { data.start-label } else { "Start" }
  let end-label = if "end-label" in data { data.end-label } else { "End" }
  let n = labels.len()

  // Compute global min/max across both value sets
  let all-values = start-values + end-values
  let max-val = calc.max(..all-values)
  let min-val = calc.min(..all-values)
  let val-range = max-val - min-val
  if val-range == 0 { val-range = 1 }

  // Layout constants
  let label-margin = 80pt    // space for category labels on the left
  let right-pad = 20pt
  let top-pad = 10pt
  let bottom-pad = 25pt      // room for value axis labels
  let plot-left = label-margin
  let plot-right = width - right-pad
  let plot-width = plot-right - plot-left

  // Colors: start uses palette color 0, end uses palette color 1
  let start-color = get-color(t, 0)
  let end-color = get-color(t, 1)
  let connector-color = luma(180)

  // Build legend entries
  let legend-entries = (
    (name: start-label, color: start-color),
    (name: end-label, color: end-color),
  )

  let legend-content = draw-legend(legend-entries, t, swatch-type: "circle")

  chart-container(width, height, title, t, extra-height: 30pt, legend: legend-content)[
    #let chart-height = height - 10pt

    #box(width: width, height: chart-height)[
      // Usable vertical space for rows
      #let usable-height = chart-height - top-pad - bottom-pad
      #let row-height = usable-height / n

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
            stroke: 0.3pt + luma(220),
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

      // Draw a few tick marks on the value axis
      #let tick-count = 5
      #for ti in range(tick-count + 1) {
        let frac = ti / tick-count
        let val = min-val + frac * val-range
        let x = plot-left + frac * plot-width
        // Tick mark
        place(left + top,
          line(
            start: (x, chart-height - bottom-pad),
            end: (x, chart-height - bottom-pad + 4pt),
            stroke: t.axis-stroke,
          )
        )
        // Tick label
        let display-val = if val == calc.floor(val) { str(int(val)) } else { str(calc.round(val, digits: 1)) }
        place(left + top,
          dx: x - 10pt,
          dy: chart-height - bottom-pad + 6pt,
          text(size: t.axis-label-size, fill: t.text-color)[#display-val]
        )
      }

      // Draw each dumbbell row
      #for (i, lbl) in labels.enumerate() {
        let y = top-pad + row-height * i + row-height / 2
        let sv = start-values.at(i)
        let ev = end-values.at(i)
        let x-start = val-to-x(sv)
        let x-end = val-to-x(ev)

        // Category label on the left
        place(left + top,
          dx: 4pt,
          dy: y - 5pt,
          text(size: t.axis-label-size, fill: t.text-color)[#lbl]
        )

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
          circle(radius: dot-size, fill: start-color, stroke: white + 0.5pt)
        )

        // End dot
        place(left + top,
          dx: x-end - dot-size,
          dy: y - dot-size,
          circle(radius: dot-size, fill: end-color, stroke: white + 0.5pt)
        )

        // Optional value labels
        if show-values {
          // Value near start dot
          let s-dx = if sv <= ev { x-start - 20pt } else { x-start + dot-size + 3pt }
          place(left + top,
            dx: s-dx,
            dy: y - 5pt,
            text(size: 6pt, fill: start-color)[#sv]
          )
          // Value near end dot
          let e-dx = if ev >= sv { x-end + dot-size + 3pt } else { x-end - 20pt }
          place(left + top,
            dx: e-dx,
            dy: y - 5pt,
            text(size: 6pt, fill: end-color)[#ev]
          )
        }
      }
    ]
  ]
}
