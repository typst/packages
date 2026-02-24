#import "@preview/i-figured:0.2.4"
#import "../utils/invisible-heading.typ": invisible-heading
#import "../utils/style.typ": font-family, font-size

//! 附表目录
//! 1. 标题: 黑体，三号，居中无缩进，大纲级别一级，段前48磅，段后24磅，1.5倍行距。
//! 2. 内容: 中文字体为宋体，英文和数字为Times New Roman字体，小四号，两端对齐无缩进，段前0行，段后0行，1.5倍行距。

#let list-of-tables(
  // thesis 传入参数
  twoside: false,
  fonts: (:),
  // 其他参数
  title: "附表目录",
  outlined: true,
  title-vspace: 24pt,
  title-text-args: auto,
  // 字体与字号
  font: auto,
  size: font-size.小四,
  // 垂直间距
  above: 6pt,
  below: 16pt,
  ..args,
) = {
  // 1.  默认参数
  fonts = font-family + fonts
  if title-text-args == auto {
    title-text-args = (font: fonts.黑体, size: font-size.三号, weight: "bold")
  }
  // 字体与字号
  if font == auto {
    font = fonts.宋体
  }

  // 2.  正式渲染
  pagebreak(weak: true, to: if twoside { "odd" })

  // 默认显示的字体
  set text(font: font, size: size)

  v(48pt)
  {
    set align(center)
    set par(leading: 1.5em)
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
  i-figured.outline(target-kind: table, title: none)

  // 手动分页
  if twoside {
    pagebreak() + " "
  }
}
