#import "@preview/pointless-size:0.1.2": zh

#import "/src/fonts.typ": *


#let outline-page() = {
  set text(font: songti, size: zh(4.5))
  set page(numbering: "I")
  set par(leading: 1.25em)
  set align(center)

  outline(
    depth: 3,
    title: text(font: heiti, size: zh(3), weight: "bold")[目录],
  )

  pagebreak()
}
