#import "@preview/subpar:0.2.0"

#let sub-figure-numbering = (super, sub) => numbering("1.1a", counter(heading).get().first(), super, sub)
#let figure-numbering = super => numbering("1.1", counter(heading).get().first(), super)
#let equation-numbering = super => numbering("(1.1)", counter(heading).get().first(), super)

#set heading(numbering: "1.1")
// #show heading.where(level: 1): it => {
//   counter(math.equation).update(0)
//   counter(figure.where(kind: image)).update(0)
//   counter(figure.where(kind: table)).update(0)
//   counter(figure.where(kind: raw)).update(0)
//   it
// }
// #show figure: set figure(numbering: figure-numbering)
// #show math.equation: set math.equation(numbering: equation-numbering)

#let subpar-grid = subpar.grid.with(
  numbering: figure-numbering,
  numbering-sub-ref: sub-figure-numbering,
)