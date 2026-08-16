#import "@preview/pointless-size:0.1.2": zh

#import "/src/fonts.typ": *


#let abstract(
  abstract-zh: [],
  keywords-zh: (),
  abstract-en: [],
  keywords-en: (),
) = {
  set page(numbering: "I")
  counter(page).update(1)

  set par(leading: 1.28em, spacing: 1.28em)

  align(center)[
    #set text(font: heiti, size: 16pt, weight: "bold")
    #block(above: 1em, below: 1.7em)[摘要]
  ]

  set text(size: 12pt)
  text(font: songti, abstract-zh)

  v(1em)
  par(first-line-indent: 0em)[
    #text(font: heiti, weight: "bold")[关键词：]
    #text(font: songti, keywords-zh.join(h(1.5em)))
  ]

  pagebreak()

  set text(font: "Times New Roman")
  align(center)[
    #set text(size: 16pt, weight: "bold")
    #block(above: 1em, below: 1.7em)[Abstract]
  ]

  set text(size: 12pt)
  abstract-en

  v(1em)
  par(first-line-indent: 0em)[
    #text(font: heiti, weight: "bold")[Key Words:]
    #text(font: songti, keywords-en.join(h(1.5em)))
  ]

  pagebreak()
}
