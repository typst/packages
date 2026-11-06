#import "@preview/i-figured:0.2.4"
#import "@preview/outrageous:0.1.0"
#import "../utils/invisible-heading.typ": invisible-heading
#import "../utils/style.typ": 字号, 字体

// 表格目录生成
#let list-of-figures(
  // documentclass 传入参数
  twoside: false,
  fonts: (:),
  // 其他参数
  title: "插图索引",
  outlined: false,
  title-vspace: 32pt,
  title-text-args: auto,
  // caption 的 separator
  separator: "  ",
  // 字体与字号
  font: auto,
  size: 字号.小四,
  // 垂直间距
  vspace: 14pt,
  // 是否显示点号
  fill: auto,
  ..args,
) = {
  // 1.  默认参数
  fonts = 字体 + fonts
  if (title-text-args == auto) {
    title-text-args = (font: fonts.黑体, size: 字号.三号,weight:"bold")
  }
  // 字体与字号
  if (font == auto) {
    font = fonts.宋体
  }

  // 2.  正式渲染
  pagebreak(weak: true)

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
  i-figured.outline(target-kind: image, title: none)

  // 手动分页
  if twoside {
    pagebreak()
    counter(page).update(n => { (n - 1) })
    set page(numbering: none,)
    ""
  }
}