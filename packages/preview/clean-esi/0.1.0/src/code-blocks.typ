// src/code-blocks.typ - opt-in thesis code and schema block helpers

#import "@preview/zebraw:0.6.3": zebraw

#let thesis-code-rule = rgb("#d7d7d7")
#let thesis-code-fill = rgb("#fbfbfb")
#let thesis-code-zebra-fill = rgb("#f4f4f4")

#let thesis-code-block(body, numbering: false, size: 8.4pt) = rect(
  width: 100%,
  radius: 2pt,
  inset: 0pt,
  stroke: 0.45pt + thesis-code-rule,
)[
  #set text(size: size)
  #set raw(theme: none)
  #zebraw(
    lang: false,
    numbering: numbering,
    numbering-separator: numbering != false,
    background-color: (thesis-code-fill, thesis-code-zebra-fill),
    radius: 2pt,
    inset: (x: 5pt, y: 4pt),
    body,
  )
]

#let thesis-json-block(body, numbering: false) = thesis-code-block(body, numbering: numbering)
