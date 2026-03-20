// container.typ - Chart container wrapper

#import "../theme.typ": *
#import "./title.typ": draw-title

/// Fallback inset for non-theme contexts (e.g. heatmap overhead calc).
/// Charts should use theme.container-inset instead.
#let container-inset = 8pt

// Wraps chart body in a box with optional background/border and title.
// Adds inset padding so light and dark themes render at the same outer size.
#let chart-container(width, height, title, theme, extra-height: 0pt, legend: none, legend-width: 120pt, subtitle: none, radius: 0pt, body) = {
  let has-bg = theme.background != none
  let pad = theme.at("container-inset", default: container-inset)
  let has-subtitle = subtitle != none
  let subtitle-overhead = if has-subtitle { theme.at("subtitle-size", default: theme.axis-title-size) + 3pt } else { 0pt }
  let title-overhead = if title != none { theme.title-size + theme.title-gap + 4pt + subtitle-overhead } else { if has-subtitle { subtitle-overhead + theme.title-gap + 4pt } else { 0pt } }
  let lp = theme.legend-position
  let side-legend = (lp == "right" or lp == "left") and legend != none
  let legend-gap = if side-legend { 10pt } else { 0pt }
  box(
    width: if side-legend { width + legend-gap + legend-width + 2 * pad } else { width + 2 * pad },
    height: height + extra-height + title-overhead + 2 * pad,
    fill: theme.background,
    stroke: theme.border,
    inset: pad,
    radius: radius,
  )[
    #draw-title(title, theme, subtitle: subtitle)
    #if lp == "top" and legend != none {
      legend
    }
    #if lp == "right" and legend != none {
      context {
        let legend-h = measure(legend).height
        // Center legend relative to chart; allow negative dy when legend is taller
        let legend-dy = (height - legend-h) / 2
        let content-h = calc.max(height, legend-h)
        // Shift both chart and legend down if legend extends above chart
        let base-dy = if legend-dy < 0pt { -legend-dy } else { 0pt }
        box(width: width + legend-gap + legend-width, height: content-h)[
          #place(left + top, dy: base-dy, box(width: width, height: height, body))
          #place(left + top, dx: width + legend-gap, dy: base-dy + legend-dy,
            box(width: legend-width, legend))
        ]
      }
    } else if lp == "left" and legend != none {
      context {
        let legend-h = measure(legend).height
        let legend-dy = (height - legend-h) / 2
        let content-h = calc.max(height, legend-h)
        let base-dy = if legend-dy < 0pt { -legend-dy } else { 0pt }
        box(width: width + legend-gap + legend-width, height: content-h)[
          #place(left + top, dy: base-dy + legend-dy,
            box(width: legend-width, legend))
          #place(left + top, dx: legend-width + legend-gap, dy: base-dy,
            box(width: width, height: height, body))
        ]
      }
    } else {
      body
      if legend != none and lp == "bottom" {
        legend
      }
    }
  ]
}
