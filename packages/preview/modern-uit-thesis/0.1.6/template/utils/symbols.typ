// TeX and LaTeX logos
#let TeX = {
  set text(font: "New Computer Modern", weight: "regular")
  box(
    width: 1.7em,
    {
      [T]
      place(top, dx: 0.56em, dy: 0.22em)[E]
      place(top, dx: 1.1em)[X]
    },
  )
}

#let LaTeX = {
  set text(font: "New Computer Modern", weight: "regular")
  box(
    width: 2.55em,
    {
      [L]
      place(top, dx: 0.3em, text(size: 0.7em)[A])
      place(top, dx: 0.7em)[#TeX]
    },
  )
}

#let BibTeX = {
  set text(font: "New Computer Modern", weight: "regular")
  box(
    width: 3.4em,
    {
      [Bib]
      place(top, dx: 1.5em)[#TeX]
    },
  )
}
