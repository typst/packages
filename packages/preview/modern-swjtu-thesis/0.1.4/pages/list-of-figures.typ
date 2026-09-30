#import "@preview/i-figured:0.2.4"
#import "../utils/invisible-heading.typ": invisible-heading
#import "../utils/style.typ": 字号, 字体

// 表格目录生成
#let list-of-figures(
  // documentclass 传入参数
  twoside: false,
  fonts: (:),
  // 其他参数
  title: "插图目录",
  outlined: false,
  title-vspace: 32pt,
  title-text-args: auto,
  // 字体与字号
  font: auto,
  size: 字号.小四,
  // 垂直间距
  above: 14pt,
  below: 14pt,
  ..args,
) = {
  // 1.  默认参数
  fonts = 字体 + fonts
  if title-text-args == auto {
    title-text-args = (font: fonts.宋体, size: 字号.三号, weight: "bold")
  }
  // 字体与字号
  if font == auto {
    font = fonts.宋体
  }

  // 2.  正式渲染
  pagebreak(weak: true, to: if twoside { "odd" })

  // 默认显示的字体
  set text(font: font, size: size)

  {
    set align(center)
    text(..title-text-args, title)
    // 标记一个不可见的标题用于目录生成
    invisible-heading(level: 1, outlined: outlined, title)
  }

  v(title-vspace)

  show outline.entry: set block(
    above: above,
    below: below,
  )

  // 显示目录
  i-figured.outline(target-kind: image, title: none)

  // 手动分页
  if twoside {
    pagebreak() + " "
  }
}