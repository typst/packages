// container.typ - Chart container wrapper

#import "../theme.typ": *
#import "./title.typ": draw-title

// Wraps chart body in a box with optional background/border and title.
// Adds inset padding when background is set (dark themes, etc.) to prevent content
// from touching the container edges.
#let chart-container(width, height, title, theme, extra-height: 0pt, legend: none, legend-width: 120pt, subtitle: none, radius: 0pt, body) = {
  let has-bg = theme.background != none
  let pad = if has-bg { 8pt } else { 0pt }
  let has-subtitle = subtitle != none
  let subtitle-overhead = if has-subtitle { theme.at("subtitle-size", default: theme.axis-title-size) + 3pt } else { 0pt }
  let title-overhead = if title != none { theme.title-size + theme.title-gap + 4pt + subtitle-overhead } else { if has-subtitle { subtitle-overhead + theme.title-gap + 4pt } else { 0pt } }
  let lp = theme.legend-position
  let side-legend = (lp == "right" or lp == "left") and legend != none
  box(
    width: if side-legend { width + legend-width + 2 * pad } else { width + 2 * pad },
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
      grid(
        columns: (width, 1fr),
        column-gutter: 10pt,
        body,
        legend,
      )
    } else if lp == "left" and legend != none {
      grid(
        columns: (1fr, width),
        column-gutter: 10pt,
        legend,
        body,
      )
    } else {
      body
      if legend != none and lp == "bottom" {
        legend
      }
    }
  ]
}
