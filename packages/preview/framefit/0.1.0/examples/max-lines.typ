#import "@preview/framefit:0.1.0": framefit
#import "_helpers.typ": settings

#set page(width: 150mm, height: 90mm, margin: 14mm)
#set text(font: "Libertinus Serif", size: 14pt)

#let text = [
  Product labels often need the largest readable text size while keeping the
  result within a fixed number of lines.
]

= Maximum lines

#grid(
  columns: (1fr, 1fr),
  gutter: 10mm,
  [
    *No line limit*

    #settings[
      `framefit(width: 56mm, height: 34mm)`
      #linebreak()
      `min: 60%, max: none`
    ]

    _Result:_

    #framefit(
      width: 56mm,
      height: 34mm,
      min: 60%,
      max: none,
      inset: 6pt,
      stroke: 0.6pt + gray,
    )[ #text ]
  ],
  [
    *Framefit max-lines: 3*

    #settings[
      `framefit(width: 56mm, height: 34mm)`
      #linebreak()
      `min: 60%, max: none, max-lines: 3`
    ]

    _Result:_

    #framefit(
      width: 56mm,
      height: 34mm,
      min: 60%,
      max: none,
      max-lines: 3,
      inset: 6pt,
      stroke: 0.6pt + blue,
    )[ #text ]
  ],
)
