// funnel.typ - Funnel chart for process/conversion stages
#import "../theme.typ": resolve-theme, get-color
#import "../util.typ": normalize-data, format-number
#import "../validate.typ": validate-simple-data
#import "../primitives/container.typ": chart-container

/// Renders a funnel chart for visualizing process or conversion stages.
///
/// - data (dictionary, array): Label-value pairs as dict or array of tuples
/// - width (length): Chart width
/// - height (length): Chart height
/// - title (none, content): Optional chart title
/// - show-values (bool): Display numeric values on segments
/// - show-percentages (bool): Display conversion percentages relative to the first stage
/// - gap (length): Vertical gap between segments
/// - theme (none, dictionary): Theme overrides
/// -> content
#let funnel-chart(
  data,
  width: 300pt,
  height: 250pt,
  title: none,
  show-values: true,
  show-percentages: true,
  gap: 3pt,
  theme: none,
) = {
  validate-simple-data(data, "funnel-chart")
  let t = resolve-theme(theme)
  let norm = normalize-data(data)
  let labels = norm.labels
  let values = norm.values

  let n = values.len()
  let max-val = calc.max(..values)
  let first-val = values.at(0)

  // Usable drawing area inside the container (leave padding for title)
  let padding-x = 10pt
  let usable-width = width - 2 * padding-x
  let usable-height = height - 30pt
  let center-x = width / 2

  // Segment height accounting for gaps
  let total-gap = gap * (n - 1)
  let seg-height = (usable-height - total-gap) / n

  chart-container(width, height, title, t, extra-height: 20pt)[
    #box(width: width, height: usable-height + 10pt)[
      #v(5pt)
      #for (i, val) in values.enumerate() {
        // Top edge width proportional to this segment's value
        let top-width = (val / max-val) * usable-width
        let top-half = top-width / 2

        // Bottom edge width: next segment's value, or same as top for last segment
        let bottom-width = if i < n - 1 {
          (values.at(i + 1) / max-val) * usable-width
        } else {
          top-width
        }
        let bottom-half = bottom-width / 2

        let y-top = i * (seg-height + gap)
        let y-bottom = y-top + seg-height

        let color = get-color(t, i)

        // Draw trapezoid using polygon with place
        place(
          left + top,
          dy: y-top,
          polygon(
            fill: color,
            stroke: white + 0.5pt,
            (center-x - top-half, 0pt),
            (center-x + top-half, 0pt),
            (center-x + bottom-half, seg-height),
            (center-x - bottom-half, seg-height),
          )
        )

        // Text label on each segment (only if tall enough)
        // Use count-based heuristic to avoid comparing relative lengths with absolute
        if n <= 15 {
          let label-text = labels.at(i)
          let value-text = if show-values { format-number(val) } else { "" }
          let pct-text = if show-percentages {
            str(calc.round((val / first-val) * 100, digits: 1)) + "%"
          } else { "" }

          // Build display string
          let display = label-text
          let detail-parts = ()
          if show-values { detail-parts.push(value-text) }
          if show-percentages { detail-parts.push(pct-text) }
          let detail = detail-parts.join(" · ")

          // Center the text on the segment
          let mid-y = y-top + seg-height / 2
          let avg-half = (top-half + bottom-half) / 2

          place(
            left + top,
            dx: center-x - avg-half,
            dy: mid-y - 7pt,
            box(width: avg-half * 2, height: 14pt)[
              #align(center)[
                #text(size: t.value-label-size, fill: t.text-color-inverse, weight: "bold")[#label-text]
              ]
            ]
          )

          if n <= 9 and detail != "" {
            place(
              left + top,
              dx: center-x - avg-half,
              dy: mid-y + 3pt,
              box(width: avg-half * 2, height: 12pt)[
                #align(center)[
                  #text(size: t.value-label-size * 0.85, fill: t.text-color-inverse)[#detail]
                ]
              ]
            )
          }
        }
      }
    ]
  ]
}
