#let bibliography-page(bib) = {
  set heading(
    numbering: none,
    outlined: true,
  )

  bib

  pagebreak(weak: true, to: "odd")
}
