#import "../utils/style.typ": ziti, zihao
#import "../utils/header.typ": no-numbering-page-header
#import "../utils/heading.typ": no-numbering-first-heading

#let preface(
  doctype: "master",
  twoside: false,
  it,
) = {
  show footnote.entry: set text(font: ziti.songti, size: zihao.xiaowu)

  show: no-numbering-page-header.with(doctype: doctype, twoside: twoside)
  show: no-numbering-first-heading

  set page(header-ascent: 0.5cm)
  set par(justify: true)
  set page(numbering: "I")
  counter(page).update(1)

  set figure.caption(separator: [#h(1em)])
  show figure.where(kind: "image"): set text(size: zihao.wuhao, weight: "bold")
  show figure.where(kind: "image-en"): set text(size: zihao.wuhao, weight: "bold")
  show figure.where(kind: "table"): set text(size: zihao.wuhao, weight: "bold")
  show figure.where(kind: "table-en"): set text(size: zihao.wuhao, weight: "bold")
  show figure.where(kind: "table"): set figure.caption(position: top)
  show figure.where(kind: "table-en"): set figure.caption(position: top)
  show figure: set block(breakable: true)
  let xubiao = state("xubiao")

  show table: set text(size: zihao.wuhao, weight: "regular")
  show table: set par(leading: 14pt)
  set table(stroke: (x, y) => {
    if y == 0 {
      none
    } else {
      none
    }
  })
  show table: it => xubiao.update(false) + it

  set math.equation(supplement: [公式])

  set text(font: ziti.songti, size: zihao.xiaosi)
  set par(first-line-indent: 2em, leading: 16pt, spacing: 16pt)

  it
}