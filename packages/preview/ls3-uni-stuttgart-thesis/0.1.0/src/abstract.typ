// abstract.typ
//
// Abstract and Kurzfassung chapter helpers. Unnumbered. Both added to TOC.

// English Abstract chapter. Pass content via the `body` argument.
#let abstract-en(body) = {
  heading(level: 1, numbering: none, outlined: true)[Abstract]
  body
}

// German Kurzfassung chapter. Pass content via the `body` argument.
#let abstract-de(body) = {
  heading(level: 1, numbering: none, outlined: true)[Kurzfassung]
  body
}
