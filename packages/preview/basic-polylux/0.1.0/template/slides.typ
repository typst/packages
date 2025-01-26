#import "@preview/polylux:0.4.0": *

#set page(
  paper: "presentation-16-9",
  footer: align(right, text(size: .8em, toolbox.slide-number)),
  margin: (bottom: 2em, rest: 1em),
)
#set text(
  font: "Lato",
  size: 23pt,
)
#show math.equation: set text(font: "Lete Sans Math")
#show heading: set block(below: 2em)

#slide[
  #set page(footer: none)
  #set align(horizon)

  #text(1.5em)[Title of the presentation]

  The author, the date
]

#slide[
  = My first slide

  Here come my three favourite fonts:
  #show: later

  + Atkinson Hyperlegible
  + Alegreya
  + TeX Gyre Pagella

  #show: later

  And now some math:
  $
    sum_(k = 1)^n k = (n (n + 1)) / 2
  $
]

#slide[
  = Second slide

  #toolbox.side-by-side[
    #rect(width: 100%, height: 1fr)[(imagine this being an image)]
  ][
    On the left, you see a #only(2)[not so] beautiful image.
  ]
]
