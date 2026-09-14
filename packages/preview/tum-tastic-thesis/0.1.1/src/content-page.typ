#import "tum-font.typ": font-sizes
#import "utils.typ": format-title-section-before-chapters

#let print-index() = [
  // --------------  Sets  --------------
  #show outline.entry.where(level: 1): it => {
    v(6pt) // Adjust spacing as needed
    link(
      it.element.location(),
      it.indented(it.prefix(), text(
        weight: "bold",
        size: font-sizes.base,
      )[#it.inner()]),
    )
  }

  #show outline.entry: set text(size: font-sizes.base)


  // We need to reset the show rule in case this is called from a document
  // where this was already set. Otherwise both rules will stack
  #show heading.where(level: 1): it => it.body

  #show heading.where(level: 1): it => {
    set text(size: font-sizes.h1)
    v(2em)
    strong(it)
    v(1em)
  }

  // --------------  Content  --------------
  #outline(title: [Content])
]

#let outline-style(doc) = {
  // --------------  Sets  --------------
  show outline.entry: set text(size: font-sizes.base)

  // See: https://github.com/typst/typst/issues/1295#issuecomment-2749005636
  let in-outline = state("in-outline", false)
  show outline: it => {
    in-outline.update(true)
    it
    in-outline.update(false)
  }

  // We need this to show this on the Content page
  show outline: set heading(outlined: true)

  // We need to reset the show rule in case this is called from a document
  // where this was already set. Otherwise both rules will stack
  show heading.where(level: 1): it => it.body

  show heading.where(level: 1): it => {
    set text(size: font-sizes.h1)
    v(2em)
    strong(it)
    v(1em)
  }

  doc
}

#let print-figure-index() = [
  #show: outline-style.with()

  // --------------  Content  --------------
  #outline(title: [List of Figures], target: figure.where(kind: image))
]

#let print-table-index() = [
  #show: outline-style.with()

  // --------------  Content  --------------
  #outline(title: [List of Tables], target: figure.where(kind: table))
]

#let print-listing-index() = [
  #show: outline-style.with()

  // --------------  Content  --------------
  #outline(title: [List of Listings], target: figure.where(kind: raw))
]

#let print-algorithm-index() = [
  #show: outline-style.with()

  // --------------  Content  --------------
  #outline(title: [List of Algorithms], target: figure.where(kind: "algorithm"))
]

#print-index()
#print-figure-index()
#print-table-index()
#print-listing-index()
#print-algorithm-index()
