// badges.typ - UI badge components for difficulty and labels

// Badge styling constants
#let badge-inset = (x: 6pt, y: 3pt)
#let badge-radius = 3pt
#let badge-font-size = 9pt
#let badge-stroke-width = 0.5pt

// Difficulty badge colors
#let difficulty-colors = (
  easy: rgb("#00b8a3"),
  medium: rgb("#ffc01e"),
  hard: rgb("#ff375f"),
)

// Create a difficulty badge
#let difficulty-badge(level) = {
  let color = difficulty-colors.at(level, default: gray)
  box(
    fill: color.lighten(80%),
    stroke: badge-stroke-width + color,
    inset: badge-inset,
    radius: badge-radius,
  )[
    #text(fill: color.darken(20%), weight: "semibold", size: badge-font-size)[
      #upper(level)
    ]
  ]
}

// Create a label badge
#let label-badge(label) = {
  box(
    fill: gray.lighten(90%),
    stroke: badge-stroke-width + gray.lighten(50%),
    inset: badge-inset,
    radius: badge-radius,
  )[
    #text(fill: gray.darken(40%), size: badge-font-size)[#upper(label)]
  ]
}
