#import "@preview/i-figured:0.1.0"
#import "@preview/outrageous:0.1.0"
#import "../utils/invisible-heading.typ": invisible-heading
#import "../utils/style.typ": 字号, 字体
#import "../utils/custom-heading.typ": heading-content
#import "../utils/pagebreak-from-odd.typ": pagebreak-from-odd

// 表格目录生成
#let list-of-tables(
  // documentclass 传入参数
  doctype: "master",
  twoside: false,
  fonts: (:),
  // 其他参数
  title: "表格目录",
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

  show outline.entry: outrageous.show-entry.with(
    // 保留 Typst 基础样式
    ..outrageous.presets.typst,
    body-transform: (level, it) => {
      // 因为好像没找到 separator 的参数，所以这里就手动寻找替换了
      if (it.has("children") and it.children.at(3, default: none) == [#": "]) {
        it.children.slice(0, 3).sum() + separator + it.children.slice(4).sum()
      } else {
        it
      }
    },
    vspace: (vspace,),
    fill: (fill,),
  )

  // 显示目录
  i-figured.outline(target-kind: table, title: none)

}