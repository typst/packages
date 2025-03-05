// #import "@preview/i-figured:0.2.4"
#import "../../utils/invisible-heading.typ": invisible-heading
#import "../../utils/style.typ": 字号, 字体

// 表格目录生成
#let list-of-figures-tables(
  // documentclass 传入参数
  twoside: false,
  fonts: (:),
  // 其他参数
  title-figures: "图清单",
  title-tables: "表清单",
  outlined: false,
  title-vspace: 1em,
  title-text-args: auto,
  // 字体与字号
  font: auto,
  size: 字号.小四,
  // 垂直间距
  above: 20pt-1em,
  below: 20pt-1em,
  ..args,
) = {
  // 1.  默认参数
  fonts = 字体 + fonts
  if title-text-args == auto {
    title-text-args = (font: fonts.黑体, size: 字号.小二, weight: "regular", bottom-edge: 0em, top-edge: 1.0em)
  }
  // 字体与字号
  if font == auto {
    font = fonts.宋体
  }

  // 2.  正式渲染
  // 默认显示的字体
  set text(font: font, size: size, bottom-edge: 0em, top-edge: 1.0em)
  show outline.entry: set block(
    above: above,
    below: below,
  )

  // 显示图清单
  {
    v(title-vspace)
    set align(center)
    text(..title-text-args, title-figures)
    // 标记一个不可见的标题用于目录生成
    invisible-heading(level: 1, outlined: outlined, title-figures)
    v(title-vspace)
  }
  outline(target: figure.where(kind: image), title: none)

  // 显示表清单
  v(title-vspace)
  { 
    v(title-vspace)
    set align(center)
    text(..title-text-args, title-tables)
    // 标记一个不可见的标题用于目录生成
    invisible-heading(level: 1, outlined: outlined, title-tables)
    v(title-vspace)
  }

  v(title-vspace)
  outline(target: figure.where(kind: table), title: none)

  // 手动分页
  pagebreak(weak: true) //换页
  if twoside {
    pagebreak() // 空白页
  }
}