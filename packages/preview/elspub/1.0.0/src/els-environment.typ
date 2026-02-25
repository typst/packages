#import "els-globals.typ": *
#import "@preview/subpar:0.2.2"

// Appendix
#let appendix(body) = {
  set heading(numbering: "A.1.", supplement: [Appendix])
  // Reset heading counter
  counter(heading).update(0)

  // Equation numbering
  let numbering-eq = (..n) => {
    let h1 = counter(heading).get().first()
    numbering("(A.1a)", h1, ..n)
  }
  set math.equation(numbering: numbering-eq)

  // Figure and Table numbering
  let numbering-fig = n => {
    let h1 = counter(heading).get().first()
    numbering("A.1", h1, n)
  }
  show figure.where(kind: image): set figure(numbering: numbering-fig)
  show figure.where(kind: table): set figure(numbering: numbering-fig)

  isappendix.update(true)

  body
}

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