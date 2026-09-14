#import "../utils/style.typ": ziti, zihao

#let outline-page(
  doctype: "master",
  twoside: false,
  info: (:),
) = {
  set par(first-line-indent: 2em)

  show outline.entry.where(level: 1): set text(weight: "bold")

  context outline(
    title: [目#h(1em)录],
    target: if doctype == "bachelor" {
      selector(heading)
    } else {
      selector(heading).after(here())
    },
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
