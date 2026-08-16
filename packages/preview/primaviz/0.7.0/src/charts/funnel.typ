// funnel.typ - Funnel chart for process/conversion stages
#import "../theme.typ": _resolve-ctx, get-color
#import "../util.typ": normalize-data, format-number
#import "../validate.typ": validate-simple-data
#import "../primitives/container.typ": chart-container
#import "../primitives/layout.typ": label-fits-inside, try-fit-label, resolve-size

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
  width: auto,
  height: auto,
  title: none,
  show-values: true,
  show-percentages: true,
  gap: 3pt,
  theme: none,
) = context {
  layout(size => {
  validate-simple-data(data, "funnel-chart")
  let t = _resolve-ctx(theme)
  let norm = normalize-data(data)
  let labels = norm.labels
  let values = norm.values
  let (width, height) = resolve-size(width, height, size, n: values.len(), theme: t)

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
      #let last-ext-bottom = -100pt
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
            stroke: t.marker-stroke,
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
          let detail-parts = ()
          if show-values { detail-parts.push(value-text) }
          if show-percentages { detail-parts.push(pct-text) }
          let detail = detail-parts.join(" · ")

          // Center the text on the segment — use inset width to avoid boundary overlap
          let mid-y = y-top + seg-height / 2
          let avg-half = (top-half + bottom-half) / 2
          let inset-half = calc.max(10pt, avg-half - 6pt)
          let label-size = if avg-half * 2 < 60pt { calc.max(5pt, t.value-label-size - 1pt) } else { t.value-label-size }

          let lbl-len = label-text.len()
          // Use actual narrowest width of trapezoid (bottom edge), not inflated inset
          let min-half = calc.min(top-half, bottom-half)
          let avail-w = calc.max(0pt, min-half * 2 - 12pt)  // 6pt padding each side
          let avail-h = seg-height

          // Check if label fits inside segment (try shrinking, but not below 6pt — unreadable)
          let has-detail = n <= 9 and detail != ""
          let fit = try-fit-label(avail-w, avail-h, label-size, lbl-len, shrink-min: 6pt)

          if fit.fits {
            let label-size = fit.size
            let detail-size = label-size * 0.85
            // Detail renders at segment midpoint where it's wider — use avg width
            let avg-w = calc.max(0pt, avg-half * 2 - 12pt)
            let detail-len = detail.len()
            let detail-fit = if has-detail { try-fit-label(avg-w, avail-h, detail-size, detail-len) } else { (fits: false, size: detail-size) }
            let show-detail = has-detail and detail-fit.fits
            let block-h = if show-detail { label-size + detail-size + 2pt } else { label-size + 2pt }
            let start-y = mid-y - block-h / 2

            place(
              left + top,
              dx: center-x - inset-half,
              dy: start-y,
              box(width: inset-half * 2, height: block-h, clip: true)[
                #align(center + horizon)[
                  #if show-detail {
                    stack(dir: ttb, spacing: 1pt,
                      text(size: label-size, fill: t.text-color-inverse, weight: "bold")[#label-text],
                      text(size: detail-size, fill: t.text-color-inverse)[#detail],
                    )
                  } else {
                    text(size: label-size, fill: t.text-color-inverse, weight: "bold")[#label-text]
                  }
                ]
              ]
            )
          } else {
            // External label: place to the right with leader line
            let ext-label-size = calc.max(5pt, label-size - 0.5pt)
            let right-edge = center-x + top-half
            let leader-start-x = right-edge + 2pt
            let ext-label-x = leader-start-x + 10pt
            let ext-label-w = width - ext-label-x - 4pt
            if ext-label-w > 20pt {
              let block-h = ext-label-size + 4pt
              let label-y = calc.max(mid-y - block-h / 2, last-ext-bottom + 1pt)
              last-ext-bottom = label-y + block-h
              // Leader line
              place(left + top,
                line(start: (leader-start-x, mid-y),
                     end: (ext-label-x - 1pt, label-y + block-h / 2),
                     stroke: 0.5pt + t.text-color-light))
              // Label
              place(
                left + top,
                dx: ext-label-x,
                dy: label-y,
                box(width: ext-label-w, height: block-h)[
                  #align(left + horizon)[
                    #text(size: ext-label-size, fill: t.text-color, weight: "bold")[#label-text]
                    #if has-detail {
                      text(size: ext-label-size * 0.85, fill: t.text-color)[ #detail]
                    }
                  ]
                ]
              )
            }
          }
        }
      }
    ]
  ]
  })
}
