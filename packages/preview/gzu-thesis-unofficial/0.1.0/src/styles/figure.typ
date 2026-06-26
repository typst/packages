#import "@preview/pointless-size:0.1.2": zh

#import "/src/fonts.typ"


#let figure-style(body) = {
  show figure.caption: set text(font: fonts.sans, size: zh(5))
  set figure(numbering: (n, ..) => numbering("1.1", counter(heading).get().first(), n))
  show heading.where(level: 1): it => counter(figure.where(kind: image)).update(0) + it
  show heading.where(level: 1): it => counter(figure.where(kind: table)).update(0) + it
  body
}
