// Example: Main Content section

#import "slide-functions.typ": card, conclusion-card, small-title

#let placeholder = "assets/szu-logo-gold.svg"

#let work-section = [
  = Main Work Section

  == Topic One

  Describe your first topic here.

  #align(center)[
    #image(placeholder, width: 40%)
    #text(size: 12pt)[Figure 1: Replace this placeholder with your image.]
  ]

  #pagebreak()

  == Topic Two

  #card(
    [Key Points],
    [
      + Point A
      + Point B
      + Point C
    ],
    fill: rgb("#fff8f4"),
  )

  #pagebreak()

  == Results

  #small-title[Results Summary]

  #conclusion-card(
    [Conclusion],
    [State the main result of this work.],
  )
]
