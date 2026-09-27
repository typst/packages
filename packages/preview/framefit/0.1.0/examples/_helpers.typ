#let settings(body) = block(
  width: 100%,
  inset: (x: 4pt, y: 3pt),
  fill: luma(248),
  stroke: 0.35pt + luma(205),
  radius: 2pt,
)[
  #text(font: "DejaVu Sans Mono", size: 7.5pt)[
    *Settings used:*
    #linebreak()
    #body
  ]
]

