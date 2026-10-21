#import "@preview/i-figured:0.2.4"
#import "@preview/outrageous:0.3.0"
#import "../utils/invisible-heading.typ": invisible-heading
#import "../utils/style.typ": 字号, 字体
#import "../utils/custom-heading.typ": heading-content
#import "../utils/pagebreak-from-odd.typ": pagebreak-from-odd

// 表格目录生成
#let list-of-figures(
  // documentclass 传入参数
  doctype: "master",
  twoside: false,
  fonts: (:),
  // 其他参数
  title: "插图目录",
  outlined: true,
  title-vspace: 32pt,
  title-text-args: auto,
  // caption 的 separator
  separator: "   ",
  // 字体与字号
  font: auto,
  size: 字号.小四,
  // 垂直间距
  vspace: 1.2em,
  // 是否显示点号
  fill: auto,
  show-heading: false,
  ..args,
) = {
  // 1.  默认参数
  fonts = 字体 + fonts
  if (title-text-args == auto) {
    title-text-args = (font: fonts.宋体, size: 字号.三号, weight: "bold")
  }
  // 字体与字号
  if (font == auto) {
    font = fonts.宋体
  }

  // 2.  正式渲染
  pagebreak-from-odd(twoside: twoside)

  set page(..(if show-heading {(
    header: {
        heading-content(doctype: doctype, twoside: twoside, fonts: fonts)
      }
  )} else {()}))

  // 默认显示的字体
  set text(font: font, size: size)

  {
    // 标记一个不可见的标题用于目录生成
    invisible-heading(level: 1, outlined: outlined, title)
    set align(center)
    text(..title-text-args, title)
  }

  v(title-vspace)

  show outline.entry: it => {
    set block(spacing: vspace)
    it
  }

  // 显示目录
  i-figured.outline(target-kind: image, title: none)

}