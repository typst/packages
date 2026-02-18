#import "../utils/style.typ":*

#let notation(
  twoside: false,
  doctype: "bachelor",
  title: "符号和缩略语说明",
  outlined: true,
  numbering: "1",
  width: 350pt,
  columns: (60pt, 1fr),
  row-gutter: 16pt,
  ..args,
  body,
) = {
  pagebreak()
  set text(font:字体.宋体, size: 字号.小四)
  import "@preview/hydra:0.6.0": hydra
  let header = ""
  if doctype == "master" or doctype == "doctor" {
    header = context {
    set par(leading:0pt,spacing:0pt)
    align(center, emph(hydra(1,skip-starting: false)))
    v(3pt)
    line(length: 100%, stroke:2pt)
    v(3pt)
    line(length: 100%, stroke: 1pt)
  }
  } else {
  }

  set page(paper: "a4",numbering: "1", header: header,
)
  if doctype == "master" or doctype == "doctor" {
    numbering = "I"
  }
  set page(numbering: numbering)
  align(center)[#text(font:字体.黑体,heading(
    level: 1,
    numbering: none,
    outlined: outlined,
    title
  )),
  ]

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
  if (twoside) {
    pagebreak() + " "
  }
}