#import "@preview/framefit:0.1.0": framefit
#import "_helpers.typ": settings

#set page(width: 150mm, height: 90mm, margin: 14mm)
#set text(font: "Libertinus Serif", size: 14pt)

#let tight-copy = [
  This paragraph is intentionally long for the small frame, forcing framefit to
  use the lower size bound to keep the text inside the available area.
]

= Text shrinks to min

#grid(
  columns: (1fr, 1fr),
  gutter: 10mm,
  [
    *Normal frame*

    #settings[
      `block(width: 46.3mm, height: 21.8mm)`
      #linebreak()
      `text(size: 14pt)`
    ]

    _Result:_

    #block(
      width: 46.3mm,
      height: 21.8mm,
      inset: 6pt,
      stroke: 0.6pt + red,
    )[ #tight-copy ]
  ],
  [
    *Framefit min: 60%*

    #settings[
      `framefit(width: 46.3mm, height: 21.8mm)`
      #linebreak()
      `min: 60%, max: 120%`
    ]

    _Result:_

    #framefit(
      width: 46.3mm,
      height: 21.8mm,
      min: 60%,
      max: 120%,
      inset: 6pt,
      stroke: 0.6pt + green,
    )[ #tight-copy ]
  ],
)
