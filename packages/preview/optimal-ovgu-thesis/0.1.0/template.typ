#import "components.typ": body-font, sans-font, small-heading, number-until-with, variable-pagebreak, author-fullname
#import "titlepage.typ": oot-titlepage
#import "acknowledgement.typ": oot-acknowledgement
#import "abstract.typ": oot-abstract
#import "disclaimer.typ": oot-disclaimer
#import "expose.typ": oot-expose

#let optimal-ovgu-thesis(title: "", author: none, lang: "en", is-doublesided: none, body) = {
  set document(title: title, author: author-fullname(author))
  set page(
    margin: (left: 30mm, right: 30mm, top: 27mm, bottom: 27mm),
    numbering: "1",
    number-align: center,
  )

  set text(font: body-font, size: 11pt, lang: lang)
  show math.equation: set text(weight: 400)
  show figure.caption: emph

  show figure.where(kind: table): set figure.caption(position: top)

  show figure.where(kind: raw): set figure.caption(position: top)

  set table(stroke: gray)

  show heading: set text(font: sans-font)
  show heading.where(level: 1): h => [
    #variable-pagebreak(is-doublesided)
    #h
  ]

  // Apply custom numbering to headings
  set heading(numbering: number-until-with(3, "1.1"))

  // Make nested headings apply small-heading style
  show heading.where(level: 4) : small-heading()
  show heading.where(level: 5) : small-heading()
  show heading.where(level: 6) : small-heading()
  show heading.where(level: 7) : small-heading()

  show par: set block(spacing: 1em)
  set par(
    justify: true,
    leading: 1em, // Set the space between lines in text
    first-line-indent: 1em,
  )

  show raw.where(block: true): it => align(start, block(
    fill: luma(250),
    stroke: 0.6pt + luma(200),
    inset: 8pt,
    radius: 3pt,
    width: 100%,
    it,
  ))
  show raw.where(block: true): set text(size: 8pt)
  show raw.where(block: true): set par(leading: 0.6em)

  // Table of contents
  set outline(indent: 2em)
  show outline: outline => [
    #show heading: heading => [
      #text(font: body-font, 1.5em, weight: 700, heading.body)
      #v(15mm)
    ]
    #outline
    #variable-pagebreak(is-doublesided)
  ]

  body
}
