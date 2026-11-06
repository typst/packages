// Set/reset numbering in the given format for figures of different kinds, as well as equations
// Does NOT apply to figures with subfigures
#let set-figure-numbering(it, new-format: none) = {
  
  // Set chapter-relative numbering for images
  let image-numbering = super => numbering(new-format, counter(heading).get().first(), super)
  show heading.where(level: 1): it => it + counter(figure.where(kind: image)).update(0)
  show figure.where(kind: image): set figure(numbering: image-numbering)

  // Same for tables
  let table-numbering = super => numbering(new-format, counter(heading).get().first(), super)
  show heading.where(level: 1): it => it + counter(figure.where(kind: table)).update(0)
  show figure.where(kind: table): set figure(numbering: table-numbering)
  
  // Same for code snippets
  let code-numbering = super => numbering(new-format, counter(heading).get().first(), super)
  show heading.where(level: 1): it => it + counter(figure.where(kind: raw)).update(0)
  show figure.where(kind: raw): set figure(numbering: code-numbering)
  
  // Same for algorithms
  let algorithm-numbering = super => numbering(new-format, counter(heading).get().first(), super)
  show heading.where(level: 1): it => it + counter(figure.where(kind: "algorithm")).update(0)
  show figure.where(kind: "algorithm"): set figure(numbering: algorithm-numbering)
  
  // Same for equations
  let equation-numbering = super => numbering("("+new-format+")", counter(heading).get().first(), super)
  show heading.where(level: 1): it => it + counter(math.equation).update(0)
  set math.equation(numbering: equation-numbering)

  it
}
