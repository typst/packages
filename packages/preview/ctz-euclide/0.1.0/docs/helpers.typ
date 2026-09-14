// Shared helper functions for manual documentation
#import "@preview/ctz-euclide:0.1.0": *

/// Two-column example layout with code and figure
#let example(code, body, length: 0.75cm) = block(breakable: false)[
  #table(
    columns: (1fr, 1fr),
    stroke: none,
    inset: 6pt,
    align: (left + top, center + top),
    [
      #set text(size: 8.5pt)
      *Code*
      #v(0.3em)
      #code
    ],
    [
      *Figure*
      #v(0.3em)
      #box(
        inset: 4pt,
        radius: 3pt,
        stroke: 0.5pt + luma(85%),
        fill: luma(98%),
      )[
        #ctz-canvas(length: length, body)
      ]
    ],
  )
  #v(0.5em)
]

/// Full-page figure
#let full-figure(title, body, code: none, length: 1cm, caption: none) = {
  pagebreak()
  v(1fr)
  align(center)[
    #text(size: 12pt, weight: "bold")[#title]
    #v(1em)
    #box(
      inset: 8pt,
      radius: 4pt,
      stroke: 0.5pt + luma(80%),
      fill: luma(98%),
    )[
      #ctz-canvas(length: length, body)
    ]
    #if caption != none [
      #v(1.5em)
      #text(size: 10pt)[#caption]
    ]
    #if code != none [
      #v(1.5em)
      #align(left)[
        #box(
          width: 100%,
          inset: 10pt,
          radius: 3pt,
          stroke: 0.5pt + luma(70%),
          fill: luma(95%),
        )[
          #set text(size: 8pt, font: "DejaVu Sans Mono")
          #code
        ]
      ]
    ]
  ]
  v(2fr)
}
