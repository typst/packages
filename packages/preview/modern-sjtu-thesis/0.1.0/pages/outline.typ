#import "../utils/style.typ": ziti, zihao
#import "@preview/outrageous:0.1.0"

#let outline-page(
  twoside: false,
  info: (:),
) = {
  set par(first-line-indent: 2em)

  show outline.entry: outrageous.show-entry.with(
    ..outrageous.presets.typst,
    font-weight: ("bold", auto),
  )

  context outline(
    title: [目#h(1em)录],
    target: selector(heading).after(here()),
    indent: 2em,
    depth: 3,
  )

  pagebreak(
    weak: true,
    to: if twoside {
      "odd"
    },
  )
}