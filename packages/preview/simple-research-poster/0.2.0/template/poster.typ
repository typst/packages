#import "@preview/simple-research-poster:0.2.0": *
#import "colors.typ": (
  base-colors,
  bold-color,
)
#import "sections.typ": *

#set page(
  paper:   "a1",
  flipped: true,
  margin:  0%,
)

#show: poster.with(
  title:       text(size: 58pt, weight: "extrabold")[Applied Cryonics: How I Slept Through the 21st Century],
  author:      text(size: 40pt)[Philip J. Fry and Turanga Leela --- Advisor: Bender B. Rodriguez],
  subtitle:    text(size: 28pt)[College of New New York],
  logo:        image("assets/logo.png", height: 120%),
  base-colors: base-colors,
)
#let colored-poster-section = poster-section.with(
  base-colors: base-colors,
  title-style: text.with(
    size:   30pt,
    weight: "extrabold",
    fill:   base-colors.bgcolor2
  ),
)

#set text(
  size: 17pt,
)
#set par(justify: true)
#show strong: set text(fill: bold-color)

#pad(
  grid(
    columns: 3,
    inset:   35pt,
    gutter:  30pt,
    [
      #colored-poster-section[Section 1][#section1]
      #colored-poster-section(fill: true)[Section 2][#section2]
    ],
    [
      #colored-poster-section[Section 3][#section3]
      #colored-poster-section(fill: true)[Section 4][#section4]
      #colored-poster-section[Section 5][#section5]
    ],
    [
      #colored-poster-section(fill: true)[Section 6][#section6]
      #colored-poster-section[Section 7][#section7]
      #colored-poster-section(fill: true)[Acknowledgements][#acknowledgements]
      #colored-poster-section[References][#references]
    ]
  ),
  top: 20pt,
  x: 70pt,
)
