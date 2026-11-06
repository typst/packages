#let uline(width, body) = box(
  align(left, body),
  width: width,
  stroke: (bottom: 0.5pt),
  outset: (bottom: 2pt),
)

#let uline-center(width, body) = box(
  align(center, body),
  width: width,
  stroke: (bottom: 0.5pt),
  outset: (bottom: 2pt),
)

#let center-box(width, body) = box(align(center, body), width: width)
