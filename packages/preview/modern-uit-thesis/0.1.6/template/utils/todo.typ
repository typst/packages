// Utility to highlight TODOs to easily find them in the PDF
#let TODO(body, color: yellow, title: "TODO") = {
  rect(
    width: 100%,
    radius: 3pt,
    stroke: 0.5pt,
    fill: color,
  )[
    #text(weight: 700)[#title]: #body
  ]
}
