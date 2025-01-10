#import "@preview/outrageous:0.1.0"
#import "../utils/invisible-heading.typ": invisible-heading
#import "../utils/style.typ": 字号, 字体
#import "../utils/custom-heading.typ": heading-content
#import "../utils/pagebreak-from-odd.typ": pagebreak-from-odd

// 本科生目录生成
#let bachelor-outline-page(
  // documentclass 传入参数
  doctype: "master",
  show-heading: false,
  twoside: false,
  fonts: (:),
  // 其他参数
  depth: 4,
  title: "目　　录",
  outlined: false,
  title-vspace: 0pt,
  title-text-args: auto,
  // 引用页数的字体，这里用于显示 Times New Roman
  reference-font: auto,
  reference-size: 字号.小四,
  // 字体与字号
  font: auto,
  size: (字号.四号, 字号.小四),
  weight: ("bold", "regular"),
  // 垂直间距
  vspace: (12pt, 12pt),
  indent: (0pt, 2.4em, 1.8em),
  // 全都显示点号
  fill: (auto,),
  ..args,
) = {
  // 1.  默认参数
  fonts = 字体 + fonts
  if (title-text-args == auto) {
    title-text-args = (font: fonts.宋体, size: 字号.三号, weight: "bold")
  }
  // 引用页数的字体，这里用于显示 Times New Roman
  if (reference-font == auto) {
    reference-font = fonts.宋体
  }
  // 字体与字号
  if (font == auto) {
    font = (fonts.黑体, fonts.宋体)
  }

  // 2.  正式渲染
  pagebreak-from-odd(twoside: twoside)

  set page(..(if show-heading {
    (header: {
      heading-content(doctype: doctype, fonts: fonts)
    })
  } else { () }))

  // 默认显示的字体
  set text(font: reference-font, size: reference-size)

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
      // 设置字体和字号
      set text(
        font: font.at(calc.min(level, font.len()) - 1),
        size: size.at(calc.min(level, size.len()) - 1),
      )
      // 计算缩进
      let indent-list = indent + range(level - indent.len()).map((it) => indent.last())
      let indent-length = indent-list.slice(0, count: level).sum()
      if "children" in it.fields() and it.children.len() > 2 {
        set text(weight: weight.at(calc.min(level, weight.len()) - 1))
        let (number, space, ..text) = it.children
        [#h(indent-length) #box[#number] #h(if level > 1 {3pt} else {2pt}) #text.join()]
      } else {
        set text(weight: weight.at(calc.min(level, weight.len()) - 1))
        h(indent-length) + it
      }
    },
    vspace: vspace,
    fill: fill,
    ..args,
  )

  // 显示目录
  outline(title: none, depth: depth)
}