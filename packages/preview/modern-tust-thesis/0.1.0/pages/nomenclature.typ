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
  pagebreak()
  set text(font: ziti.songti, size: zihao.xiaosi)
  set par(first-line-indent: 2em, leading: 16pt, spacing: 16pt)

  // 标题样式参考正文章节标题
  show heading.where(level: 1): it => {
    set text(font: ziti.heiti, weight: "bold", size: zihao.xiaosan)
    set par(first-line-indent: 0em, leading: 20pt)
    set align(center)
    v(40pt)
    it.body
    v(20pt)
  }
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
