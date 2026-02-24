#import "../utils/utils.typ": ziti, zihao

#let outline-conf(outline-depth: 3, show-self-in-outline: true) = {
  set page(
    numbering: "I",
    number-align: center,
    margin: (top: 3.5cm, bottom: 3.2cm, left: 3.2cm, right: 3.2cm),
  )
  set par(first-line-indent: 0pt, leading: 1.2em)

  heading(
    numbering: none,
    outlined: show-self-in-outline,
    bookmarked: true,
  )[目  录]
  v(1cm)
  show outline.entry.where(level: 1): it => {
    v(1.2em, weak: true)
    set text(font: ziti.宋体, size: zihao.小四, weight: "bold")
    strong(it)
  }
  outline(title: none, depth: outline-depth, indent: 2em)
}
