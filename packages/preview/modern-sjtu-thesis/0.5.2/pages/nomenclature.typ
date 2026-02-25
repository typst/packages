#import "../utils/style.typ": zihao, ziti

#let nomenclature-page(
  twoside: false,
  width: 80%,
  columns: 2,
  column-gutter: 2em,
  info: (:),
  title: "符号对照表",
  body,
) = {
  set text(font: ziti.songti, size: zihao.xiaosi)
  set par(first-line-indent: 2em, leading: 16pt, spacing: 16pt)

  heading(level: 1, outlined: false)[#title]

  align(center, block(
    width: width,
    grid(
      align: (right, left),
      columns: columns,
      row-gutter: 16pt,
      column-gutter: column-gutter,
      // 解析 terms 内部结构以渲染到表格里
      ..body.children.filter(it => it.func() == terms.item).map(it => (it.term, it.description)).flatten()
    ),
  ))

  pagebreak(
    weak: true,
    to: if twoside {
      "odd"
    },
  )
}

#let nomenclature-table(
  twoside: false,
  width: 80%,
  columns: 2,
  column-gutter: 2em,
  info: (:),
  body,
) = {
  set text(font: ziti.songti, size: zihao.xiaosi)
  set par(first-line-indent: 2em, leading: 16pt, spacing: 16pt)

  align(center, block(
    width: width,
    grid(
      align: (right, left),
      columns: columns,
      row-gutter: 16pt,
      column-gutter: column-gutter,
      // 解析 terms 内部结构以渲染到表格里
      ..body.children.filter(it => it.func() == terms.item).map(it => (it.term, it.description)).flatten()
    ),
  ))
}
