#import "@preview/framefit:0.1.0": framefit
#import "_helpers.typ": settings

#set page(width: 220mm, height: 230mm, margin: 14mm)
#set text(size: 14pt)

#let sample = [
  Different font metrics and line spacing change the measured three-line
  height, so the fitted size can change too.
]

#let frame-color = rgb("#2f6f9f")

= Maximum lines with style changes

== Fonts

#grid(
  columns: (1fr, 1fr, 1fr),
  gutter: 8mm,
  [
    *Libertinus Serif*

    #set text(font: "Libertinus Serif")

    #settings[
      `font: "Libertinus Serif"`
      #linebreak()
      `width: 58mm, height: 34mm`
      #linebreak()
      `min: 45%, max: none, max-lines: 3`
    ]

    _Result:_

    #framefit(
      width: 58mm,
      height: 34mm,
      min: 45%,
      max: none,
      max-lines: 3,
      inset: 6pt,
      stroke: 0.6pt + frame-color,
    )[ #sample ]
  ],
  [
    *New Computer Modern*

    #set text(font: "New Computer Modern")

    #settings[
      `font: "New Computer Modern"`
      #linebreak()
      `width: 58mm, height: 34mm`
      #linebreak()
      `min: 45%, max: none, max-lines: 3`
    ]

    _Result:_

    #framefit(
      width: 58mm,
      height: 34mm,
      min: 45%,
      max: none,
      max-lines: 3,
      inset: 6pt,
      stroke: 0.6pt + frame-color,
    )[ #sample ]
  ],
  [
    *DejaVu Sans Mono*

    #set text(font: "DejaVu Sans Mono")

    #settings[
      `font: "DejaVu Sans Mono"`
      #linebreak()
      `width: 58mm, height: 34mm`
      #linebreak()
      `min: 45%, max: none, max-lines: 3`
    ]

    _Result:_

    #framefit(
      width: 58mm,
      height: 34mm,
      min: 45%,
      max: none,
      max-lines: 3,
      inset: 6pt,
      stroke: 0.6pt + frame-color,
    )[ #sample ]
  ],
)

#v(8mm)

== Paragraph leading

#grid(
  columns: (1fr, 1fr, 1fr),
  gutter: 8mm,
  [
    *Tight leading*

    #set text(font: "Libertinus Serif")
    #set par(leading: 2pt)

    #settings[
      `font: "Libertinus Serif"`
      #linebreak()
      `par(leading: 2pt)`
      #linebreak()
      `max-lines: 3`
    ]

    _Result:_

    #framefit(
      width: 58mm,
      height: 34mm,
      min: 45%,
      max: none,
      max-lines: 3,
      inset: 6pt,
      stroke: 0.6pt + green,
    )[ #sample ]
  ],
  [
    *Default leading*

    #set text(font: "Libertinus Serif")

    #settings[
      `font: "Libertinus Serif"`
      #linebreak()
      `par(leading: default)`
      #linebreak()
      `max-lines: 3`
    ]

    _Result:_

    #framefit(
      width: 58mm,
      height: 34mm,
      min: 45%,
      max: none,
      max-lines: 3,
      inset: 6pt,
      stroke: 0.6pt + frame-color,
    )[ #sample ]
  ],
  [
    *Loose leading*

    #set text(font: "Libertinus Serif")
    #set par(leading: 8pt)

    #settings[
      `font: "Libertinus Serif"`
      #linebreak()
      `par(leading: 8pt)`
      #linebreak()
      `max-lines: 3`
    ]

    _Result:_

    #framefit(
      width: 58mm,
      height: 34mm,
      min: 45%,
      max: none,
      max-lines: 3,
      inset: 6pt,
      stroke: 0.6pt + orange,
    )[ #sample ]
  ],
)
