
// Bibliography
#let insert-bibliography(bib, lang: "en") = {
  if bib != none {
    show heading: it => {
      pagebreak(to: "odd", weak: true)
      pad(top: 1em + 35mm, bottom: 2em, text(
        size: 1.7em,
      )[#it.body])
    }
    heading(
      level: 1,
      numbering: none,
      if lang == "en" {
        "Bibliography"
      } else {
        "Bibliografie"
      },
      outlined: true,
    )
    set bibliography(title: none)
    set par(spacing: 1em)
    show bibliography: set text(size: 0.9em)
    show link: it => text(fill: rgb(238, 34, 153), weight: "semibold")[#it]
    bib
  }
}
