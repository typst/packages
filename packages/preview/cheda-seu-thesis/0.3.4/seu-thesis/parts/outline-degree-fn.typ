#let outline-conf(outline-depth: 3, show-self-in-outline: true) = {
  set page(
    numbering: "I",
    number-align: center,
  )
  set par(first-line-indent: 0pt, leading: 10pt)

  heading(
    numbering: none,
    outlined: show-self-in-outline,
    bookmarked: true,
  )[目录]
  show outline.entry.where(level: 1): it => {
    v(1.2em, weak: true)
    strong(it)
  }
  outline(title: none, depth: outline-depth, indent: 2em)
}
