// #import "@preview/i-figured:0.2.4"
#import "@preview/outrageous:0.1.0"
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
  title-vspace: 18pt,
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
    title-text-args = (font: fonts.黑体, size: 字号.小二, weight: "regular")
  }
  // 字体与字号
  if (font == auto) {
    font = fonts.宋体
  }

  // 2.  正式渲染
  pagebreak(weak: true, to: if twoside { "odd" })

  // 默认显示的字体
  set text(font: font, size: size)
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
  if (twoside) {
    pagebreak() + " "
  }
}