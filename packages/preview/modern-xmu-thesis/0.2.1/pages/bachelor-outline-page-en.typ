#import "../utils/invisible-heading.typ": invisible-heading
#import "../utils/style.typ": 字号, 字体
#import "@preview/numbly:0.1.0": numbly

// 本科生英文目录
#let bachelor-outline-page-en(
  // documentclass 传入参数
  twoside: false,
  fonts: (:),
  // 其他参数
  depth: 3,
  title: "Contents",
  entry-numbering: ("Chapter {1}",),
  outlined: false,
  title-vspace: 14pt,
  title-text-args: auto,
  // 引用页码字体与字号
  reference-font: auto,
  reference-size: 字号.小四,
  // 字体与字号
  font: auto,
  size: (字号.四号, 字号.小四),
  weight: ("bold", "bold", "regular"),
  // 目录样式
  above: (20pt, 14pt),
  below: (14pt, 14pt),
  indent: (0pt, 18pt, 28pt),
  fill: (repeat([.], gap: 0.15em),),
  gap: .3em,
) = {
  // 1.  默认参数
  fonts = 字体 + fonts
  if title-text-args == auto {
    title-text-args = (font: fonts.宋体, size: 字号.小三, weight: "bold")
  }
  if reference-font == auto {
    reference-font = fonts.宋体
  }
  if font == auto {
    font = (fonts.宋体, fonts.宋体, fonts.宋体)
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
            weight: weight.at(entry.level - 1, default: weight.last()),
            {
              if entry.prefix() not in (none, []) and entry.element.numbering != none {
                let enentry-numbering-len = entry-numbering.len()
                let used-numbering = if entry.element.level <= enentry-numbering-len {
                  numbly(..entry-numbering)
                } else {
                  entry.element.numbering
                }
                numbering(used-numbering, ..counter(outline.target).at(entry.element.location()))
                h(gap)
              }
              {
                let body = entry.body()
                assert(
                  body.fields().keys().contains("children"),
                  message: "论文标题应在最后添加 `#metadata((en: \"英文标题\"))`",
                )
                let meta = body.children.last()
                assert(
                  repr(meta).starts-with("metadata"),
                  message: "论文标题应在最后添加 `#metadata((en: \"英文标题\"))`",
                )
                assert(
                  meta.value.keys().contains("en"),
                  message: "论文标题应在最后添加 `#metadata((en: \"英文标题\"))`",
                )
                meta.value.en
              }
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
