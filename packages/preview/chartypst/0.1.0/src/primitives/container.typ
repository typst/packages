// container.typ - Chart container wrapper

#import "../theme.typ": *
#import "./title.typ": draw-title

// Wraps chart body in a box with optional background/border and title.
#let chart-container(width, height, title, theme, extra-height: 0pt, legend: none, body) = {
  box(
    width: if theme.legend-position == "right" and legend != none { width + 120pt } else { width },
    height: height + extra-height,
    fill: theme.background,
    stroke: theme.border,
  )[
    #draw-title(title, theme)
    #if theme.legend-position == "right" and legend != none {
      grid(
        columns: (width, 1fr),
        column-gutter: 10pt,
        body,
        legend,
      )
    } else {
      body
      if legend != none and theme.legend-position == "bottom" {
        legend
      }
    }
  ]
}
