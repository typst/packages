#import "../utils/utils.typ": ziti, zihao

#let outline-conf(outline-depth: 3, show-self-in-outline: true) = {
  set page(
    numbering: "I",
    number-align: center,
    margin: (top: 3.5cm, bottom: 3.2cm, left: 3.2cm, right: 3.2cm),
  )
  set par(first-line-indent: 0pt, leading: 10pt)

  show heading.where(
    level: 1
  ): it => {
    set align(center)
    set text(font: ziti.黑体, size: zihao.小二, weight: "bold")
    it.body
  }

  heading(
    numbering: none,
    outlined: show-self-in-outline,
    bookmarked: true,
  )[目  录]
  v(1cm)
  show outline.entry.where(level: 1): it => {
    v(1.2em, weak: true)
    set text(font: ziti.宋体, size: zihao.四号, weight: "bold")
    strong(it)
  }
  outline(title: none, depth: outline-depth, indent: 0em)
}
