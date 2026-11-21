// APA caption presentation for native Typst figures/tables.
#let with-captions(body) = {
  show figure: set block(breakable: true)
  show figure.where(kind: image): set figure.caption(position: top)
  show figure.where(kind: table): set figure.caption(position: top)

  show figure.caption: it => block(width: 100%)[
    #set par(first-line-indent: 0pt, leading: 1em, spacing: 0pt)
    #align(left)[
      #strong[
        #it.supplement
        #h(0.25em)
        #context it.counter.display(it.numbering)
      ]
      #linebreak()
      #emph[#it.body]
    ]
  ]
  body
}
