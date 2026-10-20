/// Bibliography.
///
/// CHANGED: `to` is now a parameter. 0.1.0 always forced the bibliography onto
/// an odd page, which inserts a blank filler page in a one-sided document.
/// lib.typ passes "odd" only when the document is actually two-sided.
///
/// CHANGED: links are no longer forced to pink. They inherit `link-color`,
/// which defaults to black, as in kulemt.
/// -> content
#let insert-bibliography(bib, lang: "en", to: none) = {
  if bib != none {
    show heading: it => {
      pagebreak(to: to, weak: true)
      pad(top: 1em + 35mm, bottom: 2em, text(size: 1.7em)[#it.body])
    }
    heading(
      level: 1,
      numbering: none,
      if lang == "en" { "Bibliography" } else { "Bibliografie" },
      outlined: true,
    )
    set bibliography(title: none)
    set par(spacing: 1em)
    show bibliography: set text(size: 0.9em)
    bib
  }
}
