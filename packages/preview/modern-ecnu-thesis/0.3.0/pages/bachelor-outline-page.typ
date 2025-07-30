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
      heading-content(doctype: doctype, twoside: twoside, fonts: fonts)
    })
  } else { () }))

  // 默认显示的字体
  set text(font: reference-font, size: reference-size)

  {
    set align(center)
    // 标记一个不可见的标题用于目录生成
    invisible-heading(level: 1, outlined: outlined, title)
    text(..title-text-args, title)

  }

  v(title-vspace)

  let array-at(arr, pos) = {
    arr.at(calc.min(pos, arr.len()) - 1)
  }

  show outline.entry.where(level: 1): it => link(
    it.element.location(),
    it.indented(
      if it.prefix() != none and repr(it.prefix()).len() > 2 {
        text(font: fonts.黑体, size: array-at(size, 0), it.prefix())
      } else { none },
      {
      text(font: fonts.黑体, size: array-at(size, 0), it.body())
      [ ]
      box(width: 1fr, it.fill)
      [ ]
      it.page()
    })
  )

  show outline.entry: it => {
    set block(spacing: array-at(vspace, it.level - 1))
    // if it.prefix() != none {it.prefix()} else { block(it) }
    it
  }

  // 显示目录
  outline(title: none, depth: depth, indent: auto)
}