#let theme(
  inset: 6pt,
  fill: red,
  radius: 4pt,
  stroke: 1pt,
  type-radius: 2pt,
  type-inset: 4pt,
  type-fill: orange,
  type-stroke: none,
  line-paint: black,
  line-thickness: 1pt,
  text-color: black,
) = {
  return (
    inset: inset,
    fill: fill,
    radius: radius,
    stroke: stroke,
    type-radius: type-radius,
    type-inset: type-inset,
    type-fill: type-fill,
    type-stroke: type-stroke,
    line-paint: line-paint,
    line-thickness: line-thickness,
    text-color: text-color,
  )
}

#let themes = (
  // Default theme
  default: theme(
    inset: 6pt,
    fill: red,
    radius: 4pt,
    stroke: 1pt,
    type-radius: 2pt,
    type-inset: 4pt,
    type-fill: orange,
    type-stroke: none,
  ),

  // Dark
  pixies: theme(
    inset: 6pt,
    fill: gray.darken(40%),
    radius: 0pt,
    stroke: 3pt,
    type-radius: 0pt,
    type-inset: 4pt,
    type-fill: gray.darken(70%),
    type-stroke: black + 2pt,
    line-paint: black,
    line-thickness: 1pt,
    text-color: white.darken(10%),
  ),

  // Material Design 3 - Clean, modern, elevation-based
  material-design: theme(
    inset: 12pt,
    fill: rgb("#e8def8"),
    radius: 8pt,
    stroke: 0pt,
    type-radius: 4pt,
    type-inset: 8pt,
    type-fill: rgb("#d0bcff"),
    type-stroke: none,
    line-paint: rgb("#d0bcff"),
    line-thickness: 2pt,
  ),

  // Modern/Clean - Minimal borders, generous spacing
  modern: theme(
    inset: 8pt,
    fill: rgb("#f5f5f5"),
    radius: 8pt,
    stroke: 0pt,
    type-radius: 4pt,
    type-inset: 6pt,
    type-fill: rgb("#e8e8e8"),
    type-stroke: none,
  ),

  // Accent Blue - Professional
  accent-blue: theme(
    inset: 6pt,
    fill: rgb("#e3f2fd"),
    radius: 4pt,
    stroke: 1pt + rgb("#2196f3"),
    type-radius: 2pt,
    type-inset: 4pt,
    type-fill: rgb("#bbdefb"),
    type-stroke: none,
  ),

  // Accent Green - Success/positive
  accent-green: theme(
    inset: 6pt,
    fill: rgb("#e8f5e9"),
    radius: 4pt,
    stroke: 1pt + rgb("#4caf50"),
    type-radius: 2pt,
    type-inset: 4pt,
    type-fill: rgb("#c8e6c9"),
    type-stroke: none,
  ),

  // Subtle/Flat - Minimal visual weight
  subtle: theme(
    inset: 5pt,
    fill: rgb("#fafafa"),
    radius: 2pt,
    stroke: 0pt,
    type-radius: 0pt,
    type-inset: 3pt,
    type-fill: rgb("#f0f0f0"),
    type-stroke: none,
  ),

  // Rounded/Soft - Friendly appearance
  rounded: theme(
    inset: 7pt,
    fill: rgb("#f3e5f5"),
    radius: 12pt,
    stroke: 1pt + rgb("#ce93d8"),
    type-radius: 8pt,
    type-inset: 5pt,
    type-fill: rgb("#e1bee7"),
    type-stroke: none,
  ),
)
