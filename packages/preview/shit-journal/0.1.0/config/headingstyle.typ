#let headingstyle(body) = {
  set heading(numbering: "I.A.")

  show heading.where(level: 1): it => align(center)[
    #v(0.2em)
    #if it.numbering != none [ #counter(heading).display() #h(0.5em) ]
    #text(weight: "regular", size: 10pt)[#smallcaps(it.body)]
    #v(-0.4em)
  ]

  show heading.where(level: 2): it => [
    #v(0.4em)
    #text(weight: "regular", style: "italic", size: 10pt)[
      #if it.numbering != none [
        #context numbering("A.", counter(heading).get().last())
        #h(0.5em)
      ]
      #it.body
    ]
    #v(-0.2em)
  ]
  body
}