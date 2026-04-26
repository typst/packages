#import "els-globals.typ": *
#import "@preview/subpar:0.2.2"

// Subfigures
#let subfigure = {
  subpar.grid.with(
    numbering: n => if isappendix.get() {numbering("A.1", counter(heading).get().first(), n)
      } else {
        numbering("1", n)
      },
    numbering-sub-ref: (m, n) => if isappendix.get() {numbering("A.1a", counter(heading).get().first(), m, n)
      } else {
        numbering("1a", m, n)
      }
  )
}

// Equations
#let nonumeq(body) = {
  set math.equation(numbering: none)
  body
}