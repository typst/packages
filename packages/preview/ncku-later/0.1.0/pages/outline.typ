#let make-outline() = {
  // text size except for outline title
  set text(size: 12pt)

  // set leading of outline (spaceing between lines)
  set par(leading: 1.2em)

  // outline heading style
  show outline: it => {
    // change the title style of outline
    show heading: it => {
      set text(size: 21pt)
      set align(center)
      it
      v(0.8cm)
    }
    it
  }

  // the intention of the invisible level 1 heading is to
  // make the outline itself appear on the outline
  [
    #show heading: none
    = Table of Contents
  ]
  outline(title: [Table of Contents], indent: auto)
  pagebreak()

  [
    #show heading: none
    = List of Table
  ]
  outline(
    indent: auto,
    title: [List of Tables],
    target: figure.where(kind: table),
  )
  pagebreak()

  [
    #show heading: none
    = List of Figures
  ]
  outline(
    indent: auto,
    title: [List of Figures],
    target: figure.where(kind: image),
  )
  pagebreak()
}

