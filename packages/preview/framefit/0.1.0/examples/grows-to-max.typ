#import "@preview/framefit:0.1.0": framefit
#import "_helpers.typ": settings

#set page(width: 140mm, height: 105mm, margin: 14mm)
#set text(font: "Libertinus Serif", size: 14pt)

= Text grows to max

#grid(
  columns: (1fr, 1fr),
  gutter: 10mm,
  [
    *Normal frame*

    #settings[
      `block(width: 58mm, height: 14mm)`
      #linebreak()
      `text(size: 14pt)`
    ]

    _Result:_

    #block(
      width: 58mm,
      height: 14mm,
      inset: 6pt,
      stroke: 0.6pt + gray,
    )[Short headline]
  ],
  [
    *Framefit max: 180%*

    #settings[
      `framefit(width: 58mm, height: 14mm)`
      #linebreak()
      `min: 70%, max: 180%`
    ]

    _Result:_

    #framefit(
      width: 58mm,
      height: 14mm,
      min: 70%,
      max: 180%,
      inset: 6pt,
      stroke: 0.6pt + blue,
    )[Short headline]
  ],
)
