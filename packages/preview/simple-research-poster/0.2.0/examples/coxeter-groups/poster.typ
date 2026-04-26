#import "@preview/simple-research-poster:0.2.0": *
#import "./colors.typ": base-colors
#import "sections.typ": *

#set page(
  width:   43in,
  height:  32.5in,
  margin:  0%,
)

#show: poster.with(
  title:       text(size: 72pt, weight: "extrabold")[Geometric Realization of Coxeter Groups],
  author:      text(size: 48pt)[Nate Annau and Jesse Cobb --- Mentor: Benedict Lee],
  subtitle:    text(size: 36pt)[University of California, Santa Barbara],
  logo:        align(horizon)[#image("assets/whitelogo.png", height: 90%)],
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
  size: 24pt,
)
#set par(justify: true)

#let rgutter = 0.5cm
#pad(
  grid(
    columns: 3,
    inset: 0.5in,
    gutter: 30pt,
    grid(
      rows: 2,
      row-gutter: rgutter,
      colored-poster-section[Coxeter Systems][#coxeter-systems],
      colored-poster-section(fill: true)[Chambers and Nerves][#chambers-and-nerves],
    ),
    grid(
      rows: 2,
      row-gutter: rgutter,
      colored-poster-section(fill: true)[The Davis Complex as a Basic Construction][#basic-construction],
      colored-poster-section[The Davis Complex is _CAT(0)_][#Davis-complex-CAT0],
    ),
    grid(
      rows: 4,
      row-gutter: rgutter,
      colored-poster-section[Tits Representation][#tits-representation],
      colored-poster-section(fill: true)[Buildings][#buildings],
      colored-poster-section[Acknowledgements][#acknowledgements],
      colored-poster-section[References][#references],
    )
  ),
  top: 0.3cm,
  x: 1in,
)
