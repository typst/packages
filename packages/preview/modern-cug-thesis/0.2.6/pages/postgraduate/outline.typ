#import "../../utils/invisible-heading.typ": invisible-heading
#import "../../utils/style.typ": 字号, 字体

// 目录生成
#let postgraduate-outline(
  // documentclass 传入参数
  twoside: false,
  fonts: (:),
  // 其他参数
  depth: 4,
  title: "目　　录",
  outlined: false,
  title-vspace: 1em,
  title-text-args: auto,
  // 引用页数的字体，这里用于显示 Times New Roman
  reference-font: auto,
  reference-size: 字号.小四,
  // 字体与字号
  font: auto,
  size: (字号.四号, 字号.小四, 字号.小四),
  // 垂直间距
  above: (20pt-1em, 20pt-1em, 20pt-1em, 20pt-1em),
  below: (20pt-1em, 20pt-1em, 20pt-1em, 20pt-1em),
  indent: (0pt, 1em, 2em,),
  // 全都显示点号
  fill: (repeat([.], gap: 0.15em),),
  gap: .3em,
  ..args,
) = {
  // 1.  默认参数
  fonts = 字体 + fonts
  if title-text-args == auto {
    title-text-args = (
      font: fonts.黑体, 
      size: 字号.三号, 
      weight: "bold",
      bottom-edge: 0em, top-edge: 1.0em,
    )
  }
  // 引用页数的字体，这里用于显示 Times New Roman
  if reference-font == auto {
    reference-font = fonts.宋体
  }
  // 字体与字号
  if font == auto {
    font = (fonts.宋体, fonts.宋体, fonts.宋体)
  }

  // 2.  正式渲染

  // 默认显示的字体
  set text(font: reference-font, size: 1.0em)

  {
    set align(center)
    // set par(spacing: 1em)
    text(..title-text-args, title)
    // 标记一个不可见的标题用于目录生成
    invisible-heading(level: 1, outlined: outlined, title)
  }

  v(title-vspace)

  // 目录样式
  set outline(indent: level => indent.slice(0, calc.min(level + 1, indent.len())).sum())
  show outline.entry: entry => block(
    above: above.at(entry.level - 1, default: above.last()),
    below: below.at(entry.level - 1, default: below.last()),
    
    link(
      entry.element.location(),
      entry.indented(
        none,
        {
          text(
            font: font.at(entry.level - 1, default: font.last()),
            size: size.at(entry.level - 1, default: size.last()),
            bottom-edge: 0em, top-edge: 1.0em,
            {
              if entry.prefix() not in (none, []) {
                entry.prefix()
                h(gap)
              }
              entry.body()
            },
          )
          box(width: 1fr, inset: (x: .25em), fill.at(entry.level - 1, default: fill.last()))
          entry.page()
        },
        gap: 0pt,
      ),
    ),
  )

  // 显示目录
  outline(title: none, depth: depth)
  pagebreak(weak: true) //换页
  if twoside {
    pagebreak() // 空白页
  }
}