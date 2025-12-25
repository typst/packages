#import "@local/post-it:0.1.0": *
#import "./colors.typ": base-colors
#import "sections.typ": *

#show: poster.with(
  title:       [Geometric Realization of Coxeter Groups],
  author:      [Nate Annau and Jesse Cobb],
  mentor:      [Mentor: Benedict Lee],
  subtitle:    [University of California, Santa Barbara],
  logo:        image("assets/whitelogo.png", height: 100%),
  base-colors: base-colors,
)
#let colored-poster-section = poster-section.with(base-colors: base-colors)


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
