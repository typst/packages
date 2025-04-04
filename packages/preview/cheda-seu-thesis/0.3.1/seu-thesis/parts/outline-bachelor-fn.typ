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
    if it.element.numbering == none and it.body.text.clusters().len() == 2 {
      link(it.element.location(), {
        it.body.text.clusters().first()
        h(2em)
        it.body.text.clusters().last()
      })
      h(3pt)
      box(repeat("."), width: 1fr)
      h(3pt)
      link(it.element.location(), {
        it.page
      })
      // 默认的 outline 中间没有链接，所以我也没加
    } else {
      it
    }
  }

  outline(title: none, depth: outline-depth, indent: 2em)
  // 如果要和 Word 模板完全一样，需要改成 indent: n => (n + 1) * 2em
}
