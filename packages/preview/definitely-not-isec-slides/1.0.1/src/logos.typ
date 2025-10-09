#let institute-logo(self) = [
  #block[
    #text(size: 13.5pt, weight: "medium")[#self.store.institute]
    #h(0.1cm)
    #box(inset: 0pt, outset: 0pt)[#square(
        width: 0.3cm,
        height: 0.3cm,
        outset: 0pt,
        inset: 0pt,
        stroke: none,
        fill: self.colors.primary,
      )]
  ]
]

#let tugraz-logo = [
  #set align(right)
  #set text(size: 12pt, tracking: 3.6pt)

  #image("assets/tuglogo.svg", width: 4.1cm)

  #v(0.13cm)

  #move(dx: -0.07cm)[
    SCIENCE
  ]

  #v(0.65em)

  #move(dx: -0.03cm)[
    PASSION
  ]

  #v(0.65em)

  #move(dx: -0.06cm)[
    TECHNOLOGY
  ]
]

