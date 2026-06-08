#let setup-thanks(body) = {
  import "font_config.typ": *

  pagebreak(weak: true) //假设当前页面并没有包含任何内容,pagebreak(weak: true)不会创建新的页面
  show heading.where(level: 2): it => {
    set align(center)
    set text(font: 黑体, size: 三号)
    it
  }

  heading(level: 2, numbering: none)[致#h(1em)谢]

  v(三号)

  set text(size: 小四)
  set par(
    justify: true,
    first-line-indent: (amount: 2em, all: true),
    leading: 0.975em,
    linebreaks: "simple",
  ) // 两端对齐，段前缩进2字符
  body
}
