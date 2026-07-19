#let bibliography-page(bib) = {
  set heading(
    numbering: none,
    outlined: true,
  )
  counter(heading).update(0)

  bib

  pagebreak(weak: true, to: "odd")
}
