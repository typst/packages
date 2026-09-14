#import "@preview/framefit:0.1.0": framefit
#import "_helpers.typ": settings

#set page(width: 140mm, height: 105mm, margin: 14mm)
#set text(font: "Libertinus Serif", size: 14pt)

= No configured maximum

#grid(
  columns: (1fr, 1fr),
  gutter: 10mm,
  [
    *Normal frame*

    #settings[
      `block(width: 58mm, height: 18mm)`
      #linebreak()
      `text(size: 14pt)`
    ]

    _Result:_

    #block(
      width: 58mm,
      height: 18mm,
      inset: 6pt,
      stroke: 0.6pt + gray,
    )[Short headline]
  ],
  [
    *Framefit max: none*

    #settings[
      `framefit(width: 58mm, height: 18mm)`
      #linebreak()
      `min: 70%, max: none`
    ]

    _Result:_

    #framefit(
      width: 58mm,
      height: 18mm,
      min: 70%,
      max: none,
      inset: 6pt,
      stroke: 0.6pt + blue,
    )[Short headline]
  ],
)
