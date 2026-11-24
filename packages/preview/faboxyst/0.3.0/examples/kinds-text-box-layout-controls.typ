// Demonstrates independent text-width, gap, and element-offset controls
// for the three approved Kinds Text Boxes layouts.
#import "@preview/faboxyst:0.3.0": *

#set page(width: 9.8cm, height: 11.0cm, margin: 0.35cm, fill: rgb("#F1F0EF"))
#set text(font: "DejaVu Sans", size: 8pt)
#show: faboxyst.with(theme: themes.notebook)

#align(center)[#text(fill: rgb("#444444"))[Style 1 — separate title/body widths, vertical gap and number/text offsets]]
#align(center + horizon)[
  #kinds-text-box-1(
    number: [1], title: [CUSTOM TITLE],
    body: [Tune the text columns and their spacing separately, then move the number or either text block.],
    width: 6.8cm, height: 6.8cm,
    title-width: 3.55cm, body-width: 3.45cm,
    title-body-gap: 0.28cm,
    title-offset-x: 0.08cm, body-offset-y: 0.05cm,
    number-offset-x: 0.08cm,
  )
]
#pagebreak()

#align(center)[#text(fill: rgb("#444444"))[Style 2 — independent centered widths and text/number placement]]
#align(center + horizon)[
  #kinds-text-box-2(
    number: [2], title: [CUSTOM TITLE],
    body: [Choose different title and body widths, add a vertical gap, and reposition the number.],
    width: 4.3cm, height: 7.4cm,
    title-width: 3.65cm, body-width: 3.3cm,
    title-body-gap: 0.32cm,
    title-offset-y: -0.05cm, body-offset-x: 0.08cm,
    number-offset-y: 0.06cm,
  )
]
#pagebreak()

#align(center)[#text(fill: rgb("#444444"))[Style 3 — independent title/body widths, spacing and number position]]
#align(center + horizon)[
  #kinds-text-box-3(
    number: [3], title: [CUSTOM TITLE],
    body: [Adjust the two copy widths and title/body gap; change the number position independently.],
    width: 8.8cm, height: 6.2cm,
    title-width: 4.35cm, body-width: 4.6cm,
    title-body-gap: 0.28cm,
    title-offset-x: 0.08cm, body-offset-y: -0.05cm,
    number-position: "lower", number-offset-y: 0.08cm,
  )
]
