#import "../utils/style.typ": 字号, 字体
#import "../utils/custom-heading.typ": heading-content
#import "../utils/invisible-heading.typ": invisible-heading
#import "../utils/pagebreak-from-odd.typ": pagebreak-from-odd

#let notation(
  twoside: false,
  doctype: "master",
  title: "符号表",
  fonts: (:),
  font: auto,
  title-text-args: auto,
  size: 字号.小四,
  outlined: true,
  width: 350pt,
  columns: (60pt, 1fr),
  row-gutter: 16pt,
  show-heading: false,
  title-vspace: 32pt,
  ..args,
  body,
) = {

  fonts = 字体 + fonts
  if (title-text-args == auto) {
    title-text-args = (font: fonts.宋体, size: 字号.三号, weight: "bold")
  }
  // 字体与字号
  if (font == auto) {
    font = fonts.宋体
  }

  pagebreak-from-odd(twoside: twoside)

  set page(..(if show-heading {(
    header: {
      heading-content(doctype: doctype, fonts: fonts)
    }
  )} else {()}))

  // 默认显示的字体
  set text(font: font, size: size)

  {
    set align(center)
    text(..title-text-args, title)
    // 标记一个不可见的标题用于目录生成
    invisible-heading(level: 1, outlined: outlined, title)
  }

  v(title-vspace)

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

}