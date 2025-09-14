#import "../utils/style.typ": font_family, font_size
#import "../utils/invisible-heading.typ": invisible-heading

//! 符号和缩略语说明
//! 1. 标题: 黑体三号，居中无缩进，大纲级别1级，段前48磅，段后24磅，1.5倍行距。
//! 2. 内容: 中文字体为宋体，英文和数字为Times New Roman字体，小四号，大纲级别正文文本，两端对齐，首行无缩进，段前0行，段后0行，1.5倍行距。说明部分尽量上下对齐。
#let notation(
  // thesis 传入参数
  twoside: false,
  fonts: (:),
  // 其他参数
  title: "符号和缩略语说明",
  title-vspace: 24pt,
  title-text-args: auto,
  outlined: true,
  width: 85%,
  columns: (70pt, 1fr),
  row-gutter: 16pt,
  ..args,
  body,
) = {
  // 1.  默认参数
  fonts = font_family + fonts
  if title-text-args == auto {
    title-text-args = (font: fonts.黑体, size: font_size.三号, weight: "bold")
  }

  // 2.  正式渲染
  pagebreak(weak: true, to: if twoside { "odd" })

  // 默认显示的字体
  set text(font: fonts.宋体, size: font_size.小四)

  v(48pt)
  {
    set align(center)
    set par(leading: 1.5em)
    text(..title-text-args, title)
    // 标记一个不可见的标题用于目录生成
    invisible-heading(level: 1, outlined: outlined, title)
  }
  v(title-vspace)

  set par(justify: true, leading: 1.5em)
  align(start, block(width: width, align(start, grid(
    columns: columns,
    row-gutter: row-gutter,
    ..args,
    // 解析 terms 内部结构以渲染到表格里
    ..body.children.filter(it => it.func() == terms.item).map(it => (it.term, it.description)).flatten()
  ))))
}
