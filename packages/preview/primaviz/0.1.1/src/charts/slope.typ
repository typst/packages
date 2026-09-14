// slope.typ - Slope chart (two-period comparison)
#import "../theme.typ": resolve-theme, get-color
#import "../validate.typ": validate-slope-data
#import "../primitives/container.typ": chart-container

/// Renders a slope chart showing changes between two time periods.
///
/// Each item is drawn as a line connecting its start-value (left axis)
/// to its end-value (right axis), with dots and labels at both endpoints.
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
#let slope-chart(
  data,
  width: 300pt,
  height: 250pt,
  title: none,
  dot-size: 3pt,
  line-width: 1.5pt,
  show-values: true,
  theme: none,
) = {
  validate-slope-data(data, "slope-chart")
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
  let label-margin = 70pt   // space for labels on each side
  let axis-x-left = label-margin
  let axis-x-right = width - label-margin
  let top-pad = 25pt        // room for column headers
  let bottom-pad = 10pt

  chart-container(width, height, title, t, extra-height: 20pt)[
    #let chart-height = height - 10pt

    #box(width: width, height: chart-height)[
      // Column headers
      #place(left + top,
        dx: axis-x-left - 15pt,
        dy: 2pt,
        text(size: t.axis-title-size, weight: "bold", fill: t.text-color)[#start-label]
      )
      #place(left + top,
        dx: axis-x-right - 15pt,
        dy: 2pt,
        text(size: t.axis-title-size, weight: "bold", fill: t.text-color)[#end-label]
      )

      // Left axis line
      #place(left + top,
        line(
          start: (axis-x-left, top-pad),
          end: (axis-x-left, chart-height - bottom-pad),
          stroke: t.axis-stroke,
        )
      )
      // Right axis line
      #place(left + top,
        line(
          start: (axis-x-right, top-pad),
          end: (axis-x-right, chart-height - bottom-pad),
          stroke: t.axis-stroke,
        )
      )

      // Usable vertical space for data points
      #let usable-height = chart-height - top-pad - bottom-pad - 20pt
      #let y-top = top-pad + 10pt

      // Helper: map a value to a y position (higher value = higher on chart = smaller y)
      #for (i, lbl) in labels.enumerate() {
        let color = get-color(t, i)
        let sv = start-values.at(i)
        let ev = end-values.at(i)
        let y-start = y-top + (1 - (sv - min-val) / val-range) * usable-height
        let y-end = y-top + (1 - (ev - min-val) / val-range) * usable-height

        // Connecting line
        place(left + top,
          line(
            start: (axis-x-left, y-start),
            end: (axis-x-right, y-end),
            stroke: line-width + color,
          )
        )

        // Left dot
        place(left + top,
          dx: axis-x-left - dot-size,
          dy: y-start - dot-size,
          circle(radius: dot-size, fill: color, stroke: white + 0.5pt)
        )
        // Right dot
        place(left + top,
          dx: axis-x-right - dot-size,
          dy: y-end - dot-size,
          circle(radius: dot-size, fill: color, stroke: white + 0.5pt)
        )

        // Left label + value
        {
          let label-content = if show-values {
            [#text(size: t.axis-label-size, fill: t.text-color)[#lbl #sv]]
          } else {
            [#text(size: t.axis-label-size, fill: t.text-color)[#lbl]]
          }
          place(left + top,
            dx: 2pt,
            dy: y-start - 5pt,
            label-content,
          )
        }

        // Right label + value
        {
          let label-content = if show-values {
            [#text(size: t.axis-label-size, fill: t.text-color)[#ev #lbl]]
          } else {
            [#text(size: t.axis-label-size, fill: t.text-color)[#lbl]]
          }
          place(left + top,
            dx: axis-x-right + dot-size + 4pt,
            dy: y-end - 5pt,
            label-content,
          )
        }
      }
    ]
  ]
}
