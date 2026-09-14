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

// Create a dictionary for authors
#let create-dict(default-dict, user-dict) = {
  let new-dict = default-dict
    for (key, value) in user-dict {
      if key in default-dict.keys() {
        new-dict.insert(key, value)
      }
    }

  return new-dict
}
