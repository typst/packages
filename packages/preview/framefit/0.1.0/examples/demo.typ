#import "@preview/framefit:0.1.0": framefit, fit-copy
#import "_helpers.typ": settings

#set page(width: 260mm, height: 180mm, margin: 16mm)
#set text(font: "Libertinus Serif", size: 14pt)

#let sample-long = [
  The copy is longer than the frame was designed for, so framefit reduces the
  text size until the paragraph fits within the available area.
]

#let sample-short = [Short headline]

= Framefit demo

#grid(
  columns: (1fr, 1fr),
  gutter: 10mm,
  [
    *Without framefit*

    #settings[
      `block(width: 100%, height: 32mm)`
      #linebreak()
      `text(font: "Libertinus Serif", size: 14pt)`
    ]

    _Result:_

    #block(
      width: 100%,
      height: 32mm,
      inset: 6pt,
      stroke: 0.6pt + red,
    )[ #sample-long ]
  ],
  [
    *With framefit*

    #settings[
      `framefit(width: 100%, height: 32mm)`
      #linebreak()
      `min: 65%, max: 120%`
    ]

    _Result:_

    #framefit(
      width: 100%,
      height: 32mm,
      min: 65%,
      max: 120%,
      inset: 6pt,
      stroke: 0.6pt + green,
    )[ #sample-long ]
  ],
)

#v(10mm)

#grid(
  columns: (1fr, 1fr),
  gutter: 10mm,
  [
    *Short copy at normal size*

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
    )[ #sample-short ]
  ],
  [
    *Short copy grown to max: 180%*

    #settings[
      `framefit(width: 58mm, height: 14mm)`
      #linebreak()
      `min: 65%, max: 180%`
    ]

    _Result:_

    #framefit(
      width: 58mm,
      height: 14mm,
      min: 65%,
      max: 180%,
      inset: 6pt,
      stroke: 0.6pt + blue,
    )[ #sample-short ]
  ],
)

#v(10mm)

*Existing frame helper*

#settings[
  `block(width: 100%, height: 24mm)`
  #linebreak()
  `fit-copy(min: 70%, max: 130%, only-if-overflow: true)`
]

_Result:_

#block(width: 100%, height: 24mm, inset: 6pt, stroke: 0.6pt + black)[
  #fit-copy(min: 70%, max: 130%, only-if-overflow: true)[
    With `only-if-overflow`, this helper keeps the original text size when it
    already fits and shrinks only when the frame would overflow.
  ]
]
