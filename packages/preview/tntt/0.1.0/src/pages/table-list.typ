#import "../utils/invisible-heading.typ": invisible-heading
#import "../font.typ": font-size, font-family

#import "../imports.typ": i-figured

// 表格目录生成
#let table-list(
  // documentclass 传入参数
  twoside: false,
  fonts: (:),
  // 其他参数
  title: "表格目录",
  outlined: false,
  title-vspace: 32pt,
  title-text-args: auto,
  // 字体与字号
  font: auto,
  size: font-size.小四,
  // 垂直间距
  above: 14pt,
  below: 14pt,
  ..args,
) = {
  // 1.  默认参数
  fonts = font-family + fonts
  if title-text-args == auto {
    title-text-args = (font: fonts.SongTi, size: font-size.三号, weight: "bold")
  }
  // 字体与字号
  if font == auto {
    font = fonts.SongTi
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
  i-figured.outline(target-kind: table, title: none)

  // 手动分页
  if twoside {
    pagebreak() + " "
  }
}
