#import "_globals.typ": *

// Appendix
#let appendix(body) = {
  set heading(numbering: "A.1.")
  // Reset heading counter
  counter(heading).update(0)

  // Equation numbering
  let numbering-eq = n => {
    let h1 = counter(heading).get().first()
    numbering("(A.1)", h1, n)
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