#import "../utils/translation.typ": translation

#let make-outline() = {
  pagebreak(weak: true)

  outline(title: translation("Table of contents"))
}

#let make-other-outlines(
  bibliography: none,
  units: none,
) = context {
  set page(numbering: "I")
  set heading(numbering: none)
  show heading.where(level: 1): set heading(numbering: none)

  // TODO register
  if query(figure.where(kind: "todo")).len() > 0 {
    pagebreak(weak: true)
    // style all outlines (outline, table register, figure register, ...)
    show outline.entry: it => {
      link(
        it.element.location(),
        it.indented(it.prefix(), it.inner()),
        //text(it.element.supplement, weight: "thin")
      )
    }
    // TODO outline
    // TODO: make this look a lot nicer
    heading(text("TODOs", fill: red))
    outline(
      title: none,
      target: figure.where(kind: "todo"),
    )
  }

  // bilbiography
  pagebreak(weak: true)
  bibliography

  // images register
  if query(figure.where(kind: image)).len() > 0 {
    heading(translation("List of figures"))
    outline(
      title: none,
      target: figure.where(kind: image),
    )
  }

  // tables register
  if query(figure.where(kind: table)).len() > 0 {
    heading(translation("List of tables"))
    outline(
      title: none,
      target: figure.where(kind: table),
    )
  }

  // code register
  if query(figure.where(kind: raw)).len() > 0 {
    heading("List of code")
    outline(
      title: none,
      target: figure.where(kind: raw),
    )
  }
}

#let outline-styles(doc) = {
  // style all outlines (outline, table register, figure register, ...)
  show outline.entry: it => {
    if it.level == 1 {
      set block(above: 2em)
      show repeat: none
      strong(it)
    } else {
      text(it, weight: "thin")
    }
  }
  doc
}
