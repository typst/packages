#let math-style(body) = {
  set math.equation(numbering: (n, ..) => numbering("(1-1)", counter(heading).get().first(), n))
  show heading.where(level: 1): it => counter(math.equation).update(0) + it
  body
}
