#import "../utils/invisible-heading.typ": invisible-heading
#import "../utils/style.typ": 字号, 字体

// 本科生目录生成
#let bachelor-outline-page(
  // documentclass 传入参数
  twoside: false,
  fonts: (:),
  // 其他参数
  depth: 3,
  title: "目　　录",
  outlined: false,
  title-vspace: 0pt,
  title-text-args: auto,
  // 引用页数的字体，这里用于显示 Times New Roman
  reference-font: auto,
  reference-size: 字号.小四,
  // 字体与字号
  font: auto,
  size: (字号.小四,),
  // 垂直间距
  above: (1em,),
  below: (1em,),
  indent: (0pt, 2em, 2em),
  // 全都显示点号
  fill: (repeat(sym.dot.c, gap: 0.15em),),
  gap: .3em,
  ..args,
) = {
  // 1.  默认参数
  fonts = 字体 + fonts
  if title-text-args == auto {
    title-text-args = (font: fonts.黑体, size: 字号.小二)
  }
  // 引用页数的字体，这里用于显示 Times New Roman
  if reference-font == auto {
    reference-font = fonts.宋体
  }
  // 字体与字号
  if font == auto {
    font = (fonts.宋体, fonts.宋体)
  }

  // 2.  正式渲染
  pagebreak(weak: true, to: if twoside { "odd" })

  // 默认显示的字体
  set text(font: reference-font, size: reference-size)

  {
    set align(center)
    text(..title-text-args, title)
    v(10pt)
    // 标记一个不可见的标题用于目录生成
    invisible-heading(level: 1, outlined: outlined, title)
  }

  v(title-vspace)

  // 目录样式
  set outline(indent: level => indent.slice(0, calc.min(level + 1, indent.len())).sum())
  show outline.entry: entry => block(
    above: above.at(entry.level - 1, default: above.last()),
    below: below.at(entry.level - 1, default: below.last()),
    context [
      // TODO: Bad Practice: use hardcoded page number to determine if linebreak is needed
      #if (entry.level == 1 and entry.page().text == "1") or entry.body() in ([结论], ) {
        // 目录页不显示页码
        // query(label("linebreak-in-outline"))
        linebreak()
      }
      #link(
        entry.element.location(),
        [#entry.indented(
            none,
            {
              let body-font = font.at(entry.level - 1, default: font.last())
              if entry.prefix() in (none, []) { 
                body-font = ("Times New Roman", "SimHei", )
              }
              text(
                font: body-font,
                size: size.at(entry.level - 1, default: size.last()),
                {
                  if entry.prefix() not in (none, []) {
                    entry.prefix()
                    h(gap)
                  }
                  entry.body()
                },
              )
              text(font: "Times New Roman")[
                #box(width: 1fr, inset: (x: .25em), fill.at(entry.level - 1, default: fill.last()))
                #entry.page()
              ]
            },
            gap: 0pt,
          )
          // #if entry.body() in (text("ABSTRACT"),) { linebreak() }
        ],
      )
    ],
  )

  // 显示目录
  outline(title: none, depth: depth)

  // context {
  // let chapters = query(
  //   heading.where(
  //     outlined: true,
  //   )
  // )
  // for chapter in chapters {
  //   let loc = chapter.location()
  //   let nr = numbering(
  //     loc.page-numbering(),
  //     ..counter(page).at(loc),
  //   )
  //   let fill = box(width: 1fr, inset: (x: .25em), fill.at(chapter.level - 1, default: fill.last()))
  //   if chapter.level == 1 and counter(page).at(loc) == (1,) {
  //     // 目录页不显示页码
  //     linebreak()
  //   } else {
  //   }
  //   [#chapter.body #fill #nr \ ]
  // }
  // }
}
