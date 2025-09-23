#let graph-outline(..args) = {
  show outline: set heading(outlined: true)
  outline(..args)
}
#let create-page-number(it) = box(
  width: 2.5em,
  align(right + top, it.page()),
)
#let format-body-with-page(body, number) = {}

/// Inserts outline
/// - lang (string): language for the oultine, "en" or "nl" allowed
/// -> content
#let insert-heading-outline(lang: "en") = {
  // Table of contents
  // Outline customization
  show outline.entry: it => {
    let weight = if it.element.level == 1 { 900 } else { 500 }
    let fill = if it.element.level != 1 {
      repeat(gap: 0.5em)[.]
    } else { [] }
    let rest = (
      text(red, weight: weight)[#it.body()]
        + h(1em)
        + box(width: 1fr, fill)
        + sym.space
        + sym.wj
        + text(weight: weight)[ #create-page-number(it) ]
    )
    // TOOD: fix indentation of numbered items
    link(
      it.element.location(),
      it.indented(text(red, weight: weight)[#it.prefix()], rest),
    )
  }
  show outline: set heading(numbering: none, outlined: false)
  show outline.entry.where(level: 1): set block(above: 1.1em)
  let title = if lang == "nl" {
    "Inhoudsopgave"
  } else {
    "Contents"
  }
  outline(title: title, depth: 2)
}

#let insert-figure-outline(title, target: image) = {
  // Table of contents
  // Outline customization
  show outline.entry: it => {
    let fill = repeat(gap: 0.5em)[.]
    let rest = (
      text(red, weight: 500)[#it.body()]
        + h(1em)
        + box(width: 1fr, fill)
        + sym.space
        + sym.wj
        + create-page-number(it)
    )
    // + [#it.element.fields()]
    let location = it.element.location()
    let number = context {
      let chapter-number = counter(heading).at(location).at(0)
      if it.element.caption != none {
        let figure-number = it.element.caption.counter.at(location).at(0)
        numbering("1.1", chapter-number, figure-number)
      } else { "" }
    }
    // TODO: add spacing for images with number "N.1"
    link(
      location,
      it.indented(
        text(red, weight: 500)[#number],
        rest,
      ),
    )
  }
  show outline: set heading(numbering: none, outlined: false)
  show outline.entry.where(level: 1): set block(above: 1.1em)
  graph-outline(
    title: title,
    target: figure.where(kind: target),
  )
}
#let insert-listing-outline(lang: "en") = {
  let title = if lang == "en" { "List of Listings" } else {
    "Lijst van code"
  }
  insert-figure-outline(title, target: raw)
}
#let insert-image-outline(lang: "en") = {
  let title = if lang == "en" { "List of Figures" } else {
    "Lijst van Figuren"
  }
  insert-figure-outline(title, target: image)
}
