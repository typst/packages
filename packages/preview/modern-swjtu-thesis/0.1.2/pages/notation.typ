#let notation(
  twoside: false,
  title: "符号表",
  outlined: true,
  width: 350pt,
  columns: (60pt, 1fr),
  row-gutter: 16pt,
  ..args,
  body,
) = {
  heading(
    level: 1,
    numbering: none,
    outlined: outlined,
    title
  )

  align(center, block(width: width,
    align(start, grid(
      columns: columns,
      row-gutter: row-gutter,
      ..args,
      // 解析 terms 内部结构以渲染到表格里
      ..body.children
        .filter(it => it.func() == terms.item)
        .map(it => (it.term, it.description))
        .flatten()
    ))
  ))

  // 手动分页
  if twoside {
    pagebreak() + " "
  }
}