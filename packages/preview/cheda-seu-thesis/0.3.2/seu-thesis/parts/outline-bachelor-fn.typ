#let outline-conf(outline-depth: 3, show-self-in-outline: true) = {
  set page(
    numbering: "I",
    number-align: center,
  )
  set par(first-line-indent: 0pt, leading: 13.84pt)
  // 试出来的数值

  heading(
    numbering: none,
    outlined: show-self-in-outline,
    bookmarked: true,
  )[目录]

  v(3pt)

  show outline.entry.where(level: 1): it => {
    if it.element.numbering == none and it.element.body.text.clusters().len() == 2 {
      show regex("\p{script=Han}{2}"): it => {
        it.text.first()
        h(2em)
        it.text.last()
      }
      it
    } else { it }
  }

  outline(title: none, depth: outline-depth, indent: 2em)
  // 如果要和 Word 模板完全一样，需要改成 indent: n => (n + 1) * 2em
}
