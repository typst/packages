#import "../utils/invisible-heading.typ": invisible-heading
#import "../font.typ": font-size, font-family

// 本科生目录生成
#let outline-config(
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
  reference-size: font-size.小四,
  // 字体与字号
  font: auto,
  size: (font-size.四号, font-size.小四),
  // 垂直间距
  above: (25pt, 14pt),
  below: (14pt, 14pt),
  indent: (0pt, 18pt, 28pt),
  // 全都显示点号
  fill: (repeat([.], gap: 0.15em),),
  gap: .3em,
  ..args,
) = {
  // 1.  默认参数
  fonts = font-family + fonts
  if title-text-args == auto {
    title-text-args = (font: fonts.SongTi, size: font-size.三号, weight: "bold")
  }
  // 引用页数的字体，这里用于显示 Times New Roman
  if reference-font == auto {
    reference-font = fonts.SongTi
  }
  // 字体与字号
  if font == auto {
    font = (fonts.HeiTi, fonts.SongTi)
  }

  // 2.  正式渲染
  pagebreak(weak: true, to: if twoside { "odd" })

  // 默认显示的字体
  set text(font: reference-font, size: reference-size)

  {
    set align(center)
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
}
