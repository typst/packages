// SCUT 表格目录
#import "@preview/i-figured:0.2.4"
#import "../utils/invisible-heading.typ": invisible-heading
#import "../utils/section-break.typ": section-break
#import "../utils/outline-cite.typ": outline-cite
#import "../utils/style.typ": 字号, 字体, 章标题字体, 章标题字号

#let list-of-tables(
  open-right: false,
  fonts: (:),
  title: "表格目录",
  outlined: false,
  title-vspace: 18pt,
  title-text-args: auto,
  font: auto,
  size: 字号.小四,
  above: 14pt,
  below: 14pt,
  ..args,
) = {
  fonts = 字体 + fonts
  if title-text-args == auto {
    title-text-args = (font: 章标题字体, size: 章标题字号, weight: "bold")
  }
  if font == auto {
    font = fonts.宋体
  }

  section-break(open-right: open-right)

  set text(font: font, size: size)

  {
    set align(center)
    text(..title-text-args, title)
    invisible-heading(level: 1, outlined: outlined, title)
  }

  v(title-vspace)

  show outline.entry: set block(
    above: above,
    below: below,
  )

  // 目录条目不登记引用：图题中的 @cite 显示为正文顺序编号文本，不参与编号
  show cite: outline-cite

  i-figured.outline(target-kind: table, title: none)
}
